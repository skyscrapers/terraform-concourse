variable "cidr_block" {
  default = "172.30.0.0/16"
  type    = string
}

variable "environment" {
  default = "test"
  type    = string
}

variable "project" {
  type    = string
}

variable "db_instance_type" {
  default = "db.t2.micro"
  type    = string
}

variable "rds_root_password" {
  default = "superduperstrongpassword"
  type    = string
}

variable "rds_storage_encrypted" {
  default = false
  type    = bool
}

variable "db_engine_version" {
  default = "9.6.6"
  type    = string
}

variable "default_parameter_group_family" {
  default = "postgres9.6"
  type    = string
}

variable "rds_allocated_storage" {
  default = "10"
  type    = string
}

variable "key_name" {
  default = ""
  type    = string
}

variable "ecs_instance_type" {
  default = "t3.micro"
  type    = string
}

variable "concourse_version" {
  type    = string
}

variable "concourse_db_username" {
  default = "concourse"
  type    = string
}

variable "concourse_db_password" {
  default = "concourse"
  type    = string
}

variable "concourse_db_name" {
  default = "concourse"
  type    = string
}

variable "github_client_id" {
  default = ""
  type    = string
}

variable "concourse_auth_username" {
  default = "concourse"
  type    = string
}

variable "concourse_auth_password" {
  default = "concourse"
  type    = string
}

variable "github_client_secret" {
  default = ""
  type    = string
}

variable "github_auth_team" {
  default = ""
  type    = string
}

variable "container_memory" {
  default = "256"
  type    = string
}

variable "container_cpu" {
  default = "256"
  type    = string
}

variable "elb_ssl_certificate_id" {
  default = ""
  type    = string
}

variable "worker_instance_count" {
  default = "1"
  type    = string
}

variable "worker_cpu_credits" {
  default = "standard"
  type    = string
}

