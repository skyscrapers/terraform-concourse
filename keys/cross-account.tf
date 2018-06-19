data "aws_iam_policy_document" "concourse_keys_cross_account_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${var.concourse_workers_iam_role_arns}"]
    }
  }
}

data "aws_iam_policy_document" "concourse_keys_cross_account_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "${aws_s3_bucket.concourse_keys.arn}",
      "${aws_s3_bucket.concourse_keys.arn}/*",
    ]
  }
}

resource "aws_iam_role" "concourse_keys_cross_account" {
  name_prefix        = "concourse-keys-"
  description        = "This role is meant to be assumed by Concourse workers on other AWS accounts to be able to access the Concourse keys. Setup: ${var.name}"
  assume_role_policy = "${data.aws_iam_policy_document.concourse_keys_cross_account_assume_role_policy.json}"
}

resource "aws_iam_role_policy" "concourse_keys_cross_account" {
  role   = "${aws_iam_role.concourse_keys_cross_account.name}"
  policy = "${data.aws_iam_policy_document.concourse_keys_cross_account_policy.json}"
}
