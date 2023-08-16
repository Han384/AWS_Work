data "aws_ssm_parameter" "myIP-terraform" {
  name            = "/myIP-terraform" # パラメータの名前/パスを指定
  with_decryption = true
}

data "aws_ssm_parameter" "MasterUsername-terraform" {
  name            = "/MasterUsername-terraform" # パラメータの名前/パスを指定
  with_decryption = true
}
