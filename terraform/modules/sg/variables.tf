variable "name" {
  description = "Name to be used on all resources as prefix"
  type        = string
}

variable "description" {
  description = "Description of the security group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
# variable "ingress_rules" {
#   description = "List of ingress rules"
#   type = list(object({
#     from_port   = number
#     to_port     = number
#     protocol    = string
#     cidr_blocks = list(string)
#     description = optional(string)
#     security_groups = optional(list(string))
#   }))
#   default = []
# }

# variable "egress_rules" {
#   description = "List of egress rules"
#   type = list(object({
#     from_port   = number
#     to_port     = number
#     protocol    = string
#     cidr_blocks = list(string)
#     description = optional(string)
#     security_groups = optional(list(string))
#   }))
#   default = []
# }
