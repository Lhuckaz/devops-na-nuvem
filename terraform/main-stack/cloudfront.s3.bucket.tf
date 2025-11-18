resource "aws_s3_bucket" "this" {
  bucket = var.domain.name
}

resource "aws_s3_bucket_policy" "allow_oac_access" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.allow_oac_access.json
}

data "aws_iam_policy_document" "allow_oac_access" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.site.arn]
    }
  }
}
