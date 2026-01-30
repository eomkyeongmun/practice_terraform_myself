# Terraform Lab: ALB → EC2(PHP) → RDS(MySQL)

## 1) 아키텍처 구성 요소

### 네트워크
- **VPC**: `10.0.0.0/16`
- **Public Subnet (2개 / AZ 분산)**
  - `10.0.1.0/24` (ap-northeast-2a)
  - `10.0.2.0/24` (ap-northeast-2b)
- **Private Subnet (2개 / AZ 분산)**
  - `10.0.11.0/24` (ap-northeast-2a)
  - `10.0.12.0/24` (ap-northeast-2b)
- **IGW + Public Route Table**
  - Public Subnet의 기본 라우트: `0.0.0.0/0 → IGW`

### 로드밸런서 / 컴퓨트 / DB
- **ALB (Internet-facing)**
  - Public Subnet 2개에 생성
  - Listener: `80/HTTP`
  - Target Group: `80/HTTP`
  - Health Check: `GET /` (200~399)
- **EC2 2대 (Amazon Linux 2023)**
  - Public Subnet A/B에 1대씩
  - UserData로 Apache + PHP 설치 및 간단 웹 페이지 생성
- **RDS MySQL**
  - Private Subnet 2개로 DB Subnet Group 구성
  - `publicly_accessible = false` (인터넷 직접 접근 차단)

### Security Group 요약
- **ALB SG**
  - Inbound: `80/tcp` from `0.0.0.0/0`
  - Outbound: all
- **APP SG**
  - Inbound: `80/tcp` from **ALB SG only**
  - Outbound: all
- **DB SG (실습 단순화)**
  - Inbound: `3306/tcp` from **VPC CIDR(10.0.0.0/16)**
  - Outbound: all

---

## 2) 전체 동작 흐름(트래픽/구성 흐름)

### 트래픽 흐름
1. 사용자(Internet) → **ALB:80**
2. ALB → **Target Group**으로 포워딩
3. Target Group → **EC2(app_a/app_b):80** 로 분산 전달
4. EC2(PHP) → **RDS(MySQL):3306** 로 DB 접속 및 INSERT 수행

### Terraform apply 시점 흐름
1. **VPC/서브넷/라우팅/SG** 생성
2. **RDS 인스턴스** 생성(Private Subnet)
3. **EC2 2대** 생성 + **UserData 실행**(웹서버 설치/페이지 생성)
4. **ALB + Target Group + Listener** 생성 및 EC2 등록
5. Output으로 **ALB DNS** 받아 접속

> 참고: Terraform은 보통 “RDS 서버(인프라)”까지 만들고,  
> DB 내부의 “테이블/계정/초기 데이터(스키마)”는 별도 단계(초기화/마이그레이션)에서 준비한다.


아키텍처 다이어그램

```text
                   Internet (0.0.0.0/0)
                           |
                    (HTTP 80 inbound)
                           |
                    +----------------+
                    |   ALB (Public) |
                    |  SG: alb_sg    |
                    |  In: 80 from   |
                    |      0.0.0.0/0 |
                    +----------------+
                           |
                  (HTTP 80 forward to TG)
                           |
                 +----------------------+
                 | Target Group (HTTP)  |
                 | HealthCheck: /       |
                 +----------+-----------+
                            |
        +-------------------+-------------------+
        |                                       |
+---------------------+                +---------------------+
| EC2 app_a (Public A)|                | EC2 app_b (Public B)|
| Subnet: 10.0.1.0/24 |                | Subnet: 10.0.2.0/24 |
| SG: app_sg          |                | SG: app_sg          |
| In: 80 only from    |                | In: 80 only from    |
|     alb_sg          |                |     alb_sg          |
+----------+----------+                +----------+----------+
           |                                       |
           | (MySQL 3306)                          | (MySQL 3306)
           +-------------------+-------------------+
                               |
                      +-------------------+
                      | RDS MySQL (Private)|
                      | SubnetGroup:       |
                      |  - 10.0.11.0/24(A) |
                      |  - 10.0.12.0/24(B) |
                      | SG: db_sg          |
                      | In: 3306 from VPC  |
                      +-------------------+

VPC: 10.0.0.0/16
- IGW + Public RouteTable (0.0.0.0/0 → IGW)
- Public Subnet A/B: ALB, EC2
- Private Subnet A/B: RDS
