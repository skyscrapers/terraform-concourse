terraform {
  required_version = ">= 0.9.0"

  backend "s3" {
    bucket  = "skyscraperstest-terraform"
    key     = "concourse/ecs-cluster"
    region  = "eu-west-1"
    encrypt = true
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

data "terraform_remote_state" "static" {
  backend     = "s3"
  environment = "${terraform.env}"

  config {
    bucket = "skyscraperstest-terraform"
    key    = "concourse/main"
    region = "eu-west-1"
  }
}
