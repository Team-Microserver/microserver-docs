# runtime 모듈 구성

## 1. 문서 목적

본 문서는 MicroServer의 `runtime` Module을
**실제 업무 Runtime을 제공하는 Spring Boot 실행 Application**으로 구성할 때의 책임과 Resource 운영 원칙을 정의한다.

관련 문서:

- [멀티모듈 프로젝트 구조](multi_module_structure.md)
- [리소스 / 설정 관리 아키텍처](resource_configuration_architecture.md)
- [module-common 구성](module_common.md)
- [Spring Boot YAML 공통 설정](spring_boot_configuration.md)
- [Profile / 외부 리소스 구성](profile_external_resources.md)

---

## 2. runtime의 역할

`runtime`은 실행 가능한 Spring Boot Application이다.

```text
runtime
→ Spring Boot Executable Application
```

책임:

```text
Application Main Class
Runtime API / 업무 처리
Runtime 전용 Configuration
Runtime 전용 Mapper / SQL
Runtime 전용 Resource
Common Module 사용
외부 Runtime Configuration 연결
```

---

## 3. module-common과 관계

Dependency 방향:

```text
runtime ──────► module-common
```

Gradle 예:

```groovy
dependencies {
    implementation project(':module-common')
}
```

`runtime`은 Common의 공개 Java 기능을 사용한다.
Common이 `runtime`을 참조하게 만들지 않는다.

---

## 4. 권장 Directory 구조

```text
runtime/
├─ build.gradle
└─ src/
   ├─ main/
   │  ├─ java/
   │  │  └─ io/github/.../runtime/
   │  │     ├─ RuntimeApplication.java
   │  │     ├─ controller/
   │  │     ├─ service/
   │  │     ├─ mapper/
   │  │     └─ config/
   │  │
   │  └─ resources/
   │     ├─ application.yml
   │     └─ mybatis/
   │        └─ runtime/
   │
   └─ test/
```

실제 Package Layer는 API 개발 표준 단계에서 확정한다.

---

## 5. `application.yml`은 Runtime의 정체성을 가진다

예:

```yaml
spring:
  application:
    name: microserver-runtime

server:
  port: ${SERVER_PORT:8080}
```

여기에는 `runtime`이 스스로 알아야 하는 최소 기본값을 둔다.

---

## 6. Port 관리

Port는 Common 설정이 아니라 Application 설정이다.

```yaml
server:
  port: ${SERVER_PORT:8080}
```

의미:

```text
SERVER_PORT 존재
→ 해당 값 사용

없음
→ runtime 기본값 8080
```

Local 실행 또는 배포환경에서 Port가 달라질 수 있으므로
기본값 + Runtime Override 구조를 사용한다.

---

## 7. Common YAML 사용

공통 Framework 설정을 Application YAML에 복사하지 않는다.

필요 시:

```yaml
spring:
  application:
    name: microserver-runtime
  config:
    import: classpath:microserver-common.yml
```

와 같이 Common Resource를 명시적으로 Import한다.

공통 YAML과 Runtime YAML에 같은 Key를 서로 다른 값으로 반복 정의하는 구조는 피한다.

---

## 8. Runtime 전용 Mapper SQL

Runtime 기능이 직접 사용하는 SQL은 Runtime이 소유한다.

```text
runtime/src/main/resources/mybatis/runtime/
```

예:

```text
RuntimeJobMapper.xml
RuntimeStatusMapper.xml
```

Runtime Java와 SQL은 같은 Module Build / Release 단위로 관리한다.

---

## 9. Common SQL 사용

Common 기능은 Common JAR에 포함된 Java API를 통해 사용한다.

```text
runtime Service
        ↓
Common Service / Repository
        ↓
Common Mapper
        ↓
Common JAR Mapper XML
```

Runtime이 Common Mapper XML File을 복사하거나
같은 SQL을 Runtime Resource에 중복 배치하지 않는다.

---

## 10. 환경별 DB 설정은 Runtime JAR 밖으로

다음 값은 Runtime `application.yml`에 실제 운영값으로 고정하지 않는다.

```text
DB URL
DB Username / Password
외부 API URL
인증서 경로
운영 Log Directory
```

Runtime Application은 Placeholder 또는 Default 구조만 정의하고
실제 값은 외부 Environment에서 제공한다.

자세한 내용:

→ [Profile / 외부 리소스 구성](profile_external_resources.md)

---

## 11. Runtime 전용 Resource

Runtime이 소유할 수 있는 Resource 예:

```text
Runtime Mapper XML
Runtime Message
Runtime 전용 Config Default
Runtime 업무 Template - 실제 필요 시
Runtime 전용 Static Resource - 실제 필요 시
```

다른 Application과 우연히 파일 형태가 같다는 이유로 Common으로 옮기지 않는다.

---

## 12. Build와 실행

Project Root에서:

```powershell
.\gradlew.bat :runtime:clean :runtime:build
```

실행:

```powershell
.\gradlew.bat :runtime:bootRun
```

`runtime` Build 시 Gradle이 Project Dependency를 분석하여 필요한 Common Task를 처리한다.

---

## 13. Local Profile 실행 예

개념 예:

```powershell
$env:SPRING_PROFILES_ACTIVE="local"
$env:SERVER_PORT="8080"

.\gradlew.bat :runtime:bootRun
```

외부 Config Directory 연결은 Profile / 외부 리소스 문서에서 구성한다.

---

## 14. Runtime에 두지 않을 것

```text
Admin 전용 Controller
Admin Template
Common Framework 구현 복사본
다른 Module의 Mapper XML 복사본
운영 Password
개인 인증서
모든 Application의 공통 설정 복사본
```

---

## 15. Application 경계와 업무 Module

Runtime이 커진다고 모든 업무 기능을 계속 `runtime`에 넣을 필요는 없다.

실제 업무 경계가 확인되면:

```text
runtime
 ├─► module-common
 ├─► module-customer
 └─► module-account
```

형태로 분리할 수 있다.

이때 Runtime은 실행 / 조합 역할에 집중하고
업무 Module이 해당 Java와 SQL을 소유하도록 발전시킬 수 있다.

---

## 16. 체크리스트

- [ ] `runtime`은 Spring Boot 실행 Application이다.
- [ ] `module-common`을 단방향으로 의존한다.
- [ ] `application.yml`에 Runtime Application Name을 정의한다.
- [ ] 기본 Port는 Runtime이 소유한다.
- [ ] 환경별 Port는 Runtime Override가 가능하다.
- [ ] Runtime 전용 SQL은 Runtime Resource에 둔다.
- [ ] Common SQL을 Runtime에 복사하지 않는다.
- [ ] 실제 DB Password / 운영정보를 JAR에 넣지 않는다.
- [ ] `:runtime:build`, `:runtime:bootRun`으로 독립 검증 가능하다.

---

## 17. 다음 단계

관리 Application의 책임을 구성한다.

→ [admin 모듈 구성](admin_module.md)
