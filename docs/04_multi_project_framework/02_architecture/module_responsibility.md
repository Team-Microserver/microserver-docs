# 프로젝트별 책임 정의

## 문서 목적

Framework, Runtime, Admin의 책임 경계를 정의하여 기능이 서로 섞이는 것을 방지합니다.

## Framework

Runtime Application의 업무 개발을 지원하는 공통 기술 기반을 제공합니다. DataSource, Transaction, Logging, Exception, Validation, Security, Cache, 전문 처리 등은 향후 실제 구현 범위를 검토하여 확정합니다.

## Runtime

MicroServer Framework를 이용하여 실제 업무를 구현하는 실행 Application입니다. Controller, Service, Domain, Repository/Mapper 등 프로젝트의 업무 코드가 위치할 수 있습니다.

## Admin

MicroServer Framework 자체를 관리하기 위한 독립 실행형 Application입니다. 시스템 모니터링, Framework 기능 관리, 전문 관리, 게시판 관리, Cache 제어, 시스템 설정 등의 관리 기능을 대상으로 하며 세부 범위는 구현 단계에서 확정합니다.

## 설계 원칙

- 위치가 애매하다는 이유만으로 Framework에 기능을 넣지 않습니다.
- Runtime의 업무 로직을 Framework에 포함하지 않습니다.
- Admin을 Runtime의 일반 업무 관리자 화면으로 사용하지 않습니다.
- 각 기능의 소유권과 의존성을 먼저 결정한 후 구현 위치를 결정합니다.

> 문서 상태: **설계 진행중**
