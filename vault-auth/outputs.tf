output "concourse_vault_policy_name" {
  value = "${vault_policy.concourse.name}"
}

output "concourse_vault_role_name" {
  value = "${vault_aws_auth_backend_role.concourse.role}"
}
