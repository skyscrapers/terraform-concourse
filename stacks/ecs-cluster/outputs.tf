output "ecs_cluster" {
  value = "${data.terraform_remote_state.static.ecs_cluster_name}"
}
