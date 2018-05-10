resource "null_resource" "generate_concourse_keys" {
  triggers {
    version                    = "${var.concourse_keys_version}"
    concourse_keys_bucket_name = "${aws_s3_bucket.concourse_keys.bucket}"
  }

  provisioner "local-exec" {
    command = "${data.template_file.keys_generator_cmd.rendered}"
  }

  depends_on = ["aws_s3_bucket.concourse_keys"]
}

data "template_file" "keys_generator_cmd" {
  template = <<EOF
mkdir -p $${base_path}/concourse_keys/ &&
rm -rf $${base_path}/concourse_keys/* &&
ssh-keygen -q -t rsa -f $${base_path}/concourse_keys/session_signing_key -N '' -C 'concourse_keys_$${environment}' &&
ssh-keygen -q -t rsa -f $${base_path}/concourse_keys/tsa_host_key -N '' -C 'concourse_keys_$${environment}' &&
ssh-keygen -q -t rsa -f $${base_path}/concourse_keys/worker_key -N '' -C 'concourse_keys_$${environment}' &&
aws $${aws_opts} s3 mv $${base_path}/concourse_keys/ s3://$${bucket_name}/ --recursive --acl private --sse AES256 &&
aws $${aws_opts} s3 cp s3://$${bucket_name}/worker_key.pub s3://$${bucket_name}/authorized_worker_keys --acl private --sse AES256
EOF

  vars {
    aws_opts    = "${length(var.aws_profile) > 0 ? "--profile ${var.aws_profile}" : ""}"
    base_path   = "${path.module}"
    bucket_name = "${aws_s3_bucket.concourse_keys.bucket}"
    environment = "${var.name}_${var.environment}"
  }
}
