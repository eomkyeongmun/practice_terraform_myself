terraform {
  # Terraform CLI 자체 버전 하한선
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      # AWS Provider는 HashiCorp 공식 provider를 사용
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
