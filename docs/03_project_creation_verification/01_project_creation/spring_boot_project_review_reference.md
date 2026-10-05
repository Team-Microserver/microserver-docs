# 생성 프로젝트 확인 참고 가이드

## 1. 문서 목적

본 문서는 **생성된 파일 / Directory 구조 확인**과 **생성된 Gradle /
Spring 설정값 확인** 과정에서 알아두면 좋은 상세 개념과 문제 해결 내용을
모아 둔 참고 문서이다.

실제 필수 절차는 앞의 두 문서에서 수행한다. 이 문서는 필요할 때 찾아보는
Reference 성격으로 사용한다.

------------------------------------------------------------------------

## 2. Gradle Project와 Maven Project의 차이

현재 MicroServer는 **Gradle - Groovy** 프로젝트이다.

Gradle Project:

``` text
build.gradle
settings.gradle
gradle/wrapper/
gradlew
gradlew.bat
```

Maven Project:

``` text
pom.xml
.mvn/
mvnw
mvnw.cmd
```

따라서 Gradle Project에 Maven Wrapper용 `.mvn`을 만들거나 복사하지
않는다.

Maven의 전체 기본 구조는 별도의 **Maven 기본 구조 (비교 / 참고)** 문서를
참고한다.

------------------------------------------------------------------------

## 3. Team / Java Group / Gradle Root Project 구분

현재 프로젝트에서는 다음 값을 사용한다.

  ----------------------------------------------------------------------------
  구분                    현재 값                      의미
  ----------------------- ---------------------------- -----------------------
  Team / Organization     `team-microserver`           GitHub Organization /
                                                       Team 식별

  Java Group              `io.github.microserverlab`   Java Package / Artifact
                                                       Namespace

  Gradle Root Project     `microserver`                Gradle Build의 Root
                                                       Project 이름
  ----------------------------------------------------------------------------

세 값은 같은 개념이 아니다.

실제 회사 프로젝트에서는 공식 Domain이나 Java Package Naming Rule이
있다면 해당 프로젝트 기준을 우선한다.

------------------------------------------------------------------------

## 4. `settings.gradle`에 한 줄만 있는 이유

현재는 하나의 Spring Boot Project만 존재하기 때문에 다음 한 줄만 있어도
정상이다.

``` groovy
rootProject.name = 'microserver'
```

향후 Multi-Project 구조로 확장하면 다음과 같은 항목이 추가될 수 있다.

``` groovy
rootProject.name = 'microserver'

include 'microserver-core'
include 'microserver-api'
```

하지만 현재 단계에서는 추가하지 않는다.

------------------------------------------------------------------------

## 5. Gradle Wrapper 이해

Gradle Wrapper는 개발자 PC에 별도의 Gradle 설치를 강제하지 않고
프로젝트에서 정한 Gradle Version으로 Build할 수 있게 하는 실행 환경이다.

``` text
gradlew
gradlew.bat
gradle/wrapper/gradle-wrapper.jar
gradle/wrapper/gradle-wrapper.properties
```

Wrapper 파일은 Git 관리 대상이다.

### Project Root가 아닌 곳에서 Wrapper 경로 오류가 나는 경우

예를 들어 현재 위치가 `workspace`이면 다음 상대경로는 실패할 수 있다.

``` text
./gradle/wrapper
```

실제 Wrapper는 다음 위치에 있기 때문이다.

``` text
workspace/microserver/gradle/wrapper
```

따라서 먼저 Project Root로 이동한다.

=== "Windows"

    ```powershell
    Set-Location C:\local-microserver\workspace\microserver
    ```

=== "macOS"

    ```bash
    cd ~/local-microserver/workspace/microserver
    ```

------------------------------------------------------------------------

## 6. VS Code의 Java Project Import란?

VS Code Java Extension에서 말하는 **Import**는 프로젝트 파일을 다른
위치에서 복사하거나 다시 생성한다는 뜻이 아니다.

``` text
build.gradle / settings.gradle 발견
        ↓
Gradle Project 구조 분석
        ↓
src/main/java / src/test/java 인식
        ↓
Java Toolchain / Dependency / Classpath 정보 구성
        ↓
VS Code에서 Java Project로 사용
```

즉 실제 파일을 가져오는 작업이 아니라 이미 존재하는 프로젝트를 VS Code가
Java Project Model로 인식하는 과정이다.

------------------------------------------------------------------------

## 7. Java Project는 보통 자동으로 Import된다

VS Code에서 Project Root를 열면 Java / Gradle Extension이
`build.gradle`을 발견하고 일반적으로 자동으로 Project를 인식한다.

``` text
Project 생성 또는 Clone 완료
        ↓
VS Code에서 Project Root Open
        ↓
build.gradle 발견
        ↓
Java / Gradle Extension 자동 Import
        ↓
Java Project 인식
```

따라서 `Java: Import Java Projects in Workspace` 명령을 매번 실행할
필요는 없다.

