# ---------------------------------------------
# RDS subnet group
# ---------------------------------------------
# DB Subnet Group for Private
resource "aws_db_subnet_group" "RDSDBSubnetGroup" {
  name        = "${var.project}-${var.environment}-rds-mysql-private-subnetgroup"
  description = "DB Subnet Group for Private Subnet"

  subnet_ids = [
    aws_subnet.PrivateSubnet1a.id,
    aws_subnet.PrivateSubnet1c.id
  ]

  tags = {
    Name    = "${var.project}-${var.environment}-RDS-MySQL-private-subnetgroup"
    Project = var.project
    Env     = var.environment
  }
}

# ---------------------------------------------
# RDS instance
# ---------------------------------------------
resource "aws_db_instance" "RDSDBInstance" {
  engine                      = "mysql"
  engine_version              = "8.0.32"
  identifier                  = "${var.project}-${var.environment}-rds-mysql"
  username                    = data.aws_ssm_parameter.MasterUsername-terraform.value # パラメータストアの暗号化した値を取得
  manage_master_user_password = true                                                  # Secrets Manager でのマスター パスワードの管理を有効化
  instance_class              = "db.t3.micro"
  allocated_storage           = 20
  storage_type                = "gp2"
  storage_encrypted           = true
  multi_az                    = false
  availability_zone           = "ap-northeast-1a"
  db_subnet_group_name        = aws_db_subnet_group.RDSDBSubnetGroup.name
  vpc_security_group_ids      = [aws_security_group.RDSSecurityGroup.id]
  publicly_accessible         = false
  port                        = 3306
  db_name                     = "terraform"
  copy_tags_to_snapshot       = true
  backup_retention_period     = 0
  auto_minor_version_upgrade  = true
  deletion_protection         = false
  skip_final_snapshot         = true
  apply_immediately           = false

  tags = {
    Name    = "${var.project}-${var.environment}-rds-mysql"
    Project = var.project
    Env     = var.environment
  }
}
