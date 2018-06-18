variable "environment" {
  description = "The name of the environment these subnets belong to (prod,stag,dev)"
}

variable "name" {
  description = "The name of the Concourse deployment, used to distinguish different Concourse setups"
}

variable "aws_profile" {
  description = "This is the AWS profile name as set in the shared credentials file. Used to upload the Concourse keys to S3. Omit this if you're using environment variables."
  default     = ""
}

variable "concourse_keys_version" {
  description = "Change this if you want to re-generate Concourse keys"
  default     = "1"
}

variable "concourse_workers_iam_role_arns" {
  type        = "list"
  description = "List of ARNs for the IAM roles that will be able to assume the role to access concourse keys in S3. Normally you'll include the Concourse worker IAM role here"
}
