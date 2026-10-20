# 프로젝트 의존성 설계

## 문서 목적

Framework, Runtime, Admin 사이의 허용 의존성과 금지 의존성을 정의합니다.

## 기본 방향

Runtime은 MicroServer Framework가 제공하는 기능을 사용합니다. Admin은 Framework 관리용 독립 Application으로 구성합니다.

```text
Runtime Application ──> MicroServer Framework

Admin Application   ──> Framework 관리 기능
```

Admin이 실행 중인 Runtime의 Framework 기능을 어떻게 조회하거나 제어할지는 별도 관리 아키텍처가 필요합니다. Management API, 관리 저장소 등 구체적인 방식은 현재 단계에서 확정하지 않습니다.

순환 의존성은 허용하지 않으며 실제 Gradle 의존성은 프로젝트 책임 설계가 확정된 후 정의합니다.

> 문서 상태: **설계 진행중**
