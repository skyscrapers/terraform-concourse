variable "environment" {
  description = "The name of the environment these subnets belong to (prod,stag,dev)"
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

variable "concourse_db_host" {
  description = "postgresql hostname or IP"
}

variable "concourse_db_port" {
  description = "port of the postgresql server"
  default     = "5432"
}

variable "concourse_db_username" {
  description = "db user to logon to postgresql"
}

variable "concourse_db_password" {
  description = "password to logon to postgresql"
}

variable "concourse_db_name" {
  description = "db name to use on the postgresql server"
}

variable "ecs_service_role_arn" {
  description = "IAM role to use for the service to be able to let it register to the ELB"
}

variable "concourse_github_auth_client_id" {
  description = "Github client id"
  default     = ""
}

variable "concourse_github_auth_client_secret" {
  description = "Github client secret"
  default     = ""
}

variable "concourse_github_auth_team" {
  description = "Github team that can login"
  default     = ""
}

variable "concourse_auth_username" {
  description = "Basic authentication username"
  default     = ""
}

variable "concourse_auth_password" {
  description = "Basic authentication password"
  default     = ""
}

variable "concourse_web_instance_count" {
  description = "Number of containers running Concourse web"
  default     = "1"
}

variable "elb_subnets" {
  description = "Subnets to deploy the ELB in"
  type        = "list"
}

variable "backend_security_group_id" {
  description = ""
}

variable "ssl_certificate_id" {
  description = "SSL certificate arn to attach to the ELB"
}

variable "allowed_incoming_cidr_blocks" {
  type        = "list"
  description = "Allowed CIDR blocks in Concourse ATC+TSA. Defaults to 0.0.0.0/0"
  default     = ["0.0.0.0/0"]
}

variable "keys_bucket_id" {
  description = "The S3 bucket id which contains the SSH keys to connect to the TSA"
}

variable "keys_bucket_arn" {
  description = "The S3 bucket ARN which contains the SSH keys to connect to the TSA"
}
