variable "environment" {
  description = "The name of the environment these subnets belong to (prod,stag,dev)"
}

variable "name" {
  description = "A descriptive name of the purpose of this Concourse worker pool"
}

variable "vpc_id" {
  description = "The VPC id where to deploy the worker instances"
}

variable "subnet_ids" {
  type        = "list"
  description = "List of subnet ids where to deploy the worker instances"
}

variable "instance_type" {
  description = "EC2 instance type for the worker instances"
}

variable "ssh_key_name" {
  description = "The key name to use for the instance"
}

variable "custom_ami" {
  description = "Use a custom AMI for the worker instances. If omitted the latest Ubuntu 16.04 AMI will be used."
  default     = ""
}

variable "additional_security_group_ids" {
  type        = "list"
  description = "Additional security group ids to attach to the worker instances"
  default     = []
}

variable "root_disk_volume_type" {
  description = "Volume type of the worker instances root disk"
  default     = "standard"
}

variable "root_disk_volume_size" {
  description = "Size of the worker instances root disk"
  default     = "10"
}

variable "work_disk_device_name" {
  description = "Device name of the external EBS volume"
  default     = "/dev/xvdf"
}

variable "work_disk_internal_device_name" {
  description = "Device name of the internal volume"
  default     = "/dev/xvdf"
}

variable "work_disk_volume_type" {
  description = "Volume type of the external EBS volume"
  default     = "standard"
}

variable "work_disk_volume_size" {
  description = "Size of the external EBS volume"
  default     = "100"
}

variable "concourse_hostname" {
  description = "Hostname on what concourse will be available, this hostname needs to point to the ELB."
}

variable "worker_tsa_port" {
  description = "tsa port that the worker can use to connect to the web"
  default     = "2222"
}

variable "concourse_worker_instance_count" {
  description = "Number of Concourse worker instances"
  default     = "1"
}

variable "concourse_version" {
  description = "Concourse CI version to use"
}

variable "keys_bucket_id" {
  description = "The S3 bucket id which contains the SSH keys to connect to the TSA"
}

variable "keys_bucket_arn" {
  description = "The S3 bucket ARN which contains the SSH keys to connect to the TSA"
}

variable "concourse_tags" {
  description = "List of tags to add to the worker to use for assigning jobs and tasks"
  type        = "list"
  default     = []
}

variable "tsa_account_id" {
  description = "AWS Account ID of the TSA when remote"
  default     = ""
}
