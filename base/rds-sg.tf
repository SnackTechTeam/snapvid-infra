resource "aws_security_group" "rds_sg" {
  name        = "SG-${var.projectName}"
  description = "Este grupo e usado no snap-vid"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description = "VPC_ACCESS_SQLSERVER"
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = [var.vpcCidr]
  }

  egress {
    description = "All"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}