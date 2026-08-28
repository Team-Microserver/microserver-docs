# Team-Microserver 문서 NAV 구조 개편 방향

## 1. 문서 목적

이 문서는 Team-Microserver 프로젝트 문서의 **전체 NAV 구조 개편 방향**을 정리한다.

이번 개편의 핵심은 단순히 메뉴 이름을 정리하는 것이 아니라,
MicroServer를 처음 이해하고 개발환경을 준비하는 단계부터 프로젝트 생성,
멀티 프로젝트 전환, 기능 개발, 서버 구성, 배포 및 운영까지의 흐름을
**실제 구축 순서와 동일하게 문서 NAV에 표현하는 것**이다.

향후 `mkdocs.yml`의 NAV를 개편할 때 이 문서를 기준으로 사용한다.

---

## 2. NAV 개편 배경

기존 NAV에서는 다음과 같은 구조를 사용했다.

```text
프로젝트 시작
├─ 프로젝트 이해
├─ 프로젝트 환경 구성
├─ 프로젝트 생성
└─ Python / MkDocs
```

프로젝트가 진행되면서 `프로젝트 환경 구성`과 `프로젝트 생성` 영역에 문서가 계속 추가되었다.

특히 다음 내용이 서로 혼재하기 시작했다.

- 개발 PC 및 로컬 개발환경 준비
- JDK 설치
- Gradle 설치 및 운영
- VS Code 설치 및 Extension 구성
- Spring Boot 프로젝트 생성
- 생성된 프로젝트의 JDK / VS Code 설정
- Gradle Wrapper 설정
- 프로젝트 실행 및 Build 검증

따라서 **프로젝트 생성 전의 개발환경 준비**와
**프로젝트 생성 이후의 프로젝트 설정 및 검증**을 명확하게 분리하기로 한다.

또한 프로젝트 생성 이후에는 바로 기능 개발로 이동하지 않고,
MicroServer의 실제 구조를 만들기 위한 **멀티 프로젝트 전환 단계**를 별도의 최상위 단계로 구성한다.

이후 실제 기능 개발을 수행하고,
마지막에는 서버 환경, 배포, 무중단 배포, CI/CD 및 운영 환경까지 연결한다.

---

# 3. 최상위 NAV 구조

Team-Microserver 문서의 최상위 NAV는 다음 흐름을 기본으로 한다.

```text
1. MicroServer 소개
        ↓
2. 개발 환경 구성
        ↓
3. 프로젝트 생성 및 검증
        ↓
4. 멀티 프로젝트 전환
        ↓
5. 기능 개발
        ↓
6. 서버 환경 구성
        ↓
7. 배포 환경 구성
        ↓
8. 운영 환경 구성
        ↓
9. 부록 / 문서 환경
```

`부록 / 문서 환경`은 필요에 따라 최하단에 구성한다.

---

# 4. 전체 NAV 구조안

## 4.1 MicroServer 소개

기존의 **`프로젝트 이해`를 `MicroServer 소개`로 변경**한다.

이 영역에서는 MicroServer가 무엇인지,
왜 구축하는지,
어떤 아키텍처 원칙을 가지고 있는지를 설명한다.

```text
MicroServer 소개
│
├─ 프로젝트 소개
├─ 구축 목표
├─ 프로젝트 로드맵
│
└─ 아키텍처 방향
    ├─ 아키텍처 방향 개요
    ├─ 구축 원칙 및 개발 방식
    ├─ 멀티모듈 및 프로젝트 구조
    ├─ 애플리케이션 계층 구조
    ├─ 공통 처리 구조
    ├─ 데이터 및 보안 아키텍처
    ├─ 공통 데이터 및 캐시 구조
    ├─ 금융 시스템 연계 아키텍처
    └─ 확장 및 운영 아키텍처
```

---

## 4.2 개발 환경 구성

이 영역은 **Spring Boot 프로젝트를 생성하기 전까지 필요한 개발환경을 준비하는 단계**다.

즉 프로젝트가 아직 존재하지 않아도 수행할 수 있는 작업을 중심으로 구성한다.

