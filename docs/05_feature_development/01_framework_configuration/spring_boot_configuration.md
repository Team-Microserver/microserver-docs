# Spring Boot YAML 공통 설정

## 1. 문서 목적

본 문서는 MicroServer의 Spring Boot Configuration 형식을 YAML로 통일하고,
각 실행 Application의 설정과 Framework 공통 설정을 **중복 없이 명확한 책임으로 분리**하는 방법을 설명한다.

주요 목표:

- `application.properties` → `application.yml` 전환
- Runtime / Admin Application YAML의 책임 정의
- Common YAML의 역할 정의
- `spring.config.import`를 이용한 명시적 공통 설정 연결
- Custom Property Naming 기준
- 설정 중복과 Override 남용 방지

환경별 `local / dev / test / prod`, 외부 Directory, Secret은
[Profile / 외부 리소스 구성](profile_external_resources.md)에서 별도로 다룬다.

---

## 2. MicroServer 설정 파일 표준

Spring Boot는 Properties와 YAML을 모두 지원한다.
MicroServer에서는 가독성과 계층 구조 표현을 위해 YAML을 기본 형식으로 사용한다.

```text
application.properties   → 기본 사용하지 않음
application.yml          → MicroServer 기본
```

Spring Initializr가 생성한 `application.properties`는
YAML 전환 단계에서 `application.yml`로 변경한다.

!!! important "혼용하지 않음"
    하나의 Application에서 동일 목적의 `application.properties`와 `application.yml`을
    함께 운영하지 않는다.

---

## 3. 각 실행 Application은 자신의 `application.yml`을 가진다

```text
runtime/src/main/resources/application.yml
admin/src/main/resources/application.yml
```

Runtime:

```yaml
spring:
  application:
    name: microserver-runtime

server:
  port: ${SERVER_PORT:8080}
```

Admin:

```yaml
spring:
  application:
    name: microserver-admin

server:
  port: ${SERVER_PORT:8081}
```

Application Name과 기본 Port는 공통화하지 않는다.

---

## 4. Application YAML을 작게 유지

지양:

```text
runtime/application.yml  300 lines
admin/application.yml    295 lines

두 파일 대부분 동일
```

이런 상태는 공통 Framework 정책이 Application 설정에 복사되고 있다는 신호일 수 있다.

Application YAML에는 다음을 중심으로 둔다.

```text
Application 정체성
Application 기본값
Application 전용 Feature Property
Common Config Import
```

---

## 5. Common YAML

초기에는 `module-common`이 공통 Framework 설정 Resource를 제공할 수 있다.

```text
module-common/src/main/resources/microserver-common.yml
```

예:

```yaml
mybatis:
  mapper-locations: classpath*:/mybatis/**/*.xml
  configuration:
    map-underscore-to-camel-case: true

microserver:
  framework:
    request-id-enabled: true
```

Common YAML은 **Framework 정책의 기본값**이다.

---

## 6. `spring.config.import`

실행 Application이 Common YAML을 명시적으로 Import하도록 구성할 수 있다.

```yaml
spring:
  application:
    name: microserver-runtime
  config:
    import: classpath:microserver-common.yml

server:
  port: ${SERVER_PORT:8080}
```

이 방식의 장점:

```text
Common Config 사용 여부가 Application YAML에 명시됨
Library JAR의 Resource를 재사용 가능
Application YAML의 중복 감소
```

---

## 7. Import 우선순위 주의

Spring Boot Config Data Import는 Import된 문서를
선언한 문서보다 우선할 수 있다.

따라서 다음 패턴을 기본 설계로 사용하지 않는다.

```text
microserver-common.yml
server.port = 8080

runtime/application.yml
server.port = 8090

→ 우선순위에 의존
```

권장:

```text
Common YAML
→ Common Key만 정의

Application YAML
→ Application Key만 정의
```

즉 설정 우선순위보다 **책임 분리**를 우선한다.

---

## 8. Common YAML에 적합한 설정

예:

```text
MyBatis mapper-locations
MyBatis 공통 configuration
Jackson 공통 정책
공통 Framework Custom Property
공통 Web 정책
공통 Message / Encoding 기준
```

판단:

```text
Application이 달라도 값과 의미가 동일한가?
Framework 정책 변경 시 함께 바뀌는가?
```

---

## 9. Common YAML에 적합하지 않은 설정

```text
spring.application.name
server.port
spring.datasource.url
spring.datasource.username
spring.datasource.password
외부 API Host
인증서 실제 경로
환경별 Log Directory
```

이 값들은 Application 또는 Environment 책임이다.

---

## 10. Custom Property Namespace

