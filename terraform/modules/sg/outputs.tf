  output "security_group_id" {
    value = aws_security_group.this.id
    description = "value of security group id"
  }