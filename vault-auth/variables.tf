variable "name_suffix" {
  description = "Name suffix to append to the policy name, to differentiate different concourse policies. Defaults to 'default'"
  default     = "default"
}

variable "additional_vault_policies" {
  description = "Additional Vault policies to attach to the Concourse role. Defaults to empty list"
  default = []
}

variable "concourse_iam_role_arn" {
  description = "IAM role ARN of the Concourse ATC server"
}

variable "vault_aws_auth_backend_path" {
  description = "The path the AWS auth backend being configured was mounted at. Defaults to aws."
  default = "aws"
}

variable "vault_server_url" {
  description = "The Vault server url"
}
