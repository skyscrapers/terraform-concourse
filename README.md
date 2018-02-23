# terraform-concourse

Terraform module to setup Concourse CI. This repository contains the following modules:
* `keys`: Creates an S3 bucket and uploads an auto-generated set of keys for concourse.
* `ecs-web`: ECS based setup for the Concourse web service, which is currently
  the combination of the ATC and TSA.
  (See the [Concourse Architecture](http://concourse.ci/architecture.html)
  documentation what these acronyms mean)
* `ecs-worker`: ECS based setup for a (pool of) Concourse worker(s).
* `ec2-worker`: EC2 based setup for a (pool of) Concourse worker(s).

## keys
Creates an S3 bucket and uploads an auto-generated set of keys for concourse.

The following resources are created:
- S3 bucket for concourse keys
- Uploads concourse keys to bucket

### Available variables
* [`environment`]: String(required): the name of the environment these subnets belong to (prod,stag,dev)
* [`name`]: String(required): The name of the Concourse deployment, used to distinguish different Concourse setups
* [`concourse_keys_version`]: Integer(optional): Change this if you want to re-generate the Concourse keys
* [`aws_profile`]: String(optional): This is the AWS profile name as set in the shared credentials file. Used to upload the Concourse keys to S3. Omit this if you're using environment variables.

### Outputs
* [`keys_bucket_id`]: String: The id (name) of the S3 bucket where the concourse keys are stored.
* [`keys_bucket_arn`]: String: The ARN of the S3 bucket where the concourse keys are stored.

### Example
```
module "concourse-keys" {
  source      = "github.com/skyscrapers/terraform-concourse//keys"
  environment = "${terraform.env}"
  name        = "internal"
}
```

## ecs-web-and-db
This sets up Concourse Web on an ECS cluster and a Postgresql database for concourse.

Before running `Plan` you will need setup an SSH tunnel through the jumphost to the RDS instance to create the database:
ssh [jumbhost] -L 5432:[RDS Endpoint]:5432

The following resources are created:
- ELB
- Web concourse ECS service
- Postgresql Databse in RDS

### Available variables
 * [`environment`]: String(required): the name of the environment these subnets belong to (prod,stag,dev)
 * [`name`]: String(required): The name of the Concourse deployment, used to distinguish different Concourse setups
 * [`ecs_cluster`]: String(required): name of the ecs cluster
 * [`concourse_hostname`]: String(required): hostname on what concourse will be available, this hostname needs to point to the ELB.
 * [`concourse_docker_image`]: String(optional): docker image to use to start concourse. Default is [skyscrapers/concourse](https://hub.docker.com/r/skyscrapers/concourse/)
 * [`concourse_version`]: String(required): the Concourse CI version to use
 * [`concourse_db_host`]: String(required): postgresql hostname or IP
 * [`concourse_db_port`]: String(optional): port of the postgresql server
 * [`concourse_db_username`]: String(optional): db user to logon to postgresql. Defaults to "concourse".
 * [`concourse_db_password`]: String(required): password to logon to postgresql
 * [`concourse_db_name`]: String(optional): db name to use on the postgresql server. Defaults to "concourse".
 * [`ecs_service_role_arn`]: String(required): IAM role to use for the service to be able to let it register to the ELB
 * [`concourse_web_instance_count`]: Integer(optional): Number of containers running Concourse web
 * [`elb_subnets`]: List(required): Subnets to deploy the ELB in
 * [`ssl_certificate_id`]: String(required): SSL certificate arn to attach to the ELB
 * [`backend_security_group_id`]: String(required): Security groups of the ECS servers
 * [`allowed_incoming_cidr_blocks`]: List(optional): Allowed CIDR blocks in Concourse ATC+TSA. Defaults to 0.0.0.0/0
 * [`keys_bucket_id`]: String(required): The id (name) of the bucket where the concourse keys are stored.
 * [`keys_bucket_arn`]: String(required): The ARN of the bucket where the concourse keys. Used to allow access to the bucket.
 * [`vault_server_url`]: String(optional): The Vault server URL to configure in Concourse. Leaving it empty will disable the Vault integration. Defaults to ""
 * [`vault_auth_concourse_role_name`]: String(optional): The Vault role that Concourse will use. This is normally fetched from the `vault-auth` terraform module. Defaults to "".
 * [`container_cpu`]: Int(optional): The number of cpu units to reserve for the container. This parameter maps to CpuShares in the Create a container section of the Docker Remote API. Defaults to 256.
 * [`container_memory`]: Int(optional): The amount of memory (in MiB) used by the task. Defaults to 256.

Depending on if you want standard Github authentication or standard authentication,
you need to fill in the following variables. We advise to use Github as there you can enforce 2 factor
authentication. More information about teams can be found on
the [concourse website](http://concourse.ci/teams.html).

 * [`concourse_github_auth_client_id`]: String(optional): Github client id
 * [`concourse_github_auth_client_secret`]: String(optional): Github client secret
 * [`concourse_github_auth_team`]: String(optional): Github team that can login

 * [`concourse_auth_username`]: String(optional): Basic authentication username
 * [`concourse_auth_password`]: String(optional): Basic authentication password

### Output
 * [`elb_dns_name`]: String: DNS name of the loadbalancer
 * [`elb_sg_id`]: String: Security group id of the loadbalancer
 * [`iam_role_arn`]: String: ARN of the IAM role created for the Concourse ECS task

### Example
```
module "concourse-web" {
  source                              = "github.com/skyscrapers/terraform-concourse//ecs-web"
  environment                         = "${terraform.env}"
  name                                = "internal"
  ecs_cluster                         = "test-ecs"
  ecs_service_role_arn                = "${data.terraform_remote_state.static.ecs-service-role}"
  concourse_hostname                  = "concourse.staging.client.company"
  concourse_version                   = "3.2.1"
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
  keys_bucket_id                      = "${module.keys.keys_bucket_id}"
  keys_bucket_arn                     = "${module.keys.keys_bucket_arn}"
  vault_server_url                    = "https://vault.example.com"
  vault_auth_concourse_role_name      = "${module.concourse-vault-auth.concourse_vault_role_name}"
}
```

## ecs-worker
This setups Concourse CI workers on an ECS cluster.
This setups the following resources:
- Concourse Worker ECS service

**Warning**: due to an [issue with Concourse](https://github.com/concourse/concourse/issues/544), it's recommended to run the workers on a `btrfs` formatted volume. This module **won't** setup that volume on the ECS instances for you, so unless the EC2 instances forming your ECS cluster already have their root disks formatted as `btrfs`, we advise to use the [`ec2-worker`](#ec2-worker) module instead.

### Available variables
 * [`environment`]: String(required): the name of the environment these subnets belong to (prod,stag,dev)
 * [`name`]: String(required): The name of the Concourse deployment, used to distinguish different Concourse setups
 * [`ecs_cluster`]: String(required): name of the ecs cluster
 * [`concourse_hostname`]: String(required): hostname on what concourse will be available, this hostname needs to point to the ELB.
 * [`concourse_docker_image`]: String(optional): docker image to use to start concourse. Default is [skyscrapers/concourse](https://hub.docker.com/r/skyscrapers/concourse/)
 * [`concourse_version`]: String(required): the Concourse CI version to use
 * [`ecs_service_role_arn`]: String(required): IAM role to use for the service to be able to let it register to the ELB
 * [`concourse_worker_instance_count`]: Integer(optional): Number of containers running Concourse web
 * [`backend_security_group_id`]: String(required): Security groups of the ECS servers
 * [`keys_bucket_id`]: String(required): The id of the bucket where the concourse keys are stored for connecting to the TSA.
 * [`keys_bucket_arn`]: String(required): The ARN of the bucket where the concourse keys. Used to allow access to the bucket.

### Output
None

### Example
```
module "concourse-worker" {
  source                              = "github.com/skyscrapers/terraform-concourse//ecs-worker"
  environment                         = "${terraform.env}"
  name                                = "internal"
  ecs_cluster                         = "test-ecs"
  ecs_service_role_arn                = "${data.terraform_remote_state.static.ecs-service-role}"
  concourse_hostname                  = "concourse.staging.client.company"
  concourse_version                   = "3.2.1"
  backend_security_group_id           = "${data.terraform_remote_state.static.sg_ecs_instance}"
  keys_bucket_id                      = "${module.concourse.keys_bucket_id}"
  keys_bucket_arn                     = "${module.concourse.keys_bucket_arn}"
}
```

## ec2-worker

This sets up a Concourse CI worker pool as EC2 instances running in an Autoscaling group.

The following resources will be created:
- Autoscaling launch configuration & autoscaling group
  - The EC2 instances have an additional EBS volume attached, automatically formatted as `btrfs`
- Security group
- IAM role

### Available variables

| Name | Description | Default | Required |
|------|-------------|:-----:|:-----:|
| additional_security_group_ids | Additional security group ids to attach to the worker instances | [ ] | no |
| concourse_hostname | Hostname on what concourse will be available, this hostname needs to point to the ELB. | - | yes |
| concourse_version | Concourse CI version to use | `3.2.1` | yes |
| concourse_worker_instance_count | Number of Concourse worker instances | `1` | no |
| custom_ami | Use a custom AMI for the worker instances. | latest Ubuntu 16.04 AMI | no |
| environment | The name of the environment these subnets belong to (prod,stag,dev) | - | yes |
| instance_type | EC2 instance type for the worker instances | - | yes |
| keys_bucket_arn | The S3 bucket ARN which contains the SSH keys to connect to the TSA | - | yes |
| keys_bucket_id | The S3 bucket id which contains the SSH keys to connect to the TSA | - | yes |
| name | A descriptive name of the purpose of this Concourse worker pool | - | yes |
| root_disk_volume_size | Size of the worker instances root disk | `10` | no |
| root_disk_volume_type | Volume type of the worker instances root disk | `standard` | no |
| ssh_key_name | The key name to use for the instance | - | yes |
| subnet_ids | List of subnet ids where to deploy the worker instances | - | yes |
| vpc_id | The VPC id where to deploy the worker instances | - | yes |
| work_disk_device_name | Device name of the external EBS volume | `/dev/xvdf` | no |
| work_disk_internal_device_name | Device name of the internal EBS volume | `/dev/xvdf` | no |
| work_disk_volume_size | Size of the external EBS volume | `100` | no |
| work_disk_volume_type | Volume type of the external EBS volume | `standard` | no |
| concourse_tags | List of tags to add to the worker to use for assigning jobs and tasks | [ ] | no |
| tsa_account_id | AWS Account ID of the TSA when remote | - | no |

### Output

| Name | Description |
|------|-------------|
| worker_instances_sg_id | Security group ID used for the worker instances |
| worker_iam_role | Role name of the worker instance |

### Example
```
module "concourse-worker" {
  source                        = "github.com/skyscrapers/terraform-concourse//ec2-worker"
  environment                   = "${terraform.env}"
  name                          = "internal"
  concourse_hostname            = "concourse.staging.client.company"
  concourse_version             = "3.2.1"
  keys_bucket_id                = "${module.keys.keys_bucket_id}"
  keys_bucket_arn               = "${module.keys.keys_bucket_arn}"
  ssh_key_name                  = "default"
  instance_type                 = "t2.small"
  subnet_ids                    = "${data.terraform_remote_state.static.private_app_subnets}"
  vpc_id                        = "${data.terraform_remote_state.static.vpc_id}"
  additional_security_group_ids = ["${data.terraform_remote_state.static.sg_all_id}"]
}
```

## vault-auth

This module sets up the needed Vault resources for Concourse:

- It creates a Vault policy that allows read-only access to `/concourse/*`
- It creates a Vault role in the aws auth backend (which should be previously created) for Concourse and attaches the previously mentioned policy

### Available variables

| Name | Description | Default | Required |
|------|-------------|:-----:|:-----:|
| name_suffix | Name suffix to append to the policy name, to differentiate different concourse policies. | `default` | no |
| additional_vault_policies | Additional Vault policies to attach to the Concourse role. | [] | no |
| concourse_iam_role_arn | IAM role ARN of the Concourse ATC server. | - | yes |
| vault_aws_auth_backend_path | The path the AWS auth backend being configured was mounted at. | `aws` | no |
| vault_server_url | The Vault server url. | - | yes |

### Output

| Name | Description |
|------|-------------|
| concourse_vault_policy_name | Name of the Vault policy created for Concourse |
| concourse_vault_role_name | Name of the Vault role created for Concourse |

### Example

```
module "concourse-vault-auth" {
  source                 = "github.com/skyscrapers/terraform-concourse//vault-auth"
  concourse_iam_role_arn = "${module.concourse-web.iam_role_arn}"
  vault_server_url       = "https://vault.example.com"
}
```
