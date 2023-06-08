// Refer : https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-origin-request-policies.html
locals {
  managed_origin_request_policies = {
    "AllViewer"                                   = "216adef6-5c7f-47e4-b989-5492eafa07d3"
    "AllViewerAndCloudFrontHeaders-2022-06"       = "33f36d7e-f396-46d9-90e0-52428a34d9dc"
    "AllViewerExceptHostHeader"                   = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
    "CORS-CustomOrigin"                           = "59781a5b-3903-41f3-afcb-af62929ccde1"
    "CORS-S3Origin"                               = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
    "Elemental-MediaTailor-PersonalizedManifests" = "775133bc-15f2-49f9-abea-afb2e0bf67d2"
    "UserAgentRefererHeaders"                     = "acba4595-bd28-49b8-b9fe-13317c0390fa"
  }
}
