variable "name" {
  description = "Name to be used on all resources as prefix"
  type        = string
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "was_subnets" {
  description = "A list of WAS subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "db_subnets" {
  description = "A list of private database subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "vpc_peering_connection_id" {
  description = "The ID of the VPC peering connection"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "nat_instance_id" {
  description = "The ID of the NAT instance"
  type        = string
  default     = null
}

variable "nat_instance_network_interface_id" {
  description = "The network interface ID of the NAT instance"
  type        = string
  default     = null
}