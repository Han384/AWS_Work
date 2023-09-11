# ---------------------------------------------
# VPC
# ---------------------------------------------
resource "aws_vpc" "TerraformVPC" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project}-${var.environment}-vpc"
    Project = var.project
    Env     = var.environment
  }
}

# ---------------------------------------------
# Subnet
# ---------------------------------------------
resource "aws_subnet" "PublicSubnet1a" {
  vpc_id                  = aws_vpc.TerraformVPC.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.0.0/20"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-${var.environment}-public-subnet-1a"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

resource "aws_subnet" "PublicSubnet1c" {
  vpc_id                  = aws_vpc.TerraformVPC.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "10.0.16.0/20"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-${var.environment}-public-subnet-1c"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

resource "aws_subnet" "PrivateSubnet1a" {
  vpc_id                  = aws_vpc.TerraformVPC.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.128.0/20"
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.environment}-private-subnet-1a"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}

resource "aws_subnet" "PrivateSubnet1c" {
  vpc_id                  = aws_vpc.TerraformVPC.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "10.0.144.0/20"
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.environment}-private-subnet-1c"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}

# ---------------------------------------------
# Route Table
# ---------------------------------------------
resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.TerraformVPC.id

  tags = {
    Name    = "${var.project}-${var.environment}-public-rtb"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

resource "aws_route_table_association" "PublicSubnet1aRouteTableAssociation" {
  route_table_id = aws_route_table.PublicRouteTable.id
  subnet_id      = aws_subnet.PublicSubnet1a.id
}

resource "aws_route_table_association" "PublicSubnet1cRouteTableAssociation" {
  route_table_id = aws_route_table.PublicRouteTable.id
  subnet_id      = aws_subnet.PublicSubnet1c.id
}

resource "aws_route_table" "PrivateRouteTable" {
  vpc_id = aws_vpc.TerraformVPC.id

  tags = {
    Name    = "${var.project}-${var.environment}-private-rtb"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}

resource "aws_route_table_association" "PrivateSubnet1aRouteTableAssociation" {
  route_table_id = aws_route_table.PrivateRouteTable.id
  subnet_id      = aws_subnet.PrivateSubnet1a.id
}

resource "aws_route_table_association" "PrivateSubnet1cRouteTableAssociation" {
  route_table_id = aws_route_table.PrivateRouteTable.id
  subnet_id      = aws_subnet.PrivateSubnet1c.id
}

# ---------------------------------------------
# Internet Gateway
# ---------------------------------------------
resource "aws_internet_gateway" "TerraformInternetGateway" {
  vpc_id = aws_vpc.TerraformVPC.id

  tags = {
    Name    = "${var.project}-${var.environment}-igw"
    Project = var.project
    Env     = var.environment
  }
}

resource "aws_route" "PublicRoute" {
  route_table_id         = aws_route_table.PublicRouteTable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.TerraformInternetGateway.id
}
  