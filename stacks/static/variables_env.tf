variable "cidr_block" {
  type = "map"

  default = {
    test = "10.29.0.0/16"
  }
}

variable "rds_password" {
  type = "map"

  default = {
    test = "concoursetest"
  }
}

variable "rds_storage_encrypted" {
  type = "map"

  default = {
    test = false
  }
}
