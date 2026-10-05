# 생성된 Gradle / Spring 설정값 확인

## 1. 문서 목적

본 문서는 생성 또는 Clone된 MicroServer Spring Boot 프로젝트의
`settings.gradle`, `build.gradle`, Gradle Wrapper 및 Spring Boot 기본
설정값을 확인한다.

이 단계의 핵심은 **설정값을 변경하는 것이 아니라 생성 결과가 기준에
맞는지 확인하는 것**이다.

선행 문서:

→ [생성된 파일 / Directory 구조
확인](spring_boot_project_structure_review.md)

------------------------------------------------------------------------

## 2. 현재 단계의 위치

``` text
Spring Boot 프로젝트 생성
        ↓
Git Repository 초기화 / Clone
        ↓
생성된 파일 / Directory 구조 확인
        ↓
[ 생성된 Gradle / Spring 설정값 확인 ]   ← 현재
        ↓
Package 구조 설계
        ↓
프로젝트 개발환경 설정
```

------------------------------------------------------------------------

## 3. `settings.gradle` 확인

현재 MicroServer는 아직 단일 Project이므로 기본 내용은 단순하다.

``` groovy
rootProject.name = 'microserver'
```

확인 항목:

``` text
1. settings.gradle이 Project Root에 존재하는가?
2. rootProject.name이 'microserver'인가?
3. 아직 include(...) Subproject가 추가되어 있지 않은가?
```

정상 기준:

``` text
파일 존재                    → O
rootProject.name             → microserver
include(...)                 → 없음
Multi-Project 구성           → 아직 안 함
```

현재는 `settings.gradle`을 수정하지 않는다.

------------------------------------------------------------------------

## 4. `build.gradle` 기본값 확인

현재 단계에서는 Spring Initializr가 생성한 기준값을 확인한다.

주요 확인 항목:

``` text
Spring Boot Plugin Version
Group
Version
Java Toolchain
Repositories
Spring Web Dependency
Test Dependency
```

### 4.1 Spring Boot Plugin

현재 프로젝트 기준:

``` text
4.1.1
```

예:

``` groovy
plugins {
    id 'java'
    id 'org.springframework.boot' version '4.1.1'
}
```

Initializr가 추가한 다른 Plugin은 실제 생성 결과를 기준으로 확인한다.

### 4.2 Group / Version

현재 기준:

``` text
Group   : io.github.microserverlab
Version : 0.0.1-SNAPSHOT
```

구분:

``` text
Team / Organization : team-microserver
Java Group          : io.github.microserverlab
Project             : microserver
```

Team 이름, Java Group, Gradle Root Project 이름은 각각 역할이 다르다.

### 4.3 Java Toolchain

현재 MicroServer 프로젝트 표준:

``` text
Java 25
```

예:

``` groovy
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(25)
    }
}
```

현재는 `build.gradle`에 Java 25 기준이 들어 있는지만 확인한다.

!!! important "JDK 연결 설정은 다음 단계" VS Code Language Server JDK,
Terminal의 `JAVA_HOME`, Gradle 실행 JDK와 Project Toolchain의 상세
연계는 **프로젝트 개발환경 설정**의 전용 문서에서 진행한다.

### 4.4 Spring Web Dependency

현재 프로젝트에서 확인할 Spring MVC 기반 Starter:

``` text
org.springframework.boot:spring-boot-starter-webmvc
```

예:

``` groovy
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-webmvc'
}
```

현재 Initializr가 생성한 Dependency를 우선 보존한다.

### 4.5 Test Dependency

Spring Boot 4에서는 Test Starter 구성이 과거 버전과 다를 수 있으므로
현재 Initializr가 생성한 Test Dependency를 기준으로 확인한다.

현재 단계에서는 Test Dependency Version이나 구성을 임의로 변경하지
않는다.

------------------------------------------------------------------------

## 5. `settings.gradle`과 `build.gradle` 역할 구분

``` text
settings.gradle
    → 어떤 Project들이 Gradle Build에 포함되는가?
    → Root Project 이름은 무엇인가?

build.gradle
    → 어떤 Plugin을 사용하는가?
    → Java Version은 무엇인가?
    → 어떤 Dependency를 사용하는가?
    → Build Task를 어떻게 구성하는가?
```

