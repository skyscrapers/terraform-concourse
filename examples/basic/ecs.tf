module "ecs_cluster" {
  source      = "github.com/skyscrapers/terraform-ecs//ecs-cluster?ref=3.0.1"
  project     = var.project
  environment = var.environment
}

data "aws_ami" "ecs" {
  # http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI_launch_latest.html
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["591542846629"] # Amazon
}

module "bluegreen" {
  source                 = "github.com/skyscrapers/terraform-bluegreen//blue-green?ref=3.0.1"
  name                   = "asg-${var.project}-test-cluster-${terraform.workspace}"
  blue_ami               = data.aws_ami.ecs.id
  green_ami              = data.aws_ami.ecs.id
  subnets                = module.vpc.private_app_subnets
  green_instance_type    = var.ecs_instance_type
  blue_instance_type     = var.ecs_instance_type
  iam_instance_profile   = module.ecs_cluster.ecs-instance-profile
  key_name               = var.key_name
  blue_max_size          = 1
  blue_min_size          = 1
  blue_desired_capacity  = 1
  blue_disk_volume_size  = 30
  green_max_size         = 0
  green_min_size         = 0
  green_desired_capacity = 0
  green_disk_volume_size = 30
  security_groups        = [aws_security_group.sg_ecs_instance.id]

  green_user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${module.ecs_cluster.cluster_name} >> /etc/ecs/ecs.config
EOF
  blue_user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${module.ecs_cluster.cluster_name} >> /etc/ecs/ecs.config
EOF

}

resource "aws_security_group" "sg_ecs_instance" {
  name = "sg_ecs_instance_${var.project}_${var.environment}"
  description = "Security group that is needed for the ecs instance hosts"
  vpc_id = module.vpc.vpc_id

  tags = {
    Environment = var.environment
    Project = var.project
  }
}

resource "aws_security_group_rule" "sg_ecs_out_ntp" {
  type = "egress"
  security_group_id = aws_security_group.sg_ecs_instance.id
  from_port = 123
  to_port = 123
  protocol = "udp"
  cidr_blocks = ["0.0.0.0/0"]
}

# Allow HTTP connections to the outside
resource "aws_security_group_rule" "sg_ecs_out_http" {
  type = "egress"
  security_group_id = aws_security_group.sg_ecs_instance.id
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# Allow HTTPS connections to the outside
resource "aws_security_group_rule" "sg_ecs_out_https" {
  type = "egress"
  security_group_id = aws_security_group.sg_ecs_instance.id
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

