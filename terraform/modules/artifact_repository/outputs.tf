output "s3_bucket_arn" {
  value = aws_s3_bucket.artifacts.arn
}

output "docker_ecr_arn" {
  value = aws_ecr_repository.docker.arn
}

output "helm_ecr_arn" {
  value = aws_ecr_repository.helm.arn
}