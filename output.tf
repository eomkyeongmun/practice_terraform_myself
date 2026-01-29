output "vpc_id" {
  value = aws_vpc.this.id
}

# Public Subnets
output "public_subnet_a_id" {
  value = aws_subnet.public_a.id
}

output "public_subnet_b_id" {
  value = aws_subnet.public_b.id
}

# Private Subnets
output "private_subnet_a_id" {
  value = aws_subnet.private_a.id
}

output "private_subnet_b_id" {
  value = aws_subnet.private_b.id
}

# AZ 확인용
output "az_a" {
  value = local.az_a
}

output "az_b" {
  value = local.az_b
}

output "db_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "db_port" {
  value = aws_db_instance.mysql.port
}

output "app_a_public_ip" {
  value = aws_instance.app_a.public_ip
}

output "app_b_public_ip" {
  value = aws_instance.app_b.public_ip
}
