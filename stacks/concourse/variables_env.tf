variable "concourse_external_url" {
  type = "map"

  default = {
    test = "https://test.concourse.skyscrape.rs"
  }
}

variable "concourse_db_username" {
  type = "map"

  default = {
    test = "concourse"
  }
}

variable "concourse_db_password" {
  type = "map"

  default = {
    test = "changeme"
  }
}

variable "concourse_db_name" {
  type = "map"

  default = {
    test = "concourse"
  }
}

variable "concourse_auth_username" {
  type = "map"

  default = {
    test = "concourse"
  }
}

variable "concourse_auth_password" {
  type = "map"

  default = {
    test = "concourse"
  }
}
