# Provider configuration
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

# Provider cho ACM certificate (phải ở us-east-1 cho CloudFront)
provider "aws" {
  alias   = "us_east_1"
  profile = var.aws_profile
  region  = "us-east-1"
}

# Module: S3 + CloudFront
# Module này tạo S3 bucket với static website hosting và CloudFront distribution
module "static_website" {
  source = "./modules/s3-cloudfront"

  # Truyền providers vào module
  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  # S3 bucket configuration
  bucket_name = var.bucket_name

  # CloudFront configuration
  cloudfront_aliases = var.cloudfront_aliases
  cloudfront_enabled = var.cloudfront_enabled

  # ACM Certificate configuration
  certificate_domain  = var.certificate_domain
  acm_certificate_arn = var.acm_certificate_arn

  # Upload HTML files
  index_html_path = "${path.module}/html/index.html"
  error_html_path = "${path.module}/html/error.html"

  # Tags
  tags = var.tags
}
