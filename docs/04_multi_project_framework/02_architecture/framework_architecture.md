# MicroServer Framework 아키텍처

## 문서 목적

MicroServer Framework가 해결하려는 문제와 Framework, Runtime, Admin의 전체 관계를 정의합니다.

## 기본 개념

```text
MicroServer Framework
        │
        ├── Framework Common/Core
        │       └── Runtime 업무 개발을 지원하는 공통 Framework 기능
        │
        ├── Runtime Application
        │       └── 실제 업무 Application
        │
        └── Admin Application
                └── MicroServer Framework 관리용 독립 Application
```

Runtime은 금융, 일반 Web, API Server 등 프로젝트 성격에 따라 달라질 수 있습니다. Framework는 Runtime 개발자가 기술 기반 설정보다 업무 구현에 집중할 수 있도록 공통 기능과 기본 동작을 제공합니다.

Admin은 Framework의 설정, 모니터링 및 운영 기능을 제공하는 독립 실행형 관리 Application을 목표로 합니다. 구체적인 Runtime 제어 방식과 관리 통신 구조는 후속 설계에서 확정합니다.

> 문서 상태: **설계 진행중**
