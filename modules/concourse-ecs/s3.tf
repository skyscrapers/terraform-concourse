resource "aws_s3_bucket" "concourse_keys" {
  count  = "${var.generate_concourse_keys == "false" ? 0 : 1 }"
  bucket = "concourse-keys-${var.environment}"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags {
    Name        = "concourse keys"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket_policy" "concourse_keys" {
  count  = "${var.generate_concourse_keys == "false" ? 0 : 1 }"
  bucket = "${aws_s3_bucket.concourse_keys.bucket}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "PutObjPolicy",
  "Statement": [
    {
      "Sid": "DenyIncorrectEncryptionHeader",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.concourse_keys.arn}/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    },
    {
      "Sid": "DenyUnEncryptedObjectUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.concourse_keys.arn}/*",
      "Condition": {
        "Null": {
          "s3:x-amz-server-side-encryption": "true"
        }
      }
    }
  ]
}
EOF
}
