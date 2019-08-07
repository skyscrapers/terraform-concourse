data "aws_iam_policy_document" "concourse_worker_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "concourse_worker_role" {
  name               = "concourse_worker_${var.environment}_${var.name}_role"
  assume_role_policy = data.aws_iam_policy_document.concourse_worker_role.json
}

data "aws_iam_policy_document" "concourse_worker_policy" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      var.keys_bucket_arn,
      "${var.keys_bucket_arn}/*",
    ]
  }

  statement {
    actions = [
      "ec2:DescribeVolume*", # needed to query the status of the worker volume
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "concourse_worker_policy" {
  count  = var.cross_account_worker_role_arn != null ? 0 : 1   # Disable if accessing another AWS account through an assume role
  name   = "concourse_worker_${var.environment}_${var.name}_policy"
  role   = aws_iam_role.concourse_worker_role.id
  policy = data.aws_iam_policy_document.concourse_worker_policy.json
}

data "aws_iam_policy_document" "concourse_worker_cross_account_policy" {
  count  = var.cross_account_worker_role_arn != null ? 1 : 0 # Enable if accessing another AWS account through an assume role
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      var.cross_account_worker_role_arn,
    ]
  }
}

resource "aws_iam_role_policy" "concourse_worker_cross_account_policy" {
  count  = var.cross_account_worker_role_arn != null ? 1 : 0 # Enable if accessing another AWS account through an assume role
  name   = "concourse_worker_cross_account_${var.environment}_${var.name}"
  role   = aws_iam_role.concourse_worker_role.id
  policy = data.aws_iam_policy_document.concourse_worker_cross_account_policy[0].json
}

resource "aws_iam_instance_profile" "concourse_worker_instance_profile" {
  name = "concourse_worker_${var.environment}_${var.name}_instance_profile"
  role = aws_iam_role.concourse_worker_role.id
}

