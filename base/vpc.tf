resource "aws_vpc" "main" {
  cidr_block           = var.vpcCidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.projectName}-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.projectName}-igw"
  }
}

resource "aws_eip" "nat" {
  # domain = "vpc" # Use this for VPC EIP, Terraform AWS provider >= 4.0 automatically handles this
  depends_on = [aws_internet_gateway.gw] # Ensure IGW is created first

  tags = {
    Name = "${var.projectName}-nat-eip"
  }
}

# Create 2 Public Subnets in different AZs
resource "aws_subnet" "public" {
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index) # e.g., 10.0.0.0/24, 10.0.1.0/24
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true # Good practice for public subnets

  tags = {
    Name                     = "${var.projectName}-public-subnet-${count.index + 1}"
    "kubernetes.io/role/elb" = "1" # Tag for automatic discovery by K8s LoadBalancer controller
  }
}

# Create 2 Private Subnets in different AZs
resource "aws_subnet" "private" {
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 2) # e.g., 10.0.2.0/24, 10.0.3.0/24
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.available.names[count.index] # Same AZs as public for NAT GW routing
  map_public_ip_on_launch = false

  tags = {
    Name                              = "${var.projectName}-private-subnet-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1" # Tag for internal ELBs if needed
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # Place NAT GW in the first public subnet

  tags = {
    Name = "${var.projectName}-nat-gw"
  }

  depends_on = [aws_internet_gateway.gw]
}

# Route Table for Public Subnets -> IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.projectName}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route Table for Private Subnets -> NAT GW
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.projectName}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
