+++ 
draft = false
date = 2020-04-12T17:24:20+05:30
title = "Of apps and authentications"
description = "Thoughts on choosing an IAM provider for web applications."
slug = "" 
tags = ["iam","authentication"]
categories = ["devops"]
externalLink = ""
series = []
+++

Most often than not, when we build a web application, we have to let a user log in to access the full functionality of the app. Reasons could vary, but for us, it is mostly because we would like to prevent DoS-ing and unwanted spam on our application. OAuth2.0 is pretty much the standard but how does one provision it? We have relied on a custom built IAM server for this purpose for the most part. While it gets the job done, I was wondering if there's an easier way out of this than managing the maintenance of a server. After all, all I need is a OAuth2.0 token. Regardless of what I do the flow is going to be the same. Also, our custom server does not do SSO...yet.

For organizations using Active Directory, the best bet is probably to use Azure AD for authentication. It's a bit tricky to set up but is robust and integrates very well with the Microsoft ecosystem. For organizations in Google ecosystem, Google Sign In should get the job done.

But what about consumer facing apps? What if the user wants to use their own username and password? What if you can't add the user into your internal directory? Here comes the need for a IAM server which you can host on your own environment.

We were putting up a small app which fell under the above use case. And I thought I should try out a self hosted IAM instead of working on integrating my app into our main IAM server. Frankly, I just wanted to focus on building the app logic instead of worrying about all this. [Firebase][firebase] is a good solution, but you've to pay up for it after 10K requests a month and the data doesn't reside with us. So I did some research looking specifically for open source options and surprisingly there are very few good ones here. Of the lot, Keycloak, Gluu and FusionAuth stood out. The first two are free and open source while FusionAuth is free but not open source. It does provide some open source components though.

[Keycloak][keycloak] has the backing of RedHat and is widely lauded. So I decided to try that first using their Docker image. And the experience was rather underwhelming. The container failed to spin up. The first reason was that the connectivity timeout for the database was set at 300ms which is apparently too low. So I had to set the `JAVA_OPTS` environment variable with a value of `-Djboss.as.management.blocking.timeout=600`. This sorted out that error but the app failed to bind to my IP. I had to add `-Djava.net.preferIPv4Stack=true` also to the environment variable. (So `JAVA_OPTS` ultimately had a value of `-Djboss.as.management.blocking.timeout=600 -Djava.net.preferIPv4Stack=true`). These fixed the DB connection issues but more socket binding issues showed up. I gave up at this point.

I'm pretty sure some more fumbling around or using the standalone installer to create a custom Docker image would've got it up and running. But my point is that it is not easy to set up. Also, a clustered deployment is way more complicated than it should be with KeyCloak. The documentation is helpful. But it is not something one can attempt in a Sunday afternoon like I did.

I feel like this needn't have to be this complex. Perhaps Gluu or FusionAuth would be better. I will update here when I get to try them.

[firebase]: https://firebase.google.com/docs/auth
[keycloak]: https://www.keycloak.org/