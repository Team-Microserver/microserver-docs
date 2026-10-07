# 생성된 Gradle / Spring 설정값 확인

## 1. 문서 목적

본 문서는 생성 또는 Clone된 MicroServer Spring Boot 프로젝트의 `settings.gradle`, `build.gradle`, Gradle Wrapper 및 Spring Boot 기본 설정값을 확인한다.

이 단계의 목적은 **설정을 새로 구성하거나 변경하는 것이 아니라, Spring Initializr 또는 기존 Repository에서 가져온 설정이 현재 MicroServer 프로젝트의 기준과 일치하는지 확인하는 것**이다.

선행 문서:

→ [생성된 파일 / Directory 구조 확인](spring_boot_project_structure_review.md)

------------------------------------------------------------------------

## 2. 현재 단계의 위치

```text
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

이전 단계에서는 **파일과 Directory가 올바른 위치에 생성되었는지**를 확인했다.

이번 단계에서는 한 단계 더 들어가 다음 내용을 확인한다.

| 확인 대상 | 확인하는 이유 |
| --- | --- |
| `settings.gradle` | Gradle이 어떤 프로젝트를 Root Project로 인식하는지 확인 |
| `build.gradle` | Spring Boot, Java Version, Dependency 등 Build 기준 확인 |
| Gradle Wrapper | 개발 PC에 설치된 Gradle에 의존하지 않고 동일한 Gradle 환경을 사용할 준비가 되었는지 확인 |
| `application.properties` | Spring Boot 기본 설정 파일이 정상 위치에 존재하는지 확인 |

!!! note "현재 단계에서는 확인만 수행"
    설정값이 현재 MicroServer 기준과 일치하는지 확인하는 단계이다.  
    Multi-Project 구성, JDK 연결, Datasource, Profile 등의 실제 설정 작업은 이후 단계에서 진행한다.

------------------------------------------------------------------------

## 3. `settings.gradle` 확인

### 3.1 `settings.gradle`의 역할

`settings.gradle`은 Gradle Build에서 **프로젝트의 전체 구성과 Root Project를 정의하는 파일**이다.

현재 MicroServer는 아직 Multi-Project로 전환하기 전의 **단일 Project 상태**이므로 내용이 매우 단순하다.

현재 기준:

```groovy
rootProject.name = 'microserver'
```

이 한 줄은 현재 Gradle Build의 Root Project 이름을 `microserver`로 사용한다는 의미이다.

### 3.2 확인해야 할 내용

| 확인 항목 | 확인 방법 | 현재 정상 기준 | 의미 |
| --- | --- | --- | --- |
| 파일 위치 | Project Root 확인 | `settings.gradle` 존재 | Gradle Project 설정 파일이 정상 위치에 있음 |
| Root Project 이름 | `rootProject.name` 확인 | `'microserver'` | 현재 프로젝트 이름이 MicroServer 기준과 일치 |
| Subproject 등록 | `include(...)` 존재 여부 확인 | 없음 | 아직 Multi-Project 전환 전 단계 |
| Multi-Project 구성 | Module 등록 여부 확인 | 아직 구성하지 않음 | 이후 별도 단계에서 구성 |

즉, 현재 `settings.gradle`은 다음 상태이면 정상이다.

```groovy
rootProject.name = 'microserver'
```

아직 다음과 같은 Subproject 등록은 없어야 한다.

```groovy
include('microserver-core')
include('microserver-web')
```

!!! important "왜 include(...)가 없어야 하는가?"
    현재 단계는 Spring Boot 기본 프로젝트가 정상 생성되었는지 확인하는 단계이다.  
    Framework와 업무 Domain을 분리하는 Multi-Project 구조는 이후 **Multi-Project 전환 단계**에서 설계하고 적용한다.

따라서 현재는 `settings.gradle`을 수정하지 않는다.

------------------------------------------------------------------------

## 4. `build.gradle` 기본값 확인

### 4.1 `build.gradle`의 역할

`build.gradle`은 현재 Project를 **어떤 Java Version으로 Build할지, 어떤 Spring Boot Plugin과 Dependency를 사용할지** 정의한다.

현재 단계에서는 Spring Initializr가 생성한 내용을 수정하지 않고 다음 핵심 설정이 MicroServer 기준과 일치하는지만 확인한다.

| 확인 항목 | 현재 기준 | 확인 목적 |
| --- | --- | --- |
| Spring Boot Plugin | `4.1.1` | 프로젝트의 Spring Boot 기준 Version 확인 |
| Group | `io.github.microserverlab` | Java Package / Artifact Namespace 기준 확인 |
| Version | `0.0.1-SNAPSHOT` | 현재 Project 기본 Version 확인 |
| Java Toolchain | `25` | Source Compile 및 Build 대상 Java Version 확인 |
| Repository | `mavenCentral()` 등 생성값 | Dependency를 조회할 Repository 확인 |
| Spring Web | `spring-boot-starter-webmvc` | Spring MVC 기반 Web 개발 Dependency 확인 |
| Test | Initializr 생성값 | 기본 Test 환경이 유지되는지 확인 |

### 4.2 Spring Boot Plugin 확인

현재 MicroServer 기준 Spring Boot Plugin Version:

```text
4.1.1
```

`build.gradle`의 `plugins` 영역에서 다음과 같이 확인한다.

```groovy
plugins {
    id 'java'
    id 'org.springframework.boot' version '4.1.1'
}
```

여기서 확인할 핵심은 `org.springframework.boot` Plugin의 Version이 현재 MicroServer 기준인 `4.1.1`인지 여부이다.

Initializr가 추가한 다른 Plugin은 실제 생성 결과를 기준으로 유지한다.

### 4.3 Group / Version 확인

현재 기준:

```text
Group   : io.github.microserverlab
Version : 0.0.1-SNAPSHOT
```

각 값의 역할은 다음과 같다.

| 구분 | 값 | 의미 |
| --- | --- | --- |
| Team / Organization | `team-microserver` | GitHub Organization 및 프로젝트 관리 단위 |
| Java Group | `io.github.microserverlab` | Java Package / Artifact Namespace |
| Project | `microserver` | Gradle Root Project 이름 |

Team 이름, Java Group, Gradle Root Project 이름은 서로 비슷해 보이지만 각각 역할이 다르므로 구분해서 확인한다.

### 4.4 Java Toolchain 확인

현재 MicroServer 프로젝트의 Java 기준:

```text
Java 25
```

`build.gradle`에서 다음 설정을 확인한다.

```groovy
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(25)
    }
}
```

이 설정은 **이 프로젝트가 Java 25를 기준으로 Compile / Build되어야 한다는 의미**이다.

!!! important "Project Java 기준과 실제 실행 JDK는 구분"
    여기서는 `build.gradle`의 Java Toolchain이 `25`인지 확인한다.

    VS Code Language Server가 사용하는 JDK, Terminal의 `JAVA_HOME`, Gradle 실행 JDK 등 실제 개발환경의 JDK 연결은 이후 **프로젝트 개발환경 설정** 단계에서 확인한다.

### 4.5 Repository 확인

Dependency를 내려받기 위한 Repository 설정이 존재하는지 확인한다.

예:

```groovy
repositories {
    mavenCentral()
}
```

현재 단계에서는 Repository를 추가하거나 변경하지 않고 Initializr가 생성한 값을 유지한다.

### 4.6 Spring Web Dependency 확인

현재 프로젝트에서 사용하는 Spring MVC 기반 Starter:

```text
org.springframework.boot:spring-boot-starter-webmvc
```

예:

```groovy
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-webmvc'
}
```

이 Dependency가 존재하면 Spring MVC 기반 Web Application을 구성하기 위한 기본 기능이 프로젝트에 포함된다.

현재 단계에서는 Initializr가 생성한 Dependency를 임의로 변경하지 않는다.

### 4.7 Test Dependency 확인

Test 관련 Dependency도 `dependencies` 영역에서 확인한다.

Spring Boot Version에 따라 Initializr가 생성하는 Test Dependency 구성이 달라질 수 있으므로 **현재 생성된 구성을 그대로 유지하는 것**을 기준으로 한다.

이 단계에서는 Test Dependency를 추가하거나 Version을 임의로 변경하지 않는다.

------------------------------------------------------------------------

## 5. `settings.gradle`과 `build.gradle` 역할 구분

두 파일의 역할을 혼동하지 않도록 다음과 같이 구분한다.

| 파일 | 핵심 역할 | 대표적으로 확인하는 내용 |
| --- | --- | --- |
| `settings.gradle` | Gradle Project 구조 정의 | Root Project 이름, Subproject 포함 여부 |
| `build.gradle` | Project Build 방법 정의 | Plugin, Java Version, Repository, Dependency, Build 설정 |

간단히 보면 다음과 같다.

```text
settings.gradle
    └─ "어떤 Project를 Build 대상으로 볼 것인가?"

