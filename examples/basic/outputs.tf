output "concourse_hostname" {
  value = module.concourse_web.concourse_hostname
}

output "concourse_local_user_username" {
  value = var.concourse_auth_username
}

output "concourse_local_user_password" {
  value = var.concourse_auth_password
}

