# Profile / 외부 리소스 구성

## 1. 문서 목적

본 문서는 MicroServer 실행 Application을
`local / dev / test / prod` 환경에서 **동일한 Build Artifact로 실행**할 수 있도록
Spring Profile, External Configuration, Environment Variable, `local-resource` 운영 기준을 정의한다.

주요 목표:

- Build와 Runtime Environment 분리
- Spring Profile 표준화
- `local-resource` 외부 설정 구조 정의
- `spring.config.additional-location` 사용 기준
- Port / DB / 외부 API 값 Override
- Secret을 Source Repository와 분리
- Local 실행 명령의 기준 위치 명시

---

## 2. 환경마다 다른 JAR를 만들지 않는다

기본 방향:

```text
runtime.jar
        +
local Config
```

```text
runtime.jar
        +
dev Config
```

```text
runtime.jar
        +
prod Config
```

지양:

```text
runtime-local.jar
runtime-dev.jar
runtime-prod.jar
```

Gradle은 Build를 담당하고,
Spring Profile / External Config가 Runtime 환경을 담당한다.

---

## 3. 기본 Profile

MicroServer Runtime Profile은 다음을 기본 후보로 한다.

```text
local
 dev
 test
 prod
```

Profile 이름은 환경을 표현한다.

다음처럼 Module 이름을 Profile로 사용하지 않는다.

```text
X runtime
X admin
```

`runtime`, `admin`은 Application 역할이고
`local`, `dev`, `prod`는 환경이다.

---

## 4. Profile 활성화

PowerShell:

```powershell
$env:SPRING_PROFILES_ACTIVE="local"
```

Command Line:

```powershell
java -jar runtime.jar --spring.profiles.active=local
```

JVM System Property:

```powershell
java -Dspring.profiles.active=local -jar runtime.jar
```

실행환경에서 Profile을 결정하는 것을 기본으로 한다.

---

## 5. Profile별 YAML

Spring Boot는 Profile-specific Config를 사용할 수 있다.

```text
application.yml
application-local.yml
application-dev.yml
application-test.yml
application-prod.yml
```

Profile이 `local`이면 기본 `application.yml`과 Local Profile 설정이 함께 적용될 수 있다.

---

## 6. 모든 환경정보를 JAR 내부에 넣지 않는다

다음처럼 운영정보가 JAR 내부 Profile YAML에 직접 들어가는 구조는 피한다.

```yaml
spring:
  datasource:
    password: real-production-password
```

Profile은 환경 구분 기능이고,
Secret을 Source에 저장해도 된다는 의미가 아니다.

---

## 7. `local-resource` 기본 구조

개발환경용 외부 Resource는 Project Root의 `local-resource`에서 관리할 수 있다.

```text
microserver/
└─ local-resource/
   ├─ README.md
   ├─ config/
   │  ├─ common/
   │  ├─ runtime/
   │  └─ admin/
   ├─ cert/
   ├─ logback/
   └─ db/
```

Directory는 실제 사용 시점에 생성한다.

---

## 8. `config/common`

환경은 같고 여러 Application이 실제로 공유하는 외부 값을 둘 수 있다.

예:

```text
local-resource/config/common/application-local.yml
```

예시:

```yaml
logging:
  level:
    root: INFO

microserver:
  external:
    connect-timeout: 3s
```

DB가 Application마다 다르면 Datasource를 Common에 두지 않는다.

---

## 9. Application별 외부 Config

Runtime:

```text
local-resource/config/runtime/application-local.yml
```

Admin:

```text
local-resource/config/admin/application-local.yml
```

예:

```yaml
server:
  port: 8085

spring:
  datasource:
    url: ${DB_URL}
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
```

실제 Password는 Environment에서 제공한다.

---

## 10. `spring.config.additional-location`

Spring Boot의 기본 Config 위치를 유지하면서
외부 Config Directory를 추가하려면 `spring.config.additional-location`을 사용할 수 있다.

PowerShell 예:

