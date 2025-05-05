package test

import (
	"encoding/json"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformExample(t *testing.T) {
	// Arrange
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/s3-origin/.",
	}
	defer terraform.Destroy(t, terraformOptions)

	// Act
	terraform.InitAndApply(t, terraformOptions)

	// Assert
	assert := assert.New(t)

	
	// outputValue := terraform.Output(t, terraformOptions, "cloudfront_domain_name")

	// assert.NotNil(outputValue)

	// Use OutputJson to get raw JSON string
	rawOutput := terraform.OutputJson(t, terraformOptions, "cloudfront_domain_name")

	// Unmarshal the JSON string into a Go string
	var domain string
	err := json.Unmarshal([]byte(rawOutput), &domain)

	// Validate
	assert.NoError(err, "Failed to unmarshal cloudfront_domain_name output")
	assert.NotEmpty(domain, "Expected a non-empty CloudFront domain name")
}
