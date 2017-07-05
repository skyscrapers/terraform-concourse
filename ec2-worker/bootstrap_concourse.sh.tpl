#!/bin/bash

set -e

# Install concourse
curl -L -f -o /usr/local/bin/concourse https://github.com/concourse/concourse/releases/download/v${concourse_version}/concourse_linux_amd64
chmod +x /usr/local/bin/concourse

# Download concourse keys
mkdir /etc/concourse
aws s3 cp s3://${keys_bucket_id}/tsa_host_key.pub /etc/concourse/
aws s3 cp s3://${keys_bucket_id}/worker_key /etc/concourse/

# Enable & start concourse_worker service
systemctl enable concourse_worker.service
systemctl start concourse_worker.service
