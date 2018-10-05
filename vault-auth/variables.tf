variable "vault_concourse_role_name" {
  description = "Name to give to the Vault role and policy for Concourse"
}

variable "additional_vault_policies" {
  description = "Additional Vault policies to attach to the Concourse role"
  default     = []
}

variable "concourse_iam_role_arn" {
  description = "IAM role ARN of the Concourse ATC server. You can get this from the concourse web module outputs"
}

variable "vault_aws_auth_backend_path" {
  description = "The path the AWS auth backend being configured was mounted at"
  default     = "aws"
}

variable "vault_server_url" {
  description = "The Vault server url"
}

variable "vault_token_period" {
  description = "Vault token renewal period, in seconds. This make the token to never expire, but still has to be renewed within the duration specified by this value"
  default     = 43200
}
