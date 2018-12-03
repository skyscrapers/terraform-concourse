module "concourse_keys" {
  source                          = "../../keys"
  environment                     = "${var.environment}"
  name                            = "${var.project}"
  concourse_workers_iam_role_arns = ["${module.concourse_worker.worker_iam_role_arn}"]
  bucket_force_destroy            = true
}

module "concourse_web" {
  source                               = "../../ecs-web"
  environment                          = "${var.environment}"
  name                                 = "${var.project}"
  ecs_cluster                          = "${module.ecs_cluster.cluster_name}"
  concourse_db_host                    = "${module.postgres.rds_address}"
  ecs_service_role_arn                 = "${module.ecs_cluster.ecs-service-role}"
  concourse_version                    = "${var.concourse_version}"
  concourse_db_username                = "${var.concourse_db_username}"
  concourse_db_password                = "${var.concourse_db_password}"
  concourse_db_name                    = "${var.concourse_db_name}"
  concourse_github_auth_client_id      = "${var.github_client_id}"
  concourse_auth_username              = "${var.concourse_auth_username}"
  concourse_auth_password              = "${var.concourse_auth_password}"
  concourse_github_auth_client_secret  = "${var.github_client_secret}"
  concourse_github_auth_team           = "${var.github_auth_team}"
  elb_subnets                          = "${module.vpc.public_lb_subnets}"
  container_memory                     = "${var.container_memory}"
  container_cpu                        = "${var.container_cpu}"
  backend_security_group_id            = "${aws_security_group.sg_ecs_instance.id}"
  ssl_certificate_id                   = "${var.elb_ssl_certificate_id}"
  keys_bucket_id                       = "${module.concourse_keys.keys_bucket_id}"
  keys_bucket_arn                      = "${module.concourse_keys.keys_bucket_arn}"
  concourse_db_root_password           = "${var.rds_root_password}"
  auto_create_db                       = true
  concourse_db_postgres_engine_version = "${var.db_engine_version}"
  concourse_auth_main_team_local_user  = "${var.concourse_auth_username}"
}

module "concourse_worker" {
  source                          = "../../ec2-worker"
  environment                     = "${var.environment}"
  name                            = "${var.project}"
  concourse_worker_instance_count = "${var.worker_instance_count}"
  concourse_version               = "${var.concourse_version}"
  concourse_hostname              = "${module.concourse_web.concourse_hostname}"
  keys_bucket_id                  = "${module.concourse_keys.keys_bucket_id}"
  keys_bucket_arn                 = "${module.concourse_keys.keys_bucket_arn}"
  ssh_key_name                    = "${var.key_name}"
  instance_type                   = "${var.worker_instance_type}"
  subnet_ids                      = "${module.vpc.private_management_subnets}"
  vpc_id                          = "${module.vpc.vpc_id}"
  work_disk_ephemeral             = "${var.worker_work_disk_ephemeral}"
  work_disk_volume_type           = "${var.worker_work_disk_volume_type}"
  work_disk_volume_size           = "${var.worker_work_disk_volume_size}"
  work_disk_internal_device_name  = "${var.worker_work_disk_internal_device_name}"
  root_disk_volume_type           = "${var.worker_root_disk_volume_type}"
  root_disk_volume_size           = "${var.worker_root_disk_volume_size}"
  cpu_credits                     = "${var.worker_cpu_credits}"
}

# Workers need to access the outside world
resource "aws_security_group_rule" "workers_access_out" {
  security_group_id = "${module.concourse_worker.worker_instances_sg_id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
