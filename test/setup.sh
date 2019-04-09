#!/bin/sh

apk add --update unzip curl dep git

# Unzip terraform binary
unzip terraform-release/terraform_*_linux_amd64.zip -d /usr/local/bin
chmod +x /usr/local/bin/terraform