build.gradle
    └─ "그 Project를 어떤 기준과 Dependency로 Build할 것인가?"
```

현재는 단일 Project 단계이므로 `settings.gradle`에는 `rootProject.name`만 존재하고 `include(...)`는 추가하지 않는다.

------------------------------------------------------------------------

## 6. Gradle Wrapper 생성값 확인

### 6.1 Gradle Wrapper란?

Gradle Wrapper는 개발 PC에 별도로 설치된 Gradle Version에 의존하지 않고 **프로젝트가 지정한 Gradle 환경으로 Build할 수 있도록 제공되는 실행 도구**이다.

Project Root에는 다음 파일들이 존재해야 한다.

```text
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

| 파일 | 역할 |
| --- | --- |
| `gradlew` | macOS / Linux용 Gradle Wrapper 실행 Script |
| `gradlew.bat` | Windows용 Gradle Wrapper 실행 Script |
| `gradle-wrapper.jar` | Gradle Wrapper 실행 Program |
| `gradle-wrapper.properties` | 사용할 Gradle Distribution / Version 정보 |

### 6.2 Wrapper 파일 확인

=== "Windows"

    ```powershell
    Get-ChildItem .\gradle\wrapper
    ```

=== "macOS"

    ```bash
    ls -la ./gradle/wrapper
    ```

