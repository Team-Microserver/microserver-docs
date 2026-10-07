# application.yml 기본 설정

## 1. 목적

이 문서는 Spring Boot Project의 `application.yml`에 **초기 공통 설정을 작성하고 확인하는 절차**를 다룬다.

Profile, 설정 우선순위, Secret 관리 원리는 다음 문서를 참고한다.

→ [Spring Boot Configuration / Profile 개념](spring_boot_configuration_concepts.md)

---

## 2. 파일 위치 확인

기본 파일:

```text
src/main/resources/application.yml
```

없으면 생성한다.

---

## 3. 초기 설정 원칙

초기 Project에서는 환경 의존 값이나 Credential을 먼저 넣지 않는다.

공통으로 필요한 최소 설정부터 작성한다.

예:

```yaml
spring:
  application:
    name: microserver
```

현재 Project에서 이미 Spring Initializr가 생성한 설정이 있다면 무조건 덮어쓰지 말고 기존 값을 확인한 후 유지 또는 정리한다.

---

## 4. YAML 작성 규칙

YAML은 들여쓰기가 구조를 결정한다.

```yaml
spring:
  application:
    name: microserver
```

다음 사항을 지킨다.

```text
Tab 대신 Space 사용
같은 Level의 Key는 같은 들여쓰기
중복 Key 작성 금지
Credential / Password 직접 Commit 금지
```

---

## 5. 환경별 설정은 지금 분리하지 않음

초기 Project 생성/검증 단계에서는 다음 구성을 성급하게 추가하지 않는다.

```text
application-local.yml
application-dev.yml
application-stg.yml
application-prod.yml
```

환경별 Profile 정책은 서버/배포 환경 설계와 함께 확정한 뒤 적용한다.

필요한 원리는 다음 문서를 참고한다.

→ [Spring Boot Configuration / Profile 개념](spring_boot_configuration_concepts.md)

---

## 6. Secret 작성 금지

다음과 같은 실제 Credential을 Repository에 직접 기록하지 않는다.

```yaml
# 금지 예시
spring:
  datasource:
    username: real-user
    password: real-password
```

DB, 외부 API, 인증정보는 이후 환경변수 / Secret 관리 정책에 맞춰 구성한다.

---

## 7. 확인

파일 저장 후 YAML 문법 오류가 없는지 VS Code에서 확인한다.

현재 단계에서는 설정 파일 때문에 Application 구조가 깨지지 않는지만 확인하고 환경별 운영 설정은 추가하지 않는다.

---

## 8. 완료 체크리스트

- [ ] `src/main/resources/application.yml`이 존재한다.
- [ ] `spring.application.name`을 확인했다.
- [ ] YAML 들여쓰기가 정상이다.
- [ ] 실제 Credential / Secret이 없다.
- [ ] 불필요한 환경별 Profile 파일을 미리 만들지 않았다.
