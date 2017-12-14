resource "vault_policy" "concourse" {
  name = "concourse-${var.name_suffix}"

  policy = <<EOT
path "concourse/*" {
  capabilities = ["read"]
}
EOT
}
