module "vpc" {
  source     = "../../modules/vpc"
  vpc_name   = "stage-vpc"
  vpc_cidr   = "10.3.0.0/16"

  public_subnets = {
    public-a = { cidr = "10.3.0.0/24", az = "ap-northeast-2a", name = "stage-public-subnet-a" },
    public-b = { cidr = "10.3.10.0/24", az = "ap-northeast-2b", name = "stage-public-subnet-b" }
  }

  was_subnets = {
    was-a = { cidr = "10.3.100.0/24", az = "ap-northeast-2a", name = "stage-was-subnet-a" },
    was-b = { cidr = "10.3.110.0/24", az = "ap-northeast-2b", name = "stage-was-subnet-b" }
  }

  db_subnets = {
    db-a = { cidr = "10.3.200.0/24", az = "ap-northeast-2a", name = "stage-db-subnet-a" },
    db-b = { cidr = "10.3.210.0/24", az = "ap-northeast-2b", name = "stage-db-subnet-b" }
  }
  
}

output "vpc_id" {
  value = module.vpc.vpc_id
}