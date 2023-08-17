# ---------------------------------------------
# SSM パラメータストア：暗号化した値を取得
# ---------------------------------------------
data "aws_ssm_parameter" "myIP-terraform" {
  name            = "/myIP-terraform" # パラメータの名前/パスを指定
  with_decryption = true
}

data "aws_ssm_parameter" "MasterUsername-terraform" {
  name            = "/MasterUsername-terraform" # パラメータの名前/パスを指定
  with_decryption = true
}

data "aws_ssm_parameter" "KeyName-terraform" {
  name            = "/KeyName-terraform" # パラメータの名前/パスを指定
  with_decryption = true
}

# ---------------------------------------------
# AMI：Amazon Linux 2 の最新のAMIを動的取得
# ---------------------------------------------
# 事前に AWS CLI で該当のAMI情報を確認し、必要な情報を抽出
data "aws_ami" "EC2WebServer01" {
  most_recent = true # 最新のものを選択
  owners      = ["self", "amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
    #values = ["amzn2-ami-kernel-5.10-hvm-2.0.*-x86_64-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