MicroServer 자체 Property는 Spring 표준 Property와 구분되는 Namespace를 사용한다.

예:

```yaml
microserver:
  framework:
    request-id-enabled: true
    trace-enabled: false
```

Application 전용:

```yaml
microserver:
  runtime:
    worker-count: 4
```

Admin 전용:

```yaml
microserver:
  admin:
    menu-cache-enabled: true
```

실제 Property 이름은 기능 구현 시점에 확정한다.

---

## 11. `@ConfigurationProperties` 사용 방향

Custom Property가 여러 개로 증가하면
문자열 `@Value`를 여러 곳에 흩뿌리기보다 `@ConfigurationProperties` 기반 객체를 권장한다.

개념:

```text
YAML
    ↓
ConfigurationProperties
    ↓
Java Type
```

장점:

```text
Type Safety
Property 구조 명확화
Validation 적용 가능
IDE Metadata 확장 가능
```

실제 구현은 해당 Framework 기능 가이드에서 진행한다.

---

## 12. MyBatis 공통 설정

MyBatis Engine 설정이 MicroServer 전체 표준이라면 Common YAML에 둘 수 있다.

```yaml
mybatis:
  mapper-locations: classpath*:/mybatis/**/*.xml
  configuration:
    map-underscore-to-camel-case: true
```

실제 Mapper XML은 Common YAML이 아니라 각 기능 Module의 Resource가 소유한다.

```text
설정
→ Common YAML

SQL
→ 해당 Module
```

---

## 13. Logging 설정과의 관계

YAML에는 Log Level 등 Property를 둘 수 있지만
Appender / Encoder / Rolling Policy 등 실제 Logging Framework 구성은
`공통 Framework > Logging 구성` 문서에서 다룬다.

Project Structure 문서에서는 다음만 결정한다.

```text
공통 Logging 정책인가?
Application 전용 Logging인가?
환경별 Override인가?
```

---

## 14. Profile 설정은 별도 문서에서 관리

다음은 본 문서에서 깊게 구성하지 않는다.

```text
application-local.yml
application-dev.yml
application-prod.yml
SPRING_PROFILES_ACTIVE
SPRING_CONFIG_ADDITIONAL_LOCATION
Secret
```

→ [Profile / 외부 리소스 구성](profile_external_resources.md)

---

## 15. YAML 작성 규칙

권장:

```text
2 Space Indent
Tab 사용 금지
Key 구조를 과도하게 깊게 만들지 않음
환경값은 Placeholder 활용
동일 Key 중복 정의 최소화
```

환경변수 Placeholder 예:

```yaml
server:
  port: ${SERVER_PORT:8080}
```

---

## 16. 설정 파일 이름

기본:

```text
application.yml
```

공통 Framework Resource:

```text
microserver-common.yml
```

환경별 파일은 Spring Profile 표준 형식을 사용한다.

```text
application-local.yml
application-dev.yml
application-test.yml
application-prod.yml
```

---

## 17. 단계별 적용 순서

```text
1. application.properties 확인
2. application.yml로 전환
3. Runtime / Admin Application 기본값 분리
4. Common YAML 생성
5. Common Property 이동
6. spring.config.import 연결
7. Build / Run 검증
8. Commit
9. Profile / External Config 단계 진행
```

한 번에 DB / Security / Logging 설정까지 모두 이동하지 않는다.

---

## 18. 검증

Runtime:

```powershell
.\gradlew.bat :runtime:bootRun
```

Admin:

```powershell
.\gradlew.bat :admin:bootRun
```

확인:

```text
Application Name 정상
기본 Port 정상
Common Config Load 정상
기존 Build 정상
```

---

## 19. 체크리스트

- [ ] `application.properties`를 `application.yml`로 전환했다.
- [ ] Runtime / Admin이 각각 자신의 YAML을 가진다.
- [ ] Application Name과 기본 Port를 각 Application이 소유한다.
- [ ] Common YAML에는 Framework 공통 정책만 둔다.
- [ ] Common Config 사용 관계를 명시적으로 확인할 수 있다.
- [ ] 동일 Key의 충돌을 Override 우선순위에 의존해 설계하지 않는다.
- [ ] Custom Property는 `microserver.*` Namespace를 사용한다.
- [ ] 실제 Secret을 YAML에 Hard Coding하지 않는다.
- [ ] MyBatis Engine 설정과 Mapper SQL을 구분한다.

---

## 20. 다음 단계

동일한 Build Artifact를 환경별로 실행할 수 있도록
Spring Profile과 External Configuration을 구성한다.

→ [Profile / 외부 리소스 구성](profile_external_resources.md)
