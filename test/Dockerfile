FROM golang:1.9-alpine

# This is the release of Terraform to pull in.
ARG TF_VERSION

VOLUME [ "/go/src/github.com/skyscrapers/terraform-concourse" ]

ADD ./setup.sh /opt/setup.sh

RUN /opt/setup.sh

WORKDIR /go/src/github.com/skyscrapers/terraform-concourse/test
