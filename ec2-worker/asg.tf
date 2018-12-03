# Get the latest ubuntu ami
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "is_ebs_optimised" {
  source        = "github.com/skyscrapers/terraform-instances//is_ebs_optimised?ref=2.3.5"
  instance_type = "${var.instance_type}"
}

resource "aws_launch_template" "concourse_worker_launchtemplate" {
  count         = "${var.work_disk_ephemeral ? 0 : 1}"
  image_id      = "${length(var.custom_ami) == 0 ? data.aws_ami.ubuntu.id : var.custom_ami}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.ssh_key_name}"
  user_data     = "${data.template_cloudinit_config.concourse_bootstrap.rendered}"
  ebs_optimized = "${module.is_ebs_optimised.is_ebs_optimised}"

  credit_specification {
    cpu_credits = "${var.cpu_credits}"
  }

  network_interfaces {
    security_groups       = ["${concat(list(aws_security_group.worker_instances_sg.id), var.additional_security_group_ids)}"]
    delete_on_termination = true
  }

  iam_instance_profile {
    name = "${aws_iam_instance_profile.concourse_worker_instance_profile.id}"
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_type           = "${var.root_disk_volume_type}"
      volume_size           = "${var.root_disk_volume_size}"
      delete_on_termination = "true"
    }
  }

  # This is the work dir for concourse
  block_device_mappings {
    device_name = "${var.work_disk_device_name}"

    ebs {
      volume_type           = "${var.work_disk_volume_type}"
      volume_size           = "${var.work_disk_volume_size}"
      delete_on_termination = "true"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "concourse_worker_launchtemplate_ephemeral" {
  count         = "${var.work_disk_ephemeral ? 1 : 0}"
  image_id      = "${length(var.custom_ami) == 0 ? data.aws_ami.ubuntu.id : var.custom_ami}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.ssh_key_name}"
  user_data     = "${data.template_cloudinit_config.concourse_bootstrap.rendered}"
  ebs_optimized = "${module.is_ebs_optimised.is_ebs_optimised}"

  credit_specification {
    cpu_credits = "${var.cpu_credits}"
  }

  network_interfaces {
    security_groups = ["${concat(list(aws_security_group.worker_instances_sg.id), var.additional_security_group_ids)}"]
  }

  iam_instance_profile {
    name = "${aws_iam_instance_profile.concourse_worker_instance_profile.id}"
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_type           = "${var.root_disk_volume_type}"
      volume_size           = "${var.root_disk_volume_size}"
      delete_on_termination = "true"
    }
  }

  # This is the work dir for concourse
  block_device_mappings {
    device_name  = "${var.work_disk_device_name}"
    virtual_name = "ephemeral0"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "concourse_worker_asg" {
  name = "concourse_worker_${var.environment}_${var.name}_asg"

  launch_template = {
    id      = "${element(concat(aws_launch_template.concourse_worker_launchtemplate.*.id, aws_launch_template.concourse_worker_launchtemplate_ephemeral.*.id), 0)}"
    version = "$$Latest"
  }

  vpc_zone_identifier = ["${var.subnet_ids}"]
  max_size            = "${var.concourse_worker_instance_count}"
  min_size            = "${var.concourse_worker_instance_count}"
  desired_capacity    = "${var.concourse_worker_instance_count}"

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "concourse_worker_${var.name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "concourse_worker_${var.environment}_${var.name}"
    propagate_at_launch = true
  }
}

data "template_file" "concourse_systemd" {
  template = "${file("${path.module}/concourse_systemd.tpl")}"

  vars {
    concourse_hostname = "${var.concourse_hostname}:${var.worker_tsa_port}"
    tags               = "${join(" ", formatlist("--tag=%s", var.concourse_tags))}"
  }
}

data "template_file" "concourse_bootstrap" {
  template = "${file("${path.module}/bootstrap_concourse.sh.tpl")}"

  vars {
    concourse_version             = "${var.concourse_version}"
    keys_bucket_id                = "${var.keys_bucket_id}"
    cross_account_worker_role_arn = "${var.cross_account_worker_role_arn}"
  }
}

data "template_file" "check_attachment" {
  template = "${file("${path.module}/check_attachment.sh.tpl")}"

  vars {
    work_disk_device_name = "${var.work_disk_device_name}"
  }
}

data "template_cloudinit_config" "concourse_bootstrap" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "package_update: true"
  }

  part {
    content_type = "text/cloud-config"
    content      = "package_upgrade: true"
  }

  part {
    content_type = "text/cloud-config"

    content = <<EOF
packages:
  - awscli
  - jq
EOF
  }

  # Wait for the EBS volume to become ready
  # And format and mount the drive
  part {
    content_type = "text/x-shellscript"
    content      = "${var.work_disk_ephemeral ? "" : data.template_file.check_attachment.rendered}"
  }

  # Format external volume as btrfs
  part {
    content_type = "text/cloud-config"

    content = <<EOF
fs_setup:
  - label: concourseworkdir
    filesystem: 'btrfs'
    device: '${var.work_disk_internal_device_name}'
EOF
  }

  # Mount external volume
  part {
    content_type = "text/cloud-config"

    content = <<EOF
mounts:
  - [ ${var.work_disk_internal_device_name}, /opt/concourse, btrfs, "defaults", "0", "2" ]
EOF
  }

  # Create concourse_worker systemd service file
  part {
    content_type = "text/cloud-config"

    content = <<EOF
write_files:
- encoding: b64
  content: ${base64encode(data.template_file.concourse_systemd.rendered)}
  owner: root:root
  path: /etc/systemd/system/concourse_worker.service
  permissions: '0755'
${module.teleport_bootstrap_script.teleport_config_cloudinit}
${module.teleport_bootstrap_script.teleport_service_cloudinit}
EOF
  }

  # Bootstrap concourse
  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.concourse_bootstrap.rendered}"
  }

  part {
    content_type = "text/x-shellscript"

    content = <<EOF
#!/bin/bash
cd /tmp
curl -L "https://get.gravitational.com/teleport-v${var.teleport_version}-linux-amd64-bin.tar.gz" > ./teleport.tar.gz
sudo tar -xzf ./teleport.tar.gz
sudo ./teleport/install
EOF
  }

  part {
    content_type = "text/x-shellscript"

    content = "${module.teleport_bootstrap_script.teleport_bootstrap_script}"
  }
}

module "teleport_bootstrap_script" {
  source      = "github.com/skyscrapers/terraform-teleport//teleport-bootstrap-script?ref=3.3.5"
  auth_server = "${var.teleport_server}"
  auth_token  = "${var.teleport_auth_token}"
  function    = "concourse"
  environment = "${var.environment}"
  project     = "${var.project}"

  additional_labels = [
    "concourse_version: \"${var.concourse_version}\"",
    "instance_type: \"${var.instance_type}\"",
  ]
}
