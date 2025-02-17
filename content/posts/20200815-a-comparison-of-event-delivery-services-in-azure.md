+++ 
draft = false
date = 2020-08-15T22:31:49+05:30
title = "Event delivery services in Azure"
description = "A comparison of event delivery services in Azure based on a personal experience."
slug = "" 
authors = ["Rajshri Mohan K S"]
tags = ["cloud","messaging","azure"]
categories = ["devops"]
externalLink = ""
series = []
+++

Azure provides three different messaging services - Azure Event Grid, Azure Event Hubs and Azure Service Bus. If you are like us with little experience in cloud messaging services, choosing between them can be confusing and Microsoft's documentation doesn't help to make things easier. In this post, we would like to walk through a situation we had to face recently and the things we learnt as a result of it.

## The Scenario

Our application utlizes a service based architecture and the services were built on NodeJS. All our services are containerized and are running inside a Kubernetes (AKS) cluster. We recently modified our application which would let a user change an application setting for dynamically. This meant, that when a user changes the setting, this change has to be propagated to other services (in other containers) in real time so that those containers can also refresh their application settings to be in sync with the others. If we were running some sort of a shared cache or pub/sub mechanism like Redis locally, this wouldn't be much of a problem. But we didn't. And we wanted to leave as much of this to Azure managed services as possible so we do not have to manage anything other than business logic in our end.

Along the same lines we also wanted to introduce a new service which would manage audit logging and this service would run alongside the other services within the AKS cluster. It made sense to utilize a messaging system to deliver audit log events to this service.

So in essence we had two problems we wanted to tackle:

1. Propagate a application setting change event raised by a container to all other containers in our cluster so that all of them can refresh their settings.
2. Propagate audit log events to our audit log service (running in a container) so that the service can write them to a database.

## Azure Event Grid

> "Designed for high availability, consistent performance and dynamic scale, Event Grid lets you focus on your app logic rather than infrastructure."

That is how Microsoft describes Event Grid in their product page. And as a result this was the first thing we considered using. All we had to do was publish an event to an Event Grid Topic and Event Grid would take care of delivering the event to a Event Subscription. Simple enough, right? It is, as long as your application is not behind a loadbalancer, that is.

Publishing an event to Event Grid is super simple. We use NodeJS and all we had to do was just:

```bash
npm install --save azure-eventgrid
```

```typescript
const eventGridTopicHost = '';
const eventGridTopicKey = '';
const client = new eventGridClient(new msRestAzure.TopicCredentials(eventGridTopicKey));
await client.publishEvents(eventGridTopicHost, [event]);
```

This is straightforward. Event Grid provides the following options when configuring a event delivery endpoint:

![Event Grid delivery endpoint](/post-img/event-grid-endpoints.png)

None of the above except **Web Hook** makes sense if looking at them for the first time. So that is what we thought we could use. Web Hook endpoint, basically lets us expose a HTTP POST endpoint on our service and configure the URL here. Now whenever we publish an event, Azure would deliver the event by making a HTTP POST call to our endpoint. And we can do whatever processing we'd like to do within our application. We can configure multiple subscribers too. So this would perfectly solve problem #2 we described above.

Why would it not solve problem #1? Well, our application is running inside a loadbalanced AKS cluster. Which means we have multiple containers running for the same service. Since Event Grid web hook comes as a HTTP POST, the request would be routed to only a single container which will refresh its configuration. Meanwhile, the other container(s) for the same service would be left hanging with an outdated configuration. This would not be the case for problem #2, because that involves processing the incoming request and persisting it to a database which should happen **only once**.

What about the other endpoint options then? Well, it didn't make sense to us at this point, so we moved forward. But we'll come back to it in just a moment.

## Azure Event Hubs

Microsoft describes Event Hubs as thus:

> "Stream millions of events per second from any source to build dynamic data pipelines and immediately respond to business challenges."

This would be overkill for propagating configuration change events, but would definitely be beneficial if we are going utilize the same infrastructure which we had ideas of doing. So we went ahead and tried this for our problem. Microsoft also touts this service as a replacement for Apache Kafka and it is able to work directly with Kafka producers without any code changes. Neat!

This would be apparent to people who've worked with Kafka but for those who haven't, the way Event Hubs works is by creating namespaces (or "hubs" as Microsoft calls them) and publishing events to the hub. All subscribers to the hub then can receive the event and process it. How is this different from Event Grid above? Well, where as Event Grid depended on Web Hooks to deliver events, Event Hubs use the AMQP protocol over TCP to deliver events. (Event Hubs also support AMQP over WebSocket so you can use it from the browser too!) This means, the subscribing client maintains a connection with the Hub constantly instead of the Hub having to make a HTTP request like before in Event Grid. As a result, all our containers can receive the events regardless of whether they are load balanced or not.

The programming is also super simple as before:

```bash
npm install --save @azure/event-hubs
```