```text
개발 환경 구성
│
├─ 개발 장비 구성
├─ 프로젝트 로컬 개발환경 구성
├─ Git / GitHub 환경 구성
│
├─ JDK 설치 및 설정
│   ├─ 구성 및 운영 기준
│   ├─ Windows 설치 및 검증
│   ├─ macOS 설치 및 검증
│   └─ JDK 운영 및 문제 해결
│
├─ Build Tool 개발환경
│   ├─ Gradle 개요 및 프로젝트 기준
│   ├─ Gradle 설치 및 기본 환경 구성
│   ├─ Gradle Wrapper 및 프로젝트 운영 원칙
│   ├─ Gradle 명령어 / Cache / 문제 해결
│   └─ Maven 설치 및 기본 환경 구성 (비교 / 참고)
│
├─ VS Code 개발환경
│   ├─ VS Code 설정 원칙
│   ├─ VS Code 설치
│   ├─ VS Code 기본 설정
│   ├─ Java 개발 Extension 구성
│   ├─ Spring Boot Extension 구성
│   ├─ 개발 지원 Extension 및 Profile 구성
│   └─ JDK 연계 및 개발환경 운영
│
└─ Oracle / Docker 로컬 환경
    ├─ Docker Desktop 개요 및 공통 환경
    ├─ Windows Docker Desktop 설치
    ├─ macOS Docker Desktop 설치
    ├─ Oracle Database Free 설치 및 접속
    ├─ Oracle Tablespace 및 프로젝트 사용자 구성
    └─ Apple Silicon Oracle Docker 지원 및 검증
```

### 구분 원칙

이 영역에서는 다음 질문에 답한다.

> 프로젝트를 만들기 전에 개발자의 PC에는 무엇이 준비되어 있어야 하는가?

예를 들어 Portable VS Code의 `data/user-data/User/settings.json`,
JDK 설치 경로, Git 환경, Gradle 기본 환경 등은 이 영역에 포함한다.

---

# 5. 프로젝트 생성 및 검증

Spring Boot 프로젝트를 실제로 생성한 이후부터는 별도의 단계로 분리한다.

```text
프로젝트 생성 및 검증
│
├─ 프로젝트 생성
│   ├─ Spring Boot 프로젝트 생성
│   ├─ Git Repository 초기화 및 최초 Commit
│   └─ 생성 프로젝트 구조 확인 및 초기 정리
│
├─ 프로젝트 개발환경 설정
│   ├─ 프로젝트 JDK / VS Code Workspace 설정
│   ├─ Gradle Wrapper 및 프로젝트 Gradle 설정
│   └─ Maven Wrapper 및 프로젝트 Maven 설정 (비교 / 참고)
│
└─ 프로젝트 초기 실행 및 검증
    └─ Spring Boot 초기 실행 및 Build 검증
```

### 구분 원칙

이 단계는 다음 질문에 답한다.

> 생성된 Spring Boot 프로젝트가 개발 가능한 정상 상태인가?

따라서 다음 작업은 이 영역에 포함한다.

- `build.gradle` 확인
- `settings.gradle` 확인
- Gradle Wrapper 확인
- 프로젝트별 VS Code 설정
- 프로젝트별 JDK 연결
- Java Project 인식 확인
- Gradle Project 인식 확인
- `gradlew build`
- Spring Boot 실행 검증
- Git 초기 Commit / Push

VS Code의 **사용자 전역 설정**은 개발 환경 구성에 속하지만,
프로젝트의 `.vscode/settings.json`과 같은 **프로젝트별 설정**은 이 단계에 속한다.

---

# 6. 멀티 프로젝트 전환

프로젝트 생성과 초기 검증이 완료된 후에는
단일 Spring Boot 프로젝트를 MicroServer 구조에 맞게 확장한다.

이를 **`멀티 프로젝트 전환`이라는 독립된 최상위 NAV 단계**로 구성한다.

```text
멀티 프로젝트 전환
│
├─ 멀티 프로젝트 구성 개요
├─ Gradle Multi-Project 기본 구성
├─ Maven 멀티모듈 기본 구성 (비교 / 참고)
│
├─ 모듈 구성
│   ├─ common
│   ├─ runtime
│   └─ admin
│
├─ 모듈 간 의존성 구성
└─ 멀티 프로젝트 실행 및 Build 검증
```

### 중요한 추가 검토 사항

현재 `common`, `runtime`, `admin` 등을 하나의 Repository 안의
멀티모듈로 구성하는 방안을 검토하고 있으나,
**공통 Framework를 일반 업무 개발자에게 어떤 방식으로 제공할 것인지**에 따라
최종 구조는 변경될 수 있다.

Team-Microserver가 지향하는 방향은 다음과 같다.

```text
Framework 개발 영역
        ↓
공통 Framework Build
        ↓
JAR / Starter Artifact 배포
        ↓
일반 업무 개발 프로젝트
        ↓
업무 Domain 개발
```