현재는 Multi-Project 단계가 아니므로 `settings.gradle`에
`include(...)`를 추가하지 않는다.

------------------------------------------------------------------------

## 6. Gradle Wrapper 생성값 확인

Project Root 기준:

``` text
<MICROSERVER_PROJECT_ROOT>
│
├─ gradle
│  └─ wrapper
│     ├─ gradle-wrapper.jar
│     └─ gradle-wrapper.properties
│
├─ gradlew
└─ gradlew.bat
```

각 파일의 역할:

  파일                          역할
  ----------------------------- --------------------------------------------
  `gradlew`                     macOS / Linux용 Gradle Wrapper 실행 Script
  `gradlew.bat`                 Windows용 Gradle Wrapper 실행 Script
  `gradle-wrapper.jar`          Wrapper 실행 Program
  `gradle-wrapper.properties`   Gradle Distribution / Version 정보

현재 단계에서는 Wrapper를 실행하거나 Version을 변경하지 않는다.

확인 목적:

``` text
Spring Initializr가 Gradle Project를 정상 생성했는가?
        ↓
Gradle Wrapper 관련 파일이 모두 존재하는가?
```

### Wrapper Directory 확인

=== "Windows"

    ```powershell
    Get-ChildItem .\gradle\wrapper
    ```

=== "macOS"

    ```bash
    ls -la ./gradle/wrapper
    ```

확인:

``` text
gradle-wrapper.jar          → 존재
gradle-wrapper.properties   → 존재
```

!!! important "Gradle Wrapper는 Git 관리 대상" 다음 파일은 Git에
포함한다.

    ```text
    gradlew
    gradlew.bat
    gradle/wrapper/gradle-wrapper.jar
    gradle/wrapper/gradle-wrapper.properties
    ```

------------------------------------------------------------------------

## 7. Spring 기본 설정 파일 확인

기본 설정 파일:

``` text
src/main/resources/application.properties
```

현재 단계에서는 생성 상태를 유지한다.

다음 작업은 이후 `application.yml 기본 설정` 문서에서 진행한다.

``` text
application.yml 전환
Profile 구성
Datasource
Logging
환경별 설정
```

------------------------------------------------------------------------

## 8. 현재 단계에서 수정하지 않는 항목

``` text
settings.gradle의 include(...)
Gradle Wrapper Version
Project JDK / VS Code 상세 설정
.vscode/settings.json
application-local.yml
Oracle JDBC / Datasource
업무 Package
Controller / Service / DAO
Filter / AOP
Security / Transaction / Cache
Multi-Project
```

또한 아직 다음 명령으로 Build / Run 검증을 수행하지 않는다.

=== "Windows"

    ```powershell
    .\gradlew.bat build
    .\gradlew.bat bootRun
    ```

=== "macOS"

    ```bash
    ./gradlew build
    ./gradlew bootRun
    ```

실제 Gradle 실행과 Build 기준은 이후 전용 문서에서 확인한다.

------------------------------------------------------------------------

## 9. 완료 체크리스트

-   [ ] `settings.gradle`이 존재한다.
-   [ ] `rootProject.name = 'microserver'`이다.
-   [ ] 아직 `include(...)`가 없다.
-   [ ] Spring Boot Plugin Version이 `4.1.1`이다.
-   [ ] Group이 `io.github.microserverlab`이다.
-   [ ] Version이 `0.0.1-SNAPSHOT`이다.
-   [ ] Java Toolchain 기준이 `25`이다.
-   [ ] Spring Web Dependency가 현재 Initializr 생성 기준과 일치한다.
-   [ ] Test Dependency를 임의로 변경하지 않았다.
-   [ ] `gradlew`, `gradlew.bat`이 존재한다.
-   [ ] `gradle-wrapper.jar`, `gradle-wrapper.properties`가 존재한다.
-   [ ] Wrapper Version을 임의로 변경하지 않았다.
-   [ ] 아직 Build / Run을 수행하지 않았다.

------------------------------------------------------------------------

## 10. 다음 단계

생성 결과의 구조와 기본 설정값 확인이 끝나면 **Package 구조 설계**를
진행한 뒤 프로젝트 개발환경 설정 단계로 이동한다.

상세 개념, 문제 해결, VS Code Import, Git 상태, Build와 Import의 차이
등은 별도의 **생성 프로젝트 확인 참고 가이드**에서 확인한다.
