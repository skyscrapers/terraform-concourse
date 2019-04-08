#!/bin/bash

set -e

# Install concourse
curl -s -L -f -o ./concourse.tgz https://github.com/concourse/concourse/releases/download/v${concourse_version}/concourse-${concourse_version}-linux-amd64.tgz
tar -xzf ./concourse.tgz -C /usr/local

# AssumeRole for remote TSA
 if [ ! -z "${cross_account_worker_role_arn}" ]
 then
     ASSUMED_ROLE=$(aws sts assume-role --role-arn ${cross_account_worker_role_arn} --role-session-name concourse-worker-$HOSTNAME)
     export AWS_ACCESS_KEY_ID=$(echo "$ASSUMED_ROLE" | jq -r ".Credentials.AccessKeyId")
     export AWS_SECRET_ACCESS_KEY=$(echo "$ASSUMED_ROLE" | jq -r ".Credentials.SecretAccessKey")
     export AWS_SESSION_TOKEN=$(echo "$ASSUMED_ROLE" | jq -r ".Credentials.SessionToken")
 fi

# Download concourse keys
mkdir /etc/concourse
aws s3 cp s3://${keys_bucket_id}/tsa_host_key.pub /etc/concourse/
aws s3 cp s3://${keys_bucket_id}/worker_key /etc/concourse/

# Enable & start concourse_worker service
systemctl enable concourse_worker.service
systemctl start concourse_worker.service
