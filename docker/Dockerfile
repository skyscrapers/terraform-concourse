FROM concourse/concourse

RUN apt-get update && apt-get install -y python python-pip
RUN pip install awscli
RUN mkdir -p /concourse-keys

ADD download-keys.sh /opt/download-keys.sh

ENTRYPOINT [ "/opt/download-keys.sh" ]
