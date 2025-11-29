# LuckyDraw Infrastructure - AWS S3 + CloudFront

Dự án này triển khai một static website lên AWS S3 với CloudFront distribution sử dụng **Terraform Module** pattern.

## 🏗️ Kiến trúc

### Sơ đồ kiến trúc

```
┌─────────────────────────────────────────────────────────────────┐
│                         INTERNET USERS                           │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ HTTPS (www.tigerz2h.click)
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    CLOUDFRONT DISTRIBUTION                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Domain: www.tigerz2h.click, *.tigerz2h.click            │  │
│  │  SSL Certificate: ACM (us-east-1)                          │  │
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
│  │  Bucket: luckydraw-static-website                        │  │
│  │  Region: ap-southeast-1                                  │  │
│  │  Static Website Hosting: Enabled                         │  │
│  │  • Index Document: index.html                             │  │
│  │  • Error Document: error.html                             │  │
│  │  Website Endpoint:                                        │  │
│  │  luckydraw-static-website.s3-website-                    │  │
│  │  ap-southeast-1.amazonaws.com                            │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Block Public Access: DISABLED                           │  │
│  │  Bucket Policy: Public Read (GetObject)                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Files:                                                   │  │
│  │  • index.html                                             │  │
│  │  • error.html                                             │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    DNS CONFIGURATION                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Domain: www.tigerz2h.click                              │  │
│  │  Type: CNAME                                              │  │
│  │  Value: djws16y5hcsy4.cloudfront.net                      │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    ACM CERTIFICATE                               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Region: us-east-1 (required for CloudFront)             │  │
│  │  Domain: tigerz2h.click                                   │  │
│  │  Status: Validated                                        │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Flow dữ liệu

```
User Request
    │
    ├─→ DNS Query (www.tigerz2h.click)
    │       │
    │       └─→ CNAME → CloudFront Domain
    │
    ├─→ CloudFront Distribution
    │       │
    │       ├─→ Check Cache
    │       │   ├─→ Cache Hit → Return cached content
    │       │   └─→ Cache Miss → Forward to Origin
    │       │
    │       └─→ Origin Request
    │               │
    │               └─→ S3 Website Endpoint
    │                       │
    │                       └─→ Return files (index.html, error.html)
    │
    └─→ Response to User (HTTPS)
```

## 📋 Components

- **S3 Bucket**: 
  - Lưu trữ static website files (index.html, error.html)
  - Static website hosting enabled
  - Public read access (via bucket policy)
  - Block public access: DISABLED (cần cho website endpoint)

- **CloudFront Distribution**: 
  - CDN để phân phối nội dung với tốc độ cao
  - Custom domain: `www.tigerz2h.click`, `*.tigerz2h.click`
  - SSL/TLS certificate từ ACM
  - Cache behaviors tối ưu cho static website
  - Lifecycle protection: prevent_destroy = true

- **ACM Certificate**: 
  - Certificate có sẵn (region us-east-1)
  - Được attach vào CloudFront distribution

- **DNS**: 
  - CNAME record trỏ domain về CloudFront
  - Cấu hình thủ công trong DNS provider

## 🏛️ Cấu trúc Module

Dự án này sử dụng **Terraform Module** pattern để tổ chức code:
- Logic được tách vào module riêng (`modules/s3-cloudfront/`)
- Root level chỉ gọi module và truyền variables
- Dễ dàng tái sử dụng và maintain

## 📁 Cấu trúc files

```
.
├── main.tf                    # Root: Gọi module
├── variables.tf               # Root variables
├── outputs.tf                 # Root outputs
├── versions.tf                # Terraform và provider versions
├── terraform.tfvars           # Giá trị biến (có thể chỉnh sửa)
├── html/                      # Static website files
│   ├── index.html            # Trang chủ
│   └── error.html            # Trang lỗi
├── README.md                  # File này
└── modules/
    └── s3-cloudfront/         # Module: S3 + CloudFront
        ├── main.tf            # Logic chính của module
        ├── variables.tf        # Module variables
        ├── outputs.tf         # Module outputs
        ├── versions.tf        # Module provider requirements
        └── README.md          # Module documentation
