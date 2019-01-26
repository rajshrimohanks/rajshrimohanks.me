# Stage 0: Build stage
FROM ubuntu:latest as build-stage

# Install wget
RUN apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY ./ /app/

# Fetch Hugo deb
RUN wget -i .hugourl -O hugo.deb

# Install Hugo
RUN dpkg -i hugo.deb

# Build site
RUN hugo

# Stage 1, based on Nginx, to have only the compiled app, ready for production with Nginx
FROM nginx:latest

COPY --from=build-stage /app/public/ /usr/share/nginx/html

COPY ./nginx-custom.conf /etc/nginx/conf.d/default.conf
