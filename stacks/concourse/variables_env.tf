variable "concourse_external_url" {
  type = "map"

  default = {
    test = "test.concourse.skyscrape.rs"
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

variable "concourse_github_auth_client_id" {
  type = "map"

  default = {
    test = "1e30430a800c305ecffe"
  }
}

variable "concourse_github_auth_client_secret_encrypted" {
  type = "map"

  default = {
    test = "AQECAHgH2b5PjCRhJwn6otng6Sln2gyey9L+02YYTwotEL3JQAAAAIcwgYQGCSqGSIb3DQEHBqB3MHUCAQAwcAYJKoZIhvcNAQcBMB4GCWCGSAFlAwQBLjARBAzJbtzpQrtLut3PzaECARCAQ5n+iAUDMEDnlQ1aKuK/1P5adDJUgt4H33ABVFis4FqvEnCh7v+ZVxjgXEoYkrmMYj3E3xQYnTNlNUxB1hLCoUM485E="
  }
}

variable "concourse_github_auth_team" {
  type = "map"

  default = {
    test = "skyscrapers/skyscrapers"
  }
}

variable "elb_ssl_certificate" {
  type = "map"

  default = {
    test = "arn:aws:acm:eu-west-1:847239549153:certificate/cf89435a-0af0-49e8-a249-94e823c94d3f"
  }
}
