# 17-newsum-cloud

17팀 클라우드 인프라스트럭처 레포지토리

## 📁 디렉토리 구조

```
17-newsum-cl/
├── .github/           # GitHub 워크플로우 및 이슈 템플릿
├── scripts/           # 유틸리티 스크립트
├── terraform/         # 인프라스트럭처 코드
│   ├── environments/  # 환경별 설정
│   │   ├── dev/      # 개발 환경
│   │   ├── prod/     # 운영 환경
│   │   ├── stage/    # 스테이징 환경
│   │   └── shared/   # 공유 리소스
│   ├── modules/      # 재사용 가능한 모듈
│   │   ├── alb/      # Application Load Balancer
│   │   ├── autoscaling/  # Auto Scaling
│   │   ├── ec2/      # EC2 인스턴스
│   │   ├── sg/       # Security Group
│   │   ├── subnet/   # 서브넷
│   │   ├── transit_gateway/  # Transit Gateway
│   │   └── vpc/      # VPC
│   ├── provider.tf   # 프로바이더 설정
│   ├── variables.tf  # 변수 정의
│   └── versions.tf   # 버전 제약 조건
└── README.md         # 프로젝트 문서
```

## 🚀 시작하기

### 전제 조건

- Terraform >= 1.0.0
- AWS CLI 구성 완료
- 적절한 IAM 권한 보유

### 개발 환경 설정

1. 저장소 클론
   ```bash
   git clone [repository-url]
   cd 17-newsum-cl
   ```

2. Terraform 초기화
   ```bash
   cd terraform/environments/dev  # 또는 해당 환경
   terraform init
   ```

3. 계획 확인
   ```bash
   terraform plan
   ```

4. 적용
   ```bash
   terraform apply
   ```

## 📝 모듈 사용법

각 모듈은 독립적으로 사용할 수 있으며, 필요한 변수들을 정의하여 사용합니다.

예시: VPC 모듈 사용

```hcl
module "vpc" {
  source = "../../modules/vpc"
  
  name               = "my-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["ap-northeast-2a", "ap-northeast-2c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
}
```

## 🤝 기여하기

1. 이슈 생성
2. feature 브랜치 생성 (`feature/기능-이름`)
3. 변경사항 커밋 및 푸시
4. Pull Request 생성

## 📜 라이선스

이 프로젝트는 팀 내부 사용을 위한 전용 라이선스를 따릅니다.
