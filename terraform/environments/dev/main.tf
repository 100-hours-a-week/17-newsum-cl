# /Users/roklee/NewSum/17-newsum-cl/terraform/environments/dev/main.tf

# VPC 모듈
module "vpc" {
  source = "../../modules/vpc"
  
  name = "dev"
  cidr = "10.1.0.0/16"  # 기존 dev-vpc의 CIDR
  azs  = ["ap-northeast-2a", "ap-northeast-2b"]

  # 서브넷 CIDR 설정
  public_subnets   = ["10.1.1.0/24", "10.1.0.0/24"]    # dev-public-subnet-a, dev-public-subnet-b
  was_subnets      = ["10.1.100.0/24", "10.1.110.0/24"] # dev-was-subnet-a, dev-was-subnet-b
  db_subnets       = ["10.1.200.0/24", "10.1.210.0/24"] # dev-db-subnet-a, dev-db-subnet-b

  vpc_peering_connection_id = "dev"

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

# 보안그룹

# ALB
module "alb_sg" {
  source = "../../modules/sg"
  
  name = "alb"
  description = "alb security group"
  vpc_id = module.vpc.vpc_id
}

# WAS
module "was_sg" {
  source = "../../modules/sg" 
  
  name = "was"
  description = "was security group"
  vpc_id = module.vpc.vpc_id
}

# DB
module "db_sg" {
  source = "../../modules/sg"
  
  name = "db"
  description = "db security group"
  vpc_id = module.vpc.vpc_id
}

# Redis
module "redis_sg" {
  source = "../../modules/sg"

  name = "redis"
  description = "redis security group"
  vpc_id = module.vpc.vpc_id
}

# NAT
module "nat_sg" {
  source = "../../modules/sg"

  name = "nat"
  description = "nat security group"
  vpc_id = module.vpc.vpc_id
}

# OpenVPN
module "openvpn_sg" {
  source = "../../modules/sg"

  name = "openvpn"
  description = "openvpn security group"
  vpc_id = module.vpc.vpc_id
}

# Kafka
module "kafka_sg" {
  source = "../../modules/sg"
  
  name = "kafka"
  description = "kafka security group"
  vpc_id = module.vpc.vpc_id
}