**UNMAINTAINED: this project is not being actively maintained anymore. It works as it is, but we won't be working on new features or bug fixes anymore. If you are using this module and are willing to maintain it, open an issue and we'll be more than happy to transfer the repo.**

# terraform-concourse

[![ci.skyscrape.rs](https://ci.skyscrape.rs/api/v1/teams/skyscrapers/pipelines/terraform-modules/jobs/test-terraform-concourse-master/badge)](https://ci.skyscrape.rs/teams/skyscrapers/pipelines/terraform-modules?groups=terraform-concourse)

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

* S3 bucket for concourse keys
* Uploads concourse keys to bucket

### Available variables

| Name                            | Description                                                                                                                                                                                                                                                                                                                                                                                                                           |  Type  | Default | Required |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----: | :-----: | :------: |
| bucket_force_destroy            | A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable                                                                                                                                                                                                                                                                           | string | `false` |    no    |
| concourse_keys_version          | Change this if you want to re-generate Concourse keys                                                                                                                                                                                                                                                                                                                                                                                 | string |   `1`   |    no    |
| concourse_workers_iam_role_arns | List of ARNs for the IAM roles that will be able to assume the role to access concourse keys in S3. Normally you'll include the Concourse worker IAM role here                                                                                                                                                                                                                                                                        |  list  |    -    |   yes    |
| environment                     | The name of the environment these subnets belong to (prod,stag,dev)                                                                                                                                                                                                                                                                                                                                                                   | string |    -    |   yes    |
| generate_keys                   | If set to `true` this module will generate the necessary RSA keys with the [`tls_private_key`](https://www.terraform.io/docs/providers/tls/r/private_key.html) resource and upload them to S3 (server-side encrypted). **Be aware** that this will store the generated *unencrypted* keys in the Terraform state, so be sure to use a secure state backend (e.g. S3 encrypted), or set this to `false` and generate the keys manually | string | `true`  |    no    |
| name                            | The name of the Concourse deployment, used to distinguish different Concourse setups                                                                                                                                                                                                                                                                                                                                                  | string |    -    |   yes    |

### Outputs

| Name                                  | Description                                                                                                       |
| ------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| concourse_keys_cross_account_role_arn | IAM role ARN that Concourse workers on other AWS accounts will need to assume to access the Concourse keys bucket |
| keys_bucket_arn                       | The ARN of the S3 bucket where the concourse keys are stored                                                      |
| keys_bucket_id                        | The id (name) of the S3 bucket where the concourse keys are stored                                                |

## ecs-web

This sets up Concourse Web on an ECS cluster.

The following resources are created:

* ELB
* Web concourse ECS service

### Available variables

| Name                                        | Description                                                                                                                                                                                                    | Type           | Default                            | Required |
| ------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ---------------------------------- | :------: |
| backend_security_group_id                   | Security group ID of the ECS servers                                                                                                                                                                           | `string`       | n/a                                |   yes    |
| concourse_db_host                           | Postgresql server hostname or IP                                                                                                                                                                               | `string`       | n/a                                |   yes    |
| concourse_db_password                       | Password to logon to postgresql                                                                                                                                                                                | `string`       | n/a                                |   yes    |
| ecs_cluster                                 | Name of the ecs cluster                                                                                                                                                                                        | `string`       | n/a                                |   yes    |
| ecs_service_role_arn                        | IAM role to use for the service to be able to let it register to the ELB                                                                                                                                       | `string`       | n/a                                |   yes    |
| elb_subnets                                 | Subnets to deploy the ELB in                                                                                                                                                                                   | `list(string)` | n/a                                |   yes    |
| environment                                 | The name of the environment these subnets belong to (prod,stag,dev)                                                                                                                                            | `string`       | n/a                                |   yes    |
| keys_bucket_arn                             | The S3 bucket ARN which contains the SSH keys to connect to the TSA                                                                                                                                            | `string`       | n/a                                |   yes    |
| keys_bucket_id                              | The S3 bucket id which contains the SSH keys to connect to the TSA                                                                                                                                             | `string`       | n/a                                |   yes    |
| name                                        | The name of the Concourse deployment, used to distinguish different Concourse setups                                                                                                                           | `string`       | n/a                                |   yes    |
| ssl_certificate_id                          | SSL certificate arn to attach to the ELB                                                                                                                                                                       | `string`       | n/a                                |   yes    |
| allowed_incoming_cidr_blocks                | Allowed CIDR blocks in Concourse ATC+TSA. Defaults to 0.0.0.0/0                                                                                                                                                | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> |    no    |
| auto_create_db                              | If set to `true`, the Concourse web container will attempt to create the postgres database if it's not already created                                                                                         | `bool`         | `false`                            |    no    |
| concourse_auth_main_team_local_user         | Local user to allow access to the main team                                                                                                                                                                    | `string`       | `null`                             |    no    |
| concourse_auth_password                     | Basic authentication password                                                                                                                                                                                  | `string`       | `null`                             |    no    |
| concourse_auth_username                     | Basic authentication username                                                                                                                                                                                  | `string`       | `null`                             |    no    |
| concourse_db_name                           | Database name to use on the postgresql server                                                                                                                                                                  | `string`       | `"concourse"`                      |    no    |
| concourse_db_port                           | Port of the postgresql server                                                                                                                                                                                  | `string`       | `"5432"`                           |    no    |
| concourse_db_postgres_engine_version        | Postgres engine version used in the Concourse database server. Only needed if `auto_create_db` is set to `true`                                                                                                | `string`       | `null`                             |    no    |
| concourse_db_root_password                  | Root password of the Postgres database server. Only needed if `auto_create_db` is set to `true`                                                                                                                | `string`       | `""`                               |    no    |
| concourse_db_username                       | Database user to logon to postgresql                                                                                                                                                                           | `string`       | `"concourse"`                      |    no    |
| concourse_default_build_logs_to_retain      | Default number of build logs that are kept. This can be overridden on job level                                                                                                                                | `string`       | `"100"`                            |    no    |
| concourse_default_days_to_retain_build_logs | Default days of build logs that are kept. This can be overridden on job level                                                                                                                                  | `string`       | `"90"`                             |    no    |
| concourse_docker_image                      | Docker image to use to start concourse                                                                                                                                                                         | `string`       | `"concourse/concourse"`            |    no    |
| concourse_extra_args                        | Extra arguments to pass to Concourse Web                                                                                                                                                                       | `string`       | `null`                             |    no    |
| concourse_extra_env                         | Extra ENV variables to pass to Concourse Web. Use a map with the ENV var name as key and value as value                                                                                                        | `map(string)`  | `null`                             |    no    |
| concourse_github_auth_client_id             | Github client id                                                                                                                                                                                               | `string`       | `null`                             |    no    |
| concourse_github_auth_client_secret         | Github client secret                                                                                                                                                                                           | `string`       | `null`                             |    no    |
| concourse_github_auth_team                  | Github team that can login                                                                                                                                                                                     | `string`       | `null`                             |    no    |
| concourse_hostname                          | Hostname on which concourse will be available, this hostname needs to point to the ELB. If ommitted, the hostname of the AWS ELB will be used instead                                                          | `string`       | `null`                             |    no    |
| concourse_prometheus_bind_ip                | IP address where Concourse will listen for the Prometheus scraper                                                                                                                                              | `string`       | `"0.0.0.0"`                        |    no    |
| concourse_prometheus_bind_port              | Port where Concourse will listen for the Prometheus scraper                                                                                                                                                    | `string`       | `"9391"`                           |    no    |
| concourse_version                           | Concourse CI version to use. Defaults to the latest tested version                                                                                                                                             | `string`       | `"7.7.1"`                          |    no    |
| concourse_version_override                  | Variable to override the default Concourse version. Leave it empty to fallback to `concourse_version`. Useful if you want to default to the module's default but also give the users the option to override it | `string`       | `null`                             |    no    |
| concourse_web_instance_count                | Number of containers running Concourse web                                                                                                                                                                     | `number`       | `1`                                |    no    |
| container_cpu                               | The number of cpu units to reserve for the container. This parameter maps to CpuShares in the Create a container section of the Docker Remote API                                                              | `number`       | `256`                              |    no    |
| container_memory                            | The amount of memory (in MiB) used by the task                                                                                                                                                                 | `number`       | `256`                              |    no    |
| prometheus_cidrs                            | CIDR blocks that'll allowed to access the Prometheus scraper port                                                                                                                                              | `list(string)` | `[]`                               |    no    |
| vault_auth_concourse_role_name              | The Vault role that Concourse will use. This is normally fetched from the `vault-auth` Terraform module                                                                                                        | `string`       | `null`                             |    no    |
| vault_docker_image_tag                      | Docker image version to use for the Vault auth container                                                                                                                                                       | `string`       | `"1.3.2"`                          |    no    |
| vault_server_url                            | The Vault server URL to configure in Concourse. Leaving it empty will disable the Vault integration                                                                                                            | `string`       | `null`                             |    no    |

### Outputs

| Name               | Description                                            |
| ------------------ | ------------------------------------------------------ |
| concourse_hostname | Final Concourse hostname                               |
| concourse_version  | Concourse version deployed                             |
| ecs_service_name   | ECS Service Name of concourse web                      |
| elb_dns_name       | DNS name of the loadbalancer                           |
| elb_sg_id          | Security group id of the loadbalancer                  |
| elb_zone_id        | Zone ID of the ELB                                     |
| iam_role_arn       | ARN of the IAM role created for the Concourse ECS task |

### Examples

You can use `concourse_extra_args` or `concourse_extra_env` to pass any Concourse configuration to the deployment. For example, to add GitLab authentication for a self-hosted instance:

```terraform
concourse_extra_env = {
  CONCOURSE_GITLAB_CLIENT_ID       = "my_client_id",
  CONCOURSE_GITLAB_CLIENT_SECRET   = "my_client_secret",
  CONCOURSE_GITLAB_HOST            = "https://gitlab.example.com",
  # If you want a GitLab group to access the `main` Concourse team:
  CONCOURSE_MAIN_TEAM_GITLAB_GROUP = "my_group"
}
```

## ec2-worker

This sets up a Concourse CI worker pool as EC2 instances running in an Autoscaling group.

The following resources will be created:

* Autoscaling launch configuration & autoscaling group
  * The EC2 instances have an additional EBS volume attached, automatically formatted as `btrfs`
* Security group
* IAM role

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | ~> 3.74 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 3.74 |
| <a name="provider_template"></a> [template](#provider_template) | n/a |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_is_ebs_optimised"></a> [is_ebs_optimised](#module_is_ebs_optimised) | github.com/skyscrapers/terraform-instances//is_ebs_optimised | 3.1.0 |
| <a name="module_teleport_bootstrap_script"></a> [teleport_bootstrap_script](#module_teleport_bootstrap_script) | github.com/skyscrapers/terraform-teleport//teleport-bootstrap-script | 7.2.1 |

### Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.concourse_worker_asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_iam_instance_profile.concourse_worker_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.concourse_worker_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.concourse_worker_cross_account_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.concourse_worker_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_launch_template.concourse_worker_launchtemplate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_launch_template.concourse_worker_launchtemplate_ephemeral](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.worker_instances_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.worker_instances_to_tsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ami.AL2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.concourse_worker_cross_account_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.concourse_worker_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.concourse_worker_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [template_cloudinit_config.concourse_bootstrap](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config) | data source |
| [template_file.check_attachment](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.concourse_bootstrap](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.concourse_systemd](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_concourse_hostname"></a> [concourse_hostname](#input_concourse_hostname) | Hostname on what concourse will be available, this hostname needs to point to the ELB. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input_environment) | The name of the environment these subnets belong to (prod,stag,dev) | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance_type](#input_instance_type) | EC2 instance type for the worker instances | `string` | n/a | yes |
| <a name="input_keys_bucket_arn"></a> [keys_bucket_arn](#input_keys_bucket_arn) | The S3 bucket ARN which contains the SSH keys to connect to the TSA | `string` | n/a | yes |
| <a name="input_keys_bucket_id"></a> [keys_bucket_id](#input_keys_bucket_id) | The S3 bucket id which contains the SSH keys to connect to the TSA | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input_name) | A descriptive name of the purpose of this Concourse worker pool | `string` | n/a | yes |
| <a name="input_ssh_key_name"></a> [ssh_key_name](#input_ssh_key_name) | The key name to use for the instance | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet_ids](#input_subnet_ids) | List of subnet ids where to deploy the worker instances | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id) | The VPC id where to deploy the worker instances | `string` | n/a | yes |
| <a name="input_additional_security_group_ids"></a> [additional_security_group_ids](#input_additional_security_group_ids) | Additional security group ids to attach to the worker instances | `list(string)` | `[]` | no |
| <a name="input_baggageclaim_driver"></a> [baggageclaim_driver](#input_baggageclaim_driver) | Which Concourse Worker baggageclaim driver to use. Supported choices: `btrfs` and `overlay` | `string` | `"overlay"` | no |
| <a name="input_concourse_tags"></a> [concourse_tags](#input_concourse_tags) | List of tags to add to the worker to use for assigning jobs and tasks | `list(string)` | `[]` | no |
| <a name="input_concourse_version"></a> [concourse_version](#input_concourse_version) | Concourse CI version to use. Defaults to the latest tested version | `string` | `"7.7.1"` | no |
| <a name="input_concourse_version_override"></a> [concourse_version_override](#input_concourse_version_override) | Variable to override the default Concourse version. Leave it empty to fallback to `concourse_version`. Useful if you want to default to the module's default but also give the users the option to override it | `string` | `null` | no |
| <a name="input_concourse_worker_instance_count"></a> [concourse_worker_instance_count](#input_concourse_worker_instance_count) | Number of Concourse worker instances | `number` | `1` | no |
| <a name="input_cpu_credits"></a> [cpu_credits](#input_cpu_credits) | The credit option for CPU usage. Can be `standard` or `unlimited` | `string` | `"standard"` | no |
| <a name="input_cross_account_worker_role_arn"></a> [cross_account_worker_role_arn](#input_cross_account_worker_role_arn) | IAM role ARN to assume to access the Concourse keys bucket in another AWS account | `string` | `null` | no |
| <a name="input_custom_ami"></a> [custom_ami](#input_custom_ami) | Use a custom AMI for the worker instances. If omitted the latest Ubuntu 16.04 AMI will be used. | `string` | `null` | no |
| <a name="input_project"></a> [project](#input_project) | Project where the concourse claster belongs to. This is mainly used to identify it in Teleport | `string` | `""` | no |
| <a name="input_public"></a> [public](#input_public) | Whether to assign these worker nodes a public IP (when public subnets are defined in `var.subnet_ids`) | `bool` | `false` | no |
| <a name="input_root_disk_volume_size"></a> [root_disk_volume_size](#input_root_disk_volume_size) | Size of the worker instances root disk | `string` | `"10"` | no |
| <a name="input_root_disk_volume_type"></a> [root_disk_volume_type](#input_root_disk_volume_type) | Volume type of the worker instances root disk | `string` | `"gp2"` | no |
| <a name="input_teleport_auth_token"></a> [teleport_auth_token](#input_teleport_auth_token) | Teleport node token to authenticate with the auth server | `string` | `""` | no |
| <a name="input_teleport_server"></a> [teleport_server](#input_teleport_server) | Teleport auth server hostname | `string` | `""` | no |
| <a name="input_teleport_version"></a> [teleport_version](#input_teleport_version) | Teleport version for the client | `string` | `"10.1.4"` | no |
| <a name="input_work_disk_device_name"></a> [work_disk_device_name](#input_work_disk_device_name) | Device name of the external EBS volume to use as Concourse worker storage | `string` | `"/dev/sdf"` | no |
| <a name="input_work_disk_ephemeral"></a> [work_disk_ephemeral](#input_work_disk_ephemeral) | Whether to use ephemeral volumes as Concourse worker storage. You must use an [`instance_type` that supports this](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/InstanceStorage.html#InstanceStoreDeviceNames) | `string` | `false` | no |
| <a name="input_work_disk_internal_device_name"></a> [work_disk_internal_device_name](#input_work_disk_internal_device_name) | Device name of the internal volume as identified by the Linux kernel, which can differ from `work_disk_device_name` depending on used AMI. Make sure this is set according the `instance_type`, eg. `/dev/xvdf` when using an older AMI | `string` | `"/dev/nvme1n1"` | no |
| <a name="input_work_disk_volume_size"></a> [work_disk_volume_size](#input_work_disk_volume_size) | Size of the external EBS volume to use as Concourse worker storage | `string` | `"100"` | no |
| <a name="input_work_disk_volume_type"></a> [work_disk_volume_type](#input_work_disk_volume_type) | Volume type of the external EBS volume to use as Concourse worker storage | `string` | `"gp2"` | no |
| <a name="input_worker_tsa_port"></a> [worker_tsa_port](#input_worker_tsa_port) | tsa port that the worker can use to connect to the web | `string` | `"2222"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_concourse_version"></a> [concourse_version](#output_concourse_version) | Concourse version deployed |
| <a name="output_worker_autoscaling_group_arn"></a> [worker_autoscaling_group_arn](#output_worker_autoscaling_group_arn) | The AWS region configured in the provider |
| <a name="output_worker_autoscaling_group_id"></a> [worker_autoscaling_group_id](#output_worker_autoscaling_group_id) | The Concourse workers autoscaling group ARN |
| <a name="output_worker_autoscaling_group_name"></a> [worker_autoscaling_group_name](#output_worker_autoscaling_group_name) | The Concourse workers autoscaling group name |
| <a name="output_worker_iam_role"></a> [worker_iam_role](#output_worker_iam_role) | Role name of the worker instances |
| <a name="output_worker_iam_role_arn"></a> [worker_iam_role_arn](#output_worker_iam_role_arn) | Role ARN of the worker instances |
| <a name="output_worker_instances_sg_id"></a> [worker_instances_sg_id](#output_worker_instances_sg_id) | Security group ID used for the worker instances |

### NOTE on the external EBS volume

The EC2 instances created by this module will include an external EBS volume that will automatically be attached and mounted. You should pay special attention to the device name that those volumes will have inside the OS once attached, as that name can vary depending on the instance type you selected. For example, in general for `t2` instances, if you attach the EBS volume as `/dev/xvdf` it'll have the same device name inside the OS, but on `m5` or `c4` instances that's not the case, as it'll be named `/dev/nvme1n1`.

As of now, this situation is not being handled automatically by the module, so depending on the instance type you select, you might have to change the internal device name via the variable `work_disk_internal_device_name`.

## vault-auth

This module sets up the needed Vault resources for Concourse:

* It creates a Vault policy that allows read-only access to `/concourse/*`
* It creates a Vault role in the aws auth method (which should be previously created - explained below) for Concourse and attaches the previously mentioned policy

### Available variables

| Name                        | Description                                                                                                                                             |  Type  | Default  | Required |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | :----: | :------: | :------: |
| additional_vault_policies   | Additional Vault policies to attach to the Concourse role                                                                                               | string | `<list>` |    no    |
| concourse_iam_role_arn      | IAM role ARN of the Concourse ATC server. You can get this from the concourse web module outputs                                                        | string |    -     |   yes    |
| vault_aws_auth_backend_path | The path the AWS auth backend being configured was mounted at                                                                                           | string |  `aws`   |    no    |
| vault_concourse_role_name   | Name to give to the Vault role and policy for Concourse                                                                                                 | string |    -     |   yes    |
| vault_server_url            | The Vault server url                                                                                                                                    | string |    -     |   yes    |
| vault_token_period          | Vault token renewal period, in seconds. This sets the token to never expire, but it still has to be renewed within the duration specified by this value | string | `43200`  |    no    |

### Output

--

### How to enable and configure the AWS auth method

If the AWS auth method is not previously enabled, you'll need to do it before applying this module. To do that you'll need to follow the first two steps described in the [official Vault documentation](https://www.vaultproject.io/docs/auth/aws.html#via-the-cli).

* Enable the auth method
* Configure the AWS credentials so Vault can make calls to the AWS API. Note that you can skip this step if you're going to use Vault's IAM EC2 instance role to access the AWS API.

## Examples

Check out the [examples](examples/) folder.
