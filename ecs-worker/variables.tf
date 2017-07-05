variable "environment" {
  description = "the name of the environment these subnets belong to (prod,stag,dev)"
}

variable "ecs_cluster" {
  description = "name of the ecs cluster"
}

variable "concourse_hostname" {
  description = " hostname on what concourse will be available, this hostname needs to point to the ELB."
}

variable "concourse_docker_image" {
  description = "docker image to use to start concourse"
  default     = "skyscrapers/concourse"
}

variable "concourse_version" {
  # No default version set here to make sure a version is locked for a customer setup.
  description = "Concourse CI version to use"
}

variable "concourse_worker_instance_count" {
  description = "Number of containers running Concourse web"
  default     = "1"
}

variable "keys_bucket_id" {
  description = "The S3 bucket id which contains the SSH keys to connect to the TSA"
}

variable "keys_bucket_arn" {
  description = "The S3 bucket ARN which contains the SSH keys to connect to the TSA"
}
