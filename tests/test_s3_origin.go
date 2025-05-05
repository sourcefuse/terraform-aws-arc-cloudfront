package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestCloudFrontWithAcm(t *testing.T) {
	t.Parallel()

	// Arrange
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/s3-origin",
	}

	defer terraform.Destroy(t, terraformOptions)

	// Act
	terraform.InitAndApply(t, terraformOptions)

	// Assert
	acmArn := terraform.Output(t, terraformOptions, "acm_certificate_arn")

	// Validate the output is not empty and contains expected values
	assert.NotEmpty(t, acmArn)
	assert.Contains(t, acmArn, "arn:aws:acm:us-east-1")
	assert.Contains(t, acmArn, "certificate/")
}
