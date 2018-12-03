#!/bin/sh

TF_VERSION=${TF_VERSION:-0.11.10}

apk add --update unzip curl dep git

# Install terraform
curl -s -o "terraform.zip" "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip"
unzip terraform.zip -d /usr/local/bin
