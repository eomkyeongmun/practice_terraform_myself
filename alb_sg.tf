########################################
# ALB Security Group (실습용 최소)
# - Inbound: 80(HTTP) from 0.0.0.0/0
# - Outbound: all (ALB -> EC2 타겟 헬스체크/전달 필요)
########################################

resource "aws_security_group" "alb_sg" {
  name        = "${var.name}-alb-sg"
  description = "ALB SG: allow HTTP from Internet"
  vpc_id      = aws_vpc.this.id

  # 인터넷 -> ALB (HTTP)
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ALB -> (타겟/외부) 아웃바운드 허용
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-alb-sg"
  }
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}
