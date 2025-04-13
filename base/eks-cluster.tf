resource "aws_eks_cluster" "cluster" {
  name     = var.projectName
  role_arn = data.aws_iam_role.labrole.arn

  vpc_config {
    subnet_ids = [for subnet in aws_subnet.private : subnet.id if subnet.availability_zone != "${var.regionDefault}e"]
    security_group_ids = [aws_security_group.sg_snap.id]
    endpoint_private_access = true 
    endpoint_public_access  = true 
  }

  access_config {
    authentication_mode = var.accessConfig
  }

  depends_on = [
    aws_vpc.main,
    aws_subnet.private,
    aws_subnet.public,
    aws_internet_gateway.gw,
    aws_nat_gateway.nat,
    aws_route_table.private,
    aws_route_table.public,
    aws_security_group.sg_snap,
    aws_security_group.sg_nodes,
  ]

  lifecycle {
    create_before_destroy = true
  }
}