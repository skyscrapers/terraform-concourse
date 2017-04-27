# Concourse

The test environment is deployed in `19) 847239549153 Skyscraperstest (For internal dev and tests)`

## Usage

### Export AWS keys

If you don't have any AWS keys setup for the Test account, then do this:
```
export AWS_ACCESS_KEY_ID=<aws_access_key>
export AWS_SECRET_ACCESS_KEY=<aws_secret_access_key>
export AWS_SESSION_TOKEN=<aws_session_token>
export AWS_DEFAULT_REGION=eu-west-1
```

### Config remote state

You only need to do this once. Test is already using the new remote state backends
from Terraform 0.9. The only command needed is this:

```
terraform init
```

### Select the correct environment

If you want to apply changes, you first have to select the correct environment:

```
$ terraform env select [staging|production]
```

To see the available environments:

```
$ terraform env list
```

### Run
```
terraform plan -out terraform.plan
```
If changes and you want to apply them:
```
terraform apply terraform.plan
```