정상이라면 최소한 다음 두 파일이 확인되어야 한다.

```text
gradle-wrapper.jar
gradle-wrapper.properties
```

Project Root의 `gradlew`, `gradlew.bat`도 함께 존재해야 한다.

!!! important "Gradle Wrapper는 Git 관리 대상"
    다음 파일은 개발환경마다 새로 만드는 파일이 아니라 Project와 함께 Git으로 관리한다.

    ```text
    gradlew
    gradlew.bat
    gradle/wrapper/gradle-wrapper.jar
    gradle/wrapper/gradle-wrapper.properties
    ```

현재 단계에서는 Wrapper가 정상 생성되어 있는지만 확인하고 실행하거나 Version을 변경하지 않는다.

------------------------------------------------------------------------

## 7. Spring 기본 설정 파일 확인

Spring Boot 기본 설정 파일 위치:

```text
src/main/resources/application.properties
```

현재 단계에서는 **파일이 정상 위치에 존재하는지만 확인**한다.

아직 다음 설정은 진행하지 않는다.

| 이후 설정 항목 | 현재 단계 |
| --- | --- |
| `application.yml` 전환 | 하지 않음 |
| Spring Profile 구성 | 하지 않음 |
| Datasource | 하지 않음 |
| Logging 상세 설정 | 하지 않음 |
| 환경별 설정 | 하지 않음 |

이 설정들은 이후 전용 문서에서 단계적으로 구성한다.

------------------------------------------------------------------------

## 8. 현재 단계에서 수정하지 않는 항목

이번 단계는 생성된 설정값을 **검토하는 단계**이므로 다음 항목은 아직 변경하지 않는다.

```text
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
Multi-Project 구성
```

또한 아직 Build / Run 검증도 수행하지 않는다.

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

실제 Gradle 실행과 Build 검증은 이후 전용 단계에서 진행한다.

------------------------------------------------------------------------

## 9. 완료 체크리스트

아래 항목을 모두 확인하면 **생성된 Gradle / Spring 설정값 확인 단계가 완료**된다.

- [ ] Project Root에 `settings.gradle`이 존재한다.
- [ ] `rootProject.name = 'microserver'`로 설정되어 있다.
- [ ] `settings.gradle`에 아직 `include(...)`가 없다.
- [ ] Spring Boot Plugin Version이 `4.1.1`이다.
- [ ] Group이 `io.github.microserverlab`이다.
- [ ] Version이 `0.0.1-SNAPSHOT`이다.
- [ ] Java Toolchain이 `25`로 설정되어 있다.
- [ ] Dependency Repository 설정이 존재한다.
- [ ] Spring Web Dependency가 현재 Initializr 생성 기준과 일치한다.
- [ ] Test Dependency를 임의로 변경하지 않았다.
- [ ] Project Root에 `gradlew`, `gradlew.bat`이 존재한다.
- [ ] `gradle/wrapper/`에 `gradle-wrapper.jar`, `gradle-wrapper.properties`가 존재한다.
- [ ] Gradle Wrapper Version을 임의로 변경하지 않았다.
- [ ] `src/main/resources/application.properties`가 존재한다.
- [ ] 아직 Multi-Project 구성을 진행하지 않았다.
- [ ] 아직 Build / Run을 수행하지 않았다.

------------------------------------------------------------------------

## 10. 다음 단계

생성 결과의 파일 구조와 Gradle / Spring 기본 설정값 확인이 끝나면 **Package 구조 설계** 단계로 이동한다.

Package 구조 설계에서는 현재 단일 Spring Boot Project의 기본 Package를 기준으로 MicroServer Framework와 업무 Domain을 어떻게 분리할지 설계한다.

이후 **Multi-Project 전환** 및 **프로젝트 개발환경 설정** 단계로 연결한다.
