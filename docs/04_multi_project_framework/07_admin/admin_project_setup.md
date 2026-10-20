# Admin Application 구성

## 문서 목적

MicroServer Framework 자체를 운영하고 관리하기 위한 독립 실행형 Admin Application의 구조를 정의합니다.

## 기본 방향

Admin은 Runtime 업무의 일반 관리자 화면이 아닙니다. Framework가 제공하는 기능과 시스템 상태를 관리하기 위한 별도 Application입니다.

## 검토 대상

- 시스템 상태 및 모니터링
- Framework 설정 관리
- 전문 관리
- 게시판 관리
- Cache 조회 및 제어
- Port 및 시스템 설정
- 기타 Framework 운영 기능

Admin과 Runtime 사이의 관리 통신 및 제어 방식은 별도의 관리 아키텍처 설계를 통해 확정합니다.

> 문서 상태: **설계 진행중**