즉 일반 업무 개발자가 Framework의 공통 소스를 직접 수정하는 것이 아니라,
배포된 공통 라이브러리를 의존성으로 사용하고 업무 개발에 집중하는 구조를 지향한다.

따라서 향후 이 단계에서는 다음 두 가지를 명확하게 구분해야 한다.

1. **Repository / 프로젝트의 물리적 분리**
2. **각 Repository 내부에서의 Multi-Module 구성**

멀티모듈 자체를 Framework 배포 방식으로 보지 않는다.

멀티모듈은 하나의 프로젝트 내부에서 책임과 Build 단위를 분리하는 수단으로 사용하고,
Framework와 업무 프로젝트의 개발/배포 경계는 별도 Repository와 Artifact 배포로 구성하는 방향을 우선 검토한다.

---

# 7. 기능 개발

멀티 프로젝트 구조가 확정되고 정상 Build가 검증되면
실제 MicroServer Framework 기능을 단계적으로 구현한다.

```text
기능 개발
│
├─ 프로젝트 공통 구조
│
├─ 공통 Framework
│   ├─ 공통 Response
│   ├─ 공통 예외 처리
│   ├─ Logging
│   ├─ Filter
│   └─ 공통 Utility
│
├─ Database
│   ├─ Oracle 연동
│   ├─ DataSource
│   ├─ MyBatis
│   ├─ Transaction
│   └─ Multi DataSource
│
├─ Security
│   ├─ Spring Security
│   ├─ 사용자 관리
│   └─ Role / 권한
│
├─ Cache / 공통 데이터
├─ 파일 처리
├─ 외부 시스템 연계
├─ Batch
└─ 업무 기능 / Sample
```

### 기능 개발의 기본 원칙

MicroServer Framework가 다음과 같은 공통 설정과 표준 동작을 제공한다.

```text
DataSource
Transaction
Security
Logging
Web
MyBatis / JPA
Exception
Cache
공통 Utility
외부 연계
```

일반 업무 개발자는 가능한 한 이러한 내부 Framework 설정을 몰라도
다음 영역에 집중할 수 있어야 한다.

```text
Controller
Service
Domain
Repository / Mapper
DTO
업무 Validation
업무 Process
```

---

# 8. 서버 환경 구성

기능 개발 이후 실제 애플리케이션을 실행할 서버 환경을 구성한다.

```text
서버 환경 구성
│
├─ 서버 구성 개요
├─ Linux 서버 기본 환경
├─ JDK Runtime 환경
├─ 애플리케이션 실행 환경
├─ Network / Port / Firewall
├─ Database 연결 환경
├─ Reverse Proxy
├─ 환경변수 및 Secret
└─ Spring Profile 및 서버별 설정
```

이 영역에서는 다음 질문에 답한다.

> 개발된 MicroServer 애플리케이션을 실제로 어디에서, 어떤 환경으로 실행할 것인가?

---

# 9. 배포 환경 구성

서버 환경이 준비되면 애플리케이션을 Build하여
서버에 안정적으로 배포하는 방법을 구성한다.

```text
배포 환경 구성
│
├─ 배포 아키텍처 및 전략
├─ Build 및 배포 Package
├─ Spring Boot 서버 배포
│
├─ 환경별 배포
│   ├─ Local
│   ├─ Development
│   ├─ Test
│   └─ Production
│
├─ 무중단 배포
│   ├─ 무중단 배포 개요
│   ├─ Blue-Green
│   ├─ Rolling
│   ├─ Health Check
│   ├─ Traffic 전환
│   └─ Rollback
│
└─ CI / CD
    ├─ CI / CD 개요
    ├─ GitHub Actions
    ├─ Build / Test 자동화
    └─ 배포 자동화
```

### 서버 환경 구성과 배포 환경 구성의 차이

```text
서버 환경 구성
    = 애플리케이션이 실행될 환경을 준비

배포 환경 구성
    = 만들어진 애플리케이션을 서버에 전달하고 실행 상태로 전환
```

---

# 10. 운영 환경 구성

배포 이후 안정적인 서비스 운영을 위한 영역이다.

```text
운영 환경 구성
│
├─ 운영 환경 개요
├─ Logging
├─ Monitoring
├─ Application Health Check
├─ 장애 대응
├─ Backup / Recovery
├─ 운영 보안
└─ 운영 및 장애 대응 가이드
```