```

## ✅ Lợi ích của Module Pattern

✅ **Tái sử dụng**: Module có thể được dùng cho nhiều projects  
✅ **Tổ chức code**: Logic được tách biệt, dễ maintain  
✅ **Testing**: Dễ test module độc lập  
✅ **Best Practice**: Theo chuẩn Terraform module structure

## 🚀 Cách sử dụng

### 1. Khởi tạo Terraform

```bash
terraform init
```

Lệnh này sẽ:
- Tải về AWS provider
- Tải về `terraform-aws-modules/s3-bucket/aws` module (được dùng trong module của chúng ta)
- Khởi tạo local module `./modules/s3-cloudfront`

### 2. Xem kế hoạch triển khai

```bash
terraform plan
```

Lệnh này sẽ hiển thị những gì Terraform sẽ tạo ra.

### 3. Triển khai infrastructure

```bash
terraform apply
```

Nhập `yes` khi được hỏi để xác nhận.

### 4. Xem thông tin output

Sau khi triển khai thành công, bạn có thể xem các thông tin quan trọng:

```bash
terraform output
```

Output quan trọng:
- `cloudfront_domain_name`: Domain name của CloudFront (dùng để tạo CNAME record)
- `cloudfront_distribution_id`: ID của CloudFront distribution

### 5. Cấu hình DNS

Sau khi CloudFront distribution được tạo, bạn cần tạo DNS CNAME record:

1. Vào DNS provider của bạn (nơi quản lý domain `tigerz2h.click`)
2. Tạo CNAME record:
   - **Name/Host**: `www`
   - **Type**: `CNAME`
   - **Value/Target**: `<cloudfront_domain_name>` (từ terraform output)
   - **TTL**: `300` (hoặc mặc định)

3. Đợi DNS propagate (5-30 phút)

## ⚙️ Cấu hình hiện tại

### S3 Bucket
- **Static Website Hosting**: Enabled
- **Block Public Access**: DISABLED (cần cho website endpoint)
- **Bucket Policy**: Public read access (GetObject)
- **Website Endpoint**: `{bucket-name}.s3-website-{region}.amazonaws.com`

### CloudFront
- **Origin**: S3 static website hosting endpoint
- **Origin Type**: Custom origin (HTTP only)
- **Aliases**: `*.tigerz2h.click`, `www.tigerz2h.click`
- **SSL Certificate**: ACM certificate (us-east-1)
- **Price Class**: PriceClass_100 (tối ưu chi phí)
- **Lifecycle**: prevent_destroy = true (không xóa khi destroy)

### Cache Behaviors
- **`*.html`**: No cache (TTL = 0) - luôn lấy version mới nhất
- **Default (`*`)**: Cache (TTL = 3600s) - cache các file khác

## 📝 Lưu ý quan trọng

1. **CloudFront Distribution**: 
   - Sau khi triển khai, CloudFront distribution có thể mất 15-20 phút để deploy hoàn toàn
   - Lifecycle protection: Distribution sẽ không bị xóa khi chạy `terraform destroy` (chỉ disable)

2. **ACM Certificate**: 
   - Certificate phải ở region `us-east-1` để sử dụng với CloudFront
   - Certificate phải được validate trước khi CloudFront có thể sử dụng

3. **S3 Public Access**: 
   - Block public access phải được TẮT để website endpoint hoạt động
   - Bucket policy cho phép public read access (GetObject)

4. **DNS Records**: 
   - Cần tạo CNAME records trong DNS provider để trỏ domain về CloudFront distribution domain name
   - DNS có thể mất vài phút đến vài giờ để propagate

## 🔧 Tùy chỉnh

Bạn có thể chỉnh sửa file `terraform.tfvars` để thay đổi:
- `bucket_name`: Tên S3 bucket
- `cloudfront_aliases`: List domain names cho CloudFront (ví dụ: `["*.tigerz2h.click", "www.tigerz2h.click"]`)
- `acm_certificate_arn`: ARN của certificate có sẵn (region us-east-1)
- `cloudfront_enabled`: Enable/disable CloudFront distribution
- `aws_region`: AWS region (mặc định: ap-southeast-1)
- `tags`: Tags cho các resources

## 🧩 Hiểu về Module Structure

### Root Level (Project Root)
- `main.tf`: Gọi module và truyền variables
- `variables.tf`: Định nghĩa variables cho project
- `outputs.tf`: Expose outputs từ module ra ngoài

### Module Level (`modules/s3-cloudfront/`)
- `main.tf`: Chứa toàn bộ logic tạo resources (S3, CloudFront, policies)
- `variables.tf`: Định nghĩa inputs mà module nhận
- `outputs.tf`: Định nghĩa outputs mà module trả về
- `versions.tf`: Provider requirements với configuration aliases

### Flow hoạt động:
```
terraform.tfvars 
    ↓
