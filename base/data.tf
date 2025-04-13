data "aws_iam_role" "labrole" {
  name = "LabRole"
}

data "aws_eks_cluster_auth" "default" {
  name = var.projectName
  depends_on = [ aws_eks_cluster.cluster ]
}

data "aws_availability_zones" "available" {
  state = "available"
}