```typescript
const connectionString = '';
const eventHubName = '';

// Publishing
const producer = new EventHubProducerClient(connectionString, eventHubName);
const batch = await producer.createBatch();
batch.tryAdd({ body: 'hello' });
await producer.sendBatch(batch);
await producer.close();

// Receiving
const containerClient = new ContainerClient(storageConnectionString, containerName);
const checkpointStore = new BlobCheckpointStore(containerClient);  
const consumer = new EventHubConsumerClient(consumerGroup, connectionString, eventHubName, checkpointStore);  
const subscription = consumerClient.subscribe({
    processEvents: async (events, context) => {
        for (const event of events) {
            console.log(`Received event: '${event.body}'`);
        }
        await context.updateCheckpoint(events[events.length - 1]);
    },
    processError: async (err, context) => {
        console.log(`Error : ${err}`);
    }
});
```

Okay, it isn't as simple as it was with Event Grids. But it is still not the most complicated. One thing that could throw new developers off in the above code is the use of a **check point store** (`BlobCheckpointStore`) in the above code. The checkpoint store is necessary in Event Hubs because Event Hubs support retaining an event for a specified amount of time. So the subscribing client should know what all events have been read from the hub and what events haven't. To achieve this, the subscribing client has to store a local log (called as a check point) of all read event ids. The check point can be stored in multiple places - this code above stores it in Azure storage.

The retention and retry features make Event Hub great for all use cases which require **at least once delivery** of events and sure enough, Microsoft guarantees that for Event Hubs. This lets us solve problem #1. But this falls apart for problem #2. Why? Because to solve problem #2, we want **exactly once delivery** of events in order to prevent multiple entries for the same audit log event in our database. Yes, we can handle this on our business logic by assigning unique IDs to the events and checking if the events are written into the DB. But doing that would defeat the purpose of using a service to manage events. Besides, Kafka supports **exactly once delivery** and considering Event Hubs is touted as a Kafka replacement, it is a bummer that it doesn't have the feature. (It could come in the future [considering Kafka didn't have this till 2017](https://www.confluent.io/blog/exactly-once-semantics-are-possible-heres-how-apache-kafka-does-it/), either.)

Moving on...

## Service Bus

> "Reliable cloud messaging as a service (MaaS) and simple hybrid integration."

That's all it says in Microsoft's product page for Service Bus. But make no mistake, this is what we actually need if we have to solve both our problems in one service.

Service Bus supports publishing messages to both - queues and topics. Publishing to queues would help us achieve **exactly once delivery** semantics while publishing to topics can let us do **at least once delivery** semantics. Then why is Service Bus not the put up front in the marketing like Event Grid and Event Hub are? The answer is that it is because Service Bus isn't exactly built for millions per second of event ingestion like Event Hubs is. I mean, it probably and mostly will handle the scale, but its priorities lie in making sure messages are delivered with enterprise class ordering and reliability. If you notice, we used the word "events" for Event Hubs (and Event Grids) but "messages" for Service Bus. Microsoft explains the difference [here](https://docs.microsoft.com/en-us/azure/event-grid/compare-messaging-services#event-vs-message-services) but in simple words, events are light weight and carry information about a change on an object but not the changed object in itself, whereas messages are bulkier and carry all information required to use the changed object at the destination. Of course if the changed object is not very big in terms of size, we could send it as an event too, but that would be breaking the semantics.

Also, considering Service Bus' focus on delivering messages, it didn't exactly support push delivery on the subscribing end requiring the client to request for new messages on a periodic basis, until recently. But Service Bus supports AMQP based push like Event Hubs do now, and it makes it a viable candidate for our use case. But because of this recent introduction, the client SDKs aren't quite out of beta yet, but we found them to be good enough for production use in our testing.

As always the programming is simple:

```bash
npm install --save @azure/service-bus@next
```

`@next` is necessary because the current stable version does not support AMQP based push delivery of messages.

```typescript
const connectionString = '';
const topicName = '';
const subscriptionName = '';        // Required for topics. Not needed for queues.
const client = new ServiceBusClient(connectionString);
const sender = client.createSender(topicName);
await sender.open();

const receiver = client.createReceiver(topicName, subscriptionName);

// Sending message
await sender.sendMessages({ body: 'hello' });

// Receiving message
receiver.subscribe({
    processMessage: async (m: ReceivedMessageWithLock) => { console.log('Received: ' + m.body); },
    processError: async (e: Error) => { console.log('Error: ' + e); }
}, { autoComplete: true });
```

Publishing to a **queue** in Service Bus guarantees in-order and optionally, **exactly once delivery**, while publishing to a topic gurantees **at least once delivery**. Thus both problems #1 and #2 can be solved using this.

## Is that it?

Not really. Service Bus definitely can solve our problem statement, but like we discussed it is really meant for enterprise class delivery of messages and not meant for simple event delivery. As a result, its cost can be slightly higher depending on your use cases. Hence it is kind of important to know that there is another way in which we could have solved our problem without using Service Bus. But it involves using Event Grid and Event Hub in tandem.

Remember this?

![Event Grid delivery endpoint](/post-img/event-grid-endpoints.png)

Now, the terms all fall in place, don't they? So Event Grid can actually use an Event Hub (or Service Bus queue or topic) as a delivery endpoint. What this means is that, we can have a webhook endpoint for cases where we'd like **exactly once delivery** and we can leverage an Event Hub endpoint for **at least once delivery** while publishing all our events to Event Grid. This can bring in some cost benefits over Service Bus but it depends on your use case.

That's all folks!