root variables.tf 
    ↓
root main.tf 
    ↓
module (modules/s3-cloudfront/)
    ↓
module outputs 
    ↓
root outputs.tf
```

### Sử dụng module trong project khác

Nếu muốn dùng module này trong project khác:

```hcl
module "my_website" {
  source = "../LuckyDrawInfra/modules/s3-cloudfront"
  
  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
  
  bucket_name        = "my-bucket"
  cloudfront_aliases = ["www.example.com"]
  acm_certificate_arn = "arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/xxx"
  index_html_path    = "${path.module}/html/index.html"
  error_html_path    = "${path.module}/html/error.html"
  
  tags = {
    Project = "MyProject"
  }
}
```

## 🗑️ Xóa infrastructure

### Xóa tất cả resources

```bash
terraform destroy
```

**Lưu ý**: 
- CloudFront distribution sẽ **KHÔNG** bị xóa (do `prevent_destroy = true`)
- CloudFront sẽ chỉ bị **disable** nếu set `cloudfront_enabled = false`
- Các resources khác (S3, policies) sẽ bị xóa bình thường

### Disable CloudFront (không xóa)

1. Sửa `terraform.tfvars`:
   ```hcl
   cloudfront_enabled = false
   ```

2. Chạy:
   ```bash
   terraform apply
   ```

3. Để enable lại:
   ```hcl
   cloudfront_enabled = true
   terraform apply
   ```

## 🔍 Troubleshooting

### CloudFront không hoạt động với custom domain
- ✅ Kiểm tra certificate đã được validate chưa (phải ở region us-east-1)
- ✅ Đợi CloudFront distribution deploy hoàn toàn (15-20 phút)
- ✅ Kiểm tra DNS CNAME record đã trỏ đúng về CloudFront domain name chưa
- ✅ Đảm bảo domain name đã được thêm vào CloudFront aliases trong Terraform

### Lỗi AccessDenied khi truy cập
- ✅ Kiểm tra S3 bucket policy đã cho phép public read access chưa
- ✅ Kiểm tra Block Public Access đã được TẮT chưa
- ✅ Kiểm tra CloudFront origin đang dùng website endpoint đúng chưa

### Website trỏ về S3 bucket thay vì CloudFront
- ✅ Kiểm tra DNS CNAME record đã trỏ về CloudFront domain name chưa
- ✅ Kiểm tra CloudFront distribution đã có aliases được cấu hình chưa
- ✅ Đợi CloudFront distribution deploy xong (status = Deployed)

## 💰 Chi phí ước tính

### Free Tier (12 tháng đầu)
- **S3**: 5GB storage + 20,000 GET requests
- **CloudFront**: 1TB data transfer + 10M requests
- **ACM**: Miễn phí

### Sau Free Tier
- **S3**: ~$0.023/GB storage + $0.0004/1000 requests
- **CloudFront**: ~$0.085/GB data transfer (PriceClass_100)
- **Route53**: $0.50/hosted zone/month + $0.40/million queries
- **ACM**: Miễn phí

**Tổng chi phí ước tính cho website nhỏ**: < $5/tháng (sau Free Tier)

## 📚 Tài liệu tham khảo

- [AWS S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [CloudFront with S3 Origins](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/DownloadDistS3AndCustomOrigins.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Module Structure](https://developer.hashicorp.com/terraform/language/modules)

---

**Tool hỗ trợ**: [Cursor](https://cursor.sh/)  
**Ngày tạo**: Tháng 11 29, 2025
