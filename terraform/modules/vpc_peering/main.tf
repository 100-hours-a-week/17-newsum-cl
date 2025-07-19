resource "aws_vpc_peering_connection" "this" {
  peer_vpc_id = var.peer_vpc_id
  vpc_id = var.vpc_id
  auto_accept = var.auto_accept

  tags = {
    Name = var.name
  }  
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  auto_accept = var.auto_accept
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id

  tags = {
    Name = "${var.name}-accepter"
  }  
}