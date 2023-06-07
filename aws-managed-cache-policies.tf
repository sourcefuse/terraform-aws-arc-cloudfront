// Refer : https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html
locals {
  managed_cache_policies = {
    "Amplify"                                = "2e54312d-136d-493c-8eb9-b001f22f67d2"
    "CachingDisabled"                        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    "CachingOptimized"                       = "658327ea-f89d-4fab-a63d-7e88639e58f6" // Recomended for S3 origin
    "CachingOptimizedForUncompressedObjects" = "b2884449-e4de-46a7-ac36-70bc7f1ddd6d"
    "Elemental-MediaPackage"                 = "08627262-05a9-4f76-9ded-b50ca2e3a84f"
  }
}
