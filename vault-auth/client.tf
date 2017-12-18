resource "vault_aws_auth_backend_client" "concourse" {
  backend                    = "${var.vault_aws_auth_backend_path}"
  iam_server_id_header_value = "${replace(replace(var.vault_server_url, "/^http(s)?:///", ""), "/", "")}"
}
