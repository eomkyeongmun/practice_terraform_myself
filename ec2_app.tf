########################################
# ec2_app.tf (최종 예시)
# - UserData를 템플릿 파일로 분리 (files/app_userdata.sh.tftpl)
# - DB 접속정보는 templatefile() 변수로 주입
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

# 2) UserData 템플릿 렌더링(공통)
locals {
  app_userdata = templatefile("${path.module}/files/app_userdata.sh.tftpl", {
    db_host = aws_db_instance.mysql.address
    db_user = var.app_db_user
    db_pass = var.app_db_pass
    db_name = var.app_db_name
  })
}

# 3) App EC2 (AZ a)
resource "aws_instance" "app_a" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true

  user_data                   = local.app_userdata
  user_data_replace_on_change = true

  key_name   = "demo-key"
  depends_on = [aws_db_instance.mysql]

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
  user_data_replace_on_change = true

  key_name   = "demo-key"
  depends_on = [aws_db_instance.mysql]

  tags = {
    Name = "${var.name}-app-b"
  }
}
