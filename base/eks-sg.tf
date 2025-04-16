resource "aws_security_group" "sg_snap" {
  name        = "${var.projectName}-cluster-sg"
  description = "Grupo usado no cluster snap-vid"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    description = "All"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.projectName}-cluster-sg"
  }
}

resource "aws_security_group" "sg_nodes" {
  name        = "${var.projectName}-node-sg"
  description = "Grupo usado pelos nodes do cluster snap-vid"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  # Allow inbound traffic from the cluster control plane SG
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.sg_snap.id]
    description     = "Allow communication from Cluster Control Plane"
  }

  # Allow inbound traffic from other nodes in the same SG (for pod-to-pod communication)
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
    description = "Allow communication between nodes"
  }

  tags = {
    Name = "${var.projectName}-node-sg"
  }
}
