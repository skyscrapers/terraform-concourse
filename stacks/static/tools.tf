module "tools" {
  source        = "github.com/skyscrapers/terraform-instances//bastion?ref=20961b3adc785fac8ae1e3bcf11a8e85a8a177b8"
  vpc_id        = "${module.vpc.vpc_id}"
  project       = "${var.project}"
  environment   = "${terraform.env}"
  sg_all_id     = "${module.general_security_groups.sg_all_id}"
  sgs           = ["${module.general_security_groups.sg_all_id}"]
  subnets       = "${module.vpc.public_nat-bastion}"
  ssh_key_name  = "mattias"
  ami           = "ami-c0cff0a6"
  instance_type = "t2.micro"
  name          = "tools"
  user_data     = "${module.tools_userdata.user_datas[0]}"
}

module "tools_userdata" {
  source              = "github.com/skyscrapers/terraform-skyscrapers//puppet-userdata?ref=1.0.0"
  amount_of_instances = "1"
  environment         = "${terraform.env}"
  customer            = "${var.customer}"
  function            = "tools"
  project             = "${var.project}"
}

resource "aws_security_group_rule" "sg_tools_ssh" {
  security_group_id = "${module.tools.bastion_sg_id}"
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sg_tools_postgres" {
  security_group_id        = "${module.tools.bastion_sg_id}"
  type                     = "egress"
  from_port                = "5432"
  to_port                  = "5432"
  protocol                 = "tcp"
  source_security_group_id = "${module.postgres.rds_sg_id}"
}

resource "aws_security_group_rule" "sg_tools_puppet" {
  security_group_id = "${module.tools.bastion_sg_id}"
  type              = "egress"
  from_port         = "8140"
  to_port           = "8140"
  protocol          = "tcp"
  cidr_blocks       = ["176.58.117.244/32"]
}
