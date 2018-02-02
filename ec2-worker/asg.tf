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

resource "aws_launch_configuration" "concourse_worker_launchconfig" {
  image_id             = "${length(var.custom_ami) == 0 ? data.aws_ami.ubuntu.id : var.custom_ami}"
  instance_type        = "${var.instance_type}"
  key_name             = "${var.ssh_key_name}"
  security_groups      = ["${concat(list(aws_security_group.worker_instances_sg.id), var.additional_security_group_ids)}"]
  iam_instance_profile = "${aws_iam_instance_profile.concourse_worker_instance_profile.id}"
  user_data            = "${data.template_cloudinit_config.concourse_bootstrap.rendered}"

  root_block_device {
    volume_type           = "${var.root_disk_volume_type}"
    volume_size           = "${var.root_disk_volume_size}"
    delete_on_termination = "true"
  }

  # This is the work dir for concourse
  ebs_block_device {
    device_name           = "${var.work_disk_device_name}"
    volume_type           = "${var.work_disk_volume_type}"
    volume_size           = "${var.work_disk_volume_size}"
    delete_on_termination = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "concourse_worker_asg" {
  name                 = "concourse_worker_${var.environment}_${var.name}_asg"
  launch_configuration = "${aws_launch_configuration.concourse_worker_launchconfig.id}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  max_size             = "${var.concourse_worker_instance_count}"
  min_size             = "${var.concourse_worker_instance_count}"
  desired_capacity     = "${var.concourse_worker_instance_count}"

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
    concourse_hostname = "${var.concourse_hostname}"
    concourse_tag      = "${var.concourse_tag}"
  }
}

data "template_file" "concourse_bootstrap" {
  template = "${file("${path.module}/bootstrap_concourse.sh.tpl")}"

  vars {
    concourse_version = "${var.concourse_version}"
    keys_bucket_id    = "${var.keys_bucket_id}"
    TSA_ACCOUNT_ID    = "${var.tsa_account_id}"
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

    content = <<EOF
#!/bin/bash
aws --region $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//') ec2 wait volume-in-use --filters Name=attachment.instance-id,Values=$(curl -s http://169.254.169.254/latest/meta-data/instance-id) Name=attachment.device,Values=${var.work_disk_device_name}
EOF
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
EOF
  }

  # Bootstrap concourse
  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.concourse_bootstrap.rendered}"
  }
}
