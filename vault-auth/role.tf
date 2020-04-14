resource "vault_aws_auth_backend_role" "concourse" {
  backend                  = var.vault_aws_auth_backend_path
  role                     = var.vault_concourse_role_name
  auth_type                = "iam"
  bound_iam_principal_arns = [var.concourse_iam_role_arn]
  token_policies           = concat(list(vault_policy.concourse.name), var.additional_vault_policies)
  token_period             = var.vault_token_period
}
