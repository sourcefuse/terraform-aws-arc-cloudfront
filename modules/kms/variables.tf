variable "deletion_window_in_days" {
  type        = number
  default     = 30
  description = "Duration in days after which the key is deleted after destruction of the resource"
}

variable "enable_key_rotation" {
  type        = bool
  default     = true
  description = "Specifies whether key rotation is enabled"
}

variable "description" {
  type        = string
  default     = "Parameter Store KMS master key"
  description = "The description of the key as viewed in AWS console"
}

variable "alias" {
  type        = string
  description = "Name/Alias to assign to the KMS key"
}

variable "key_usage" {
  type        = string
  default     = "ENCRYPT_DECRYPT"
  description = "Specifies the intended use of the key. Valid values: `ENCRYPT_DECRYPT` or `SIGN_VERIFY`."
}

variable "customer_master_key_spec" {
  type        = string
  default     = "SYMMETRIC_DEFAULT"
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: `SYMMETRIC_DEFAULT`, `RSA_2048`, `RSA_3072`, `RSA_4096`, `ECC_NIST_P256`, `ECC_NIST_P384`, `ECC_NIST_P521`, or `ECC_SECG_P256K1`."
}

variable "multi_region" {
  type        = bool
  default     = false
  description = "Indicates whether the KMS key is a multi-Region (true) or regional (false) key."
}

variable "kms_key_administrators" {
  type        = list(string)
  description = "List of AWS arns that will have full controll over the kms key"
  default     = []
}

variable "kms_key_users" {
  type        = list(string)
  description = "List of AWS arns that will have permissions to use kms key"
  default     = []
}

variable "aws_services" {
  type        = list(string)
  description = "List of AWS services for accessing KMS key , eg : sns.amazonaws.com"
  default     = []
}

variable "key_policy" {
  type        = any
  description = "KMS key policy"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags for KMS key"
  default     = {}
}

variable "environment" {
  type        = string
  description = "Environment name"
}
