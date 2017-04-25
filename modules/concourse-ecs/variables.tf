variable "environment" {
  description = ""
}

variable "ecs_cluster_arn" {
  description = ""
}

variable "concourse_web_alb_target_group_arn" {
  description = ""
}

variable "concourse_external_url" {
  description = ""
}

variable "concourse_docker_image" {
  default = "concourse/concourse"
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

variable "ecs_service_role_arn" {
  description = ""
}
