resource "aws_s3_bucket_object" "concourse_session_signing_key" {
  key                    = "session_signing_key"
  bucket                 = "${aws_s3_bucket.concourse_keys.bucket}"
  source                 = "${path.module}/session_signing_key"
  server_side_encryption = "AES256"

  depends_on = ["null_resource.generate_concourse_keys"]

  lifecycle {
    ignore_changes = ["source"]
  }
}

resource "aws_s3_bucket_object" "concourse_session_signing_key_pub" {
  key                    = "session_signing_key.pub"
  bucket                 = "${aws_s3_bucket.concourse_keys.bucket}"
  source                 = "${path.module}/session_signing_key.pub"
  server_side_encryption = "AES256"

  depends_on = ["null_resource.generate_concourse_keys"]

  lifecycle {
    ignore_changes = ["source"]
  }
}

resource "aws_s3_bucket_object" "concourse_tsa_host_key" {
  key                    = "tsa_host_key"
  bucket                 = "${aws_s3_bucket.concourse_keys.bucket}"
  source                 = "${path.module}/tsa_host_key"
  server_side_encryption = "AES256"

  depends_on = ["null_resource.generate_concourse_keys"]

  lifecycle {
    ignore_changes = ["source"]
  }
}

resource "aws_s3_bucket_object" "concourse_tsa_host_key_pub" {
  key                    = "tsa_host_key.pub"
  bucket                 = "${aws_s3_bucket.concourse_keys.bucket}"
  source                 = "${path.module}/tsa_host_key.pub"
  server_side_encryption = "AES256"

  depends_on = ["null_resource.generate_concourse_keys"]

  lifecycle {
    ignore_changes = ["source"]
  }
}

resource "aws_s3_bucket_object" "concourse_worker_key" {
  key                    = "worker_key"
  bucket                 = "${aws_s3_bucket.concourse_keys.bucket}"
  source                 = "${path.module}/worker_key"
  server_side_encryption = "AES256"

  depends_on = ["null_resource.generate_concourse_keys"]

  lifecycle {
    ignore_changes = ["source"]
  }
}

resource "aws_s3_bucket_object" "concourse_authorized_worker_keys" {
  key                    = "authorized_worker_keys"
  bucket                 = "${aws_s3_bucket.concourse_keys.bucket}"
  source                 = "${path.module}/worker_key.pub"
  server_side_encryption = "AES256"

  depends_on = ["null_resource.generate_concourse_keys"]

  lifecycle {
    ignore_changes = ["source"]
  }
}

resource "null_resource" "generate_concourse_keys" {
  triggers {
    version = "${var.concourse_keys_version}"
  }

  provisioner "local-exec" {
    command = "ssh-keygen -t rsa -f ${path.module}/session_signing_key -N '' && ssh-keygen -t rsa -f ${path.module}/tsa_host_key -N '' && ssh-keygen -t rsa -f ${path.module}/worker_key -N ''"
  }
}
