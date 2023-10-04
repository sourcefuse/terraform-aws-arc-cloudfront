// Refer : https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html
locals {
  managed_response_header_policies = {
    "CORS-and-SecurityHeadersPolicy"                = "e61eb60c-9c35-4d20-a928-2b84e02af89c"
    "CORS-With-Preflight"                           = "5cc3b908-e619-4b99-88e5-2cf7f45965bd"
    "CORS-with-preflight-and-SecurityHeadersPolicy" = "eaab4381-ed33-4a86-88ca-d9558dc6cd63"
    "SecurityHeadersPolicy"                         = "67f7725c-6f97-4210-82d7-5512b31e9d03"
    "SimpleCORS"                                    = "60669652-455b-4ae9-85a4-c4c02393f86c"
  }
}
