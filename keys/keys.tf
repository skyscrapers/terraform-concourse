resource "tls_private_key" "session_signing" {
  count     = "${var.generate_keys ? 1 : 0}"
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_private_key" "tsa_host" {
  count     = "${var.generate_keys ? 1 : 0}"
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_private_key" "worker" {
  count     = "${var.generate_keys ? 1 : 0}"
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_s3_bucket_object" "session_signing_key" {
  count                  = "${var.generate_keys ? 1 : 0}"
  key                    = "session_signing_key"
  bucket                 = "${aws_s3_bucket.concourse_keys.bucket}"
  content                = "${join("", tls_private_key.session_signing.*.private_key_pem)}"
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "session_signing_pub_key" {
  count                  = "${var.generate_keys ? 1 : 0}"
  key                    = "session_signing_key.pub"
  bucket                 = "${aws_s3_bucket.concourse_keys.bucket}"
  content                = "${join("", tls_private_key.session_signing.*.public_key_openssh)}"
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "tsa_host_key" {
  count                  = "${var.generate_keys ? 1 : 0}"
  key                    = "tsa_host_key"
  bucket                 = "${aws_s3_bucket.concourse_keys.bucket}"
  content                = "${join("", tls_private_key.tsa_host.*.private_key_pem)}"
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "tsa_host_pub_key" {
  count                  = "${var.generate_keys ? 1 : 0}"
  key                    = "tsa_host_key.pub"
  bucket                 = "${aws_s3_bucket.concourse_keys.bucket}"
  content                = "${join("", tls_private_key.tsa_host.*.public_key_openssh)}"
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "worker_key" {
  count                  = "${var.generate_keys ? 1 : 0}"
  key                    = "worker_key"
  bucket                 = "${aws_s3_bucket.concourse_keys.bucket}"
  content                = "${join("", tls_private_key.worker.*.private_key_pem)}"
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "worker_pub_key" {
  count                  = "${var.generate_keys ? 1 : 0}"
  key                    = "worker_key.pub"
  bucket                 = "${aws_s3_bucket.concourse_keys.bucket}"
  content                = "${join("", tls_private_key.worker.*.public_key_openssh)}"
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "authorized_worker_keys" {
  count                  = "${var.generate_keys ? 1 : 0}"
  key                    = "authorized_worker_keys"
  bucket                 = "${aws_s3_bucket.concourse_keys.bucket}"
  content                = "${join("", tls_private_key.worker.*.public_key_openssh)}"
  server_side_encryption = "AES256"
}
