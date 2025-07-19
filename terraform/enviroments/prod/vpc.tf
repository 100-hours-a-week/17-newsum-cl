# module "vpc" {
#   source     = "../../modules/vpc"
#   vpc_name   = "prod-vpc"
#   vpc_cidr   = "10.0.0.0/16"

#   public_subnets = {
#     public-a = { cidr = "10.0.0.0/24", az = "us-east-1a", name = "prod-public-subnet-a" },
#     public-b = { cidr = "10.0.10.0/24", az = "us-east-1b", name = "prod-public-subnet-b" }
#   }

#   was_subnets = {
#     was-a = { cidr = "10.0.100.0/24", az = "us-east-1a", name = "prod-was-subnet-a" },
#     was-b = { cidr = "10.0.110.0/24", az = "us-east-1b", name = "prod-was-subnet-b" }
#   }

#   db_subnets = {
#     db-a = { cidr = "10.0.200.0/24", az = "us-east-1a", name = "prod-db-subnet-a" },
#     db-b = { cidr = "10.0.210.0/24", az = "us-east-1b", name = "prod-db-subnet-b" }
#   }
# }

# output "vpc_id" {
#   value = module.vpc.vpc_id
# }

module "vpc_from_public" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}