이 단계에서는 단순히 애플리케이션이 실행되는 것에서 끝나지 않고,
실제 운영 중 발생하는 장애와 상태를 확인하고 대응할 수 있는 체계를 구성한다.

---

# 11. 부록 / 문서 환경

기존 `Python / MkDocs`는 MicroServer Runtime 또는 Framework 자체를 구축하기 위한 기술이라기보다
**Team-Microserver 기술문서 사이트를 관리하기 위한 환경**에 가깝다.

따라서 주요 구축 흐름과 분리하여 최하단에 배치하는 것을 검토한다.

```text
부록 / 문서 환경
│
└─ Python / MkDocs
    ├─ Windows 환경 구성
    └─ macOS 환경 구성
```

---

# 12. 전체 구축 흐름

전체 문서 구조는 다음 개발 Lifecycle을 표현한다.

```mermaid
flowchart LR

    A[MicroServer 소개]
    B[개발 환경 구성]
    C[프로젝트 생성 및 검증]
    D[멀티 프로젝트 전환]
    E[기능 개발]
    F[서버 환경 구성]
    G[배포 환경 구성]
    H[운영 환경 구성]

    A --> B
    B --> C
    C --> D
    D --> E
    E --> F
    F --> G
    G --> H
```

각 단계의 의미는 다음과 같다.

| 단계 | 핵심 질문 |
|---|---|
| MicroServer 소개 | 무엇을 만들고 왜 만드는가? |
| 개발 환경 구성 | 개발을 시작하려면 무엇이 필요한가? |
| 프로젝트 생성 및 검증 | 생성한 프로젝트가 정상적인 개발 상태인가? |
| 멀티 프로젝트 전환 | 실제 MicroServer 구조를 어떻게 구성할 것인가? |
| 기능 개발 | Framework가 어떤 표준 기능을 제공할 것인가? |
| 서버 환경 구성 | 애플리케이션을 어디에서 실행할 것인가? |
| 배포 환경 구성 | 애플리케이션을 어떻게 안정적으로 배포할 것인가? |
| 운영 환경 구성 | 배포된 시스템을 어떻게 안정적으로 운영할 것인가? |

---

# 13. 향후 `mkdocs.yml` 개편 기준

최상위 NAV의 기본 형태는 다음을 기준으로 한다.

```yaml
nav:

  - MicroServer 소개:
      # 프로젝트 소개 / 목표 / 로드맵 / 아키텍처

  - 개발 환경 구성:
      # 개발 장비 / Git / JDK / Gradle / VS Code / Oracle Docker

  - 프로젝트 생성 및 검증:
      # Spring Boot 생성 / 프로젝트 설정 / 실행 및 Build 검증

  - 멀티 프로젝트 전환:
      # Multi-Project 구조 / 모듈 / 의존성 / Build 검증

  - 기능 개발:
      # 공통 Framework / DB / Security / Cache / 연계 등

  - 서버 환경 구성:
      # Linux / Runtime / Network / DB / Reverse Proxy

  - 배포 환경 구성:
      # Build / 환경별 배포 / 무중단 배포 / CI-CD

  - 운영 환경 구성:
      # Logging / Monitoring / 장애 / Backup / 보안

  - 부록 / 문서 환경:
      # Python / MkDocs 등
```

!!! note "NAV 개편 원칙"
    기존 문서 파일을 무조건 이동하거나 새로 만드는 것이 목적이 아니다.

    먼저 **전체 Lifecycle을 기준으로 NAV의 논리적인 위치를 확정한 후**
    현재 존재하는 Markdown 문서를 해당 위치에 재배치한다.

    실제 `mkdocs.yml` 수정 시에는 존재하지 않는 Markdown 경로를 임의로 추가하지 않고,
    현재 파일 존재 여부를 확인하면서 단계적으로 반영한다.

---

# 14. 최종 방향

Team-Microserver 문서는 단순한 Framework API 설명서가 아니라
다음 전체 과정을 직접 구축하고 검증하는 가이드로 발전시킨다.

```text
이해
 ↓
개발환경
 ↓
프로젝트 생성
 ↓
프로젝트 검증
 ↓
멀티 프로젝트 구조
 ↓
Framework 기능 개발
 ↓
서버 환경
 ↓
배포
 ↓
무중단 배포 / CI-CD
 ↓
운영
```

따라서 향후 새로운 문서를 추가할 때도
**“이 문서가 전체 구축 Lifecycle 중 어느 단계에 해당하는가?”**를 먼저 판단한 후
NAV 위치를 결정하는 것을 기본 원칙으로 한다.
