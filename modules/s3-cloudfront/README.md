# S3 + CloudFront Module

Module này tạo một S3 bucket với static website hosting và CloudFront distribution để phân phối nội dung.

## Tính năng

- ✅ S3 bucket với static website hosting
- ✅ CloudFront distribution với Origin Access Control (OAC)
- ✅ S3 bucket policy cho phép CloudFront truy cập
- ✅ Upload file index.html tự động (optional)
- ✅ **Tự động tạo ACM certificate** cho domain (ví dụ: *.tigerz2h.click)
- ✅ Hỗ trợ Route53 validation tự động hoặc validation thủ công
- ✅ Hỗ trợ custom domain và SSL certificate
- ✅ Cache configuration tối ưu cho static website

## Sử dụng

```hcl
module "static_website" {
  source = "./modules/s3-cloudfront"

  bucket_name        = "my-static-website"
  cloudfront_aliases = ["*.example.com", "www.example.com"]
  
  # Tự động tạo ACM certificate
  certificate_domain = "*.example.com"
  create_certificate  = true
  route53_zone_name   = "example.com"  # Optional: để validate tự động
  
  # Hoặc dùng certificate có sẵn
  # create_certificate  = false
  # acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/xxx"
  
  index_html_path = "${path.module}/index.html"
  
  tags = {
    Project = "MyProject"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| bucket_name | Tên S3 bucket | `string` | n/a | yes |
| cloudfront_aliases | List domain names cho CloudFront | `list(string)` | `[]` | no |
| certificate_domain | Domain để tạo ACM certificate (ví dụ: *.example.com) | `string` | `""` | no |
| create_certificate | Có tạo ACM certificate mới không? | `bool` | `true` | no |
| acm_certificate_arn | ARN của ACM certificate có sẵn | `string` | `""` | no |
| route53_zone_name | Route53 zone name để validate tự động | `string` | `""` | no |
| index_html_path | Path đến file index.html | `string` | `""` | no |
| tags | Tags cho resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| s3_bucket_id | S3 bucket ID |
| s3_bucket_arn | S3 bucket ARN |
| cloudfront_distribution_id | CloudFront distribution ID |
| cloudfront_domain_name | CloudFront domain name (dùng cho CNAME) |
| cloudfront_hosted_zone_id | CloudFront hosted zone ID |
| acm_certificate_arn | ACM Certificate ARN (nếu được tạo) |
| acm_certificate_validation_records | DNS validation records (nếu không dùng Route53) |

