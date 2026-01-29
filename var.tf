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


########################################
# App(EC2 PHP)에서 사용할 DB 접속 변수 추가
########################################

# webapp이 접속할 DB 계정(실습: webuser)
variable "app_db_user" {
  type    = string
  default = "webuser"
}

# webapp이 접속할 DB 비밀번호(민감정보)
variable "app_db_pass" {
  type      = string
  sensitive = true
}

# webapp이 사용할 DB 이름(실습: webtest)
variable "app_db_name" {
  type    = string
  default = "webtest"
}