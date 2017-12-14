resource "vault_aws_auth_backend_client" "example" {
  backend                    = "${var.vault_aws_auth_backend_path}"
  iam_server_id_header_value = "${replace(replace(var.vault_url, "/^http(s)?:///", ""), "/", "")}"
}
