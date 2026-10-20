# Package 구조 설계

## 문서 목적

멀티프로젝트의 책임이 확정된 이후 각 프로젝트 내부의 Package 구조를 설계합니다.

## 설계 시점

Package 구조는 초기 Spring Boot 프로젝트 생성 단계에서 먼저 확정하지 않습니다. Framework / Runtime / Admin의 책임과 프로젝트 경계가 정해진 후 각 프로젝트의 역할에 맞게 설계합니다.

## 검토 항목

- Framework 내부 기술 기능의 Package 경계
- Runtime 업무 Layer 및 Domain Package 기준
- Admin 관리 기능 Package 기준
- Configuration 및 Resource 소유권
- 공통 DTO / Exception / Utility의 배치 기준
- 프로젝트 간 Package 직접 참조 최소화

> 문서 상태: **작성 예정**
