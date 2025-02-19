# S3 Bucket
resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.project_name}-test-reports"
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.artifacts.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["${aws_s3_bucket.artifacts.arn}/*"]
      }
    ]
  })
}

# ECR Repositories
resource "aws_ecr_repository" "docker" {
  name = "${var.project_name}-docker"
}

resource "aws_ecr_repository" "helm" {
  name = "${var.project_name}-helm"
}
