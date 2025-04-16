resource "aws_eks_node_group" "node-group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "NG-${var.projectName}"
  node_role_arn   = data.aws_iam_role.labrole.arn
  subnet_ids      = [for subnet in aws_subnet.private : subnet.id if subnet.availability_zone != "${var.regionDefault}e"]
  disk_size       = 20
  instance_types  = [var.instanceType]

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_eks_cluster.cluster,
    aws_security_group.sg_nodes,
  ]

  lifecycle {
    create_before_destroy = true
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = {
    Name = "${var.projectName}-nodegroup"
    # Add other relevant tags
  }
}