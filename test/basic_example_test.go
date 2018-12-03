package test

import (
	"testing"
	"fmt"
	"os"
	"strings"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

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

	// test_structure.RunTestStage(t, "validate", func() {
		// initializeAndUnsealVaultCluster(t)
	// })
}
