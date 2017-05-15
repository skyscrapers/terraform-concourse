variable "environment" {
  description = "the name of the environment these subnets belong to (prod,stag,dev)"
}

variable "name" {
  description = ""
}

variable "vpc_id" {
  description = ""
}

variable "subnet_ids" {
  type        = "list"
  description = ""
}

variable "instance_type" {
  description = ""
}

variable "ssh_key_name" {
  description = ""
}

variable "custom_ami" {
  description = ""
  default     = ""
}

variable "additional_security_group_ids" {
  type        = "list"
  description = ""
  default     = []
}

variable "root_disk_volume_type" {
  description = ""
  default     = "standard"
}

variable "root_disk_volume_size" {
  description = ""
  default     = "10"
}

variable "work_disk_device_name" {
  description = ""
  default     = "/dev/xvdf"
}

variable "work_disk_volume_type" {
  description = ""
  default     = "standard"
}

variable "work_disk_volume_size" {
  description = ""
  default     = "100"
}

variable "concourse_hostname" {
  description = "Hostname on what concourse will be available, this hostname needs to point to the ELB."
}

variable "concourse_worker_instance_count" {
  description = "Number of Concourse worker instances"
  default     = "1"
}

variable "concourse_version" {
  description = ""
  default     = "v2.7.7"
}

variable "keys_bucket_id" {
  description = "The S3 bucket id which contains the SSH keys to connect to the TSA"
}

variable "keys_bucket_arn" {
  description = "The S3 bucket ARN which contains the SSH keys to connect to the TSA"
}
