# ---------------------------------------------
# EC2 Instance
# ---------------------------------------------
resource "aws_instance" "EC2WebServer01" {
  ami = data.aws_ami.EC2WebServer01.id
  #ami                         = var.ami   # 第5回サンプルアプリのAMIを使用しての動作確認用
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.PublicSubnet1a.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.EC2InstanceProfile.name # SessionManager を適用
  vpc_security_group_ids = [
    aws_security_group.EC2SecurityGroup.id,
  ]
  key_name = data.aws_ssm_parameter.KeyName-terraform.value  # パラメータストアの暗号化した値を取得

  tags = {
    Name    = "${var.project}-${var.environment}-EC2WebServer01"
    Project = var.project
    Env     = var.environment
    Type    = "web/app"
  }
}
  