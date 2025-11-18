data "aws_cloudfront_cache_policy" "managed_cached_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "use_origin_cache_control_headers_query_strings" {
  name = "UseOriginCacheControlHeaders-QueryStrinds"
}

data "aws_cloudfront_origin_request_policy" "managed_all_viewer" {
  name = "Managed-AllViewer"
}

resource "aws_cloudfront_distribution" "site" {
  origin {
    domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
    origin_id                = aws_s3_bucket.this.bucket_regional_domain_name
  }

  origin {
    domain_name = data.aws_alb.this.dns_name
    origin_id   = data.aws_alb.this.dns_name
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled             = true
  default_root_object = "index.html"
  aliases             = [var.domain.name]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.this.bucket_regional_domain_name

    cache_policy_id        = data.aws_cloudfront_cache_policy.managed_cached_optimized.id
    viewer_protocol_policy = "allow-all"
  }

  ordered_cache_behavior {
    path_pattern     = "/backend/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = data.aws_alb.this.dns_name

    cache_policy_id          = data.aws_cloudfront_cache_policy.use_origin_cache_control_headers_query_strings.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed_all_viewer.id
    viewer_protocol_policy   = "allow-all"
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.this.arn
    ssl_support_method  = "sni-only"
  }
}
