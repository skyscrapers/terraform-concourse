# Tests

This folder contains automated tests for this module. All of the tests are written in [Go](https://golang.org/). Most of these are "integration tests" that deploy real infrastructure using Terraform and verify that infrastructure works as expected using a helper library called [Terratest](https://github.com/gruntwork-io/terratest).

## WARNING WARNING WARNING

**Note #1**: Many of these tests create real resources in an AWS account and then try to clean those resources up at the end of a test run. That means these tests may cost you money to run! When adding tests, please be considerate of the resources you create and take extra care to clean everything up when you're done!

**Note #2**: Never forcefully shut the tests down (e.g. by hitting `CTRL + C`) or the cleanup tasks won't run!

**Note #3**: We set `-timeout 60m` on all tests not because they necessarily take that long, but because Go has a default test timeout of 10 minutes, after which it forcefully kills the tests with a `SIGQUIT`, preventing the cleanup tasks from running. Therefore, we set an overlying long timeout to make sure all tests have enough time to finish and clean up.

**Note #4**: These tests will run automatically on every Pull Request that has the `to-test` label attached. The Pull Request status will be automatically updated with the result of the tests.

## Running the tests

### Pre-existing resources

These tests expect some AWS resources to be already there to be able to run properly. Those are mostly resources that are not easy to create automatically:

- An ACM certificate for the ELB
  - You need to provide it to the test as an environment variable `TEST_ACM_ARN`

### Prerequisites

You can either run Terratest locally or through Docker. If you decide to run it without Docker, you'll need to install the following in your computer:

- Install the latest version of [Go](https://golang.org/).
- Install [dep](https://github.com/golang/dep) for Go dependency management.
- Install [Terraform](https://www.terraform.io/downloads.html).

Also, you'll obviously need access to an AWS account, if you're using Terratest directly (without Docker), you can configure your AWS credentials using one of the [options supported by the AWS SDK](http://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html). If you're using Docker to run Terratest, you'll have to provide your AWS credentials through environment variables, as shown in the examples below.

### One-time setup

Setup the test Docker image:

```bash
cd test
docker build -t terraform-concourse-test .
docker run --rm terraform-concourse-test dep ensure
```

### Run all the tests

**Note** that all the examples below assume that you are in the root of the `terraform-concourse` project folder.

```bash
export TEST_CONCOURSE_VERSION="6.4.0"
export TEST_ACM_ARN="arn:aws:acm:eu-west-1:1234567890:certificate/uev7722-434t-55g7-86ba-a882d9da1fa5"
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...
docker run --rm -e TEST_CONCOURSE_VERSION -e TEST_ACM_ARN -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN -v $PWD:/go/src/github.com/skyscrapers/terraform-concourse terraform-concourse-test go test -v -timeout 60m
```

*Note:* add `SKIP_deploy` and or `SKIP_teardown` to skip the terraform deploy and or destroy step of the tests

You can also run the tests remotely in Concourse. *Of course you need access to a Concourse server to do this*

```bash
export TEST_CONCOURSE_VERSION="6.4.0"
export TEST_ACM_ARN="arn:aws:acm:eu-west-1:1234567890:certificate/uev7722-434t-55g7-86ba-a882d9da1fa5"
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...
fly -t your_target execute --config ci/run_tests.yaml -i terraform-src=$PWD
```

### Run a specific test

To run a specific test called `TestFoo`:

```bash
export TEST_CONCOURSE_VERSION="6.4.0"
export TEST_ACM_ARN="arn:aws:acm:eu-west-1:1234567890:certificate/uev7722-434t-55g7-86ba-a882d9da1fa5"
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...
docker run --rm -e TEST_CONCOURSE_VERSION -e TEST_ACM_ARN -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN -v $PWD:/go/src/github.com/skyscrapers/terraform-concourse terraform-concourse-test go test -v -timeout 60m -run TestFoo
```
