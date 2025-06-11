# ALB Security Group ID
output "alb_security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "was_security_group_id" {
  description = "The ID of the WAS security group"
  value       = aws_security_group.was.id
}

output "db_security_group_id" {
  description = "The ID of the DB security group"
  value       = aws_security_group.db.id
}

output "redis_security_group_id" {
  description = "The ID of the Redis security group"
  value       = aws_security_group.redis.id
}

output "kafka_security_group_id" {
  description = "The ID of the Kafka security group"
  value       = aws_security_group.kafka.id
}

output "openvpn_security_group_id" {
  description = "The ID of the OpenVPN security group"
  value       = aws_security_group.openvpn.id
}

output "nat_security_group_id" {
  description = "The ID of the NAT security group"
  value       = aws_security_group.nat.id
} 
    