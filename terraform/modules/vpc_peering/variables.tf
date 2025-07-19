variable "vpc_id" {
  description = "Requester VPC ID"
  type = string
}

variable "peer_vpc_id" {
  description = "Accepter VPC ID"
  type = string
}

variable "auto_accept" {
  description = "Whether to auto-accept the connection"
  type = bool
  default = false
}

variable "name" {
  description = "Peering connection name"
  type = string
}