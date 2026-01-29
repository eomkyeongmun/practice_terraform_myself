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

variable "db_username" {
  type    = string
  default = "admin"
}

#password 는 defualt 값이 없도록 설계 

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type    = string
  default = "appdb"
}

