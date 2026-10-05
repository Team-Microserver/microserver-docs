# 생성된 파일 / Directory 구조 확인

## 1. 문서 목적

본 문서는 Spring Initializr로 생성했거나 기존 Git Repository에서 Clone한
MicroServer Spring Boot 프로젝트의 **파일 및 Directory 구조가 정상인지
확인**한다.

이 단계에서는 프로젝트를 수정하거나 Build / Run하지 않는다. 생성 또는
Clone된 결과가 MicroServer 프로젝트의 기본 구조와 일치하는지만 확인한다.

선행 문서:

→ [Git Repository 초기화 및 연결](spring_boot_git_init.md)

다음 문서:

→ [생성된 Gradle / Spring 설정값
확인](spring_boot_project_config_review.md)

------------------------------------------------------------------------

## 2. 현재 단계의 위치

``` mermaid
flowchart LR
    A["Spring Boot 프로젝트 생성"]
    --> B["Git Repository 초기화 / Clone"]
    --> C["파일 / Directory 구조 확인"]
    --> D["Gradle / Spring 설정값 확인"]
    --> E["Package 구조 설계"]
    --> F["프로젝트 개발환경 설정"]
```

현재:

``` text
Spring Boot 프로젝트 생성
        ↓
Git Repository 초기화 / Clone
        ↓
[ 생성된 파일 / Directory 구조 확인 ]   ← 현재
        ↓
생성된 Gradle / Spring 설정값 확인
```

------------------------------------------------------------------------

## 3. Repository Root 확인

MicroServer Source Repository의 논리적 위치:

``` text
<MICROSERVER_HOME>
└─ workspace
   └─ microserver
```

운영체제별 기본 Project Root:

  운영체제   Project Root
  ---------- ----------------------------------------------
  Windows    `C:\local-microserver\workspace\microserver`
  macOS      `~/local-microserver/workspace/microserver`

Project Root로 이동한다.

=== "Windows"

    ```powershell
    Set-Location C:\local-microserver\workspace\microserver
    ```

=== "macOS"

    ```bash
    cd ~/local-microserver/workspace/microserver
    ```

Git Repository Root 확인:

``` bash
git rev-parse --show-toplevel
```

기대 결과는 현재 `microserver` Project Root이다.

!!! important "Repository Root를 먼저 확인" 이후 모든 Project 파일은 이
Repository Root를 기준으로 확인한다.

    ```text
    X workspace/microserver/microserver/build.gradle
    O workspace/microserver/build.gradle
    ```

------------------------------------------------------------------------

## 4. 생성 후 기본 Directory 구조 확인

정상적으로 생성 또는 Clone되었다면 다음과 유사한 구조가 된다.

``` text
<MICROSERVER_PROJECT_ROOT>
│
├─ .git
├─ .gitignore
├─ .gitattributes                 ← Initializr Version에 따라 존재 가능
├─ gradle
│  └─ wrapper
│     ├─ gradle-wrapper.jar
│     └─ gradle-wrapper.properties
│
├─ src
│  ├─ main
│  │  ├─ java
│  │  │  └─ io
│  │  │     └─ github
│  │  │        └─ microserverlab
│  │  │           └─ microserver
│  │  │              └─ *Application.java
│  │  └─ resources
│  │     └─ application.properties
│  │
│  └─ test
│     └─ java
│        └─ io
│           └─ github
│              └─ microserverlab
│                 └─ microserver
│                    └─ *ApplicationTests.java
│
├─ build.gradle
├─ settings.gradle
├─ gradlew
├─ gradlew.bat
├─ README.md                      ← 기존 Repository에 있던 경우
└─ HELP.md                        ← Initializr Version에 따라 존재 가능
```

!!! note "Initializr Version에 따른 차이" `.gitattributes`, `HELP.md`
등의 존재 여부는 Initializr Version에 따라 달라질 수 있다.

핵심 확인 대상:

``` text
build.gradle
settings.gradle
gradlew
gradlew.bat
gradle/wrapper/
src/main/
src/test/
```

------------------------------------------------------------------------

## 5. Gradle Project인지 확인

현재 MicroServer는 **Gradle - Groovy** 프로젝트이다.

따라서 Project Root에는 다음 파일이 존재해야 한다.

``` text
build.gradle
settings.gradle
gradle/wrapper/
gradlew
gradlew.bat
```

Maven Project에서 사용하는 다음 파일은 현재 프로젝트의 필수 구조가
아니다.

``` text
pom.xml
.mvn/
mvnw
mvnw.cmd
```

!!! warning "`.mvn`을 만들거나 복사하지 않음" 현재 MicroServer는 Gradle
Project이므로 Maven Wrapper용 `.mvn` Directory를 생성하거나 복사하지
않는다.

