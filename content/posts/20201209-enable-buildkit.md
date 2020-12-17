+++ 
draft = true
date = 2020-12-09T14:44:52+05:30
title = "TIL: BuildKit is a thing"
description = "BuildKit is a thing and it's awesome."
slug = ""
tags = ["linux","docker"]
categories = ["til","devops"]
externalLink = ""
+++

I was going through [this blog post](https://kubernetes.io/blog/2020/12/02/dont-panic-kubernetes-and-docker/) where Kubernetes developers were talking about why they are deprecating Docker in v1.20 and why no one should be panicking about it. This wasn't news for me, since I was following Docker closely and was well aware that Docker these days is merely a wrapper around containerd. I've also switched to using containerd directly as the CRI in home grown Kubernetes clusters and have found that it offers noticeably better performance simply due to less overhead involved with the Dockershim.

What caught my eye though was this paragraph:

> _One thing to note: If you are relying on the underlying docker socket (/var/run/docker.sock) as part of a workflow within your cluster today, moving to a different runtime will break your ability to use it. This pattern is often called Docker in Docker. There are lots of options out there for this specific use case including things like kaniko, img, and buildah._

Docker in Docker? Why have I never explored this before? Turns out we can actually build Docker images _inside_ a Docker container and one can actually use this to build containers from inside a Kubernetes environment.

BuildKit:

```bash
 $   export DOCKER_BUILDKIT=1
 $   time docker build . -t api-server
[+] Building 117.3s (17/17) FINISHED
 => [internal] load build definition from Dockerfile                                                0.0s
 => => transferring dockerfile: 1.93kB                                                              0.0s
 => [internal] load .dockerignore                                                                   0.0s
 => => transferring context: 215B                                                                   0.0s
 => [internal] load metadata for docker.io/library/node:14.15.1-slim                                0.0s
 => [base 1/5] FROM docker.io/library/node:14.15.1-slim                                             0.0s
 => => resolve docker.io/library/node:14.15.1-slim                                                  0.0s
 => [internal] load build context                                                                   0.0s
 => => transferring context: 1.19MB                                                                 0.0s
 => [base 2/5] RUN mkdir -p /app/                                                                   0.2s
 => [base 3/5] RUN buildDeps='libpq-dev libsecret-1-dev ca-certificates fonts-liberatio'            27.7s
 => [base 4/5] RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key     26.7s
 => [base 5/5] WORKDIR /app/                                                                        0.0s
 => [build-stage 1/6] RUN buildDeps='g++ make python libdpkg-perl'   && apt-get update   && apt-get 9.4s
 => [build-stage 2/6] COPY package*.json /app/                                                      0.0s
 => [build-stage 3/6] RUN npm install   && usermod -a -G audio,video node   && mkdir -p /home/      31.6s
 => [build-stage 4/6] COPY . /app/                                                                  0.0s
 => [build-stage 5/6] RUN npm run build                                                             8.4s
 => [build-stage 6/6] RUN npm prune --production                                                    8.5s
 => [release 1/1] COPY --from=build-stage /app/ /app/                                               1.4s
 => exporting to image                                                                              1.9s
 => => exporting layers                                                                             1.9s
 => => writing image sha256:08842b21a7a2e8356b0f7a0bf028cef54a16cbd55b6d97c3c55f085bedf000b1        0.0s
 => => naming to docker.io/library/api-server                                                       0.0s

real    1m58.414s
user    0m0.477s
sys     0m0.366s
```

Without BuildKit:

```bash
 $   export DOCKER_BUILDKIT=0
 $   time docker build . -t api-server
Sending build context to Docker daemon  1.345MB
Step 1/20 : FROM node:14.15.1-slim as base
 ---> b361b0e6694e
Step 2/20 : SHELL ["/bin/bash", "-c"]
 ---> Running in 1767606e100f
Removing intermediate container 1767606e100f
 ---> 8bb1bc9860bd
Step 3/20 : ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
 ---> Running in a2809700fd54
Removing intermediate container a2809700fd54
 ---> e727cc4ac2a8
Step 4/20 : ENV WORK_DIR /app/
 ---> Running in 44118dbf76c6
Removing intermediate container 44118dbf76c6
 ---> 0c211660e45e
Step 5/20 : RUN mkdir -p $WORK_DIR
 ---> Running in e058b90cea93
Removing intermediate container e058b90cea93
 ---> 7f73010be71c
Step 6/20 : RUN buildDeps='libpq-dev libsecret-1-dev ca-certificates fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 lsb-release wget xdg-utils gnupg'   && apt-get update   && apt-get install -y --no-install-recommends $buildDeps
 ---> Running in f734cc3fc758
Get:1 http://security.debian.org/debian-security stretch/updates InRelease [53.0 kB]
Get:2 http://security.debian.org/debian-security stretch/updates/main amd64 Packages [633 kB]

...Lots of output...

Setting up fonts-thai-tlwg (1:0.6.3-1) ...
Removing intermediate container f7e5bf9882a6
 ---> bb0ee8334533
Step 8/20 : WORKDIR $WORK_DIR
 ---> Running in 9d6e6e4f9116
Removing intermediate container 9d6e6e4f9116
 ---> 99c25b37d115
Step 9/20 : FROM base as build-stage
 ---> 99c25b37d115
Step 10/20 : RUN buildDeps='g++ make python libdpkg-perl'   && apt-get update   && apt-get install -y --no-install-recommends $buildDeps
 ---> Running in 18f884050bef
Get:1 http://security.debian.org/debian-security stretch/updates InRelease [53.0 kB]
Get:2 http://dl.google.com/linux/chrome/deb stable InRelease [1811 B]

...Lots of output...

Removing intermediate container 18f884050bef
 ---> dfcc4d27cf86
Step 11/20 : COPY package*.json $WORK_DIR
 ---> e5bb611719c1
Step 12/20 : RUN npm install   && usermod -a -G audio,video node   && mkdir -p /home/node/Downloads   && chown -R node:node /home/node   && chown -R node:node /app/node_modules
 ---> Running in b72389e884ce

> libpq@1.8.9 install /app/node_modules/libpq
> node-gyp rebuild

make: Entering directory '/app/node_modules/libpq/build'
  CXX(target) Release/obj.target/addon/src/connection.o
  CXX(target) Release/obj.target/addon/src/connect-async-worker.o
  CXX(target) Release/obj.target/addon/src/addon.o
  SOLINK_MODULE(target) Release/obj.target/addon.node
  COPY Release/addon.node
make: Leaving directory '/app/node_modules/libpq/build'

> keytar@5.6.0 install /app/node_modules/keytar
> prebuild-install || node-gyp rebuild

prebuild-install WARN install No prebuilt binaries found (target=14.15.1 runtime=node arch=x64 libc= platform=linux)
make: Entering directory '/app/node_modules/keytar/build'
  CXX(target) Release/obj.target/keytar/src/async.o
  CXX(target) Release/obj.target/keytar/src/main.o
  CXX(target) Release/obj.target/keytar/src/keytar_posix.o
  SOLINK_MODULE(target) Release/obj.target/keytar.node
  COPY Release/keytar.node
make: Leaving directory '/app/node_modules/keytar/build'

> puppeteer@5.5.0 install /app/node_modules/puppeteer
> node install.js

**INFO** Skipping browser download. "PUPPETEER_SKIP_CHROMIUM_DOWNLOAD" environment variable was found.

> @nestjs/core@7.5.5 postinstall /app/node_modules/@nestjs/core
> opencollective || exit 0

                           Thanks for installing nest
                 Please consider donating to our open collective
                        to help us maintain this package.

                            Number of contributors: 0
                              Number of backers: 469
                              Annual budget: $42,435
                             Current balance: $4,993

             Become a partner: https://opencollective.com/nest/donate

npm WARN optional SKIPPING OPTIONAL DEPENDENCY: fsevents@2.1.3 (node_modules/fsevents):
npm WARN notsup SKIPPING OPTIONAL DEPENDENCY: Unsupported platform for fsevents@2.1.3: wanted {"os":"darwin","arch":"any"} (current: {"os":"linux","arch":"x64"})

added 1519 packages from 1169 contributors and audited 1527 packages in 29.841s

78 packages are looking for funding
  run `npm fund` for details

found 1 low severity vulnerability
  run `npm audit fix` to fix them, or `npm audit` for details
Removing intermediate container b72389e884ce
 ---> 62be180e7db6
Step 13/20 : COPY . $WORK_DIR
 ---> 5df9e2622211
Step 14/20 : RUN npm run build
 ---> Running in e3b96447c87c

> deflaw-bre-api-server@0.0.1 prebuild /app
> rimraf dist


> deflaw-bre-api-server@0.0.1 build /app
> nest build

Removing intermediate container e3b96447c87c
 ---> 78af4d2eeee7
Step 15/20 : RUN npm prune --production
 ---> Running in f5ff2d32e2f1
removed 837 packages and audited 686 packages in 7.712s

24 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities

Removing intermediate container f5ff2d32e2f1
 ---> fa5d70092209
Step 16/20 : FROM base as release
 ---> 99c25b37d115
Step 17/20 : COPY --from=build-stage $WORK_DIR $WORK_DIR
 ---> ef3ddfc1602f
Step 18/20 : EXPOSE 3000
 ---> Running in befda6a07ad7
Removing intermediate container befda6a07ad7
 ---> 943c9c030294
Step 19/20 : USER node
 ---> Running in fedfc7376d14
Removing intermediate container fedfc7376d14
 ---> 500808b22d82
Step 20/20 : CMD ["node","./dist/main.js"]
 ---> Running in 05c77fbf73fe
Removing intermediate container 05c77fbf73fe
 ---> 192c4e57f94d
Successfully built 192c4e57f94d
Successfully tagged api-server:latest

real    2m14.514s
user    0m1.703s
sys     0m0.259s
```