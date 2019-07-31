output "keys_bucket_id" {
  value       = aws_s3_bucket.concourse_keys.id
  description = "The id (name) of the S3 bucket where the concourse keys are stored"
}

output "keys_bucket_arn" {
  value       = aws_s3_bucket.concourse_keys.arn
  description = "The ARN of the S3 bucket where the concourse keys are stored"
}

output "concourse_keys_cross_account_role_arn" {
  value       = aws_iam_role.concourse_keys_cross_account.arn
  description = "IAM role ARN that Concourse workers on other AWS accounts will need to assume to access the Concourse keys bucket"
}

