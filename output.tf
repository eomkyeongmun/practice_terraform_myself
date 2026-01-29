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
