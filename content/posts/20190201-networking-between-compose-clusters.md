---
draft: false
date: 2019-02-01T02:05:09+05:30
title: "TIL: Networking between docker-compose clusters"
description: "Today I figured out that one can network between multiple docker-compose clusters."
slug: ""
tags: ["docker-compose"]
categories: ["devops","til"]
externalLink: ""
---

Well I knew that one can have multiple _services_ within a compose file and refer to a service from another using its name. But I didn't know that it was super easy to do it between multiple compose files too. Especially if you are using compose file version 3.5 or above. Here's how:

Let's say we have a `docker-compose.yml` file like this:

```yaml
version: "3.6"

services:
  frontend:
    build: ./frontend/
    ports:
      - "4200:4200"

  backend:
    build: ./backend/
    ports:
      - "4001:4001"
```

And let's say we'd like the backend to communicate with a `db` service defined in another `docker-compose.yml` file. This is how we can achieve it:

First, we have to specify a network for the communication to take place. We can do this by specifying the `networks` key in the YAML file with a reference name and a network name.

```yaml
networks:
  db_net:
    name: db_network
```

Here, `db_net` is the local reference name which we can use within the compose file to refer to it. `db_network` will be the actual name of the network being created.

We can now attach this network to our `backend` like so:

```yaml
version: "3.6"

services:
  frontend:
    build: ./frontend/
    ports:
      - "4200:4200"
    environment:
      - NODE_ENV=production
    restart: always

  backend:
    build: ./backend/
    ports:
      - "4001:4001"
    networks:
      - db_net

networks:
  db_net:
    name: db_network
```

This would create the services and the network _and_ attach the network to the specified service.

Now, in the other compose file, let's say we have a structure like this:

```yaml
version: "3.6"

services:
  db:
    build: .
    ports:
      - 5001:5001
```

We can now attach this to the same `db_network` by modifying it like this:

```yaml
version: "3.6"

services:
  db:
    build: .
    ports:
      - 5001:5001
    networks:
      - db_netw

networks:
  db_netw:
    external:
      name: db_network
```

It's very similar to the first setup except now we've to specify that the network is external by giving the `name` under the `external` key.

Docker would automatically attach this cluster to the `db_network` created by the previous cluster.

Now we can start both clusters and refer to the services with their names in our app URLs.

Simple, isn't it?
