# Root level outputs
# Các outputs này lấy từ module

output "s3_bucket_id" {
  description = "S3 bucket ID"
  value       = module.static_website.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.static_website.s3_bucket_arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.static_website.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name (dùng để tạo CNAME record trong DNS)"
  value       = module.static_website.cloudfront_domain_name
}

output "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = module.static_website.cloudfront_distribution_arn
}

output "cloudfront_hosted_zone_id" {
  description = "CloudFront hosted zone ID (dùng cho Route53 alias record nếu cần)"
  value       = module.static_website.cloudfront_hosted_zone_id
}

output "acm_certificate_arn" {
  description = "ACM Certificate ARN đang được sử dụng"
  value       = module.static_website.acm_certificate_arn
}
