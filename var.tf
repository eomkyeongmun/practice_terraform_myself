# 리전 (기본 서울 리전)
variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-2"
}
# 이름 (기본 demo)
variable "name" {
  description = "Name prefix for tags"
  type        = string
  default     = "demo"
}
#VPC_CIDR (기본 10.0.0.0/16)
variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}
