# 멀티프로젝트 프레임워크 구성 개요

## 문서 목적

빈 Spring Boot 프로젝트를 기준으로 MicroServer Framework의 멀티프로젝트 구조를 설계하고 구성하는 전체 흐름을 정의합니다.

## 기본 방향

- MicroServer Framework는 특정 업무 시스템 자체가 아니라 Runtime Application의 업무 개발을 지원하는 기반 Framework입니다.
- Runtime은 MicroServer Framework를 사용하는 실제 업무 Application입니다.
- Admin은 업무 관리자 화면이 아니라 MicroServer Framework 자체를 관리하는 독립 실행형 Application입니다.
- 기존 `04_multi_project_transition` 문서는 과거 설계 및 구현 참고자료로 유지합니다.
- 새 구조는 기존 구현을 그대로 복제하지 않고 책임과 의존성을 다시 검토한 후 구성합니다.

## 구성 절차

1. Framework 아키텍처와 설계 원칙 정의
2. Framework / Runtime / Admin 책임과 의존성 정의
3. 멀티프로젝트 및 패키지 구조 설계
4. Gradle Multi-Project 구성
5. Framework 프로젝트 구성
6. Runtime Application 구성
7. Admin Application 구성
8. 전체 Build / Run 검증

> 문서 상태: **설계 진행중**
