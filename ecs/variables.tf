variable "environment" {
  description = ""
}

variable "ecs_cluster_arn" {
  description = ""
}

variable "concourse_web_elb" {
  description = ""
}

variable "concourse_external_url" {
  description = ""
}

variable "concourse_docker_image" {
  default = "skyscrapers/concourse"
}

variable "concourse_db_host" {
  description = ""
}

variable "concourse_db_port" {
  description = ""
  default     = "5432"
}

variable "concourse_db_username" {
  description = ""
}

variable "concourse_db_password" {
  description = ""
}

variable "concourse_db_name" {
  description = ""
}

variable "ecs_service_role_arn" {
  description = ""
}

variable "concourse_github_auth_client_id" {
  description = ""
  default     = ""
}

variable "concourse_github_auth_client_secret" {
  description = ""
  default     = ""
}

variable "concourse_github_auth_team" {
  description = ""
  default     = ""
}

variable "concourse_auth_username" {
  description = ""
  default     = ""
}

variable "concourse_auth_password" {
  description = ""
  default     = ""
}

variable "concourse_keys_version" {
  description = "Change this if you want to re-generate Concourse keys"
  default     = "2"
}

variable "generate_concourse_keys" {
  description = "Set to false to disable the automatic generation of Concourse keys"
  default     = "true"
}

variable "concourse_web_instance_count" {
  description = "Number of containers running Concourse web"
  default     = "1"
}

variable "concourse_worker_instance_count" {
  description = "Number of containers running Concourse web"
  default     = "1"
}

variable "elb_subnets" {
  description = ""
  default     = []
  type        = "list"
}

variable "backend_security_group_id" {
  description = ""
}

variable "ssl_certificate_id" {
  description = ""
  default     = ""
}
