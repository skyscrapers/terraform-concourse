output "elb_dns_name" {
  value = "${module.elb.elb_dns_name}"
}

output "keys_bucket_id" {
  value = "${aws_s3_bucket.concourse_keys.id}"
}

output "keys_bucket_arn" {
  value = "${aws_s3_bucket.concourse_keys.arn}"
}
