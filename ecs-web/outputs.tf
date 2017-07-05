output "elb_dns_name" {
  value = "${module.elb.elb_dns_name}"
}

output "elb_sg_id" {
  value = "${module.elb.sg_id}"
}
