#!/bin/bash

# Build files
set -e
hugo

# Copy files to webroot
set -e
rsync -avh ./public/. /var/www/rajshrimohanks.me/ \
  --chown www-data:www-data \
  --progress \
  --delete
