########################################
# APP Security Group (실습용 최소)
# - Inbound: 80(HTTP) from ALB-SG only
# - (선택) SSH: 내 IP에서만 22 허용(필요할 때만)
# - Outbound: all (앱 -> RDS 등 통신)
########################################

resource "aws_security_group" "app_sg" {
  name        = "${var.name}-app-sg"
  description = "APP SG: allow HTTP only from ALB"
  vpc_id      = aws_vpc.this.id

  # ALB -> APP (HTTP)
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # 앱 서버가 외부(예: 패키지 설치, DB 통신 등)로 나가는 건 일단 허용
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-app-sg"
  }
}

output "app_sg_id" {
  value = aws_security_group.app_sg.id
}
