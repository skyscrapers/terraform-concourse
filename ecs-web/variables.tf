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

variable "concourse_keys_version" {
  description = "Change this if you want to re-generate Concourse keys"
  default     = "1"
}

variable "generate_concourse_keys" {
  description = "Set to false to disable the automatic generation of Concourse keys"
  default     = "true"
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
