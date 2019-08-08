FROM golang:1.12-alpine

# This is the release of Terraform to pull in.
ARG TF_VERSION=0.12.5

VOLUME [ "/go/src/github.com/skyscrapers/terraform-concourse" ]

ADD ./setup.sh /opt/setup.sh

RUN apk add --update curl && \
  mkdir -p terraform-release concourse-release && \
  curl -sL -o "terraform-release/terraform_${TF_VERSION}_linux_amd64.zip" "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" && \
  /opt/setup.sh

WORKDIR /go/src/github.com/skyscrapers/terraform-concourse/test
