# Root level variables
# Các biến này được truyền vào module

variable "aws_profile" {
  description = "AWS profile to use"
  type        = string
  default     = "ttphun"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "luckydraw-static-website"
}

variable "cloudfront_aliases" {
  description = "List of domain names (CNAMEs) for CloudFront distribution (ví dụ: [\"*.tigerz2h.click\", \"www.tigerz2h.click\"])"
  type        = list(string)
  default     = []
}

variable "certificate_domain" {
  description = "Domain name để tạo ACM certificate (ví dụ: *.tigerz2h.click). Để trống nếu không muốn tạo certificate."
  type        = string
  default     = "*.tigerz2h.click"
}

variable "create_certificate" {
  description = "Có tạo ACM certificate mới không? Nếu false, có thể dùng acm_certificate_arn có sẵn."
  type        = bool
  default     = true
}

variable "acm_certificate_arn" {
  description = "ARN của ACM certificate có sẵn (region us-east-1). Chỉ dùng khi create_certificate = false."
  type        = string
  default     = ""
}

variable "cloudfront_enabled" {
  description = "Enable/disable CloudFront distribution. Set false để disable thay vì delete khi destroy."
  type        = bool
  default     = true
}


variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "LuckyDraw"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
