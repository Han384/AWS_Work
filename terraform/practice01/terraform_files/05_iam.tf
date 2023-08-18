# ---------------------------------------------
# IAM Role：セッションマネージャー用
# ---------------------------------------------
resource "aws_iam_instance_profile" "EC2InstanceProfile" {
  name = aws_iam_role.EC2IAMRole.name
  role = aws_iam_role.EC2IAMRole.name
}

resource "aws_iam_role" "EC2IAMRole" {
  name               = "${var.project}-${var.environment}-SSM-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "EC2IAMRole_ssm_managed" {
  role       = aws_iam_role.EC2IAMRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