```powershell
$env:SPRING_CONFIG_ADDITIONAL_LOCATION="optional:file:./local-resource/config/common/,optional:file:./local-resource/config/runtime/"
```

그 후:

```powershell
.\gradlew.bat :runtime:bootRun
```

`additional-location`에 로드된 설정은 기본 Location의 값을 Override할 수 있다.

---

## 11. `spring.config.location`과 차이

개념적으로:

```text
spring.config.location
→ 기본 Location을 대체하는 용도로 사용할 수 있음

spring.config.additional-location
→ 기본 Location을 유지하면서 외부 Location 추가
```

MicroServer의 기본 목표는:

```text
JAR 기본 설정
+
환경별 외부 Override
```

이므로 `additional-location`을 우선 검토한다.

---

## 12. `additional-location`은 초기에 제공해야 한다

`spring.config.name`, `spring.config.location`, `spring.config.additional-location`은
Config 파일을 찾는 초기 단계에서 사용된다.

따라서 다음과 같은 방식으로 제공한다.

```text
OS Environment Variable
JVM System Property
Command Line Argument
```

Application 내부 YAML이 자기 자신의 외부 Config 검색 위치를 뒤늦게 정의하는 구조는 피한다.

---

## 13. `optional:`

예:

```text
optional:file:./local-resource/config/runtime/
```

해당 위치가 없어도 Application이 시작될 수 있도록 할 때 사용한다.

Local 개발 편의에는 유용하지만
운영에서 반드시 필요한 Config까지 모두 `optional:`로 처리할지는 별도 운영정책으로 결정한다.

---

## 14. Project Root 기준 실행

다음 상대경로:

```text
./local-resource/...
```

를 사용할 경우 PowerShell 현재 위치는 Project Root를 기준으로 한다.

```text
C:\local-microserver\workspace\microserver
```

확인:

```powershell
Get-Location
```

이동:

```powershell
Set-Location C:\local-microserver\workspace\microserver
```

---

## 15. Runtime Local 실행 예

```powershell
Set-Location C:\local-microserver\workspace\microserver

$env:SPRING_PROFILES_ACTIVE="local"
$env:DB_URL="jdbc:oracle:thin:@localhost:1521/FREEPDB1"
$env:DB_USERNAME="microserver"
$env:DB_PASSWORD="********"

$env:SPRING_CONFIG_ADDITIONAL_LOCATION="optional:file:./local-resource/config/common/,optional:file:./local-resource/config/runtime/"

.\gradlew.bat :runtime:bootRun
```

DB URL은 예시이며 실제 Oracle 구성은 Database 가이드에서 확정한다.

---

## 16. Admin Local 실행 예

```powershell
Set-Location C:\local-microserver\workspace\microserver

$env:SPRING_PROFILES_ACTIVE="local"
$env:SPRING_CONFIG_ADDITIONAL_LOCATION="optional:file:./local-resource/config/common/,optional:file:./local-resource/config/admin/"

.\gradlew.bat :admin:bootRun
```

Runtime과 같은 Shell Session에서 실행하면
Environment Variable 값이 공유될 수 있으므로 Application별 Terminal / Run Configuration 사용을 권장한다.

---

## 17. Port Override

Application YAML:

```yaml
server:
  port: ${SERVER_PORT:8080}
```

Local Override:

```powershell
$env:SERVER_PORT="8090"
```

일회성 Command Line:

```powershell
java -jar runtime.jar --server.port=8090
```

기존 JVM `-D` 방식도 사용할 수 있다.

```powershell
java -Dserver.port=8090 -jar runtime.jar
```

---

## 18. Secret 처리

다음 값은 Git에 Commit하지 않는다.

```text
DB Password
API Token
Private Key
Certificate Password
운영 Credential
```

YAML에서는 Placeholder만 사용한다.

```yaml
spring:
  datasource:
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
```

실제 운영 Secret Store 방식은 배포환경 정책에 따라 결정한다.

---

## 19. Jasypt와의 관계

공통 Framework Nav에는 별도 `Jasypt 설정` 문서가 있다.

