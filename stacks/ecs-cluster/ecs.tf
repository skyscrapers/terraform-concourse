module "bluegreen" {
  source      = "github.com/skyscrapers/terraform-bluegreen//blue-green"
  project     = "${var.project}"
  name        = "ecs-cluster"
  environment = "${terraform.env}"

  # http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI_launch_latest.html
  blue_ami               = "ami-95f8d2f3"
  green_ami              = "ami-95f8d2f3"
  subnets                = ["${data.terraform_remote_state.static.private_app_subnets}"]
  instance_type          = "${var.ecs_instance_type["${terraform.env}"]}"
  iam_instance_profile   = "${data.terraform_remote_state.static.ecs-instance-profile}"
  loadbalancers          = []
  key_name               = "mattias"
  blue_max_size          = "0"
  blue_min_size          = "0"
  blue_desired_capacity  = "0"
  green_max_size         = "${var.ecs_instances_maximum["${terraform.env}"]}"
  green_min_size         = "0"
  green_desired_capacity = "${var.ecs_instances_desired["${terraform.env}"]}"
  security_groups        = ["${data.terraform_remote_state.static.sg_all_id}", "${data.terraform_remote_state.static.sg_ecs_instance}"]

  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${data.terraform_remote_state.static.ecs_cluster_name} >> /etc/ecs/ecs.config
EOF
}
