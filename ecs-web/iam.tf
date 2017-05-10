resource "aws_iam_role" "concourse_task_role" {
  name = "concourse_task_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "concourse_task_policy" {
  name = "concourse_task_policy"
  role = "${aws_iam_role.concourse_task_role.id}"

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
        "${aws_s3_bucket.concourse_keys.arn}",
        "${aws_s3_bucket.concourse_keys.arn}/*"
      ]
    }
  ]
}
EOF
}
