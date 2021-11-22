variable "environment" {
  description = "The name of the environment these subnets belong to (prod,stag,dev)"
  type        = string
}

variable "name" {
  description = "A descriptive name of the purpose of this Concourse worker pool"
  type        = string
}

variable "project" {
  description = "Project where the concourse claster belongs to. This is mainly used to identify it in Teleport"
  default     = ""
  type        = string
}

variable "vpc_id" {
  description = "The VPC id where to deploy the worker instances"
  type        = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet ids where to deploy the worker instances"
}

variable "instance_type" {
  description = "EC2 instance type for the worker instances"
  type        = string
}

variable "ssh_key_name" {
  description = "The key name to use for the instance"
  type        = string
}

variable "custom_ami" {
  description = "Use a custom AMI for the worker instances. If omitted the latest Ubuntu 16.04 AMI will be used."
  default     = null
  type        = string
}

variable "additional_security_group_ids" {
  type        = list(string)
  description = "Additional security group ids to attach to the worker instances"
  default     = []
}

variable "root_disk_volume_type" {
  description = "Volume type of the worker instances root disk"
  default     = "gp2"
  type        = string
}

variable "root_disk_volume_size" {
  description = "Size of the worker instances root disk"
  default     = "10"
  type        = string
}

variable "work_disk_ephemeral" {
  description = "Whether to use ephemeral volumes as Concourse worker storage. You must use an [`instance_type` that supports this](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/InstanceStorage.html#InstanceStoreDeviceNames)"
  default     = false
  type        = string
}

variable "work_disk_device_name" {
  description = "Device name of the external EBS volume to use as Concourse worker storage"
  default     = "/dev/sdf"
  type        = string
}

variable "work_disk_internal_device_name" {
  description = "Device name of the internal volume as identified by the Linux kernel, which can differ from `work_disk_device_name` depending on used AMI. Make sure this is set according the `instance_type`, eg. `/dev/xvdf` when using an older AMI"
  default     = "/dev/nvme1n1"
  type        = string
}

variable "work_disk_volume_type" {
  description = "Volume type of the external EBS volume to use as Concourse worker storage"
  default     = "gp2"
  type        = string
}

variable "work_disk_volume_size" {
  description = "Size of the external EBS volume to use as Concourse worker storage"
  default     = "100"
  type        = string
}

variable "concourse_hostname" {
  description = "Hostname on what concourse will be available, this hostname needs to point to the ELB."
  type        = string
}

variable "worker_tsa_port" {
  description = "tsa port that the worker can use to connect to the web"
  default     = "2222"
  type        = string
}

variable "concourse_worker_instance_count" {
  description = "Number of Concourse worker instances"
  default     = 1
  type        = number
}

variable "concourse_version" {
  description = "Concourse CI version to use. Defaults to the latest tested version"
  default     = "7.5.0"
  type        = string
}

variable "concourse_version_override" {
  description = "Variable to override the default Concourse version. Leave it empty to fallback to `concourse_version`. Useful if you want to default to the module's default but also give the users the option to override it"
  default     = null
  type        = string
}

variable "keys_bucket_id" {
  description = "The S3 bucket id which contains the SSH keys to connect to the TSA"
  type        = string
}

variable "keys_bucket_arn" {
  description = "The S3 bucket ARN which contains the SSH keys to connect to the TSA"
  type        = string
}

variable "concourse_tags" {
  description = "List of tags to add to the worker to use for assigning jobs and tasks"
  type        = list(string)
  default     = []
}

variable "cross_account_worker_role_arn" {
  description = "IAM role ARN to assume to access the Concourse keys bucket in another AWS account"
  default     = null
  type        = string
}

variable "teleport_server" {
  description = "Teleport auth server hostname"
  default     = ""
  type        = string
}

variable "teleport_auth_token" {
  description = "Teleport node token to authenticate with the auth server"
  default     = ""
  type        = string
}

variable "teleport_version" {
  description = "Teleport version for the client"
  default     = "8.0.0"
  type        = string
}

variable "cpu_credits" {
  description = "The credit option for CPU usage. Can be `standard` or `unlimited`"
  default     = "standard"
  type        = string
}

variable "public" {
  type        = bool
  description = "Whether to assign these worker nodes a public IP (when public subnets are defined in `var.subnet_ids`)"
  default     = false
}
