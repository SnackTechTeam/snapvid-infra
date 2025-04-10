resource "aws_security_group" "sg" {
  name        = "SG-${var.projectName}"
  description = "Este grupo e usado no snap-vid"
  vpc_id      = data.aws_vpc.vpc.id
  
  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
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