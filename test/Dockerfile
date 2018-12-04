FROM golang:1.9-alpine

# This is the release of Terraform to pull in.
ARG TF_VERSION=0.11.10

# This is the release of Fly (Concourse) to pull in.
ARG FLY_VERSION=4.2.1

ENV TEST_FLY_PATH=/usr/local/bin/fly

VOLUME [ "/go/src/github.com/skyscrapers/terraform-concourse" ]

ADD ./setup.sh /opt/setup.sh

RUN apk add --update curl && \
  mkdir -p terraform-release concourse-release && \
  curl -sL -o "terraform-release/terraform_${TF_VERSION}_linux_amd64.zip" "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" && \
  curl -sL -o "concourse-release/fly_linux_amd64" "https://github.com/concourse/concourse/releases/download/v${FLY_VERSION}/fly_linux_amd64" && \
  /opt/setup.sh

WORKDIR /go/src/github.com/skyscrapers/terraform-concourse/test