본 문서의 원칙은 다음이다.

```text
Secret을 Plain Text로 Git에 저장하지 않는다.
```

Jasypt를 사용할지,
배포 Platform Secret Store를 사용할지,
환경변수를 사용할지는 보안 / 운영 기준에 따라 결정한다.

Jasypt는 Secret Management 전체를 대체하는 개념으로 취급하지 않는다.

---

## 20. 인증서

개발 인증서가 필요한 경우:

```text
local-resource/cert/
```

를 사용할 수 있다.

다만 다음 파일은 Git 관리 여부를 반드시 구분한다.

```text
공개 가능한 Test 인증서
실제 Private Key
운영 인증서
개인 인증서
```

실제 운영 Key Material은 Source Repository에 두지 않는다.

---

## 21. Logback External Override

기존 Project처럼 환경별 Logback 파일이 필요할 수 있다.

새 프로젝트에서는 우선 공통 Logging 가이드에서 `logback-spring.xml` 구조를 정하고,
외부 Override가 실제로 필요한 경우 `local-resource/logback`을 사용한다.

즉 Project Structure 단계에서 환경별 XML 파일을 미리 다수 생성하지 않는다.

---

## 22. DB Script

`local-resource/db`에는 다음 종류를 둘 수 있다.

```text
Local DB 초기화
개발 Test Data
Docker DB Bootstrap
Schema Setup Helper
```

Runtime Mapper SQL은 넣지 않는다.

---

## 23. Git 정책 예

개념 예:

```gitignore
# 실제 Local Config
local-resource/config/**/application-local.yml

# Example은 관리
!local-resource/config/**/application-local.yml.example

# 실제 Key Material
local-resource/cert/*
!local-resource/cert/.gitkeep
!local-resource/cert/README.md
```

실제 `.gitignore`와 충돌 여부를 확인한 뒤 적용한다.

---

## 24. Local 실행 Script

환경변수 설정이 반복되면 향후 다음과 같은 Script를 둘 수 있다.

```text
scripts/
├─ run-runtime-local.ps1
└─ run-admin-local.ps1
```

Script 책임:

```text
Profile 설정
External Config Location 설정
Local Port 설정
Gradle bootRun 호출
```

Password를 Script에 Hard Coding하지 않는다.

---

## 25. 설정 문제 확인 순서

값이 예상과 다르면 다음을 확인한다.

```text
1. 실행 Application
2. SPRING_PROFILES_ACTIVE
3. Application application.yml
4. Common Config Import
5. SPRING_CONFIG_ADDITIONAL_LOCATION
6. External application-{profile}.yml
7. Environment Variable
8. JVM System Property
9. Command Line Argument
```

같은 Key가 여러 곳에 중복되어 있지 않은지도 확인한다.

---

## 26. 완료 기준

```text
동일 Build Artifact
        ↓
Profile 선택
        ↓
External Config 연결
        ↓
Environment / Secret 주입
        ↓
Application 실행
```

Runtime과 Admin에서 각각 검증한다.

---

## 27. 체크리스트

- [ ] `local / dev / test / prod`를 Runtime Profile로 사용한다.
- [ ] 환경마다 다른 JAR를 만들지 않는다.
- [ ] `local-resource`를 외부 Runtime Resource 용도로 사용한다.
- [ ] 공통 외부 Config와 Application 외부 Config를 구분한다.
- [ ] `spring.config.additional-location`의 역할을 이해했다.
- [ ] 상대경로 실행 시 Project Root 위치를 확인한다.
- [ ] Port를 Runtime에서 Override할 수 있다.
- [ ] 실제 Secret을 Git에 Commit하지 않는다.
- [ ] 인증서 / Private Key의 Git 정책을 구분한다.
- [ ] Mapper SQL을 `local-resource`에 두지 않는다.

---

## 28. 다음 단계

Project 구조와 Configuration 책임이 정리되면
공통 Framework 기능 및 Database 연동을 단계적으로 구현한다.
