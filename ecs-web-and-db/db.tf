data "aws_kms_secret" "concourse_db_passwords" {
  secret {
    name    = "root_password"
    payload = "${var.rds_root_password}"

    context {
      postgresql = "password"
    }
  }

  secret {
    name    = "concourse_password"
    payload = "${var.concourse_db_password}"

    context {
      postgresql = "password"
    }
  }
}

provider "postgresql" {
  host     = "localhost"
  port     = "5432"
  username = "root"
  password = "${data.aws_kms_secret.concourse_db_passwords.root_password}"
  sslmode  = "require"
}

resource "postgresql_role" "concourse" {
  provider = "postgresql"
  name     = "${var.concourse_db_username}"
  login    = true
  password = "${data.aws_kms_secret.concourse_db_passwords.concourse_password}"
}

resource "postgresql_database" "concourse" {
  provider = "postgresql"
  name     = "${var.concourse_db_name}"
  owner    = "${postgresql_role.concourse.name}"
}