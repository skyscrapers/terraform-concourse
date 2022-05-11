
terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/vault"
      version = "~> 3.5"
    }
  }
}
