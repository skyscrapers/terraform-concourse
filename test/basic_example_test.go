package test

import (
	"testing"
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/logger"

	"github.com/stretchr/testify/assert"

	"github.com/skyscrapers/terraform-concourse/test/fly"
)

var (
	flyBinaryPath = getenv("TEST_FLY_PATH", "fly")
	flyTargetName = "test"
)

func getenv(key, fallback string) string {
	value := os.Getenv(key)
	if len(value) == 0 {
		return fallback
	}
	return value
}

// An example of how to test the simple Terraform module in examples/basic using Terratest.
func TestBasicExample(t *testing.T) {
	// The path to where our Terraform code is located
	exampleFolder := "../examples/basic"

	defer test_structure.RunTestStage(t, "teardown", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleFolder)
		// At the end of the test, run `terraform destroy` to clean up any resources that were created
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		uniqueId := strings.ToLower(random.UniqueId())
		projectName := fmt.Sprintf("concourse-%s", uniqueId)

		terraformOptions := &terraform.Options{
			TerraformDir: exampleFolder,

			// Variables to pass to our Terraform code using -var options
			Vars: map[string]interface{}{
				"elb_ssl_certificate_id": os.Getenv("TEST_ACM_ARN"),
				"concourse_version": os.Getenv("TEST_CONCOURSE_VERSION"),
				"key_name": os.Getenv("TEST_KEY_NAME"),
				"project": projectName,
			},

			EnvVars: map[string]string{
				"AWS_DEFAULT_REGION": "eu-west-1",
			},
		}

		test_structure.SaveTerraformOptions(t, exampleFolder, terraformOptions)

		// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleFolder)
		validate(t, terraformOptions)
	})
}

func validate(t *testing.T, terraformOptions *terraform.Options) {
	var flyCommand fly.Command

	concourse_hostname := terraform.Output(t, terraformOptions, "concourse_hostname")
	concourse_user := terraform.Output(t, terraformOptions, "concourse_local_user_username")
	concourse_pass := terraform.Output(t, terraformOptions, "concourse_local_user_password")

	flyCommand = fly.NewCommand(flyTargetName, t, flyBinaryPath)

	loginInConcourse(t, flyCommand, concourse_hostname, "main", concourse_user, concourse_pass, true)
	validateWorkers(t, flyCommand, 2)
	setPipeline(t, flyCommand, "test", "./test_pipeline.yaml", make([]string, 0))
}

func loginInConcourse(t *testing.T, flyCommand fly.Command, concourse_hostname string, concourse_team string, concourse_user string, concourse_pass string, insecure bool) {
	logger.Logf(t, "Logging into Concourse server %s, team %s, username %s", concourse_hostname, concourse_team, concourse_user)

	maxRetries := 30
	sleepBetweenRetries := 10 * time.Second

	flyCommand.LoginRetry(fmt.Sprintf("https://%s", concourse_hostname), concourse_team, concourse_user, concourse_pass, insecure, maxRetries, sleepBetweenRetries)
}

func validateWorkers(t *testing.T, flyCommand fly.Command, workersCount int) {
	logger.Logf(t, "Check that there are %d running workers attached to Concourse", workersCount)
	workers := flyCommand.Workers()

	for _, w := range workers {
		assert.Equal(t, "running", w.State, fmt.Sprintf("worker %s should be running", w.Name))
	}

	assert.Equal(t, workersCount, len(workers), fmt.Sprintf("there should be %d running workers", workersCount))
}

func setPipeline(t *testing.T, flyCommand fly.Command, pipeline_name string, configFilePath string, varsFilePaths []string) {
	logger.Logf(t, "Setting pipeline %s in Concourse", pipeline_name)
	flyCommand.SetPipeline(pipeline_name, configFilePath, varsFilePaths)
	flyCommand.UnpausePipeline(pipeline_name)
}
