output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_was_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private_was[*].id
}

output "private_db_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private_db[*].id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.this.id
}

# output "nat_instance_id" {
#   description = "The ID of the NAT instance"
#   value       = aws_instance.nat_instance.id  # 이 부분을 주석 처리하거나 제거해야 합니다.
# }

output "public_route_table_ids" {
  description = "List of public route table IDs"
  value       = [aws_route_table.public.id]
}

output "private_was_route_table_ids" {
  description = "List of private route table IDs"
  value       = aws_route_table.private_was[*].id
}

output "private_db_route_table_ids" {
  description = "List of private route table IDs"
  value       = aws_route_table.private_db[*].id
}