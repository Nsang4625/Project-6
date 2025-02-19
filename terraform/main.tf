terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "artifact_repository" {
  source = "./modules/artifact_repository"
  project_name = var.project_name
}

# module "iam" {
#   source = "./modules/iam"
#   project_name = var.project_name
#   s3_bucket_arn = module.artifact_repository.s3_bucket_arn
#   docker_ecr_arn = module.artifact_repository.docker_ecr_arn
#   helm_ecr_arn = module.artifact_repository.helm_ecr_arn
# }

module "network" {
  source = "./modules/network"

  project_name = var.project_name
  vpc_cidr     = "10.0.0.0/16"
  azs          = ["us-east-1a", "us-east-1b"]  # Chỉ định 2 AZs
}

# module "eks" {
#   source = "./modules/eks"

#   project_name        = var.project_name
#   vpc_id             = module.network.vpc_id
#   subnet_ids         = module.network.public_subnet_ids
#   kubernetes_version = "1.27"
  
#   # Điều chỉnh số lượng node cho phù hợp với 2 AZs
#   node_instance_types = ["t3.medium"]
#   node_desired_size  = 2  # 1 node mỗi AZ
#   node_min_size     = 1
#   node_max_size     = 4
# }

