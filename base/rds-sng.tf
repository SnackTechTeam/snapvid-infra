resource "aws_db_subnet_group" "snapvid_db_subnet_group" {
  name        = "${var.projectName}-db-subnet-group"
  description = "Subnet group for RDS instances"

  subnet_ids = [for subnet in aws_subnet.private : subnet.id]

  tags = {
    Name = "${var.projectName}-db-subnet-group"
  }
}