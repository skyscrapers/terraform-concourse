resource "tls_private_key" "session_signing" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_private_key" "tsa_host" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_private_key" "worker" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_s3_bucket_object" "session_signing_key" {
  key                    = "session_signing_key"
  bucket                 = "${aws_s3_bucket.concourse_keys.bucket}"
  content                = "${tls_private_key.session_signing.private_key_pem}"
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "session_signing_pub_key" {
  key                    = "session_signing_key.pub"
  bucket                 = "${aws_s3_bucket.concourse_keys.bucket}"
  content                = "${tls_private_key.session_signing.public_key_pem}"
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "tsa_host_key" {
  key                    = "tsa_host_key"
  bucket                 = "${aws_s3_bucket.concourse_keys.bucket}"
  content                = "${tls_private_key.tsa_host.private_key_pem}"
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "tsa_host_pub_key" {
  key                    = "tsa_host_key.pub"
  bucket                 = "${aws_s3_bucket.concourse_keys.bucket}"
  content                = "${tls_private_key.tsa_host.public_key_pem}"
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "worker_key" {
  key                    = "worker_key"
  bucket                 = "${aws_s3_bucket.concourse_keys.bucket}"
  content                = "${tls_private_key.worker.private_key_pem}"
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "worker_pub_key" {
  key                    = "worker_key.pub"
  bucket                 = "${aws_s3_bucket.concourse_keys.bucket}"
  content                = "${tls_private_key.worker.public_key_pem}"
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "authorized_worker_keys" {
  key                    = "authorized_worker_keys"
  bucket                 = "${aws_s3_bucket.concourse_keys.bucket}"
  content                = "${tls_private_key.worker.public_key_pem}"
  server_side_encryption = "AES256"
}
