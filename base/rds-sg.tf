resource "aws_db_subnet_group" "snapvid_db_subnet_group" {
  name        = "${var.projectName}-db-subnet-group"
  description = "Subnet group for RDS instances"

  subnet_ids = [for subnet in data.aws_subnet.subnet : subnet.id if subnet.availability_zone != "${var.regionDefault}e"]

  tags = {
    Name = "${var.projectName}-db-subnet-group"
  }
}