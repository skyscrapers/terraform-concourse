resource "aws_iam_role" "admin" {
  name = "${var.team}-${var.role}-adminECSInstance"
  path = "/"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com", "ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "worker" {
  name = "${var.team}-${var.role}-workerECSInstance"
  path = "/"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com", "ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy" "ecs" {
  name = "ECS-${var.environment}"
  path = "${lower(format("/%s/", var.team))}"
  description = "ELB update access"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:Describe*",
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecr" {
  name = "ECR-${var.environment}"
  path = "${lower(format("/%s/", var.team))}"
  description = "Push-Pull access to ECR"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:CompleteLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "ecs" {
  name = "${var.role}-${var.environment}-ecs"
  roles = ["${aws_iam_role.worker.name}", "${aws_iam_role.admin.name}", "${var.ecs-instance-role}"]
  policy_arn = "${aws_iam_policy.ecs.arn}"
}

resource "aws_iam_policy_attachment" "ecr" {
  name = "${var.role}-${var.environment}-ecr"
  roles = ["${aws_iam_role.admin.name}", "${aws_iam_role.worker.name}"]
  policy_arn = "${aws_iam_policy.ecr.arn}"
}

resource "aws_iam_instance_profile" "admin" {
  name = "${var.team}-admin-${var.environment}"
  path = "${lower(format("/%s/", var.team))}"
  roles = ["${aws_iam_role.admin.name}"]
}

resource "aws_iam_instance_profile" "worker" {
  name = "${var.team}-worker-${var.environment}"
  path = "${lower(format("/%s/", var.team))}"
  roles = ["${aws_iam_role.worker.name}"]
}
