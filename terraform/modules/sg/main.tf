# alb_sg
resource "aws_security_group" "alb" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# was_sg
resource "aws_security_group" "was" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
}

# db_sg
resource "aws_security_group" "db" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
  }
}

# redis_sg
resource "aws_security_group" "redis" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
  }
}

# kafka_sg
resource "aws_security_group" "kafka" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 9092
    to_port         = 9092
    protocol        = "tcp"
  }
}

# openvpn_sg
resource "aws_security_group" "openvpn" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  ingress { 
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow SSH from anywhere"
  }

  ingress {
    from_port       = 1194
    to_port         = 1194
    protocol        = "udp"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow OpenVPN from anywhere"
  }

  ingress { 
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } 
}

# nat_sg
resource "aws_security_group" "nat" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/8"]
    description     = "Allow NAT from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}