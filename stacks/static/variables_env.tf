variable "cidr_block" {
  type = "map"

  default = {
    test = "10.29.0.0/16"
  }
}

variable "alb_ssl_certificate" {
  type = "map"

  default = {
    test = "arn:aws:acm:eu-west-1:847239549153:certificate/cf89435a-0af0-49e8-a249-94e823c94d3f"
  }
}
