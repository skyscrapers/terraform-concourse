package test

import (
	"crypto/tls"
	"fmt"
	"io"
	"net/http"
	"os"
	"runtime"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"

	"github.com/skyscrapers/terraform-concourse/test/fly"
)

var (
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
		uniqueID := strings.ToLower(random.UniqueId())
		projectName := fmt.Sprintf("concourse-%s", uniqueID)

		terraformOptions := &terraform.Options{
			TerraformDir: exampleFolder,

			// Variables to pass to our Terraform code using -var options
			Vars: map[string]interface{}{
				"elb_ssl_certificate_id": os.Getenv("TEST_ACM_ARN"),
				"concourse_version":      os.Getenv("TEST_CONCOURSE_VERSION"),
				"key_name":               os.Getenv("TEST_KEY_NAME"),
				"project":                projectName,
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

	concourseHostname := terraform.Output(t, terraformOptions, "concourse_hostname")
	concourseUser := terraform.Output(t, terraformOptions, "concourse_local_user_username")
	concoursePass := terraform.Output(t, terraformOptions, "concourse_local_user_password")

	flyBinaryPath := fmt.Sprintf("/tmp/fly-%s", terraformOptions.Vars["project"])

	downloadFly(t, concourseHostname, flyBinaryPath)

	flyCommand = fly.NewCommand(flyTargetName, t, flyBinaryPath)

	loginInConcourse(t, flyCommand, concourseHostname, "main", concourseUser, concoursePass, true)
	validateWorkers(t, flyCommand, 2)
	setPipeline(t, flyCommand, "test", "./test_pipeline.yaml", make([]string, 0))
}

func loginInConcourse(t *testing.T, flyCommand fly.Command, concourseHostname string, concourseTeam string, concourseUser string, concoursePass string, insecure bool) {
	logger.Logf(t, "Logging into Concourse server %s, team %s, username %s", concourseHostname, concourseTeam, concourseUser)

	maxRetries := 30
	sleepBetweenRetries := 10 * time.Second

	flyCommand.LoginRetry(fmt.Sprintf("https://%s", concourseHostname), concourseTeam, concourseUser, concoursePass, insecure, maxRetries, sleepBetweenRetries)
}

func validateWorkers(t *testing.T, flyCommand fly.Command, workersCount int) {
	maxRetries := 30
	sleepBetweenRetries := 10 * time.Second

	retry.DoWithRetry(t, "Validating concourse workers", maxRetries, sleepBetweenRetries, func() (string, error) {
		workers := flyCommand.Workers()

		if len(workers) != workersCount {
			return "", fmt.Errorf("the number of running workers (%d) doesn't match the expected value (%d)", len(workers), workersCount)
		}

		logger.Logf(t, "correct number of running workers found: %d", len(workers))

		for _, w := range workers {
			if w.State != "running" {
				return "", fmt.Errorf("worker %s is not in the 'running' state (%s)", w.Name, w.State)
			}
		}

		return "", nil
	})
}

func setPipeline(t *testing.T, flyCommand fly.Command, pipelineName string, configFilePath string, varsFilePaths []string) {
	logger.Logf(t, "Setting pipeline %s in Concourse", pipelineName)
	flyCommand.SetPipeline(pipelineName, configFilePath, varsFilePaths)
	flyCommand.UnpausePipeline(pipelineName)
}

func downloadFly(t *testing.T, concourseHostname string, flyBinaryPath string) {
	maxRetries := 30
	sleepBetweenRetries := 10 * time.Second

	retry.DoWithRetry(t, "Downloading fly cli", maxRetries, sleepBetweenRetries, func() (string, error) {
		// Get the data
		tr := &http.Transport{
			TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
		}
		client := &http.Client{Transport: tr}
		resp, err := client.Get(fmt.Sprintf("https://%s/api/v1/cli?arch=%s&platform=%s", concourseHostname, runtime.GOARCH, runtime.GOOS))
		if err != nil {
			return "", err
		}
		defer resp.Body.Close()

		// Create the file
		out, err := os.Create(flyBinaryPath)
		if err != nil {
			return "", err
		}
		defer out.Close()

		// Set file executable
		err = os.Chmod(flyBinaryPath, 0755)
		if err != nil {
			return "", err
		}

		// Write the body to file
		_, err = io.Copy(out, resp.Body)
		return "", err
	})
}
