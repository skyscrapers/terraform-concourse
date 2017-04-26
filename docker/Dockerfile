FROM concourse/concourse

RUN apt-get update && \
    apt-get install -y python python-pip && \
    rm -rf /var/lib/apt/lists/* && \
    pip install awscli && \
    mkdir -p /concourse-keys

ADD download-keys.sh /opt/download-keys.sh

RUN chmod +x /opt/download-keys.sh

ENTRYPOINT [ "/opt/download-keys.sh" ]
