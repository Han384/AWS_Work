# ---------------------------------------------
# Security Group
# ---------------------------------------------
# sg for EC2-WebServer
resource "aws_security_group" "EC2SecurityGroup" {
  name        = "${var.project}-${var.environment}-EC2-WebServer-sg"
  description = "sg for EC2-WebServer"
  vpc_id      = aws_vpc.TerraformVPC.id

  tags = {
    Name    = "${var.project}-${var.environment}-EC2-WebServer-sg"
    Project = var.project
    Env     = var.environment
  }
}

resource "aws_security_group_rule" "ec2_web_in_http_from_ALB" {
  security_group_id        = aws_security_group.EC2SecurityGroup.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = aws_security_group.ALBSecurityGroup.id
}

resource "aws_security_group_rule" "ec2_web_in_ssh" {
  security_group_id = aws_security_group.EC2SecurityGroup.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = [data.aws_ssm_parameter.myIP-terraform.value] # パラメータストアの暗号化した値を取得
}

resource "aws_security_group_rule" "ec2_web_in_tcp3000" {
  security_group_id = aws_security_group.EC2SecurityGroup.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 3000
  to_port           = 3000
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web_egress" {
  security_group_id = aws_security_group.EC2SecurityGroup.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

# sg for RDS-MySQL
resource "aws_security_group" "RDSSecurityGroup" {
  name        = "${var.project}-${var.environment}-RDS-MySQL-sg"
  description = "sg for RDS-MySQL"
  vpc_id      = aws_vpc.TerraformVPC.id

  tags = {
    Name    = "${var.project}-${var.environment}-RDS-MySQL-sg"
    Project = var.project
    Env     = var.environment
  }
}

resource "aws_security_group_rule" "rds_in_tcp3306_from_ec2" {
  security_group_id        = aws_security_group.RDSSecurityGroup.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = aws_security_group.EC2SecurityGroup.id
}

resource "aws_security_group_rule" "rds_egress" {
  security_group_id = aws_security_group.RDSSecurityGroup.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

# sg for ALB
resource "aws_security_group" "ALBSecurityGroup" {
  name        = "${var.project}-${var.environment}-ALB-sg"
  description = "sg for ALB"
  vpc_id      = aws_vpc.TerraformVPC.id

  tags = {
    Name    = "${var.project}-${var.environment}-ALB-sg"
    Project = var.project
    Env     = var.environment
  }
}

resource "aws_security_group_rule" "alb_in_http" {
  security_group_id = aws_security_group.ALBSecurityGroup.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "alb_egress" {
  security_group_id = aws_security_group.ALBSecurityGroup.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}
  