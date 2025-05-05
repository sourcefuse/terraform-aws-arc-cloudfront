package test

import (
	"fmt"
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

	
	fmt.Println("CloudFront domain map:", terraform.OutputMap(t, terraformOptions, "cloudfront_domain_name"))
	// outputValue := terraform.Output(t, terraformOptions, "cloudfront_domain_name")
	// outputValue := terraform.OutputMap(t, terraformOptions, "cloudfront_domain_name")["0"]
	outputs := terraform.OutputMap(t, terraformOptions, "cloudfront_domain_name")
	domain := outputs["0"]

	assert.NotNil(outputValue)
}
