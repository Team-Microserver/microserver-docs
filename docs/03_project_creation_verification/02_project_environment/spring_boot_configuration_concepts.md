# Spring Boot Configuration / Profile 개념

## 1. 목적

`application.yml`, Profile, 환경변수, Secret의 역할을 설명한다.

## 2. `application.yml`

Spring Boot Application의 공통 설정을 저장하는 기본 Configuration 파일이다.

```text
src/main/resources/application.yml
```

Project와 함께 공유해도 되는 공통 기본값을 둔다.

## 3. Profile

환경별로 설정이 달라질 때 Profile을 사용할 수 있다.

```text
application.yml
application-local.yml
application-dev.yml
application-prod.yml
```

하지만 파일을 많이 만드는 것 자체가 목적은 아니다. 실제 배포 환경과 설정 관리 정책이 정해진 뒤 필요한 Profile만 구성한다.

## 4. 외부 설정

환경에 따라 달라지거나 민감한 값은 Source Repository보다 외부 설정을 우선 검토한다.

예:

```text
환경변수
Container / Orchestrator Secret
CI/CD Secret
운영 Configuration
```

## 5. Secret

Password, Token, 실제 운영 Credential은 `application.yml`에 평문으로 Commit하지 않는다.

## 6. 설정 설계 원칙

```text
Project 공통 기본값
→ application.yml

환경별 차이
→ Profile 또는 외부 Configuration

Credential / Secret
→ Repository 밖에서 관리
```

이 원칙을 유지하면 Local, 개발, 검증, 운영 환경의 차이를 Project Source에 과도하게 섞지 않을 수 있다.
