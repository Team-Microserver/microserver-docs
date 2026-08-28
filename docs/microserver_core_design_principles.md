# MicroServer 핵심 설계 원칙

> 이 문서는 MicroServer의 소개 및 아키텍처 방향을 구체화할 때 활용하기 위한 설계 원칙 초안이다.

## 1. 설계 목표

MicroServer는 업무 개발자가 프레임워크 내부의 복잡한 기술 설정을 직접 구성하지 않고,
업무 기능 개발에 집중할 수 있는 개발 환경을 제공하는 것을 목표로 한다.

핵심 방향은 다음과 같다.

> **업무 개발자는 업무를 개발하고, 기술 기반과 표준 설정은 MicroServer가 책임진다.**

업무 개발자는 DataSource 구성 방식, Transaction Manager 구성, Security Filter 구조,
Logging 설정, Web 공통 설정 등의 내부 구현을 반드시 이해하지 않아도 업무 기능을 개발할 수 있어야 한다.

---

## 2. 업무 개발자의 책임 영역

일반 업무 개발자는 주로 다음 영역에 집중한다.

```text
Controller
Service
Domain
Repository / Mapper
DTO
업무 Validation
업무 Rule
```

즉 고객, 계좌, 상품, 주문 등 실제 비즈니스 요구사항을 구현하는 것이 업무 개발자의 주요 책임이다.

---

## 3. MicroServer Framework의 책임 영역

다음과 같은 기술 기반 설정과 공통 기능은 MicroServer Framework에서 제공하는 것을 기본 원칙으로 한다.

```text
DataSource
Transaction
Security
Logging
Exception Handling
Web Configuration
MyBatis / JPA 공통 설정
공통 Response
환경설정 로딩
공통 Utility
기타 프로젝트 표준 기능
```

업무 프로젝트마다 다음과 같은 설정 클래스를 반복해서 작성하는 구조는 지양한다.

```text
DataSourceConfig.java
TransactionConfig.java
SecurityConfig.java
WebConfig.java
MyBatisConfig.java
```

---

## 4. DataSource 설계 원칙

MicroServer에서 사용하는 DataSource는 용도에 따라 분리할 수 있다.

```text
MicroServer Framework
        │
        ├── Framework DataSource
        │       └── 프레임워크/관리 영역 DB
        │
        └── Domain DataSource
                └── 실제 업무 영역 DB
```

중요한 것은 DataSource가 여러 개 존재한다는 사실 자체를 업무 개발자에게 노출하는 것이 아니다.

프레임워크 내부에서는 Framework DataSource와 Domain DataSource를 명확하게 분리하지만,
일반 업무 개발자는 기본적으로 Domain DataSource를 자연스럽게 사용하도록 구성한다.

```text
업무 Repository / Mapper
          │
          ▼
   Domain DataSource
          │
          ▼
       업무 DB
```

반면 MicroServer 내부 기능에서 필요한 경우에는 Framework DataSource를 명시적으로 사용한다.

따라서 다음 두 원칙을 동시에 만족시키는 것을 목표로 한다.

1. 내부적으로는 DataSource의 역할과 책임을 명확하게 분리한다.
2. 업무 개발자에게는 DataSource 구성의 복잡성을 최대한 노출하지 않는다.

---

## 5. 설정은 Framework가 제공한다

업무 개발자가 직접 기술 설정을 작성하기보다 MicroServer가 기본 설정을 제공한다.

예를 들어 업무 프로젝트에서는 다음과 같은 의존성만 추가하여 MicroServer의 표준 기능을 사용할 수 있는 구조를 목표로 한다.

```gradle
dependencies {
    implementation("com.company.microserver:microserver-starter:1.0.0")
}
```

MicroServer Starter를 통해 필요한 Framework 모듈과 Auto Configuration이 적용되도록 구성한다.

```text
microserver-starter
        │
        ├── microserver-core
        ├── microserver-data
        ├── microserver-security
        ├── microserver-web
        └── microserver-logging
```

---

## 6. 기본 제공 + 제한적 확장

모든 설정을 Framework에서 제공한다고 해서 변경을 완전히 금지하는 구조로 만들지는 않는다.

기본 원칙은 다음과 같다.

