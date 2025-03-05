data "aws_caller_identity" "current" {}

# Policy để cho phép EKS node role assume Pod Identity role
# resource "aws_iam_role" "pod_role" {
#   name = "${var.project_name}-pod-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "pods.eks.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy" "pod_policy" {
#   name = "${var.project_name}-pod-policy"
#   role = aws_iam_role.pod_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:PutObject",
#           "s3:PutObjectAcl"
#         ]
#         Resource = ["${var.s3_bucket_arn}/*"]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "ecr:GetAuthorizationToken",
#           "ecr:BatchCheckLayerAvailability",
#           "ecr:GetDownloadUrlForLayer",
#           "ecr:GetRepositoryPolicy",
#           "ecr:DescribeRepositories",
#           "ecr:ListImages",
#           "ecr:DescribeImages",
#           "ecr:BatchGetImage",
#           "ecr:InitiateLayerUpload",
#           "ecr:UploadLayerPart",
#           "ecr:CompleteLayerUpload",
#           "ecr:PutImage"
#         ]
#         Resource = [
#           var.docker_ecr_arn,
#           var.helm_ecr_arn
#         ]
#       }
#     ]
#   })
# }

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "ebs-csi-driver-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attach" {
  role = aws_iam_role.ebs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_pod_identity_association" "ebs_csi" {
  cluster_name = "project-647-cluster"
  namespace = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn = aws_iam_role.ebs_csi_driver_role.arn
}

resource "aws_iam_role" "load_balancer_controller" {
  name = "load-balancer-controller"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = ["sts:AssumeRole", "sts:TagSession"]
      }
    ]
  })
}

resource "aws_iam_policy" "aws_lbc_policy" {
  name = "IAMPolicyForLoadBalancerController"
  policy = file("${path.module}/iam_policy.json")
}
resource "aws_iam_role_policy_attachment" "load_balancer_controller_policy_attach" {
  role = aws_iam_role.load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_lbc_policy.arn
}
resource "aws_eks_pod_identity_association" "load_balancer_controller" {
  cluster_name = "project-647-cluster"
  namespace = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn = aws_iam_role.load_balancer_controller.arn
}

resource "aws_iam_role" "jenkins_pod" {
  name = "jenkins-pod"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
resource "aws_iam_policy" "jenkins_pod_policy" {
  name = "jenkins-pod-policy"
  policy = file("${path.module}/jenkins_pod_policy.json")
}
resource "aws_iam_role_policy_attachment" "jenkins" {
  role = aws_iam_role.jenkins_pod.name
  policy_arn = aws_iam_policy.jenkins_pod_policy.arn
}
resource "aws_eks_pod_identity_association" "jenkins" {
  cluster_name = "project-647-cluster"
  namespace = "cicd"
  service_account = "jenkins"
  role_arn = aws_iam_role.jenkins_pod.arn
}
