variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "cloudfront_aliases" {
  description = "List of domain names (CNAMEs) for CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "certificate_domain" {
  description = "Domain name để tạo ACM certificate (ví dụ: *.tigerz2h.click). Để trống nếu không muốn tạo certificate."
  type        = string
  default     = ""
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

variable "route53_zone_name" {
  description = "Route53 hosted zone name để validate certificate (ví dụ: tigerz2h.click). Để trống nếu validate thủ công."
  type        = string
  default     = ""
}

variable "index_html_path" {
  description = "Path to index.html file to upload to S3"
  type        = string
  default     = ""
}

variable "error_html_path" {
  description = "Path to error.html file to upload to S3"
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
  default     = {}
}

