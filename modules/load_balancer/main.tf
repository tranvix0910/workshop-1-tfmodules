# Frontend Target Group
resource "aws_lb_target_group" "frontend_target_group" {
  name        = "frontend-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "80"
    healthy_threshold   = 5
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
  }
}

# Backend Target Group
resource "aws_lb_target_group" "backend_target_group" {
  name        = "backend-target-group"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/api/students"
    protocol            = "HTTP"
    port                = "8080"
    healthy_threshold   = 5
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
  }
}

# Application Load Balancer
resource "aws_lb" "load_balancer" {
  name               = var.load_balancer_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.vpc_security_group_ids
  subnets            = var.subnets
  enable_deletion_protection = false
  enable_http2               = true
  idle_timeout               = 60
  enable_cross_zone_load_balancing = true
}

# Load Balancer Listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_target_group.arn
  }
}

# Custom rule for /api/*
resource "aws_lb_listener_rule" "backend_api_rule" {
  listener_arn = "${aws_lb_listener.listener.arn}"
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.backend_target_group.arn}"
  }
  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

