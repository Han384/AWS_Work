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
