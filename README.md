# terraform-concourse
Terraform module to setup Concourse CI

## ecs
This setups Concourse CI on an ECS cluster.
This setups the following resources:
- ELB
- Web concourse ECS service
- Worker concourse ECS service
- S3 bucket for SSH certificates
- Uploads SSH certificates to bucket


### Available variables:
 * [`environment`]: String(required): the name of the environment these subnets belong to (prod,stag,dev)
 * [`ecs_cluster`]: String(required): name of the ecs cluster
 * [`concourse_hostname`]: String(required): hostname on what concourse will be available, this hostname needs to point to the ELB.
 * [`concourse_docker_image`]: String(optional): docker image to use to start concourse. Default is [skyscrapers/concourse](https://hub.docker.com/r/skyscrapers/concourse/)
 * [`concourse_db_host`]: String(required): postgresql hostname or IP
 * [`concourse_db_port`]: String(optional): port of the postgresql server
 * [`concourse_db_username`]: String(required): db user to logon to postgresql
 * [`concourse_db_password`]: String(required): password to logon to postgresql
 * [`concourse_db_name`]: String(required): db name to use on the postgresql server
 * [`ecs_service_role_arn`]: String(required): IAM role to use for the service to be able to let it register to the ELB
 * [`concourse_keys_version`]: Integer(optional): Change this if you want to re-generate Concourse keys
 * [`generate_concourse_keys`]: Boolean(optional): Set to false to disable the automatic generation of Concourse keys
 * [`concourse_web_instance_count`]: Integer(optional): Number of containers running Concourse web
 * [`concourse_worker_instance_count`]: Integer(optional): Number of containers running Concourse web
 * [`elb_subnets`]: List(required): Subnets to deploy the ELB in
 * [`ssl_certificate_id`]: String(required): SSL certificate arn to attach to the ELB
 * [`backend_security_group_id`]: String(required): Security groups of the ECS servers

Depending on if you want standard Github authentication or standard authentication, you need to fill in the following variables. We advise to use Github as there you can enforce 2 factor authentication. More information about teams can be found on the [concourse website](http://concourse.ci/teams.html).

 * [`concourse_github_auth_client_id`]: String(optional): Github client id
 * [`concourse_github_auth_client_secret`]: String(optional): Github client secret
 * [`concourse_github_auth_team`]: String(optional): Github team that can login

 * [`concourse_auth_username`]: String(optional): Basic authentication username
 * [`concourse_auth_password`]: String(optional): Basic authentication password

### Output
 * [`elb_dns_name`]: String: DNS name of the loadbalancer

### Example
  ```
  module "concourse" {
    source                              = "../../ecs"
    environment                         = "staging"
    ecs_cluster                         = "test-ecs"
    ecs_service_role_arn                = "${data.terraform_remote_state.static.ecs-service-role}"
    concourse_hostname                  = "concourse.staging.client.company"
    concourse_db_host                   = "hostname.rds.test"
    concourse_db_username               = "concourse"
    concourse_db_password               = "concourse"
    concourse_db_name                   = "consourse"
    concourse_github_auth_client_id     = "${var.concourse_github_auth_client_id}"
    concourse_github_auth_client_secret = "${var.concourse_github_auth_client_secret}"
    concourse_github_auth_team          = "${var.concourse_github_auth_team}"
    elb_subnets                         = "${data.terraform_remote_state.static.public_lb_subnets}"
    backend_security_group_id           = "${data.terraform_remote_state.static.sg_ecs_instance}"
    ssl_certificate_id                  = "${var.elb_ssl_certificate}"
  }
  ```
