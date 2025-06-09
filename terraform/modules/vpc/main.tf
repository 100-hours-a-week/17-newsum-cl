# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = var.name
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
      "kubernetes.io/role/elb" = "1"
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
    Name = "${var.name}-public"
  }
}

# 퍼블릭 서브넷과 라우트 테이블 연결
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 프라이빗 서브넷
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index % length(var.azs)]

  tags = merge(
    {
      Name = "${var.name}-private-${element(split("-", var.azs[count.index % length(var.azs)]), 2)}"
      "kubernetes.io/role/internal-elb" = "1"
    },
    var.tags
  )
}

# NAT 게이트웨이를 위한 EIP
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0

  tags = {
    Name = "${var.name}-nat"
  }
}

# NAT 게이트웨이
resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0
  
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index % length(var.public_subnets)].id

  tags = {
    Name = "${var.name}-nat"
  }

  
  depends_on = [aws_internet_gateway.this]
}

# 프라이빗 라우트 테이블
resource "aws_route_table" "private" {
  count  = length(var.private_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  route {
    cidr_block      = "0.0.0.0/0"
    network_interface_id = data.aws_instance.nat_instance.network_interface_id
  }

  tags = {
    Name = "${var.name}-private"
  }
}

# 프라이빗 서브넷과 라우트 테이블 연결
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

# NAT 인스턴스의 ENI 가져오기
data "aws_instance" "nat_instance" {
  instance_id = "i-041df7cc1fac8a438"
}

# VPC 엔드포인트 (S3)
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  
  tags = {
    Name = "${var.name}-s3-endpoint"
  }
}

# VPC 엔드포인트 라우트 테이블 연결
resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count = length(var.public_subnets)
  
  route_table_id  = element(aws_route_table.public.*.id, count.index % length(var.azs))
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

data "aws_region" "current" {}
