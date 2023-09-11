# ---------------------------------------------
# ALB
# ---------------------------------------------
resource "aws_lb" "ALB" {
  name               = "${var.project}-${var.environment}-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.ALBSecurityGroup.id
  ]
  subnets = [
    aws_subnet.PublicSubnet1a.id,
    aws_subnet.PublicSubnet1c.id
  ]

  tags = {
    Name    = "${var.project}-${var.environment}-ALB"
    Project = var.project
    Env     = var.environment
  }
}

resource "aws_lb_listener" "ALBListener_http" {
  load_balancer_arn = aws_lb.ALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ALBTargetGroup.arn
  }
}

# ---------------------------------------------
# target group
# ---------------------------------------------
resource "aws_lb_target_group" "ALBTargetGroup" {
  name        = "${var.project}-${var.environment}-ALB-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.TerraformVPC.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    interval            = 10
    healthy_threshold   = 2
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name    = "${var.project}-${var.environment}-ALB-tg"
    Project = var.project
    Env     = var.environment
  }
}

# resource "aws_lb_target_group_attachment" "instance" {
#   target_group_arn = aws_lb_target_group.ALBTargetGroup.arn
#   target_id        = aws_instance.EC2WebServer01.id
# }
