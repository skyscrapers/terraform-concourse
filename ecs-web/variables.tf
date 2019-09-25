variable "environment" {
  description = "The name of the environment these subnets belong to (prod,stag,dev)"
  type        = string
}

variable "name" {
  description = "The name of the Concourse deployment, used to distinguish different Concourse setups"
  type        = string
}

variable "ecs_cluster" {
  description = "Name of the ecs cluster"
  type        = string
}

variable "concourse_hostname" {
  description = "Hostname on which concourse will be available, this hostname needs to point to the ELB. If ommitted, the hostname of the AWS ELB will be used instead"
  default     = null
  type        = string
}

variable "concourse_docker_image" {
  description = "Docker image to use to start concourse"
  default     = "concourse/concourse"
  type        = string
}

variable "concourse_version" {
  description = "Concourse CI version to use. Defaults to the latest tested version"
  default     = "5.5.1"
  type        = string
}

variable "concourse_version_override" {
  description = "Variable to override the default Concourse version. Leave it empty to fallback to `concourse_version`. Useful if you want to default to the module's default but also give the users the option to override it"
  default     = null
  type        = string
}

variable "concourse_db_host" {
  description = "Postgresql server hostname or IP"
  type        = string
}

variable "concourse_db_port" {
  description = "Port of the postgresql server"
  default     = "5432"
  type        = string
}

variable "concourse_db_username" {
  description = "Database user to logon to postgresql"
  default     = "concourse"
  type        = string
}

variable "concourse_db_password" {
  description = "Password to logon to postgresql"
  type        = string
}

variable "concourse_db_root_password" {
  description = "Root password of the Postgres database server. Only needed if `auto_create_db` is set to `true`"
  default     = ""
  type        = string
}

variable "auto_create_db" {
  description = "If set to `true`, the Concourse web container will attempt to create the postgres database if it's not already created"
  default     = false
  type        = bool
}

variable "concourse_db_postgres_engine_version" {
  description = "Postgres engine version used in the Concourse database server. Only needed if `auto_create_db` is set to `true`"
  default     = null
  type        = string
}

variable "concourse_db_name" {
  description = "Database name to use on the postgresql server"
  default     = "concourse"
  type        = string
}

variable "ecs_service_role_arn" {
  description = "IAM role to use for the service to be able to let it register to the ELB"
  type        = string
}

variable "concourse_github_auth_client_id" {
  description = "Github client id"
  default     = null
  type        = string
}

variable "concourse_github_auth_client_secret" {
  description = "Github client secret"
  default     = null
  type        = string
}

variable "concourse_github_auth_team" {
  description = "Github team that can login"
  default     = null
  type        = string
}

variable "concourse_auth_username" {
  description = "Basic authentication username"
  default     = null
  type        = string
}

variable "concourse_auth_password" {
  description = "Basic authentication password"
  default     = null
  type        = string
}

variable "concourse_auth_main_team_local_user" {
  description = "Local user to allow access to the main team"
  default     = null
  type        = string
}

variable "concourse_web_instance_count" {
  description = "Number of containers running Concourse web"
  default     = 1
  type        = number
}

variable "elb_subnets" {
  description = "Subnets to deploy the ELB in"
  type        = list(string)
}

variable "backend_security_group_id" {
  description = "Security group ID of the ECS servers"
  type        = string
}

variable "ssl_certificate_id" {
  description = "SSL certificate arn to attach to the ELB"
  type        = string
}

variable "allowed_incoming_cidr_blocks" {
  type        = list(string)
  description = "Allowed CIDR blocks in Concourse ATC+TSA. Defaults to 0.0.0.0/0"
  default     = ["0.0.0.0/0"]
}

variable "keys_bucket_id" {
  description = "The S3 bucket id which contains the SSH keys to connect to the TSA"
  type        = string
}

variable "keys_bucket_arn" {
  description = "The S3 bucket ARN which contains the SSH keys to connect to the TSA"
  type        = string
}

variable "vault_server_url" {
  description = "The Vault server URL to configure in Concourse. Leaving it empty will disable the Vault integration"
  default     = null
  type        = string
}

variable "vault_auth_concourse_role_name" {
  description = "The Vault role that Concourse will use. This is normally fetched from the `vault-auth` Terraform module"
  default     = null
  type        = string
}

variable "container_memory" {
  description = "The amount of memory (in MiB) used by the task"
  default     = 256
  type        = number
}

variable "container_cpu" {
  description = "The number of cpu units to reserve for the container. This parameter maps to CpuShares in the Create a container section of the Docker Remote API"
  default     = 256
  type        = number
}

variable "concourse_prometheus_bind_port" {
  description = "Port where Concourse will listen for the Prometheus scraper"
  default     = "9391"
  type        = string
}

variable "concourse_prometheus_bind_ip" {
  description = "IP address where Concourse will listen for the Prometheus scraper"
  default     = "0.0.0.0"
  type        = string
}

variable "prometheus_cidrs" {
  description = "CIDR blocks that'll allowed to access the Prometheus scraper port"
  type        = list(string)
  default     = []
}

variable "vault_docker_image_tag" {
  description = "Docker image version to use for the Vault auth container"
  default     = "1.1.3"
  type        = string
}

variable "concourse_extra_args" {
  description = "Extra arguments to pass to Concourse Web"
  type        = string
  default     = null
}

variable "concourse_extra_env" {
  description = "Extra ENV variables to pass to Concourse Web. Use a map with the ENV var name as key and value as value"
  type        = map(string)
  default     = null
}
