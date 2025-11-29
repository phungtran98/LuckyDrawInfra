output "s3_bucket_id" {
  description = "S3 bucket ID"
  value       = module.s3_bucket.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3_bucket.s3_bucket_arn
}

output "s3_bucket_domain_name" {
  description = "S3 bucket domain name"
  value       = module.s3_bucket.s3_bucket_bucket_domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.s3_distribution.id
}

output "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.s3_distribution.arn
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name (dùng để tạo CNAME record)"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "CloudFront hosted zone ID (dùng cho Route53 alias record)"
  value       = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
}

output "acm_certificate_arn" {
  description = "ACM Certificate ARN đang được sử dụng"
  value       = var.acm_certificate_arn != "" ? var.acm_certificate_arn : null
}

