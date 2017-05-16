resource "aws_iam_role" "concourse_worker_role" {
  name = "concourse_worker_${var.environment}_${var.name}_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "concourse_worker_policy" {
  name = "concourse_worker_${var.environment}_${var.name}_policy"
  role = "${aws_iam_role.concourse_worker_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Resource": [
        "${var.keys_bucket_arn}",
        "${var.keys_bucket_arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "concourse_worker_instance_profile" {
  name = "concourse_worker_${var.environment}_${var.name}_instance_profile"
  role = "${aws_iam_role.concourse_worker_role.id}"
}
