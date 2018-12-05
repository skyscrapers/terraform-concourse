package fly

import (
	"testing"
	"bytes"
	"encoding/json"
	"fmt"
	"os/exec"
	"time"

	"crypto/tls"
	"net/http"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/retry"
)

//go:generate counterfeiter . Command

type Command interface {
	Login(url string, teamName string, username string, password string, insecure bool) []byte
	LoginRetry(url string, teamName string, username string, password string, insecure bool, maxRetries int, sleepBetweenRetries time.Duration) []byte
	LoginE(url string, teamName string, username string, password string, insecure bool) ([]byte, error)
	Pipelines() []string
	PipelinesE() ([]string, error)
	Workers() []worker
	WorkersE() ([]worker, error)
	GetPipeline(pipelineName string) []byte
	GetPipelineE(pipelineName string) ([]byte, error)
	SetPipeline(pipelineName string, configFilepath string, varsFilepaths []string) []byte
	SetPipelineE(pipelineName string, configFilepath string, varsFilepaths []string) ([]byte, error)
	DestroyPipeline(pipelineName string) []byte
	DestroyPipelineE(pipelineName string) ([]byte, error)
	UnpausePipeline(pipelineName string) []byte
	UnpausePipelineE(pipelineName string) ([]byte, error)
}

type worker struct {
	Name string `json:"name"`
	State string `json:"state"`
}

type command struct {
	target        string
	t             *testing.T
	flyBinaryPath string
}

func NewCommand(target string, t *testing.T, flyBinaryPath string) Command {
	return &command{
		target:        target,
		t:             t,
		flyBinaryPath: flyBinaryPath,
	}
}

func (f command) LoginRetry(
	url string,
	teamName string,
	username string,
	password string,
	insecure bool,
	maxRetries int,
	sleepBetweenRetries time.Duration,
) []byte {
	return retry.DoWithRetry(f.t, "Logging into Concourse", maxRetries, sleepBetweenRetries, func() (string, error) {
		out, err := f.LoginE(url, teamName, username, password, insecure)
		return string(out), err
	})
}

func (f command) Login(
	url string,
	teamName string,
	username string,
	password string,
	insecure bool,
) []byte {
	output, err := f.LoginE(url, teamName, username, password, insecure)
	if err != nil {
		f.t.Fatal(err)
	}

	return output
}

func (f command) LoginE(
	url string,
	teamName string,
	username string,
	password string,
	insecure bool,
) ([]byte, error) {
	args := []string{
		"login",
		"-c", url,
		"-n", teamName,
	}

	if username != "" && password != "" {
		args = append(args, "-u", username, "-p", password)
	}

	if insecure {
		args = append(args, "-k")
		tr := &http.Transport{
			TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
			Proxy:           http.ProxyFromEnvironment,
		}
		http.DefaultClient.Transport = tr
	}

	loginOut, err := f.run(args...)
	if err != nil {
		return nil, err
	}

	syncOut, err := f.run("sync")
	if err != nil {
		return nil, err
	}

	return append(loginOut, syncOut...), nil
}

func (f command) Pipelines() []string {
	pipelines, err := f.PipelinesE()
	if err != nil {
		f.t.Fatal(err)
	}

	return pipelines
}

func (f command) PipelinesE() ([]string, error) {
	psOut, err := f.run("pipelines", "--json")
	if err != nil {
		return nil, err
	}

	var ps []struct {
		Name string `json:"name"`
	}

	err = json.Unmarshal(psOut, &ps)
	if err != nil {
		return nil, err
	}

	names := make([]string, len(ps))
	for i, p := range ps {
		names[i] = p.Name
	}

	return names, nil
}

func (f command) Workers() []worker {
	workers, err := f.WorkersE()
	if err != nil {
		f.t.Fatal(err)
	}

	return workers
}

func (f command) WorkersE() ([]worker, error) {
	wsOut, err := f.run("workers", "--json")
	if err != nil {
		return nil, err
	}

	var ws []worker

	err = json.Unmarshal(wsOut, &ws)
	if err != nil {
		return nil, err
	}

	return ws, nil
}

func (f command) GetPipeline(pipelineName string) []byte {
	output, err := f.GetPipelineE(pipelineName)
	if err != nil {
		f.t.Fatal(err)
	}

	return output
}

func (f command) GetPipelineE(pipelineName string) ([]byte, error) {
	return f.run(
		"get-pipeline",
		"-p", pipelineName,
	)
}

func (f command) SetPipeline(
	pipelineName string,
	configFilepath string,
	varsFilepaths []string,
) []byte {
	output, err := f.SetPipelineE(pipelineName, configFilepath, varsFilepaths)
	if err != nil {
		f.t.Fatal(err)
	}

	return output
}

func (f command) SetPipelineE(
	pipelineName string,
	configFilepath string,
	varsFilepaths []string,
) ([]byte, error) {
	allArgs := []string{
		"set-pipeline",
		"-n",
		"-p", pipelineName,
		"-c", configFilepath,
	}

	for _, vf := range varsFilepaths {
		allArgs = append(allArgs, "-l", vf)
	}

	return f.run(allArgs...)
}

func (f command) UnpausePipeline(pipelineName string) []byte {
	output, err := f.UnpausePipelineE(pipelineName)
	if err != nil {
		f.t.Fatal(err)
	}

	return output
}

func (f command) UnpausePipelineE(pipelineName string) ([]byte, error) {
	return f.run(
		"unpause-pipeline",
		"-p", pipelineName,
	)
}

func (f command) DestroyPipeline(pipelineName string) []byte {
	output, err := f.DestroyPipelineE(pipelineName)
	if err != nil {
		f.t.Fatal(err)
	}

	return output
}

func (f command) DestroyPipelineE(pipelineName string) ([]byte, error) {
	return f.run(
		"destroy-pipeline",
		"-n",
		"-p", pipelineName,
	)
}

func (f command) run(args ...string) ([]byte, error) {
	if f.target == "" {
		return nil, fmt.Errorf("target cannot be empty in command.run")
	}

	defaultArgs := []string{
		"-t", f.target,
	}
	allArgs := append(defaultArgs, args...)
	cmd := exec.Command(f.flyBinaryPath, allArgs...)

	outbuf := bytes.NewBuffer(nil)
	errbuf := bytes.NewBuffer(nil)

	cmd.Stdout = outbuf
	cmd.Stderr = errbuf

	logger.Logf(f.t,"Starting fly command: %v\n", allArgs)
	err := cmd.Start()
	if err != nil {
		// If the command was never started, there will be nothing in the buffers
		return nil, err
	}

	logger.Logf(f.t, "Waiting for fly command: %v\n", allArgs)
	err = cmd.Wait()
	if err != nil {
		if len(errbuf.Bytes()) > 0 {
			err = fmt.Errorf("%v - %s", err, string(errbuf.Bytes()))
		}
		return outbuf.Bytes(), err
	}

	return outbuf.Bytes(), nil
}