### 자동 인식 확인

다음 상태를 확인할 수 있다.

``` text
JAVA PROJECTS
└─ microserver
```

``` text
GRADLE PROJECTS
└─ microserver
   ├─ Tasks
   └─ Dependencies
```

Java 파일에서는 문법 Highlight, 자동완성, Class / Method 탐색, Import
제안, Java 오류 표시 등이 정상 동작하는지 확인한다.

### 수동 Import가 필요한 경우

다음과 같은 경우에만 수동 Import를 고려한다.

``` text
build.gradle은 존재하지만 JAVA PROJECTS에 프로젝트가 보이지 않음
새로운 Gradle Subproject / Module을 추가함
프로젝트 구조 변경이 Java Project View에 반영되지 않음
새 Project / Module을 다시 검색해야 함
```

=== "Windows"

    ```text
    Ctrl + Shift + P
        ↓
    Java: Import Java Projects in Workspace
    ```

=== "macOS"

    ```text
    Cmd + Shift + P
        ↓
    Java: Import Java Projects in Workspace
    ```

정상 인식 상태에서는 반복 실행하지 않는다.

------------------------------------------------------------------------

## 8. VS Code Import와 Gradle Build는 다르다

``` text
VS Code Java Project Import
        ↓
IDE가 Project 구조 / Classpath를 인식

Gradle Build
        ↓
Compile / Test / Packaging 성공 여부 검증
```

Java Project가 VS Code에 보인다고 해서 `gradlew build`가 성공했다는 뜻은
아니다.

반대로 Java Language Server나 Gradle Extension이 내부 Sync를 수행하는
것도 개발자가 명시적으로 실행하는 Build 검증과는 다른 의미이다.

실제 Build / Test는 뒤의 전용 검증 단계에서 수행한다.

------------------------------------------------------------------------

## 9. Spring Boot Dashboard

Spring Boot Extension Pack이 설치되어 있다면 Spring Boot Dashboard에서
Application을 인식할 수 있다.

``` text
Spring Boot Dashboard
        ↓
MicroserverApplication 표시
```

초기 구조 확인 단계에서는 인식 여부만 참고할 수 있다. Application 실행은
Build / Run 검증 단계에서 진행한다.

------------------------------------------------------------------------

## 10. Git 상태 확인 참고

Project Root에서:

``` bash
git status
```

앞의 Git 초기화 또는 Clone 단계가 정상적으로 끝났고 현재 파일을 수정하지
않았다면 일반적으로 다음 상태가 기대된다.

``` text
nothing to commit, working tree clean
```

변경사항이 있다면:

``` bash
git diff
git status
```

로 내용을 확인한다.

선행 Git 단계에서 이미 Spring Boot 생성 상태를 Initial Commit으로
남겼다면 같은 목적의 Commit을 다시 만들 필요는 없다.

!!! tip "단계별 Commit" MicroServer 프로젝트는 의미 있는 단계별 정상
상태를 Commit 기준점으로 남기되, 실제 변경사항이 없으면 불필요한
Commit을 만들지 않는다.

------------------------------------------------------------------------

## 11. Clone한 프로젝트에서 확인할 사항

기존 Repository를 Clone한 경우에는 프로젝트 생성과 `git init`을 반복하지
않는다.

``` text
GitHub 기존 Repository
        ↓
git clone
        ↓
Project Root 생성
        ↓
.git / Commit History / origin 구성
        ↓
VS Code에서 Project Open
```

확인 명령:

``` bash
git status
git branch --show-current
git remote -v
git rev-parse --show-toplevel
```

Clone 직후 변경사항이 없다면 일반적으로 Working Tree는 Clean 상태이다.

------------------------------------------------------------------------

## 12. 현재 단계에서 미리 하지 않는 작업

초기 확인 단계에서는 다음 작업을 뒤 단계에 남겨 둔다.

``` text
.vscode/settings.json
.vscode/extensions.json
application-local.yml
Docker Compose
Oracle JDBC Dependency
Datasource
DB 접속정보
업무 Package
Controller / Service / DAO
Filter / AOP
Security
Cache
Multi-Project
```

또한 Build / Run도 전용 검증 단계에서 수행한다.

------------------------------------------------------------------------

## 13. 전체 흐름 참고

``` mermaid
flowchart TD
    A["Spring Boot Project 생성"]
    --> B["Git Repository 초기화 또는 Clone"]
    --> C["파일 / Directory 구조 확인"]
    --> D["Gradle / Spring 설정값 확인"]
    --> E["Package 구조 설계"]
    --> F["Project JDK / VS Code 설정"]
    --> G["Java / Gradle / Spring Boot 인식 확인"]
    --> H["Gradle Wrapper / Build 기준"]
    --> I["Build / Run 검증"]
```

이 문서는 위 흐름의 필수 실행 단계가 아니라 초기 확인 과정에서 필요한
상세 설명과 문제 해결 내용을 제공하는 참고 문서이다.
