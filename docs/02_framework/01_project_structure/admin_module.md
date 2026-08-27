# admin 모듈 구성

## 1. 문서 목적

본 문서는 MicroServer의 `admin` Module을
**관리 기능을 제공하는 독립 Spring Boot 실행 Application**으로 구성할 때의 책임과 Resource 운영 원칙을 정의한다.

관련 문서:

- [멀티모듈 프로젝트 구조](multi_module_structure.md)
- [리소스 / 설정 관리 아키텍처](resource_configuration_architecture.md)
- [module-common 구성](module_common.md)
- [Spring Boot YAML 공통 설정](spring_boot_configuration.md)
- [Profile / 외부 리소스 구성](profile_external_resources.md)

---

## 2. admin의 역할

`admin`은 `runtime`과 별도로 실행되는 Spring Boot Application이다.

주요 책임 예:

```text
관리자 Application Main Class
관리 API
사용자 / 권한 관리 기능
운영 관리 기능
Admin 전용 Configuration
Admin 전용 Mapper / SQL
필요한 Template / Static Resource
Common Module 사용
```

실제 사용자 / 권한 기능은 Security 단계에서 구현한다.

---

## 3. Dependency 방향

기본:

```text
admin ──────► module-common
```

Gradle 예:

```groovy
dependencies {
    implementation project(':module-common')
}
```

`module-common`이 `admin`을 역참조하지 않는다.

---

## 4. 권장 Directory 구조

```text
admin/
├─ build.gradle
└─ src/
   ├─ main/
   │  ├─ java/
   │  │  └─ io/github/.../admin/
   │  │     ├─ AdminApplication.java
   │  │     ├─ controller/
   │  │     ├─ service/
   │  │     ├─ mapper/
   │  │     └─ config/
   │  │
   │  └─ resources/
   │     ├─ application.yml
   │     ├─ mybatis/
   │     │  └─ admin/
   │     ├─ templates/
   │     └─ static/
   │
   └─ test/
```

`templates`, `static`은 실제 Admin UI 요구가 있을 때 사용한다.

---

## 5. Admin `application.yml`

예:

```yaml
spring:
  application:
    name: microserver-admin

server:
  port: ${SERVER_PORT:8081}
```

`runtime`과 구조가 비슷하더라도 Application Name과 기본 Port는 각 Application이 소유한다.

---

## 6. 설정이 비슷하다고 파일 전체를 공통화하지 않음

초기에는 `runtime`과 `admin`의 YAML이 거의 같아 보일 수 있다.

예:

```text
spring.application.name
server.port
```

그러나 두 값은 Application마다 독립적으로 변경된다.
따라서 파일을 하나로 합치지 않는다.

공통화 대상은 다음처럼 **Framework 정책**이다.

```text
MyBatis 공통 정책
Jackson 공통 정책
공통 Logging 기준
공통 Framework Custom Property
```

---

## 7. Admin 전용 Mapper SQL

관리 기능이 사용하는 SQL은 Admin이 소유한다.

```text
admin/src/main/resources/mybatis/admin/
```

예:

```text
AdminUserMapper.xml
AdminRoleMapper.xml
AdminMenuMapper.xml
```

Common 기능의 SQL과 섞지 않는다.

---

## 8. Common 기능 사용

공통 사용자 조회나 공통 코드 기능 등
실제로 여러 Application이 공유하는 기능은 Common API를 사용한다.

```text
Admin Service
     ↓
Common Service
     ↓
Common Mapper / Resource
```

Admin에 Common SQL을 복사하지 않는다.

---

## 9. Admin Template / Static Resource

Admin이 Server-side Template 또는 Static Asset을 제공한다면
Admin Module이 소유한다.

```text
admin/src/main/resources/templates
admin/src/main/resources/static
```

공통 Resource처럼 보인다고 `module-common`으로 바로 옮기지 않는다.
실제로 여러 Application에서 재사용되는 공통 UI Artifact가 확인될 때 별도 분리를 검토한다.

---

## 10. Admin 환경설정

다음 실제 값은 JAR 밖의 Environment에서 관리한다.

```text
Admin DB URL
외부 관리 시스템 URL
인증서
Password / Token
환경별 Port Override
환경별 Log Level
```

공통 External Config와 Admin 전용 External Config를 분리할 수 있다.

예:

```text
local-resource/config/common/
local-resource/config/admin/
```

---

## 11. Security 설정과의 관계

Admin은 향후 Security 기능이 가장 많이 적용되는 Application이 될 수 있다.

하지만 Project Structure 단계에서 다음을 한 번에 구현하지 않는다.

```text
사용자 인증
Role
인가
Session / Token
Jasypt
```

각 기능은 `04_security`와 `02_common_framework/jasypt.md`에서 단계적으로 구성한다.

---

## 12. Build / Run

Project Root:

```powershell
.\gradlew.bat :admin:clean :admin:build
```

실행:

```powershell
.\gradlew.bat :admin:bootRun
```

Runtime과 Admin을 동시에 실행하는 경우 Port 충돌이 없도록 한다.

---

## 13. Local Port Override 예

```powershell
$env:SERVER_PORT="8091"
.\gradlew.bat :admin:bootRun
```

단, 같은 PowerShell Session에서 Runtime도 실행할 경우
환경변수 범위에 유의한다.

IDE Run Configuration 또는 별도 실행 Script를 사용하면
Application별 실행환경을 분리하기 쉽다.

---

## 14. Admin에 두지 않을 것

```text
Runtime 전용 업무 SQL
Common Framework 구현 복사본
Common Mapper XML 복사본
운영 Secret
개인 인증서
모든 Application을 위한 공통 Property 전체
```

---

## 15. 체크리스트

- [ ] `admin`은 독립 Spring Boot Application이다.
- [ ] `module-common`을 단방향으로 의존한다.
- [ ] Admin Application Name과 기본 Port를 자체 관리한다.
- [ ] Admin 전용 SQL은 Admin Resource에 둔다.
- [ ] Admin Template / Static Resource는 Admin이 소유한다.
- [ ] Common 기능을 복사하지 않고 Common API를 사용한다.
- [ ] 실제 운영 Secret을 Admin JAR에 넣지 않는다.
- [ ] Security 상세 구현은 별도 단계로 분리한다.
- [ ] `:admin:build`, `:admin:bootRun`으로 독립 검증 가능하다.

---

## 16. 다음 단계

실행 Module 기본 구조가 정리되면
Spring Boot YAML의 공통화 방식을 구체적으로 구성한다.

→ [Spring Boot YAML 공통 설정](spring_boot_configuration.md)