Maven 구조에 대한 상세 비교는 별도의 **Maven 기본 구조 (비교 / 참고)**
문서를 참고한다.

------------------------------------------------------------------------

## 6. Main Application Class 확인

경로:

``` text
src/main/java/io/github/microserverlab/microserver/
```

예:

``` text
MicroserverApplication.java
```

기본 형태:

``` java
@SpringBootApplication
public class MicroserverApplication {

    public static void main(String[] args) {
        SpringApplication.run(MicroserverApplication.class, args);
    }
}
```

현재 단계에서는 생성된 Main Class가 존재하는지만 확인하고 ComponentScan
범위 변경, Configuration 등록, Bean 추가 등의 작업은 하지 않는다.

### Base Package 확인

현재 Base Package:

``` text
io.github.microserverlab.microserver
```

``` text
io.github
└─ microserverlab        ← Group / Namespace
   └─ microserver        ← Project
```

실제 Package 구조의 상세 설계는 뒤의 **Package 구조 설계** 단계에서
진행한다.

------------------------------------------------------------------------

## 7. 기본 Test Class 확인

경로 예:

``` text
src/test/java/io/github/microserverlab/microserver/MicroserverApplicationTests.java
```

기본 형태:

``` java
@SpringBootTest
class MicroserverApplicationTests {

    @Test
    void contextLoads() {
    }
}
```

현재 단계에서는 기본 Test Class를 삭제하지 않는다. 실제 Test 실행 여부는
이후 Build / Run 검증 단계에서 확인한다.

------------------------------------------------------------------------

## 8. Resource Directory 확인

기본 설정 파일:

``` text
src/main/resources/application.properties
```

Spring Initializr가 빈 파일 또는 최소 내용으로 생성할 수 있다.

현재는 파일의 존재와 위치만 확인한다.

다음 설정은 아직 추가하지 않는다.

``` text
server.port
Datasource
Oracle URL
DB Username / Password
Logging 상세 설정
Spring Profile
Security
Cache
Transaction
```

`application.yml` 전환과 기본 설정은 이후 전용 문서에서 진행한다.

------------------------------------------------------------------------

## 9. Git 관리 파일 기본 확인

Project Root에서 다음 파일이 존재하는지 확인한다.

``` text
.git
.gitignore
```

대표적인 Gradle Build 제외 대상:

``` gitignore
.gradle/
build/
```

반대로 Gradle Wrapper는 Git 관리 대상이다.

``` text
gradlew
gradlew.bat
gradle/wrapper/gradle-wrapper.jar
gradle/wrapper/gradle-wrapper.properties
```

기존 Repository를 Clone한 경우에는 `.git`과 Commit History가 이미
구성되어 있으므로 `git init`을 다시 실행하지 않는다.

------------------------------------------------------------------------

## 10. 현재 단계에서 하지 않는 작업

``` text
build.gradle 상세 수정
settings.gradle 상세 수정
Gradle Wrapper Version 변경
Project JDK / VS Code 설정
Java Project 수동 Import
Spring Boot Dashboard 실행
Build / Test
Application Run
Datasource 설정
Multi-Project 구성
```

이 단계의 목적은 **생성 또는 Clone된 파일과 Directory 구조 자체를
확인하는 것**이다.

------------------------------------------------------------------------

## 11. 완료 체크리스트

-   [ ] Repository Root가 `microserver` Project Root이다.
-   [ ] Project Directory가 `microserver/microserver`로 중첩되지 않았다.
-   [ ] `src/main/`이 존재한다.
-   [ ] `src/test/`가 존재한다.
-   [ ] Main Application Class가 존재한다.
-   [ ] 기본 Test Class가 존재한다.
-   [ ] `src/main/resources/application.properties`가 존재한다.
-   [ ] `build.gradle`이 존재한다.
-   [ ] `settings.gradle`이 존재한다.
-   [ ] `gradlew`, `gradlew.bat`이 존재한다.
-   [ ] `gradle/wrapper/`가 존재한다.
-   [ ] `.gitignore`가 존재한다.
-   [ ] Maven용 `.mvn`을 만들거나 복사하지 않았다.
-   [ ] 아직 Build / Run을 수행하지 않았다.

------------------------------------------------------------------------

## 12. 다음 단계

다음 단계에서는 파일 존재 여부를 넘어 Spring Initializr가 생성한
**Gradle / Spring 주요 설정값이 MicroServer 기준과 맞는지 확인**한다.

→ [생성된 Gradle / Spring 설정값
확인](spring_boot_project_config_review.md)
