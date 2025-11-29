# Data source để lấy region hiện tại
data "aws_region" "current" {}

# S3 Bucket for static website hosting
# Sử dụng terraform-aws-modules/s3-bucket/aws module
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = var.bucket_name

  # Enable static website hosting
  website = {
    index_document = "index.html"
    error_document = "error.html"
  }

  # Block public access settings - TẮT để cho phép public access qua website endpoint
  # Cần tắt để S3 static website hosting endpoint hoạt động
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  # Versioning để có thể rollback nếu cần
  versioning = {
    enabled = false
  }

  # Server-side encryption
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = var.tags
}

# Upload index.html to S3 bucket (nếu có path được cung cấp)
resource "aws_s3_object" "index_html" {
  count = var.index_html_path != "" ? 1 : 0

  bucket       = module.s3_bucket.s3_bucket_id
  key          = "index.html"
  source       = var.index_html_path
  content_type = "text/html"
  etag         = filemd5(var.index_html_path)
}

# Upload error.html to S3 bucket (nếu có path được cung cấp)
resource "aws_s3_object" "error_html" {
  count = var.error_html_path != "" ? 1 : 0

  bucket       = module.s3_bucket.s3_bucket_id
  key          = "error.html"
  source       = var.error_html_path
  content_type = "text/html"
  etag         = filemd5(var.error_html_path)
}

# Note: Không cần OAC khi dùng S3 static website hosting endpoint
# Website endpoint là public, nên CloudFront có thể truy cập trực tiếp
# CloudFront Origin Access Control (OAC) - chỉ cần khi dùng S3 bucket domain (REST API endpoint)
# resource "aws_cloudfront_origin_access_control" "s3_oac" {
#   name                              = "${var.bucket_name}-oac"
#   description                       = "OAC for S3 bucket ${var.bucket_name}"
#   origin_access_control_origin_type = "s3"
#   signing_behavior                  = "always"
#   signing_protocol                  = "sigv4"
# }

# CloudFront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled             = var.cloudfront_enabled
  is_ipv6_enabled     = false
  comment             = length(var.cloudfront_aliases) > 0 ? "CloudFront distribution for ${join(", ", var.cloudfront_aliases)}" : "CloudFront distribution for S3 bucket ${var.bucket_name}"
  default_root_object = "index.html"
  # Price class: PriceClass_100 = US, Canada, Europe (rẻ nhất)
  # PriceClass_200 = thêm Asia, Middle East, Africa
  # PriceClass_All = tất cả locations (đắt nhất)
  price_class = "PriceClass_100" # Tối ưu chi phí cho học tập

  # Lifecycle: Cho phép xóa CloudFront distribution khi destroy
  # Set prevent_destroy = true nếu muốn bảo vệ distribution khỏi bị xóa
  # Khi prevent_destroy = true, chỉ có thể disable (enabled = false) thay vì xóa
  lifecycle {
    prevent_destroy = false # Cho phép destroy CloudFront khi terraform destroy
  }

  # Custom domain names (aliases)
  # Set aliases nếu có certificate ARN (đã được validate)
  aliases = var.acm_certificate_arn != "" ? var.cloudfront_aliases : []

  # Origin configuration - S3 static website hosting endpoint
  # Sử dụng website endpoint thay vì bucket domain để tận dụng static website hosting
  origin {
    domain_name = "${var.bucket_name}.s3-website-${data.aws_region.current.name}.amazonaws.com"
    origin_id   = "S3-${var.bucket_name}"
    # Không cần OAC khi dùng website endpoint (endpoint này public)
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # Website endpoint chỉ hỗ trợ HTTP
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Default cache behavior
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.bucket_name}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  # Cache behavior for HTML files - không cache để luôn lấy version mới nhất
  ordered_cache_behavior {
    path_pattern     = "*.html"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.bucket_name}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
  }

  # Geo restrictions - không giới hạn
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # SSL Certificate configuration
  # Lưu ý: CloudFront không thể dùng certificate chưa được validate
  # Nếu certificate chưa validate, tạm thời dùng CloudFront default certificate
  # Sau khi validate certificate, cần update CloudFront distribution để dùng custom certificate

  # Option 1: Dùng certificate ARN có sẵn (đã được validate)
  dynamic "viewer_certificate" {
    for_each = var.acm_certificate_arn != "" ? [1] : []
    content {
      acm_certificate_arn      = var.acm_certificate_arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1.2_2021"
    }
  }

  # Option 2: Tạm thời dùng CloudFront default certificate
  # (Certificate mới tạo sẽ chưa được validate, nên không thể dùng ngay)
  dynamic "viewer_certificate" {
    for_each = var.acm_certificate_arn == "" ? [1] : []
    content {
      cloudfront_default_certificate = true
    }
  }

  tags = var.tags
}

# S3 Bucket Policy để cho phép public read access
# Cần thiết cho S3 static website hosting endpoint
data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid    = "PublicReadGetObject"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = ["${module.s3_bucket.s3_bucket_arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = module.s3_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

# Note: ACM Certificate sẽ được tạo thủ công hoặc dùng certificate có sẵn
# Sử dụng acm_certificate_arn trong terraform.tfvars để chỉ định certificate

