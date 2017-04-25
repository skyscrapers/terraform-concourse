#!/bin/sh

if [ ! -z ${_CONCOURSE_KEYS_S3} ]; then aws s3 cp --recursive ${_CONCOURSE_KEYS_S3} /concourse-keys; fi;

/usr/local/bin/concourse "$@"
