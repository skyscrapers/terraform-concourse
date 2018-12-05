variable "cidr_block" {
  default = "172.30.0.0/16"
}

variable "environment" {
  default = "test"
}

variable "project" {}

variable "db_instance_type" {
  default = "db.t2.micro"
}

variable "rds_root_password" {
  default = "superduperstrongpassword"
}

variable "rds_storage_encrypted" {
  default = false
}

variable "db_engine_version" {
  default = "9.6.6"
}

variable "default_parameter_group_family" {
  default = "postgres9.6"
}

variable "rds_allocated_storage" {
  default = "10"
}

variable "key_name" {
  default = ""
}

variable "ecs_instance_type" {
  default = "t3.micro"
}

variable "concourse_version" {}

variable "concourse_db_username" {
  default = "concourse"
}

variable "concourse_db_password" {
  default = "concourse"
}

variable "concourse_db_name" {
  default = "concourse"
}

variable "github_client_id" {
  default = ""
}

variable "concourse_auth_username" {
  default = "concourse"
}

variable "concourse_auth_password" {
  default = "concourse"
}

variable "github_client_secret" {
  default = ""
}

variable "github_auth_team" {
  default = ""
}

variable "container_memory" {
  default = "256"
}

variable "container_cpu" {
  default = "256"
}

variable "elb_ssl_certificate_id" {
  default = ""
}

variable "worker_instance_count" {
  default = "1"
}

variable "worker_cpu_credits" {
  default = "standard"
}
