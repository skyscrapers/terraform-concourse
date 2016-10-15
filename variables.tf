variable vpc_id {}
variable ecs-cluster-name {}
variable ecs-cluster-arn {}
variable ecs-instance-role {}
variable region {}
variable environment {}

# Location where to create the concourse Postgres database
variable pg_host {}
variable pg_admin_user {}
variable pg_admin_password {}

variable pg_concourse_db {}
variable pg_concourse_user {}
variable pg_concourse_password {}

variable team {
  default = "skyscrapers"
}

variable role {
  default = "ci"
}

variable ci_version {}
variable public_hostname {}
variable github_app_id {}
variable github_app_secret {}
variable ssl_certificate_arn {}
variable subnets {
  type = "list"
}
variable security_groups {
  type = "list"
}