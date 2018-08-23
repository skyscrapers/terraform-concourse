[Unit]
Description=Concourse CI Worker

[Service]
ExecStart=/usr/local/bin/concourse worker \
       --work-dir /opt/concourse \
       --tsa-host ${concourse_hostname} \
       --tsa-public-key /etc/concourse/tsa_host_key.pub \
       --tsa-worker-private-key /etc/concourse/worker_key ${tags}

User=root
Group=root

Type=simple

LimitNOFILE=20000

[Install]
WantedBy=default.target
