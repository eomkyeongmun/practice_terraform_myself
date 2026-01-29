########################################
# ALB (Application Load Balancer)
# - Public Subnet a,b에 생성
# - Listener(80) -> Target Group으로 전달
# - Target Group에는 EC2 2대(app_a, app_b) 등록
########################################

# 1) ALB 생성 (인터넷-facing)
resource "aws_lb" "app_alb" {
  name               = "${var.name}-alb"
  load_balancer_type = "application"
  internal           = false

  # ALB는 퍼블릭 서브넷 2개 이상(AZ 분산) 권장/필수급
  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  # ALB용 보안그룹(80 인바운드 열려있음)
  security_groups = [aws_security_group.alb_sg.id]

  tags = {
    Name = "${var.name}-alb"
  }
}

# 2) Target Group (ALB가 트래픽을 보낼 대상 그룹)
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id

  # 헬스체크 (기본 / 로 충분)
  health_check {
    protocol            = "HTTP"
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.name}-tg"
  }
}

# 3) EC2들을 Target Group에 등록
resource "aws_lb_target_group_attachment" "app_a" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_a.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "app_b" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_b.id
  port             = 80
}

# 4) Listener (80) -> Target Group으로 포워딩
resource "aws_lb_listener" "http_80" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# 5) 접속용 DNS 출력
output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}
