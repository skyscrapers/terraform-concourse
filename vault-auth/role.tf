resource "vault_aws_auth_backend_role" "concourse" {
  backend                 = "${var.vault_aws_auth_backend_path}"
  role                    = "${var.vault_concourse_role_name}"
  auth_type               = "iam"
  bound_iam_principal_arn = "${var.concourse_iam_role_arn}"
  policies                = ["${concat(list(vault_policy.concourse.name), var.additional_vault_policies)}"]
  period                  = "${var.vault_token_period}"
}
