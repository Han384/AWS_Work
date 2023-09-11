# # ---------------------------------------------
# # EC2 Instance
# # ---------------------------------------------
# resource "aws_instance" "EC2WebServer01" {
#   ami = data.aws_ami.EC2WebServer01.id
#   #ami                         = var.ami   # 第5回サンプルアプリのAMIを使用しての動作確認用
#   instance_type               = "t2.micro"
#   subnet_id                   = aws_subnet.PublicSubnet1a.id
#   associate_public_ip_address = true
#   iam_instance_profile        = aws_iam_instance_profile.EC2InstanceProfile.name # SessionManager を適用
#   vpc_security_group_ids = [
#     aws_security_group.EC2SecurityGroup.id,
#   ]
#   key_name = data.aws_ssm_parameter.KeyName-terraform.value # パラメータストアの暗号化した値を取得

#   tags = {
#     Name    = "${var.project}-${var.environment}-EC2WebServer01"
#     Project = var.project
#     Env     = var.environment
#     Type    = "web/app"
#   }
# }

# ---------------------------------------------
# launch template
# ---------------------------------------------
resource "aws_launch_template" "EC2LaunchTemplate" {
  update_default_version = true
  name                   = "${var.project}-${var.environment}-LaunchTemplate"
  image_id               = data.aws_ami.EC2WebServer01.id
  instance_type          = "t2.micro"
  key_name               = data.aws_ssm_parameter.KeyName-terraform.value # パラメータストアの暗号化した値を取得

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "${var.project}-${var.environment}-EC2WebServer"
      Project = var.project
      Env     = var.environment
      Type    = "app"
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      aws_security_group.EC2SecurityGroup.id,
    ]
    delete_on_termination = true
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.EC2InstanceProfile.name # SessionManager を適用
  }

  user_data = filebase64("./04_ec2_userdata.sh")
}

# ---------------------------------------------
# auto scaling group
# ---------------------------------------------
resource "aws_autoscaling_group" "AutoScalingGroup" {
  name = "${var.project}-${var.environment}-AutoScalingGroup"

  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  health_check_type         = "ELB"
  health_check_grace_period = 300
  protect_from_scale_in     = false

  vpc_zone_identifier = [
    aws_subnet.PublicSubnet1a.id,
    aws_subnet.PublicSubnet1c.id
  ]

  target_group_arns = [aws_lb_target_group.ALBTargetGroup.arn]

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.EC2LaunchTemplate.id
        version            = "$Latest"
      }
      # # 起動テンプレートの情報を上書き
      # override {
      #   instance_type = "t2.micro"
      # }
    }
  }
}
