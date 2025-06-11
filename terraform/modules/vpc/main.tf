# VPC 생성
# - AWS VPC를 생성하는 기본 리소스
# - DNS 지원과 호스트명 지원을 활성화하여 VPC 내에서 DNS 사용 가능
# - 태그를 통해 VPC 식별 및 관리 용이
resource "aws_vpc" "this" {
  # VPC의 IP 주소 범위 설정
  # 예: 10.0.0.0/16
  cidr_block           = var.cidr

  # VPC 내에서 DNS 지원 활성화
  # 이를 통해 VPC 내의 리소스들이 DNS 이름을 사용할 수 있음
  enable_dns_support   = true

  # VPC 내에서 DNS 호스트명 지원 활성화
  # 이를 통해 인스턴스에 DNS 호스트명이 자동으로 할당됨
  enable_dns_hostnames = true

  # 리소스에 태그 설정
  # merge 함수를 사용하여 기본 이름 태그와 추가 태그를 병합
  tags = merge(
    {
      # 기본 이름 태그: VPC 이름에 '-vpc' 접미사 추가
      Name = "${var.name}-vpc"
    },
    # 추가 태그들 (예: Environment, Project 등)
    var.tags
  )
}

# 인터넷 게이트웨이 생성
# - VPC와 인터넷을 연결하는 게이트웨이
# - 퍼블릭 서브넷의 인스턴스가 인터넷과 통신할 수 있게 함
resource "aws_internet_gateway" "this" {
  # 위에서 생성한 VPC의 ID를 참조
  vpc_id = aws_vpc.this.id

  # 리소스에 태그 설정
  tags = {
    # 이름 태그: VPC 이름에 '-igw' 접미사 추가
    Name = "${var.name}-igw"
  }
}

# 퍼블릭 서브넷 생성
# - 인터넷과 직접 통신이 가능한 서브넷
# - 여러 가용영역에 걸쳐 생성 가능 (count 사용)
# - 자동으로 퍼블릭 IP 할당 설정
# - 각 서브넷은 고유한 CIDR 블록과 가용영역을 가짐
resource "aws_subnet" "public" {
  # public_subnets 변수의 길이만큼 서브넷 생성
  # 예: ["10.0.1.0/24", "10.0.2.0/24"]이면 2개의 서브넷 생성
  count = length(var.public_subnets)

  # 위에서 생성한 VPC의 ID를 참조
  vpc_id            = aws_vpc.this.id

  # 각 서브넷의 IP 주소 범위 설정
  # count.index를 사용하여 순차적으로 CIDR 블록 할당
  cidr_block        = var.public_subnets[count.index]

  # 서브넷이 위치할 가용영역 설정
  # 가용영역 목록을 순환하면서 할당
  availability_zone = var.azs[count.index % length(var.azs)]

  # 인스턴스 시작 시 자동으로 퍼블릭 IP 할당
  # 퍼블릭 서브넷의 인스턴스가 인터넷과 통신할 수 있도록 함
  map_public_ip_on_launch = true

  # 리소스에 태그 설정
  tags = merge(
    {
      # 이름 태그: VPC 이름, 서브넷 유형, 가용영역 정보 포함
      # 예: dev-public-a
      Name = "${var.name}-public-${element(split("-", var.azs[count.index % length(var.azs)]), 2)}"
    },
    var.tags
  )
}

