resource "aws_security_group" "rds_sg" {
  name        = "SG-${var.projectName}-rds"
  description = "Este grupo e usado no snap-vid"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description = "VPC_ACCESS_SQLSERVER"
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["${var.vpcCidr}"]
  }

    ingress {
    description = "ALL_ACCESS_SQLSERVER"
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}