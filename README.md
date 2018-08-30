# terraform-concourse

Terraform module to setup Concourse CI. This repository contains the following modules:
* `keys`: Creates an S3 bucket and uploads an auto-generated set of keys for concourse.
* `ecs-web`: ECS based setup for the Concourse web service, which is currently
  the combination of the ATC and TSA.
  (See the [Concourse Concepts](https://concourse-ci.org/concepts.html)
  documentation what these acronyms mean)
* `ec2-worker`: EC2 based setup for a (pool of) Concourse worker(s).
* `vault-auth`: Sets up the required resources in Vault so it can be integrated in Concourse

## keys
Creates an S3 bucket and uploads an auto-generated set of keys for concourse.

The following resources are created:
- S3 bucket for concourse keys
- Uploads concourse keys to bucket

### Available variables

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws_profile | This is the AWS profile name as set in the shared credentials file. Used to upload the Concourse keys to S3. Omit this if you're using environment variables. | string | `` | no |
| concourse_workers_iam_role_arns | List of ARNs for the IAM roles that will be able to assume the role to access concourse keys in S3. Normally you'll include the Concourse worker IAM role here | list | - | yes |
| concourse_keys_version | Change this if you want to re-generate Concourse keys | string | `1` | no |
| environment | The name of the environment these subnets belong to (prod,stag,dev) | string | - | yes |
| name | The name of the Concourse deployment, used to distinguish different Concourse setups | string | - | yes |

### Outputs

| Name | Description |
|------|-------------|
| concourse_keys_cross_account_role_arn | IAM role ARN that Concourse workers on other AWS accounts will need to assume to access the Concourse keys bucket |
| keys_bucket_arn | The ARN of the S3 bucket where the concourse keys are stored |
| keys_bucket_id | The id (name) of the S3 bucket where the concourse keys are stored |


### Example
```
module "concourse-keys" {
  source                          = "github.com/skyscrapers/terraform-concourse//keys"
  environment                     = "${terraform.env}"
  name                            = "internal"
  concourse_workers_iam_role_arns = ["${module.concourse-worker.worker_iam_role_arn}"]
}
```

## ecs-web
This sets up Concourse Web on an ECS cluster.

The following resources are created:
- ELB
- Web concourse ECS service

### Available variables
 * [`environment`]: String(required): the name of the environment these subnets belong to (prod,stag,dev)
 * [`name`]: String(required): The name of the Concourse deployment, used to distinguish different Concourse setups
 * [`ecs_cluster`]: String(required): name of the ecs cluster
 * [`concourse_hostname`]: String(required): hostname on what concourse will be available, this hostname needs to point to the ELB.
 * [`worker_tsa_port`]: String(optional): tsa port that the worker can use to connect to the web. Defaults to ["2222"](https://concourse-ci.org/components.html#component-tsa)
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
 * [`concourse_vault_auth_backend_max_ttl`]: String(optional): The Vault max-ttl that Concourse will use. Defaults to "2592000" (30 days).
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

## ec2-worker

This sets up a Concourse CI worker pool as EC2 instances running in an Autoscaling group.

The following resources will be created:
- Autoscaling launch configuration & autoscaling group
  - The EC2 instances have an additional EBS volume attached, automatically formatted as `btrfs`
- Security group
- IAM role

### Available variables

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_security_group_ids | Additional security group ids to attach to the worker instances | list | `<list>` | no |
| concourse_hostname | Hostname on what concourse will be available, this hostname needs to point to the ELB. | string | - | yes |
| concourse_tags | List of tags to add to the worker to use for assigning jobs and tasks | list | `<list>` | no |
| concourse_version | Concourse CI version to use | string | - | yes |
| concourse_worker_instance_count | Number of Concourse worker instances | string | `1` | no |
| cross_account_worker_role_arn | IAM role ARN to assume to access the Concourse keys bucket in another AWS account | string | `` | no |
| custom_ami | Use a custom AMI for the worker instances. If omitted the latest Ubuntu 16.04 AMI will be used. | string | `` | no |
| environment | The name of the environment these subnets belong to (prod,stag,dev) | string | - | yes |
| instance_type | EC2 instance type for the worker instances | string | - | yes |
| keys_bucket_arn | The S3 bucket ARN which contains the SSH keys to connect to the TSA | string | - | yes |
| keys_bucket_id | The S3 bucket id which contains the SSH keys to connect to the TSA | string | - | yes |
| name | A descriptive name of the purpose of this Concourse worker pool | string | - | yes |
| project | Project where the concourse claster belongs to. This is mainly used to identify it in teleport | string | `` | no |
| root_disk_volume_size | Size of the worker instances root disk | string | `10` | no |
| root_disk_volume_type | Volume type of the worker instances root disk | string | `standard` | no |
| ssh_key_name | The key name to use for the instance | string | - | yes |
| subnet_ids | List of subnet ids where to deploy the worker instances | list | - | yes |
| teleport_auth_token | Teleport server node token  | string | `` | no |
| teleport_sg | Teleport server security group id | string | `` | no |
| teleport_version | teleport version for the client | string | `2.5.8` | no |
| vpc_id | The VPC id where to deploy the worker instances | string | - | yes |
| work_disk_ephemeral | Whether to use ephemeral volumes as Concourse worker storage. You must use an `instance_type` that supports this (https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/InstanceStorage.html#InstanceStoreDeviceNames) | bool | false | no
| work_disk_device_name | Device name of the external EBS volume to use as Concourse worker storage | string | `/dev/xvdf` | no |
| work_disk_internal_device_name | Device name of the internal volume as identified by the Linux kernel, which can differ from `work_disk_device_name` depending on used AMI. Make sure this is set according the `instance_type`, eg. `/dev/nvme0n1` when using NVMe ephemeral storage | string | `/dev/xvdf` | no |
| work_disk_volume_size | Size of the external EBS volume to use as Concourse worker storage | string | `100` | no |
| work_disk_volume_type | Volume type of the external EBS volume to use as Concourse worker storage | string | `standard` | no |
| worker_tsa_port | tsa port that the worker can use to connect to the web | string | `2222` | no |

### Output

| Name | Description |
|------|-------------|
| worker_instances_sg_id | Security group ID used for the worker instances |
| worker_iam_role | Role name of the worker instances |
| worker_iam_role_arn | Role ARN of the worker instances |

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

### NOTE on the external EBS volume

The EC2 instances created by this module will include an external EBS volume that will automatically be attached and mounted. You should pay special attention to the device name that those volumes will have inside the OS once attached, as that name can vary depending on the instance type you selected. For example, in general for `t2` instances, if you attach the EBS volume as `/dev/xvdf` it'll have the same device name inside the OS, but on `m5` or `c4` instances that's not the case, as it'll be named `/dev/nvme1n1`.

As of now, this situation is not being handled automatically by the module, so depending on the instance type you select, you might have to change the internal device name via the variable `work_disk_internal_device_name`.

## vault-auth

This module sets up the needed Vault resources for Concourse:

- It creates a Vault policy that allows read-only access to `/concourse/*`
- It creates a Vault role in the aws auth method (which should be previously created - explained below) for Concourse and attaches the previously mentioned policy

### Available variables

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_vault_policies | Additional Vault policies to attach to the Concourse role. Defaults to empty list | string | `<list>` | no |
| concourse_iam_role_arn | IAM role ARN of the Concourse ATC server | string | - | yes |
| vault_aws_auth_backend_path | The path the AWS auth backend being configured was mounted at. Defaults to aws. | string | `aws` | no |
| vault_concourse_role_name | Name to give to the Vault role and policy for Concourse | string | - | yes |
| vault_server_url | The Vault server url | string | - | yes |

### Output

--

### Example

```
module "concourse-vault-auth" {
  source                    = "github.com/skyscrapers/terraform-concourse//vault-auth"
  concourse_iam_role_arn    = "${module.concourse-web.iam_role_arn}"
  vault_server_url          = "https://vault.example.com"
  vault_concourse_role_name = "concourse-default"
}
```

### How to enable and configure the AWS auth method

If the AWS auth method is not previously enabled, you'll need to do it before applying this module. To do that you'll need to follow the first two steps described in the official Vault documentation: https://www.vaultproject.io/docs/auth/aws.html#via-the-cli

- Enable the auth method
- Configure the AWS credentials so Vault can make calls to the AWS API. Note that you can skip this step if you're going to use Vault's IAM EC2 instance role to access the AWS API.
