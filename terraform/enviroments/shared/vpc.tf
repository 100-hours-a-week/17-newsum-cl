module "vpc" {
  source     = "../../modules/vpc"
  vpc_name   = "shared-vpc"
  vpc_cidr   = "10.2.0.0/16"
  nat_type = "instance"

  public_subnets = {
    public-a = { cidr = "10.2.0.0/24", az = "us-east-1a", name = "dev-public-subnet-a" },
  }

  was_subnets = {
    was-a = { cidr = "10.2.100.0/24", az = "us-east-1a", name = "dev-was-subnet-a" },
  }

}

output "vpc_id" {
  value = module.vpc.vpc_id
}