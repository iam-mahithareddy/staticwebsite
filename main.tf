resource "aws_s3_bucket" "static_website" {
    bucket = "mahithasristaticwebsite"
}
resource "aws_s3_bucket_acl" "static_website_acl" {
    bucket = aws_s3_bucket.static_website.id
    acl = "public-read"
}
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.static_website.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "PublicReadGetObject",
      Effect    = "Allow",
      Principal = "*",
      Action    = "s3:GetObject",
      Resource  = "arn:aws:s3:::mahithasristaticwebsite/*"
    }]
  })
}
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.static_website.id
  key          = "index.html"
  source       = "/Users/indrasenakallam/Desktop/aws_project/project_4"
  content_type = "text/html"
}
resource "aws_s3_object" "script_js" {
  bucket       = aws_s3_bucket.static_website.id
  key          = "script.js"
  source       = "/Users/indrasenakallam/Desktop/aws_project/project_4"
  content_type = "application/javascript"
}

resource "aws_s3_object" "style_css" {
  bucket       = aws_s3_bucket.static_website.id
  key          = "style.css"
  source       = "/Users/indrasenakallam/Desktop/aws_project/project_4"
  content_type = "text/css"
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.static_website.website_endpoint
    origin_id   = aws_s3_bucket.static_website.id
  }

  enabled             = true
  default_root_object = "index.html"

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.static_website.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  
  origin {
  domain_name = aws_s3_bucket.static_website.website_endpoint
  origin_id   = "s3-static-website"
  custom_origin_config {
    http_port              = 80
    https_port             = 443
    origin_protocol_policy = "http-only"
    origin_ssl_protocols   = ["TLSv1.2"]
  }
}
}