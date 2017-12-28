[Unit]
Description=Concourse CI Worker

[Service]
Environment=CONCOURSE_TAG=${concourse_tag}
ExecStart=/usr/local/bin/concourse worker \
       --work-dir /opt/concourse \
       --tsa-host ${concourse_hostname} \
       --tsa-public-key /etc/concourse/tsa_host_key.pub \
       --tsa-worker-private-key /etc/concourse/worker_key

User=root
Group=root

Type=simple

[Install]
WantedBy=default.target
