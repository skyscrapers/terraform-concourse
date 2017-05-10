resource "null_resource" "generate_concourse_keys" {
  count = "${var.generate_concourse_keys == "false" ? 0 : 1 }"

  triggers {
    version                    = "${var.concourse_keys_version}"
    concourse_keys_bucket_name = "${aws_s3_bucket.concourse_keys.bucket}"
  }

  provisioner "local-exec" {
    command = <<EOF
mkdir -p ${path.module}/concourse_keys/ &&
rm -rf ${path.module}/concourse_keys/* &&
ssh-keygen -q -t rsa -f ${path.module}/concourse_keys/session_signing_key -N '' &&
ssh-keygen -q -t rsa -f ${path.module}/concourse_keys/tsa_host_key -N '' &&
ssh-keygen -q -t rsa -f ${path.module}/concourse_keys/worker_key -N '' &&
aws s3 mv ${path.module}/concourse_keys/ s3://${aws_s3_bucket.concourse_keys.bucket}/ --recursive --acl private --sse AES256 &&
aws s3 cp s3://${aws_s3_bucket.concourse_keys.bucket}/worker_key.pub s3://${aws_s3_bucket.concourse_keys.bucket}/authorized_worker_keys --acl private --sse AES256
EOF
  }
}