# 퍼블릭 라우트 테이블 생성
# - 퍼블릭 서브넷의 트래픽을 제어하는 라우팅 규칙 정의
# - 모든 외부 트래픽(0.0.0.0/0)을 인터넷 게이트웨이로 전달
resource "aws_route_table" "public" {
  # 위에서 생성한 VPC의 ID를 참조
  vpc_id = aws_vpc.this.id

  # 라우팅 규칙 정의
  route {
    # 모든 외부 트래픽을 인터넷 게이트웨이로 전달
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  # 리소스에 태그 설정
  tags = {
    # 이름 태그: VPC 이름에 '-rtb-public' 접미사 추가
    Name = "${var.name}-rtb-public"
  }
}

# 퍼블릭 서브넷과 라우트 테이블 연결
# - 각 퍼블릭 서브넷을 퍼블릭 라우트 테이블과 연결
# - 이를 통해 퍼블릭 서브넷의 인스턴스가 인터넷과 통신 가능
resource "aws_route_table_association" "public" {
  # public_subnets 변수의 길이만큼 연결 생성
  count = length(var.public_subnets)

  # 연결할 서브넷 ID
  # count.index를 사용하여 순차적으로 서브넷 선택
  subnet_id      = aws_subnet.public[count.index].id

  # 연결할 라우트 테이블 ID
  route_table_id = aws_route_table.public.id
}

# WAS용 프라이빗 서브넷 생성
# - 웹 애플리케이션 서버용 프라이빗 서브넷
# - 인터넷과 직접 통신 불가능
# - 여러 가용영역에 걸쳐 생성
resource "aws_subnet" "private_was" {
  # was_subnets 변수의 길이만큼 서브넷 생성
  count = length(var.was_subnets)

  # 위에서 생성한 VPC의 ID를 참조
  vpc_id            = aws_vpc.this.id

  # 각 서브넷의 IP 주소 범위 설정
  cidr_block        = var.was_subnets[count.index]

  # 서브넷이 위치할 가용영역 설정
  availability_zone = var.azs[count.index % length(var.azs)]

  # 리소스에 태그 설정
  tags = merge(
    {
      # 이름 태그: VPC 이름, 서브넷 유형(WAS), 가용영역 정보 포함
      Name = "${var.name}-was-${element(split("-", var.azs[count.index % length(var.azs)]), 2)}"
    },
    var.tags
  )
}

# DB용 프라이빗 서브넷 생성
# - 데이터베이스 서버용 프라이빗 서브넷
# - 가장 높은 보안이 필요한 서브넷
# - 여러 가용영역에 걸쳐 생성
resource "aws_subnet" "private_db" {
  # db_subnets 변수의 길이만큼 서브넷 생성
  count = length(var.db_subnets)

  # 위에서 생성한 VPC의 ID를 참조
  vpc_id            = aws_vpc.this.id

  # 각 서브넷의 IP 주소 범위 설정
  cidr_block        = var.db_subnets[count.index]

  # 서브넷이 위치할 가용영역 설정
  availability_zone = var.azs[count.index % length(var.azs)]

  # 리소스에 태그 설정
  tags = merge(
    {
      # 이름 태그: VPC 이름, 서브넷 유형(DB), 가용영역 정보 포함
      Name = "${var.name}-db-${element(split("-", var.azs[count.index % length(var.azs)]), 2)}"
    },
    var.tags
  )
}

# WAS용 프라이빗 라우트 테이블 생성
# - WAS 서브넷의 트래픽을 제어하는 라우팅 규칙
# - VPC 피어링이 설정된 경우 다른 VPC(10.2.0.0/16)와의 통신 가능
# - WAS 서브넷이 있을 때만 생성
resource "aws_route_table" "private_was" {
  # WAS 서브넷이 있을 때만 생성 (조건부 생성)
  count  = length(var.was_subnets) > 0 ? 1 : 0

  # 위에서 생성한 VPC의 ID를 참조
  vpc_id = aws_vpc.this.id

  # 동적 라우팅 규칙 생성
  dynamic "route" {
    # VPC 피어링 ID가 있을 때만 라우트 생성
    for_each = var.vpc_peering_connection_id != null ? [1] : []
    content {
      # 다른 VPC의 CIDR 블록으로의 라우팅
      cidr_block                = "10.2.0.0/16"
      # VPC 피어링 연결 ID
      vpc_peering_connection_id = var.vpc_peering_connection_id
    }
  }

  # 리소스에 태그 설정
  tags = {
    # 이름 태그: VPC 이름에 '-rtb-was' 접미사 추가
    Name = "${var.name}-rtb-was"
  }
}

# DB용 프라이빗 라우트 테이블 생성
# - DB 서브넷의 트래픽을 제어하는 라우팅 규칙
# - VPC 피어링이 설정된 경우 다른 VPC(10.2.0.0/16)와의 통신 가능
# - DB 서브넷이 있을 때만 생성
resource "aws_route_table" "private_db" {
  # DB 서브넷이 있을 때만 생성 (조건부 생성)
  count  = length(var.db_subnets) > 0 ? 1 : 0

  # 위에서 생성한 VPC의 ID를 참조
  vpc_id = aws_vpc.this.id

  # 동적 라우팅 규칙 생성
  dynamic "route" {
    # VPC 피어링 ID가 있을 때만 라우트 생성
    for_each = var.vpc_peering_connection_id != null ? [1] : []
    content {
      # 다른 VPC의 CIDR 블록으로의 라우팅
      cidr_block                = "10.2.0.0/16"
      # VPC 피어링 연결 ID
      vpc_peering_connection_id = var.vpc_peering_connection_id
    }
  }

  # 리소스에 태그 설정
  tags = {
    # 이름 태그: VPC 이름에 '-rtb-db' 접미사 추가
    Name = "${var.name}-rtb-db"
  }
}

# WAS 서브넷과 라우트 테이블 연결
# - 각 WAS 서브넷을 WAS용 라우트 테이블과 연결
# - 이를 통해 WAS 서브넷의 인스턴스가 정의된 라우팅 규칙을 따름
resource "aws_route_table_association" "private_was" {
  # was_subnets 변수의 길이만큼 연결 생성
  count = length(var.was_subnets)

  # 연결할 서브넷 ID
  subnet_id      = aws_subnet.private_was[count.index].id

  # 연결할 라우트 테이블 ID
  route_table_id = aws_route_table.private_was[0].id
}

# DB 서브넷과 라우트 테이블 연결
# - 각 DB 서브넷을 DB용 라우트 테이블과 연결
# - 이를 통해 DB 서브넷의 인스턴스가 정의된 라우팅 규칙을 따름
resource "aws_route_table_association" "private_db" {
  # db_subnets 변수의 길이만큼 연결 생성
  count = length(var.db_subnets)

  # 연결할 서브넷 ID
  subnet_id      = aws_subnet.private_db[count.index].id

  # 연결할 라우트 테이블 ID
  route_table_id = aws_route_table.private_db[0].id
}

# VPC 피어링 연결 생성
# - 다른 VPC와의 통신을 위한 피어링 연결 설정
# - 피어링 ID가 제공된 경우에만 생성
# - 양방향 DNS 해석을 허용하여 서비스 검색 용이
# - 자동 수락 설정으로 피어링 연결 자동화
resource "aws_vpc_peering_connection" "this" {
  # 조건부 생성: vpc_peering_connection_id가 null이면 생성하지 않음(0), 
  # 값이 있으면 생성(1)
  count = var.vpc_peering_connection_id == null ? 0 : 1

  # 현재 VPC의 ID를 지정
  # aws_vpc.this.id는 위에서 생성한 VPC의 ID를 참조
  vpc_id = aws_vpc.this.id

  # 피어링할 대상 VPC의 ID를 지정
  # 변수로 전달받은 피어링 대상 VPC의 ID
  peer_vpc_id = var.vpc_peering_connection_id

  # 피어링 연결을 자동으로 수락하도록 설정
  # true로 설정하면 수동 승인 없이 자동으로 피어링 연결이 수립됨
  auto_accept = true

  # 피어링 연결을 수락하는 쪽(accepter)의 설정
  accepter {
    # 원격 VPC의 DNS 해석을 허용
    # 이를 통해 피어링된 VPC 간에 DNS 이름으로 서로의 리소스에 접근 가능
    allow_remote_vpc_dns_resolution = true
  }

  # 피어링 연결을 요청하는 쪽(requester)의 설정
  requester {
    # 원격 VPC의 DNS 해석을 허용
    # 이를 통해 피어링된 VPC 간에 DNS 이름으로 서로의 리소스에 접근 가능
    allow_remote_vpc_dns_resolution = true
  }

  # 리소스에 태그 설정
  tags = {
    # 이름 태그 설정: VPC 이름에 '-shared' 접미사 추가
    Name = "${var.name}-shared"
  }
}
