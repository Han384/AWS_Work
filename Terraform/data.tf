data "aws_ssm_parameter" "myIP-terraform" {
  name            = "/myIP-terraform" # パラメータの名前を指定
  with_decryption = true
}
