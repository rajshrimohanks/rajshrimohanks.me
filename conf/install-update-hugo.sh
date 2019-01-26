#!/bin/bash

# Download hugo
set -e
wget -i .hugourl -O hugo.deb

# Install it
set -e
dpkg -i hugo.deb

# Remove setup file
set -e
rm -rf hugo.deb
