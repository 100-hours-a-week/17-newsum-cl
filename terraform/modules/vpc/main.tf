# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = "${var.name}-vpc"
    },
    var.tags
  )
}

# 인터넷 게이트웨이
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-igw"
  }
}

# 퍼블릭 서브넷
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.azs[count.index % length(var.azs)]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "${var.name}-public-${element(split("-", var.azs[count.index % length(var.azs)]), 2)}"
    },
    var.tags
  )
}

# 퍼블릭 라우트 테이블
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.name}-rtb-public"
  }
}

# 퍼블릭 서브넷과 라우트 테이블 연결
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 프라이빗 서브넷 was
resource "aws_subnet" "private_was" {
  count = length(var.was_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.was_subnets[count.index]
  availability_zone = var.azs[count.index % length(var.azs)]

  tags = merge(
    {
      Name = "${var.name}-was-${element(split("-", var.azs[count.index % length(var.azs)]), 2)}"
    },
    var.tags
  )
}

# 프라이빗 서브넷 db
resource "aws_subnet" "private_db" {
  count = length(var.db_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.db_subnets[count.index]
  availability_zone = var.azs[count.index % length(var.azs)]

  tags = merge(
    {
      Name = "${var.name}-db-${element(split("-", var.azs[count.index % length(var.azs)]), 2)}"
    },
    var.tags
  )
}

# 프라이빗 라우트 테이블 was
resource "aws_route_table" "private_was" {
  count  = length(var.was_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.vpc_peering_connection_id != null ? [1] : []
    content {
      cidr_block                = "10.2.0.0/16"
      vpc_peering_connection_id = var.vpc_peering_connection_id
    }
  }

  tags = {
    Name = "${var.name}-rtb-was"
  }
}

# 프라이빗 라우트 테이블 db
resource "aws_route_table" "private_db" {
  count  = length(var.db_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.vpc_peering_connection_id != null ? [1] : []
    content {
      cidr_block                = "10.2.0.0/16"
      vpc_peering_connection_id = var.vpc_peering_connection_id
    }
  }

  tags = {
    Name = "${var.name}-rtb-db"
  }
}


# 프라이빗 서브넷 was와 라우트 테이블 was 연결
resource "aws_route_table_association" "private_was" {
  count = length(var.was_subnets)

  subnet_id      = aws_subnet.private_was[count.index].id
  route_table_id = aws_route_table.private_was[0].id
}

# 프라이빗 서브넷 db와 라우트 테이블 db 연결
resource "aws_route_table_association" "private_db" {
  count = length(var.db_subnets)

  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db[0].id
}

# vpc peering connection
resource "aws_vpc_peering_connection" "this" {
  count = var.vpc_peering_connection_id == null ? 0 : 1

  vpc_id = aws_vpc.this.id
  peer_vpc_id = var.vpc_peering_connection_id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "${var.name}-shared"
  }
}
