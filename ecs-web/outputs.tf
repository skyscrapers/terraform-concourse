output "elb_dns_name" {
  value = "${module.elb.elb_dns_name}"
}

output "elb_zone_id" {
  value = "${module.elb.elb_zone_id}"
}

output "elb_sg_id" {
  value = "${module.elb.sg_id}"
}