> **Default는 MicroServer가 제공하고, 특별한 요구사항이 있는 경우에만 명시적으로 Override한다.**

대부분의 업무 프로젝트는 별도의 설정 없이 MicroServer 표준 설정을 그대로 사용한다.

특수한 프로젝트에서만 필요한 설정을 제한적으로 변경할 수 있도록 확장 지점을 제공한다.

예:

```yaml
microserver:
  datasource:
    domain:
      pool-size: 30
```

이러한 방식으로 표준화와 프로젝트별 유연성을 동시에 확보한다.

---

## 7. Framework와 업무 프로젝트의 분리

MicroServer Framework 자체는 Multi-Module Project로 구성하는 방향을 검토한다.

```text
microserver-framework
├── microserver-core
├── microserver-data
├── microserver-security
├── microserver-web
├── microserver-logging
└── microserver-starter
```

Framework 모듈은 JAR 또는 Starter 형태로 배포한다.

업무 프로젝트는 Framework Source와 분리된 독립 프로젝트로 구성한다.

```text
customer-service
account-service
product-service
loan-service
```

업무 프로젝트는 MicroServer Framework의 소스를 직접 포함하거나 수정하지 않고,
배포된 Framework를 Dependency로 사용한다.

```text
MicroServer Framework
        │
        │ Build / Publish
        ▼
   Maven Repository
        │
        │ Dependency
        ├───────────────┐
        ▼               ▼
customer-service   account-service
        │               │
        ▼               ▼
    업무 개발         업무 개발
```

---

## 8. 핵심 아키텍처 원칙

MicroServer의 핵심 아키텍처 원칙을 다음과 같이 정의한다.

### Convention over Configuration

업무 프로젝트마다 동일한 기술 설정을 반복하지 않는다.

MicroServer가 표준 설정과 기본 동작을 제공한다.

### Separation of Concerns

Framework 영역과 Business Domain 영역의 책임을 분리한다.

### Framework Encapsulation

DataSource, Transaction, Security 등 Framework 내부 구현의 복잡성을 업무 개발자에게 노출하지 않는다.

### Standardization

프로젝트마다 서로 다른 기술 설정이 만들어지는 것을 최소화하고 MicroServer 표준을 적용한다.

### Extensibility

표준 설정을 기본으로 사용하되 프로젝트 특성상 필요한 경우 제한적으로 확장하거나 Override할 수 있도록 한다.

---

## 9. 최종적으로 지향하는 개발 경험

MicroServer가 지향하는 최종 개발 경험은 다음과 같다.

```text
업무 개발자

"DataSource를 어떻게 생성하지?"
"TransactionManager는 무엇을 써야 하지?"
"Security Filter는 어떻게 등록하지?"
"MyBatis 설정은 어떻게 해야 하지?"

             ↓

        고민하지 않는다.

             ↓

MicroServer가 표준 기술 환경을 제공

             ↓

업무 개발자는

"이 업무를 어떻게 구현할 것인가?"

에 집중한다.
```

즉 MicroServer의 목적은 단순히 공통 클래스를 모아놓은 라이브러리를 만드는 것이 아니라,

> **금융 SI 프로젝트에서 반복되는 기술 기반과 표준 설정을 Framework가 책임지고,
> 업무 개발자는 Business Domain 구현에 집중할 수 있는 표준 개발 플랫폼을 제공하는 것**

으로 정의할 수 있다.

---

## 10. 향후 검증 사항

본 설계 원칙은 실제 구현 가능성을 POC 및 기존 프로젝트 소스 분석을 통해 검증한다.

주요 검증 대상은 다음과 같다.

- Framework / Domain Multi DataSource 자동 구성
- Domain DataSource 기본 사용 구조
- Framework 전용 DataSource 분리
- Transaction Manager 분리 및 적용 방식
- MyBatis / JPA 설정 자동화
- Security Auto Configuration
- 외부 환경설정 및 Secret 주입 방식
- Framework Starter 구성
- 업무 프로젝트에서 Framework 설정 클래스 제거 가능 여부
- Framework 설정 Override 및 확장 방식

기존 STS 기반 MicroServer 소스를 분석한 후 실제 구현 구조를 확정한다.
