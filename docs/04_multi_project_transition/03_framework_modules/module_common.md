# module-common 구성

## 1. 문서 목적

본 문서는 MicroServer의 `module-common`을
**여러 실행 Application에서 재사용하는 공통 Library Module**로 구성할 때의 책임과 Resource 운영 원칙을 정의한다.

Gradle Project 자체를 생성하는 절차는 선행 Gradle Multi-Project 문서에서 다루며,
이 문서는 `module-common`에 실제로 무엇을 넣고 무엇을 넣지 않을지에 집중한다.

관련 문서:

- [멀티모듈 프로젝트 구조](multi_module_structure.md)
- [리소스 / 설정 관리 아키텍처](../../05_feature_development/01_framework_configuration/resource_configuration_architecture.md)
- [Spring Boot YAML 공통 설정](../../05_feature_development/01_framework_configuration/spring_boot_configuration.md)
- [MyBatis 구성](../../05_feature_development/03_database/mybatis.md)

---

## 2. module-common의 역할

`module-common`은 실행 Application이 아니다.

```text
module-common
→ 재사용 가능한 Library JAR
```

주요 책임 후보:

```text
공통 Response
공통 Exception
공통 Utility
공통 Validation 지원
공통 Logging 지원
공통 Filter / AOP 지원
공통 ConfigurationProperties
공통 Data Access 기능
공통 기능이 사용하는 Mapper SQL
```

아직 필요하지 않은 기능을 미리 모두 넣지는 않는다.

---

## 3. 실행 Module과 차이

| 구분 | module-common | runtime / admin |
|---|---|---|
| 목적 | 재사용 Library | 실행 Application |
| Gradle 성격 | `java-library` | Spring Boot Application |
| Main Class | 없음 | 있음 |
| `bootRun` | 대상 아님 | 대상 |
| `spring.application.name` | 두지 않음 | 각 App에서 정의 |
| `server.port` | 두지 않음 | 각 App에서 정의 |
| 공통 Java | 소유 | 사용 |
| 공통 기능 SQL | 소유 가능 | Classpath에서 사용 |

---

## 4. 권장 Directory 구조

```text
module-common/
├─ build.gradle
└─ src/
   ├─ main/
   │  ├─ java/
   │  │  └─ io/github/.../common/
   │  │     ├─ exception/
   │  │     ├─ response/
   │  │     ├─ util/
   │  │     ├─ config/
   │  │     └─ mapper/
   │  │
   │  └─ resources/
   │     ├─ microserver-common.yml
   │     └─ mybatis/
   │        └─ common/
   │
   └─ test/
      ├─ java/
      └─ resources/
```

Package는 실제 기능이 구현되는 시점에 확정한다.

---

## 5. Java 코드와 Resource를 같이 소유

예를 들어 공통 코드 조회 기능을 제공한다고 가정한다.

```text
module-common
├─ CommonCodeService.java
├─ CommonCodeMapper.java
└─ resources/mybatis/common/CommonCodeMapper.xml
```

이 세 요소는 같은 공통 기능이므로 같은 Module에 둔다.

이렇게 해야 다음이 일치한다.

```text
코드 변경
SQL 변경
Test
Build
JAR Version
```

---

## 6. `src/main/resources`를 사용한다

공통 Resource는 Gradle 표준 위치를 사용한다.

```text
module-common/src/main/resources
```

Gradle Java Library Plugin은 Production Class와 Resource를 JAR에 패키징한다.

개념:

```text
module-common.jar
├─ *.class
├─ microserver-common.yml
└─ mybatis/common/*.xml
```

별도의 수동 Resource 복사 Script를 기본 구조로 만들지 않는다.

---

## 7. Common YAML의 역할

초기에는 다음과 같은 명시적 공통 Config Resource를 둘 수 있다.

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

여기에는 **Framework 공통 정책**만 둔다.

---

## 8. Common YAML에 두지 않는 값

```text
spring.application.name
server.port
DB URL
DB Username / Password
외부 API Host
실제 인증서 경로
운영 Log Directory
```

이 값들은 실행 Application 또는 Environment가 소유한다.

---

## 9. 실행 Application에서 Common Config 사용

`runtime`, `admin`은 Gradle Project Dependency로 Common을 사용한다.

```groovy
dependencies {
    implementation project(':module-common')
}
```

필요한 Common Config는 Application YAML에서 명시적으로 Import하는 방식을 사용할 수 있다.

```yaml
spring:
  config:
    import: classpath:microserver-common.yml
```

초기에는 자동으로 숨겨서 로드되는 구조보다
명시적으로 의존 관계를 확인할 수 있는 구조를 우선한다.

자세한 내용은 [Spring Boot YAML 공통 설정](../../05_feature_development/01_framework_configuration/spring_boot_configuration.md)에서 다룬다.

