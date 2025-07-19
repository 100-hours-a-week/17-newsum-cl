resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Subnets
resource "aws_subnet" "public" {
  for_each = var.public_subnets
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = {
    Name = each.value.name
  }
}

resource "aws_subnet" "was" {
  for_each = var.was_subnets
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = {
    Name = each.value.name
  }
}

resource "aws_subnet" "db" {
  for_each = var.db_subnets
  vpc_id = aws_vpc.this.id
  cidr_block = each.value.cidr
  availability_zone = each.value.az
  tags = {
    Name = each.value.name
  }
}

# Elastic IPs
resource "aws_eip" "nat" {
  # was subnet 갯수만큼 nat_gateway에 할당할 EIP 생성 (instance일 경우는 생성하지 않음)
  for_each = var.nat_type == "gateway" ? var.public_subnets : {}

  # 기존 EIP 삭제하고 새로 생성하는 과정에서 삭제 전에 새로운거 만들고 삭제하게끔 설정 -> NAT Gateway의 다운타임 방지 및 꼬이는 상황 방지
  # 기존 EIP를 삭제하는 상황은 tag를 Name = eip-1 -> Name = nat-1 로 수정할 때
  # 태그가 변경되었기 때문에 새로운 리소스 생성으로 보고 기존 아이피를 삭제하고 새로 생성함
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "nat-eip-${each.value.az}"  # ex) nat-eip-us-east-1a
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  for_each = var.nat_type == "gateway" ? var.public_subnets : {}
  allocation_id = aws_eip.nat[each.key].id
  subnet_id = [
  for s in values(aws_subnet.public) :
    s.id
    if s.availability_zone == each.value.az
  ][0]
  tags = {
    Name = "nat-gateway-${each.value.az}"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.vpc_name}-rtb-public" }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "was" {
  for_each = aws_subnet.was
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.vpc_name}-rtb-was-${each.key}" }
}

resource "aws_route" "private_nat" {
  for_each = aws_subnet.was
  route_table_id         = aws_route_table.was[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = [
    for k, nat in aws_nat_gateway.nat :
      nat.id
      if aws_subnet.public[k].availability_zone == each.value.availability_zone
  ][0]
}

resource "aws_route_table_association" "was" {
  for_each = aws_subnet.was
  subnet_id     = each.value.id
  route_table_id = aws_route_table.was[each.key].id
}
