module "vpc" {
  source                            = "github.com/skyscrapers/terraform-network//vpc?ref=4.0.0"
  cidr_block                        = var.cidr_block
  environment                       = "test"
  project                           = var.project
  amount_private_management_subnets = 2
}

module "nat_gateway" {
  source               = "github.com/skyscrapers/terraform-network//nat_gateway?ref=4.0.0"
  private_route_tables = module.vpc.private_rts
  public_subnets       = module.vpc.public_nat-bastion
}

