# 멀티프로젝트 구조 설계

## 문서 목적

아키텍처와 책임 설계를 실제 Gradle Multi-Project 구조로 옮기기 위한 기준을 정의합니다.

## 설계 원칙

- Root Project는 전체 Build와 하위 프로젝트 구성을 관리합니다.
- 실행 Application과 Framework Library의 역할을 구분합니다.
- 프로젝트 이름보다 책임을 먼저 확정합니다.
- 초기 단계에서 불필요하게 프로젝트를 세분화하지 않습니다.
- Framework가 성장하여 책임 분리가 필요해질 때 추가 프로젝트 분리를 검토합니다.

Framework 프로젝트의 최종 명칭(`common`, `core`, `framework` 등)과 세부 프로젝트 구성은 아키텍처 설계 후 확정합니다.

> 문서 상태: **설계 진행중**
