resource "vault_policy" "concourse" {
  name = var.vault_concourse_role_name

  policy = <<EOT
path "concourse/*" {
  capabilities = ["read"]
}
EOT
}
