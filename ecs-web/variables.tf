variable "environment" {
  description = "The name of the environment these subnets belong to (prod,stag,dev)"
}

variable "name" {
  description = "The name of the Concourse deployment, used to distinguish different Concourse setups"
}

variable "ecs_cluster" {
  description = "Name of the ecs cluster"
}

variable "concourse_hostname" {
  description = "Hostname on what concourse will be available, this hostname needs to point to the ELB. If ommitted, the hostname of the AWS ELB will be used instead"
  default     = ""
}

variable "concourse_docker_image" {
  description = "Docker image to use to start concourse"
  default     = "skyscrapers/concourse"
}

variable "concourse_version" {
  # No default version set here to make sure a version is locked for a customer setup.
  description = "Concourse CI version to use"
}

variable "concourse_db_host" {
  description = "Postgresql server hostname or IP"
}

variable "concourse_db_port" {
  description = "Port of the postgresql server"
  default     = "5432"
}

variable "concourse_db_username" {
  description = "Database user to logon to postgresql"
  default     = "concourse"
}

variable "concourse_db_password" {
  description = "Password to logon to postgresql"
}

variable "concourse_db_name" {
  description = "Database name to use on the postgresql server"
  default     = "concourse"
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

variable "concourse_auth_main_team_local_user" {
  description = "Local user to allow access to the main team"
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
  description = "Security group ID of the ECS servers"
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

variable "vault_server_url" {
  description = "The Vault server URL to configure in Concourse. Leaving it empty will disable the Vault integration"
  default     = ""
}

variable "vault_auth_concourse_role_name" {
  description = "The Vault role that Concourse will use. This is normally fetched from the `vault-auth` Terraform module"
  default     = ""
}

variable "concourse_vault_auth_backend_max_ttl" {
  description = "The Vault max-ttl (in seconds) that Concourse will use"
  default     = "2592000"
}

variable "container_memory" {
  description = "The amount of memory (in MiB) used by the task"
  default     = 256
}

variable "container_cpu" {
  description = "The number of cpu units to reserve for the container. This parameter maps to CpuShares in the Create a container section of the Docker Remote API"
  default     = 256
}

variable "concourse_prometheus_bind_port" {
  description = "Port where Concourse will listen for the Prometheus scraper"
  default     = "9391"
}

variable "concourse_prometheus_bind_ip" {
  description = "IP address where Concourse will listen for the Prometheus scraper"
  default     = "0.0.0.0"
}

variable "prometheus_cidrs" {
  description = "CIDR blocks that'll allowed to access the Prometheus scraper port"
  type        = "list"
  default     = []
}
