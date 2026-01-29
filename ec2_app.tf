########################################
# EC2 2대(PHP App) - 실습용 최소
# - Public Subnet a,b에 1대씩
# - APP-SG 부착 (ALB에서만 80 허용)
# - UserData로 Apache + PHP + MySQL 드라이버 설치
# - index.php에 hostname 출력(부하분산 확인용)
########################################

# 1) 최신 Amazon Linux 2023 AMI 조회
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# 2) UserData: Apache/PHP 설치 + 간단 PHP 페이지 생성
locals {
  app_userdata = <<-EOF
    #!/bin/bash
    set -eux

    dnf -y update
    # 웹서버 + PHP + (MySQL 연결 확장/드라이버) 안전 조합
    dnf -y install httpd php php-mysqlnd php-mysqli php-pdo

    systemctl enable httpd
    systemctl start httpd

    cat > /var/www/html/index.php <<'PHP'
    <?php
      echo "Hello from: " . gethostname() . "<br>";
      echo "Time: " . date("c") . "<br>";
    ?>
    PHP
  EOF
}

# 3) App EC2 (AZ a)
resource "aws_instance" "app_a" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  user_data                   = local.app_userdata

  tags = {
    Name = "${var.name}-app-a"
  }
}

# 4) App EC2 (AZ b)
resource "aws_instance" "app_b" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_b.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  user_data                   = local.app_userdata

  tags = {
    Name = "${var.name}-app-b"
  }
}

