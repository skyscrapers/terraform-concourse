#### First prepare the DB
# Note: Not done by Terraform as long as don't run it from within the VPC.
#       Otherwise the DB server is not directly accessible.

//provider "postgresql" {
//  host = "${var.pg_host}"
//  username = "${var.pg_admin_user}"
//  password = "${var.pg_admin_password}"
//}
//
//resource "postgresql_role" "concourse_db_user" {
//  name = "${var.pg_concourse_user}"
//  password = "${var.pg_concourse_password}"
//}
//
//resource "postgresql_database" "concourse_db" {
//  name = "concourse"
//  owner = "${postgresql_role.concourse_db_user.name}"
//}
