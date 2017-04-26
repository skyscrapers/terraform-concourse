variable "ecs_instances_desired" {
  type = "map"

  default = {
    test = "1"
  }
}

variable "ecs_instances_maximum" {
  type = "map"

  default = {
    test = "3"
  }
}

variable "ecs_instance_type" {
  type = "map"

  default = {
    test = "t2.small"
  }
}