---

## 10. 공통 Mapper SQL

Common이 제공하는 Data Access 기능은 Common이 SQL도 소유한다.

```text
module-common/src/main/resources/mybatis/common/
```

예:

```text
CommonCodeMapper.xml
SequenceMapper.xml
SystemPropertyMapper.xml
```

실행 Application은 Common SQL File 경로를 직접 알기보다
Common Java API를 통해 기능을 사용하는 것을 권장한다.

```text
runtime
→ Common Service
→ Common Mapper Interface
→ Common Mapper XML
```

---

## 11. 다른 Module의 내부 SQL을 직접 호출하지 않음

지양:

```text
runtime Service
→ "common.selectCode" 같은 Statement ID 문자열 직접 호출
```

권장:

```text
runtime
→ CommonCodeService
→ CommonCodeMapper
→ CommonCodeMapper.xml
```

Common의 내부 구현을 Java API 뒤에 감춘다.

---

## 12. `module-common`에서 Spring Boot Starter 사용 판단

Common은 실행 Application이 아니므로
실행을 위한 Spring Boot Plugin / `bootRun`을 적용하지 않는다.

Dependency도 Common 코드가 실제로 사용하는 API 중심으로 선언한다.

예를 들어 MyBatis Mapper Interface 때문에 MyBatis API가 필요할 수 있지만,
DataSource Auto Configuration과 Application Bootstrapping은 실행 Module의 책임이다.

즉 **Library에 필요하지 않은 Starter를 편의상 전부 넣지 않는다.**

---

## 13. Public API와 내부 구현

`java-library`는 `api`와 `implementation` Dependency를 구분할 수 있다.

원칙:

```text
Common의 Public Type에 노출되는 Dependency
→ api 검토

Common 내부 구현에서만 사용하는 Dependency
→ implementation
```

처음부터 모든 Dependency를 `api`로 선언하지 않는다.

---

## 14. Common이 소유하면 안 되는 것

```text
Runtime Application Main Class
Admin Application Main Class
Application별 Port
환경별 DB 접속정보
운영 Secret
Runtime 전용 Controller
Admin 전용 Template
특정 Application에서만 사용하는 SQL
```

Common은 '여기에 두면 편해서'가 아니라 '여러 Application에서 같은 책임으로 재사용해서' 사용하는 Module이다.

---

## 15. Build 확인

Windows Project Root 기준:

```powershell
.\gradlew.bat :module-common:clean :module-common:build
```

Build 결과 예:

```text
module-common/build/libs/
```

Common은 일반 Library JAR로 생성되는 것을 확인한다.

---

## 16. JAR Resource 확인

Resource Packaging 문제가 의심될 때 JDK `jar` 명령으로 확인할 수 있다.

```powershell
jar tf .\module-common\build\libs\module-common-*.jar
```

확인 예:

```text
microserver-common.yml
mybatis/common/CommonCodeMapper.xml
```

매 Build마다 확인하는 절차가 아니라 Resource 누락 문제를 분석할 때 사용하는 검증 방법이다.

---

## 17. Test 방향

Common 기능의 Unit Test는 Common Module에서 수행한다.

```text
module-common/src/test/java
```

Common SQL이 포함된 Integration Test는
향후 DataSource / Test DB 전략이 확정된 후 Common Module에서 구성한다.

실행 Application에서 Common 내부 기능을 동일하게 중복 테스트하지 않는다.

---

## 18. Module 분리 시점

`module-common`이 커졌다고 바로 여러 Module로 쪼개지 않는다.

다음과 같은 독립 책임이 실제로 확인되면 검토한다.

```text
module-data
module-web
module-security
module-observability
```

조건:

```text
독립 Dependency 경계가 필요
독립 Test 가치가 큼
여러 Application에서 별도 조합 필요
Release 책임이 분리됨
```

---

## 19. 체크리스트

- [ ] `module-common`은 일반 Library JAR이다.
- [ ] Main Application Class와 Port 설정이 없다.
- [ ] Common Java와 직접 연관된 Resource를 같은 Module에 둔다.
- [ ] Common Mapper SQL은 `src/main/resources/mybatis/common`에서 관리한다.
- [ ] Common YAML에는 Framework 공통 정책만 둔다.
- [ ] 운영 DB 정보와 Secret을 Common JAR에 넣지 않는다.
- [ ] 실행 Application에 대한 역방향 Dependency가 없다.
- [ ] 다른 Module이 Common Mapper Statement ID를 직접 문자열로 호출하지 않는다.
- [ ] Common JAR Build와 Resource Packaging을 검증할 수 있다.

---

## 20. 다음 단계

실행 Application의 역할을 구성한다.

→ [runtime 모듈 구성](runtime_module.md)
