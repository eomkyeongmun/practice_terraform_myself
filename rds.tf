########################################
# RDS MySQL (실습용 최소 구성)
# - Private Subnet 2개(private_a/private_b)에 배치
# - Publicly accessible = false (인터넷 직접 접근 차단)
# - SG는 일단 VPC CIDR에서 3306 허용(실습용)
########################################

# 1) DB Security Group
resource "aws_security_group" "db_sg" {
  name        = "${var.name}-db-sg"
  description = "Allow MySQL from inside VPC (lab)"
  vpc_id      = aws_vpc.this.id

  # 인바운드: VPC 내부에서만 MySQL(3306) 접근 허용(실습용)
  ingress {
    description = "MySQL from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # 아웃바운드: 전체 허용(기본적으로 필요)
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-db-sg" }
}

# 2) DB Subnet Group (RDS는 반드시 필요)
resource "aws_db_subnet_group" "db_subnets" {
  name = "${var.name}-db-subnet-group"

  # DB는 private 서브넷에만 배치
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = { Name = "${var.name}-db-subnet-group" }
}

# 3) RDS MySQL Instance (Single-AZ, 실습용)
resource "aws_db_instance" "mysql" {
  identifier = "${var.name}-mysql"

  # 엔진
  engine         = "mysql"
  engine_version = "8.0"

  # 스펙(실습 최소)
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp3"

  # DB 초기 설정 (terraform.tfvars에서 값이 들어온다고 가정)
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # 네트워크
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  publicly_accessible    = false

  # 실습 편의(삭제 쉽게)
  skip_final_snapshot = true
  deletion_protection = false

  tags = { Name = "${var.name}-mysql" }
}
