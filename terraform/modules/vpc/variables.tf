variable "vpc_name" {
  type = string
  default = ""
}

variable "vpc_cidr" {
  type = string
  default = ""
}

variable "public_subnets" {
  type = map(object({
    cidr = string
    az   = string
    name = string
  }))
  default = {}
}

variable "was_subnets" {
  type = map(object({
    cidr = string
    az   = string
    name = string
  }))
  default = {}
}

variable "db_subnets" {
  type = map(object({
    cidr = string
    az = string
    name = string
  }))
  default = {}
}

variable "nat_type" {
  description = "NAT 타입: 'gateway' 또는 'instance'"
  type        = string
  default     = "gateway"
}

