
resource "aws_s3_bucket" "this" {
  bucket = var.FQDN

  tags = {
    Name        = "${var.FQDN}-${var.environment}"
    Environment = var.environment
  }

}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  #  routing_rule {
  #    condition {
  #      key_prefix_equals = "docs/"
  #    }
  #    redirect {
  #      replace_key_prefix_with = "documents/"
  #    }
  #  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = <<POLICY
{    
    "Version": "2012-10-17",    
    "Statement": [        
      {            
          "Sid": "PublicReadGetObject",            
          "Effect": "Allow",            
          "Principal": "*",            
          "Action": [                
             "s3:GetObject"            
          ],            
          "Resource": [
             "arn:aws:s3:::${aws_s3_bucket.this.id}/*"            
          ]        
      }    
    ]
}
POLICY
}


resource "aws_s3_object" "object-upload-html" {
  for_each     = fileset("uploads/", "*.html")
  bucket       = aws_s3_bucket.this.bucket
  key          = each.value
  source       = "uploads/${each.value}"
  content_type = "text/html"
  etag         = filemd5("uploads/${each.value}")
  acl          = "public-read"
}
resource "aws_s3_object" "object-upload-jpg" {
  for_each     = fileset("uploads/", "*.jpeg")
  bucket       = aws_s3_bucket.this.bucket
  key          = each.value
  source       = "uploads/${each.value}"
  content_type = "image/jpeg"
  etag         = filemd5("uploads/${each.value}")
  acl          = "public-read"
}
