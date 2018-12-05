#!/bin/sh

apk add --update unzip curl dep git

# Unzip terraform binary
unzip terraform-release/terraform_*_linux_amd64.zip -d /usr/local/bin
chmod +x /usr/local/bin/terraform

# Move fly binary into PATH
export TEST_FLY_PATH=/usr/local/bin/fly
cp -a concourse-release/fly_linux_amd64 $TEST_FLY_PATH
chmod +x $TEST_FLY_PATH
