# /Users/roklee/NewSum/17-newsum-cl/terraform/environments/dev/main.tf
module "vpc" {
  source = "../../modules/vpc"
  
  name = "dev-vpc"
  cidr = "10.1.0.0/16"  # 기존 dev-vpc의 CIDR
  azs  = ["ap-northeast-2a", "ap-northeast-2b"]

  # 서브넷 CIDR 설정
  public_subnets   = ["10.1.1.0/24", "10.1.0.0/24"]    # public-subnet-a, public-subnet-b
  private_subnets  = ["10.1.200.0/24", "10.1.210.0/24"] # was-subnet-a, was-subnet-b
  database_subnets = ["10.1.100.0/24", "10.1.110.0/24"] # db-subnet-a, db-subnet-b

  enable_nat_gateway = false
  single_nat_gateway = false

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}