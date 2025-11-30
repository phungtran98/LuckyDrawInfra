# 🚀 Terraform Module: Deploy Static Website to AWS S3 + CloudFront with SSL Certificate

[![Terraform](https://img.shields.io/badge/terraform-1.0+-blue.svg)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-S3%20%7C%20CloudFront-orange.svg)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

> **Terraform module để deploy static website lên AWS S3 với CloudFront CDN, SSL certificate tự động, và custom domain. Hướng dẫn chi tiết Infrastructure as Code (IaC) cho AWS.**

## 📖 Mô tả / Description

**Tiếng Việt**: Module Terraform để tự động hóa việc triển khai static website lên AWS S3 kết hợp CloudFront CDN, tự động tìm/ tạo SSL certificate từ ACM, và cấu hình custom domain. Hỗ trợ S3 static website hosting endpoint, cache behaviors tối ưu, và lifecycle management.

**English**: Terraform module to automate deployment of static websites to AWS S3 with CloudFront CDN, automatic SSL certificate management from ACM, and custom domain configuration. Supports S3 static website hosting endpoint, optimized cache behaviors, and lifecycle management.

## ✨ Tính năng chính / Key Features

- ✅ **S3 Static Website Hosting**: Tự động cấu hình S3 bucket với static website hosting
- ✅ **CloudFront CDN**: Phân phối nội dung toàn cầu với tốc độ cao
- ✅ **SSL Certificate Management**: Tự động tìm hoặc tạo ACM certificate (us-east-1)
- ✅ **Custom Domain Support**: Hỗ trợ custom domain với aliases
- ✅ **Optimized Cache**: Cache behaviors tối ưu cho static website
- ✅ **Terraform Module Pattern**: Dễ tái sử dụng và maintain
- ✅ **Infrastructure as Code**: Quản lý infrastructure bằng code
- ✅ **Cost Optimized**: PriceClass_100 cho chi phí tối ưu

## 🎯 Use Cases / Trường hợp sử dụng

- Deploy static website (React, Vue, Angular, HTML/CSS/JS)
- Host documentation sites
- Deploy landing pages
- CDN cho static assets
- Blog sites (Jekyll, Hugo, Gatsby)
- Portfolio websites

## 🏗️ Architecture / Kiến trúc

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         INTERNET USERS                           │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ HTTPS (Custom Domain)
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    CLOUDFRONT DISTRIBUTION                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Custom Domain: *.example.com, www.example.com            │  │
│  │  SSL Certificate: ACM (us-east-1) - Auto managed         │  │
│  │  Price Class: PriceClass_100 (US, Canada, Europe)        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                             │                                    │
│  ┌──────────────────────────┴──────────────────────────┐        │
│  │              CACHE BEHAVIORS                         │        │
│  │  • *.html → No cache (TTL = 0)                     │        │
│  │  • Default → Cache (TTL = 3600s)                    │        │
│  └─────────────────────────────────────────────────────┘        │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ HTTP (S3 Website Endpoint)
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    S3 BUCKET                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Static Website Hosting: Enabled                         │  │
│  │  Website Endpoint: bucket.s3-website-region.amazonaws.com│  │
│  │  Public Access: Enabled (via bucket policy)             │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Request (HTTPS)
    │
    ├─→ DNS Query (www.example.com)
    │       │
    │       └─→ CNAME → CloudFront Domain
    │
    ├─→ CloudFront Distribution
    │       │
    │       ├─→ Check Cache
    │       │   ├─→ Cache Hit → Return cached content
    │       │   └─→ Cache Miss → Forward to Origin
    │       │
    │       └─→ Origin Request (HTTP)
    │               │
    │               └─→ S3 Website Endpoint
    │                       │
    │                       └─→ Return files
    │
    └─→ Response to User (HTTPS)
```

## 🚀 Quick Start / Bắt đầu nhanh

### Prerequisites / Yêu cầu

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured
- AWS Account với quyền tạo S3, CloudFront, ACM
- Domain name (optional, cho custom domain)

### Installation / Cài đặt

1. **Clone repository**:
```bash
git clone https://github.com/your-username/LuckyDrawInfra.git
cd LuckyDrawInfra
```

2. **Configure variables**:
```bash
cp terraform.tfvars.example terraform.tfvars
# Chỉnh sửa terraform.tfvars với thông tin của bạn
```

3. **Initialize Terraform**:
```bash
terraform init
```

4. **Review plan**:
```bash
terraform plan
```

5. **Deploy**:
```bash
terraform apply
```

## 📋 Components / Các thành phần

### S3 Bucket
- Static website hosting enabled
- Public read access (via bucket policy)
- Block public access: DISABLED (required for website endpoint)
- Server-side encryption (AES256)

### CloudFront Distribution
- CDN for global content delivery
- Custom domain support với aliases
- SSL/TLS certificate từ ACM (auto-managed)
- Optimized cache behaviors
- PriceClass_100 (cost-optimized)

### ACM Certificate
- Automatic certificate discovery hoặc creation
- DNS validation support
- Region: us-east-1 (required for CloudFront)
- Auto-attach to CloudFront when validated

### DNS Configuration
- CNAME records để trỏ domain về CloudFront
- Manual configuration trong DNS provider

## 📁 Project Structure / Cấu trúc dự án

```
.
├── main.tf                    # Root: Module invocation
├── variables.tf               # Root variables
├── outputs.tf                 # Root outputs
├── versions.tf                # Terraform & provider versions
├── terraform.tfvars           # Variable values (customizable)
├── html/                      # Static website files
│   ├── index.html            # Home page
│   └── error.html            # Error page
├── README.md                  # This file
└── modules/
    └── s3-cloudfront/         # Module: S3 + CloudFront
        ├── main.tf            # Module logic
        ├── variables.tf       # Module variables
        ├── outputs.tf         # Module outputs
        ├── versions.tf        # Module provider requirements
        └── README.md          # Module documentation
```

## ⚙️ Configuration / Cấu hình

### Basic Configuration

Edit `terraform.tfvars`:

```hcl
aws_profile = "your-profile"
aws_region  = "ap-southeast-1"

bucket_name = "my-static-website"

# CloudFront aliases
cloudfront_aliases = ["www.example.com", "*.example.com"]

# ACM Certificate (optional - auto-discovered if not provided)
acm_certificate_arn = ""  # Leave empty for auto-discovery
create_certificate  = true # Set to false if using existing certificate

tags = {
  Project     = "MyProject"
  Environment = "Production"
  ManagedBy   = "Terraform"
}
```

### Advanced Configuration

#### Certificate Management

Module tự động quản lý certificate:
1. **Auto-discovery**: Tự động tìm certificate đã validate trong ACM
2. **Auto-creation**: Tạo certificate mới nếu chưa có
3. **Manual**: Cung cấp certificate ARN trực tiếp

```hcl
# Option 1: Auto-discovery (recommended)
create_certificate  = false
acm_certificate_arn = ""  # Module will find existing validated certificate

# Option 2: Auto-creation
create_certificate  = true
certificate_domain  = "*.example.com"

# Option 3: Manual
create_certificate  = false
acm_certificate_arn = "arn:aws:acm:us-east-1:ACCOUNT:certificate/xxx"
```

#### Cache Behaviors

- **HTML files** (`*.html`): No cache (TTL = 0) - always fresh content
- **Other files**: Cache 1 hour (TTL = 3600s)

## 🔧 Usage Examples / Ví dụ sử dụng

### Example 1: Basic Static Website

```hcl
module "static_website" {
  source = "./modules/s3-cloudfront"

  bucket_name = "my-website"
  cloudfront_aliases = ["www.example.com"]
  
  index_html_path = "${path.module}/html/index.html"
  error_html_path = "${path.module}/html/error.html"
}
```

### Example 2: With Custom Certificate

```hcl
module "static_website" {
  source = "./modules/s3-cloudfront"

  bucket_name = "my-website"
  cloudfront_aliases = ["www.example.com", "example.com"]
  
  create_certificate  = false
  acm_certificate_arn = "arn:aws:acm:us-east-1:123456789:certificate/xxx"
}
```

### Example 3: Multiple Environments

```hcl
# Production
module "prod" {
  source = "./modules/s3-cloudfront"
  bucket_name = "prod-website"
  cloudfront_aliases = ["www.example.com"]
}

# Staging
module "staging" {
  source = "./modules/s3-cloudfront"
  bucket_name = "staging-website"
  cloudfront_aliases = ["staging.example.com"]
}
```

## 📊 Outputs / Đầu ra

Sau khi deploy, bạn có thể lấy các thông tin:

```bash
terraform output
```

**Important outputs**:
- `cloudfront_domain_name`: CloudFront domain (for DNS CNAME)
- `cloudfront_distribution_id`: Distribution ID
- `acm_certificate_arn`: Certificate ARN being used
- `s3_bucket_id`: S3 bucket ID

## 🔐 DNS Configuration / Cấu hình DNS

Sau khi deploy, cần cấu hình DNS:

1. **Lấy CloudFront domain**:
```bash
terraform output cloudfront_domain_name
```

2. **Thêm CNAME records** trong DNS provider:
```
www.example.com  → CNAME → dxxxxxxxxxxxxx.cloudfront.net
*.example.com    → CNAME → dxxxxxxxxxxxxx.cloudfront.net
```

3. **Đợi DNS propagation** (5-30 phút)

4. **Thêm aliases vào CloudFront** (nếu chưa có):
```hcl
cloudfront_aliases = ["www.example.com", "*.example.com"]
terraform apply
```

## 🐛 Troubleshooting / Xử lý sự cố

### CloudFront không hoạt động với custom domain

- ✅ Kiểm tra certificate đã được validate (status = ISSUED)
- ✅ Đợi CloudFront distribution deploy xong (15-20 phút)
- ✅ Kiểm tra DNS CNAME records đã trỏ đúng
- ✅ Kiểm tra aliases đã được thêm vào CloudFront

### Lỗi CNAMEAlreadyExists

DNS records đang trỏ đến CloudFront distribution khác. Cần:
1. Cập nhật DNS records trỏ về distribution hiện tại
2. Đợi DNS propagation
3. Sau đó mới thêm aliases vào CloudFront

### Lỗi AccessDenied

- ✅ Kiểm tra S3 bucket policy cho phép public read
- ✅ Kiểm tra Block Public Access đã TẮT
- ✅ Kiểm tra CloudFront origin dùng website endpoint

### Certificate không được attach

- ✅ Certificate phải ở region `us-east-1`
- ✅ Certificate phải có status = ISSUED
- ✅ Kiểm tra `acm_certificate_arn` trong terraform.tfvars

## 💰 Cost Estimation / Ước tính chi phí

### AWS Free Tier (12 months)
- **S3**: 5GB storage + 20,000 GET requests/month
- **CloudFront**: 1TB data transfer + 10M requests/month
- **ACM**: Free

### After Free Tier
- **S3**: ~$0.023/GB storage + $0.0004/1000 requests
- **CloudFront**: ~$0.085/GB (PriceClass_100)
- **Total**: < $5/month for small websites

## 🧪 Testing / Kiểm thử

```bash
# Validate configuration
terraform validate

# Format code
terraform fmt

# Check plan
terraform plan

# Apply changes
terraform apply
```

## 🗑️ Cleanup / Dọn dẹp

```bash
# Destroy all resources
terraform destroy
```

**Note**: CloudFront distribution có thể được protect khỏi destroy (tùy cấu hình).

## 📚 Documentation / Tài liệu

### Module Documentation
- [Module README](modules/s3-cloudfront/README.md)

### AWS Documentation
- [S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [CloudFront with S3 Origins](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/DownloadDistS3AndCustomOrigins.html)
- [ACM Certificates](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html)

### Terraform Documentation
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Modules](https://developer.hashicorp.com/terraform/language/modules)

## 🤝 Contributing / Đóng góp

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is licensed under the MIT License.

## 🔍 Keywords / Từ khóa

**English**: Terraform, AWS, S3, CloudFront, Static Website, SSL Certificate, ACM, CDN, Infrastructure as Code, IaC, AWS Certificate Manager, Custom Domain, HTTPS, Website Hosting, Terraform Module

**Tiếng Việt**: Terraform, AWS, S3, CloudFront, Static Website, SSL Certificate, CDN, Infrastructure as Code, IaC, Tự động hóa, Deploy website, Hosting website, Module Terraform

---

**Created with**: [Cursor](https://cursor.sh/)  
**Last Updated**: November 30, 2025
