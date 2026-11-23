# 프로젝트 생성과 개발 환경 구성

## 1. 목표와 이번 단계의 범위

[구성 개념과 설계 원칙](multi_project_concepts.md)에 따라 Framework 공통 프로젝트와 신규 Runtime을 생성한다. Framework는 여러 라이브러리를 포함하는 Gradle 멀티프로젝트로 만들고, Runtime은 별도 Gradle 프로젝트로 만든다. 로컬 개발에서는 Composite Build로 두 빌드를 연결한다.

이번 단계의 완료 기준은 **Framework의 세 하위 프로젝트가 인식되고, Runtime이 로컬 Framework를 의존성으로 사용하며, 외부 설정을 읽고 기동되는 것**이다. DataSource·MyBatis 구현 배치와 Bean 등록은 다음 가이드에서 진행한다. 따라서 이 단계의 기동 성공은 DB 접속 성공을 의미하지 않는다.

기존 `microserver` 프로젝트는 앞선 DataSource·MyBatis 구현을 참고할 원본으로 유지한다. 신규 Runtime에 기존 소스 전체를 복사하지 않고, 이번 문서에서는 프로젝트 골격과 실행 환경부터 구성한다.

## 2. 작업 경로와 빌드 기준

### 2.1 경로 기준

| 영역 | Windows | macOS |
| --- | --- | --- |
| 개발 루트 | `C:\local-microserver` | `~/local-microserver` |
| 작업 공간 | `C:\local-microserver\workspace` | `~/local-microserver/workspace` |
| 기존 구현 프로젝트 | `workspace\microserver` | `workspace/microserver` |
| 신규 Framework | `workspace\microserver-framework` | `workspace/microserver-framework` |
| 신규 Runtime | `workspace\microserver-runtime` | `workspace/microserver-runtime` |
| 외부 리소스 | `workspace\microserver_resource` | `workspace/microserver_resource` |

이 문서에서 `workspace/…`로 시작하는 경로는 위 작업 공간을 기준으로 한다. 외부 리소스의 실제 폴더명은 기존 환경과 동일한 `microserver_resource`를 사용한다. 다른 이름을 사용하는 PC에서는 실행 설정의 경로도 같은 이름으로 바꾼다.

### 2.2 버전 기준

| 항목 | 이 가이드의 기준 | 적용 위치 |
| --- | --- | --- |
| Java | 25 | 두 빌드의 Toolchain, Gradle 실행 JDK, VS Code 실행 JDK |
| Spring Boot | 4.1.1 | Runtime 플러그인, 공통·Runtime 의존성 BOM |
| Gradle | 9.7.1 | 기존 프로젝트의 Wrapper를 두 신규 빌드에 복사 |
| Framework 그룹 | `io.github.microserverlab` | 공통 모듈의 라이브러리 좌표 |
| Framework 버전 | `0.0.1-SNAPSHOT` | 공통 모듈과 Runtime 의존성 |

위 버전은 현재 프로젝트의 `build.gradle`과 Wrapper에 맞춘 기준이며 최신 버전으로의 변경을 뜻하지 않는다. 기존 Wrapper를 먼저 실행하여 설치·다운로드 상태와 JDK를 확인한다. 초기 구성과 버전 업그레이드를 동시에 진행하지 않는다.

Windows PowerShell — 기존 프로젝트에서 실행:

```powershell
Set-Location C:\local-microserver\workspace\microserver
java -version
.\gradlew.bat --version
```

macOS 터미널 — 기존 프로젝트에서 실행:

```bash
cd ~/local-microserver/workspace/microserver
java -version
bash ./gradlew --version
```

Gradle 출력에서 Launcher JVM·Daemon JVM도 확인한다. Java Toolchain 선언은 컴파일 JDK 선택이고, Gradle 자체의 실행 JDK 설정과는 구분된다. 기존 MicroServer 전용 VS Code 실행 환경을 사용한다면 해당 런처에서 새 작업 공간을 연다. JDK 경로 설정은 기존 개발 환경의 실제 설치 경로를 사용한다.

## 3. 프로젝트 디렉터리와 Wrapper 준비

### 3.1 신규 디렉터리 생성

두 신규 프로젝트 폴더가 아직 없을 때 실행한다. 이미 같은 이름의 프로젝트가 있다면 먼저 내용을 확인하고, 새로 만든다고 기존 파일을 덮어쓰지 않는다.

Windows PowerShell — 작업 공간에서 실행:

```powershell
Set-Location C:\local-microserver\workspace
New-Item -ItemType Directory -Path microserver-framework, microserver-runtime
New-Item -ItemType Directory -Path `
  microserver-framework\microserver-framework-datasource, `
  microserver-framework\microserver-framework-mybatis, `
  microserver-framework\microserver-framework-starter
```

macOS 터미널 — 작업 공간에서 실행:

```bash
cd ~/local-microserver/workspace
mkdir microserver-framework microserver-runtime
mkdir microserver-framework/microserver-framework-datasource
mkdir microserver-framework/microserver-framework-mybatis
mkdir microserver-framework/microserver-framework-starter
```

Framework는 루트에 업무 소스가 없는 집계 프로젝트이고, 실제 라이브러리는 세 하위 프로젝트에서 생성한다. Starter는 다른 공통 모듈을 묶어 제공하는 의존성 진입점으로 사용한다.

### 3.2 Wrapper 복사

기존 프로젝트에서 다음 네 파일을 각 신규 빌드 루트에 동일하게 복사한다.

| 기존 파일 | Framework 복사 위치 | Runtime 복사 위치 |
| --- | --- | --- |
| `microserver/gradlew` | `microserver-framework/gradlew` | `microserver-runtime/gradlew` |
| `microserver/gradlew.bat` | `microserver-framework/gradlew.bat` | `microserver-runtime/gradlew.bat` |
| `microserver/gradle/wrapper/gradle-wrapper.jar` | 같은 상대 경로 | 같은 상대 경로 |
| `microserver/gradle/wrapper/gradle-wrapper.properties` | 같은 상대 경로 | 같은 상대 경로 |

Windows PowerShell — 작업 공간에서 실행:

```powershell
foreach ($target in @('microserver-framework', 'microserver-runtime')) {
    New-Item -ItemType Directory -Path "$target\gradle\wrapper" -Force
    Copy-Item microserver\gradlew -Destination $target
    Copy-Item microserver\gradlew.bat -Destination $target
    Copy-Item microserver\gradle\wrapper\gradle-wrapper.jar -Destination "$target\gradle\wrapper"
    Copy-Item microserver\gradle\wrapper\gradle-wrapper.properties -Destination "$target\gradle\wrapper"
}
```

macOS 터미널 — 작업 공간에서 실행:

```bash
for target in microserver-framework microserver-runtime; do
  mkdir -p "$target/gradle/wrapper"
  cp microserver/gradlew "$target/gradlew"
  cp microserver/gradlew.bat "$target/gradlew.bat"
  cp microserver/gradle/wrapper/gradle-wrapper.jar "$target/gradle/wrapper/"
  cp microserver/gradle/wrapper/gradle-wrapper.properties "$target/gradle/wrapper/"
  chmod +x "$target/gradlew"
done
```

Framework 하위 프로젝트마다 Wrapper를 만들지 않는다. Framework에는 루트 Wrapper 하나를 사용하고, 독립 빌드인 Runtime에는 별도의 Wrapper를 둔다. `.gradle`, `build` 디렉터리나 기존 `.vscode` 설정 전체는 복사하지 않는다.

## 4. Framework 멀티프로젝트 구성

### 4.1 루트 settings.gradle

`workspace/microserver-framework/settings.gradle`:

```groovy
rootProject.name = 'microserver-framework'

// 하나의 Framework 빌드에 포함할 공통 라이브러리 프로젝트
include 'microserver-framework-datasource'
include 'microserver-framework-mybatis'
include 'microserver-framework-starter'
```

`include`에 지정한 이름과 실제 하위 디렉터리 이름을 일치시킨다. Runtime은 독립 빌드이므로 이 목록에 포함하지 않는다.

### 4.2 루트 build.gradle

`workspace/microserver-framework/build.gradle`:

```groovy
// Framework 전체에서 사용할 Spring Boot 의존성 기준
ext.springBootVersion = '4.1.1'

allprojects {
    group = 'io.github.microserverlab'
    version = '0.0.1-SNAPSHOT'
}

subprojects {
    // 공통 모듈은 실행 애플리케이션이 아닌 일반 Java 라이브러리다.
    apply plugin: 'java-library'

    repositories {
        mavenCentral()
    }

    java {
        toolchain {
            languageVersion = JavaLanguageVersion.of(25)
        }
    }

    tasks.withType(JavaCompile).configureEach {
        options.encoding = 'UTF-8'
    }

    dependencies {
        // 공통 모듈 간 Spring 라이브러리 버전 기준을 맞춘다.
        api platform("org.springframework.boot:spring-boot-dependencies:${rootProject.springBootVersion}")
    }

    tasks.withType(Test).configureEach {
        useJUnitPlatform()
    }
}
```

#### 4.2.1 루트 빌드 설정의 역할

이 파일은 Framework의 여러 공통 프로젝트에 동일한 빌드 기준을 적용한다. DataSource·MyBatis·Starter 프로젝트마다 Java 버전, 라이브러리 버전, 인코딩, 테스트 실행 방식을 반복해서 선언하지 않고 루트에서 관리한다.

| 설정 위치 | 관리하는 내용 |
| --- | --- |
| Framework 루트 `build.gradle` | 공통 그룹·버전, Java 버전, 라이브러리 저장소, BOM, 인코딩, 테스트 실행 방식 |
| DataSource `build.gradle` | JDBC 등 DataSource 구현에 필요한 의존성 |
| MyBatis `build.gradle` | MyBatis 의존성, DataSource 프로젝트 참조 |
| Starter `build.gradle` | Runtime에 제공할 공통 프로젝트 의존성 묶음 |

여기서 루트란 `microserver-framework` 빌드의 최상위 프로젝트다. 별도 빌드인 `microserver-runtime`은 이 루트의 하위 프로젝트가 아니므로, 아래 공통 설정을 자동으로 적용받지 않는다.

#### 4.2.2 Spring Boot 의존성 기준 버전 — ext

```groovy
ext.springBootVersion = '4.1.1'
```

Framework에서 사용할 Spring Boot 의존성 기준 버전을 사용자 정의 속성으로 선언한다.

| 표현 | 의미 |
| --- | --- |
| `ext` | Gradle 프로젝트에 사용자 정의 속성을 추가하는 기능 |
| `springBootVersion` | 이 가이드에서 정한 속성 이름 |
| `'4.1.1'` | 뒤의 BOM 선언에서 참조할 버전 값 |

이 선언만으로 Spring Boot가 설치되거나 Spring Boot 플러그인이 적용되지는 않는다. 이후 `${rootProject.springBootVersion}`으로 참조할 값을 저장한 것이다. 공통 모듈의 BOM 기준을 변경할 때 이 값을 수정한다. 독립 Runtime에 선언한 Boot 플러그인과 BOM 버전도 별도로 맞춰야 한다.

#### 4.2.3 전체 프로젝트의 공통 식별 정보 — allprojects

```groovy
allprojects {
    group = 'io.github.microserverlab'
    version = '0.0.1-SNAPSHOT'
}
```

`allprojects`는 Framework 루트와 모든 하위 프로젝트에 설정을 적용한다. 따라서 DataSource·MyBatis·Starter가 같은 `group`과 `version`을 사용한다.

| 항목 | 의미 | 사용 예 |
| --- | --- | --- |
| `group` | 라이브러리의 소속을 구분하는 식별자 | `io.github.microserverlab` |
| 프로젝트 이름 | 라이브러리 이름. 이 구성에서는 하위 프로젝트 이름을 사용 | `microserver-framework-datasource` |
| `version` | 라이브러리 버전 | `0.0.1-SNAPSHOT` |

세 값을 결합하면 다음 라이브러리 좌표가 된다.

```text
io.github.microserverlab:microserver-framework-datasource:0.0.1-SNAPSHOT
```

향후 Runtime은 이런 좌표로 공통 라이브러리를 의존성에 선언한다. `SNAPSHOT`은 개발 중인 버전을 나타내는 관례다. `group`·`version` 선언은 식별 정보 설정이며, 이 설정만으로 JAR이 저장소에 배포되는 것은 아니다.

#### 4.2.4 하위 프로젝트의 공통 설정 범위 — subprojects

```groovy
subprojects {
    // 하위 프로젝트가 공통으로 사용할 빌드 설정
}
```

`subprojects`는 Framework 루트를 제외하고 DataSource·MyBatis·Starter 하위 프로젝트에만 적용한다.

| 설정 블록 | Framework 루트 | 공통 하위 프로젝트 | 독립 Runtime |
| --- | --- | --- | --- |
| Framework의 `allprojects` | 적용 | 적용 | 적용하지 않음 |
| Framework의 `subprojects` | 적용하지 않음 | 적용 | 적용하지 않음 |

루트는 프로젝트를 모아 관리하고, 하위 프로젝트가 실제 Java 라이브러리를 생성한다. 이 역할 차이에 따라 공통 식별 정보는 `allprojects`에, Java 라이브러리 빌드 기능은 `subprojects`에 둔다.

#### 4.2.5 Java 라이브러리 빌드 기능 — java-library

```groovy
apply plugin: 'java-library'
```

각 공통 프로젝트에 Java 라이브러리 개발·빌드 기능을 적용한다. 이 플러그인은 Java 컴파일·리소스 처리·테스트·일반 JAR 생성 기능과 `api`·`implementation` 의존성 구분을 제공한다.

| 작업·설정 | 역할 |
| --- | --- |
| `compileJava` | 메인 Java 소스 컴파일 |
| `processResources` | 메인 리소스를 빌드 출력으로 처리 |
| `test` | 테스트 실행 |
| `jar` | 일반 Java 라이브러리 JAR 생성 |
| `api` | 라이브러리 사용자의 컴파일 의존성에도 공개할 의존성 선언 |
| `implementation` | 해당 프로젝트 구현에 필요한 의존성 선언 |

Framework 공통 모듈은 Runtime에서 사용하는 라이브러리다. Spring Boot 플러그인은 적용하지 않으므로 공통 모듈에는 `bootRun`·`bootJar`가 없다. 애플리케이션 기동과 실행 가능한 Boot JAR 생성은 Runtime에서 담당한다.

#### 4.2.6 외부 라이브러리 다운로드 위치 — repositories

```groovy
repositories {
    mavenCentral()
}
```

프로젝트에서 필요한 외부 라이브러리를 어디에서 내려받을지 지정한다. `mavenCentral()`은 Maven Central 공개 라이브러리 저장소를 사용한다는 의미다. 앞의 `subprojects` 안에 있으므로 각 공통 하위 프로젝트에 적용된다.

이 설정은 라이브러리를 다운로드할 위치다. 우리가 만든 Framework JAR을 업로드할 배포 저장소는 후속 배포 가이드에서 별도로 설정한다.

#### 4.2.7 컴파일·테스트용 JDK 기준 — Java Toolchain

```groovy
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(25)
    }
}
```

Java 컴파일·테스트 등에 사용할 도구 체인의 버전을 Java 25로 지정한다. 개발자 PC의 기본 Java가 서로 달라도 프로젝트 빌드에 사용할 JDK 기준을 맞추기 위한 설정이다.

| 구분 | 의미 |
| --- | --- |
| Java Toolchain | 프로젝트 컴파일·테스트 등에 사용할 JDK |
| Gradle 실행 JDK | Gradle 프로그램 자체를 실행하는 JDK |

Toolchain 설정과 Gradle 실행 JDK는 별도 개념이다. 이 가이드에서는 둘 다 Java 25를 기준으로 확인한다. 또한 위 선언만으로 JDK 자동 다운로드까지 구성되는 것은 아니다. 설치된 JDK 25를 Gradle이 찾을 수 있어야 한다.

#### 4.2.8 Java 소스 인코딩 — JavaCompile

```groovy
tasks.withType(JavaCompile).configureEach {
    options.encoding = 'UTF-8'
}
```

프로젝트의 Java 컴파일 작업이 소스를 UTF-8로 읽도록 지정한다. 한글 주석·문자열이 있는 소스를 개발 PC의 기본 인코딩과 관계없이 동일한 기준으로 컴파일하기 위한 설정이다.

| 표현 | 의미 |
| --- | --- |
| `tasks` | 프로젝트의 빌드 작업 |
| `withType(JavaCompile)` | Java 컴파일 유형의 작업 선택 |
| `configureEach` | 해당 유형의 각 작업이 필요해질 때 설정 적용 |
| `options.encoding` | 컴파일러가 Java 소스를 읽을 인코딩 |

메인 소스의 `compileJava`와 테스트 소스의 `compileTestJava` 등에 적용된다. 기존 파일의 저장 인코딩을 변환하거나 JVM의 모든 입출력 인코딩을 바꾸는 설정은 아니다. 실제 소스 파일도 UTF-8로 저장한다.

#### 4.2.9 Spring 라이브러리 버전 관리 — BOM과 api platform

```groovy
dependencies {
    api platform("org.springframework.boot:spring-boot-dependencies:${rootProject.springBootVersion}")
}
```

각 공통 프로젝트에서 사용할 라이브러리 버전 기준을 Spring Boot BOM에 맞춘다. BOM은 여러 라이브러리의 버전 기준을 모아 놓은 목록이다.

| 표현 | 의미 |
| --- | --- |
| `dependencies` | 의존성을 선언하는 영역 |
| `rootProject` | Framework 빌드의 루트 프로젝트 참조 |
| `rootProject.springBootVersion` | 루트의 사용자 정의 속성 `4.1.1` 참조 |
| `spring-boot-dependencies` | Spring Boot가 관리하는 라이브러리 버전 BOM |
| `platform(...)` | 해당 BOM을 Gradle의 의존성 버전 제약으로 가져옴 |
| `api` | 이 버전 기준을 라이브러리 소비 프로젝트에도 전달 |

Groovy의 큰따옴표 문자열에서 `${...}`는 속성 값을 문자열에 넣는다. 따라서 이 구성에서 위 선언은 다음과 같은 의미다.

```groovy
api platform('org.springframework.boot:spring-boot-dependencies:4.1.1')
```

이후 DataSource 프로젝트에서 다음 라이브러리를 추가하면, 별도 버전을 쓰지 않아도 BOM의 버전 기준으로 해석한다.

```groovy
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-jdbc'
}
```

BOM은 버전 기준을 제공한다. JDBC·Web·MyBatis 라이브러리를 모두 추가하는 기능은 아니다. 실제 사용할 라이브러리는 각 프로젝트에서 별도로 선언하고, BOM이 관리하지 않는 라이브러리는 버전도 별도로 지정한다.

일반 `platform`은 버전 제약을 제공하므로 다른 의존성·제약과 조합해 최종 버전이 결정된다. 모든 라이브러리가 반드시 같은 버전 숫자를 쓰는 것도 아니다. 라이브러리별 버전은 BOM에 정의된 호환 조합을 따른다.

#### 4.2.10 테스트 실행 방식 — useJUnitPlatform

```groovy
tasks.withType(Test).configureEach {
    useJUnitPlatform()
}
```

각 공통 프로젝트의 테스트 작업이 JUnit Platform을 사용하도록 설정한다. JUnit Jupiter 기반 테스트를 실행할 때 사용하는 방식이다.

| 설정 | 역할 |
| --- | --- |
| `tasks.withType(Test)` | 테스트 유형의 작업 선택 |
| `configureEach` | 선택한 각 테스트 작업에 설정 적용 |
| `useJUnitPlatform()` | 테스트 실행 기반으로 JUnit Platform 사용 |

이 설정은 테스트 실행 방식을 정한다. 테스트 코드 작성과 실행에 필요한 라이브러리는 `testImplementation`·`testRuntimeOnly` 등으로 추가해야 한다. 설정만으로 테스트 라이브러리가 설치되거나 테스트 코드가 생성되지는 않는다. 현재 공통 모듈은 소스·테스트가 없는 골격이므로 실제 테스트 의존성은 후속 구현 단계에서 추가한다.


### 4.3 DataSource 프로젝트

`workspace/microserver-framework/microserver-framework-datasource/build.gradle`:

```groovy
description = 'MicroServer DataSource and transaction support'

// 다음 가이드에서 JDBC 의존성과 기존 DataSource 구현을 추가한다.
```

이번 단계에서는 Java 소스를 넣지 않아도 된다. 빈 소스 디렉터리 생성은 필요하지 않으며 `jar`로 프로젝트의 라이브러리 구성을 확인한다.

### 4.4 MyBatis 프로젝트

`workspace/microserver-framework/microserver-framework-mybatis/build.gradle`:

```groovy
description = 'MicroServer MyBatis support'

dependencies {
    // 같은 Framework 빌드 안의 DataSource 모듈을 참조한다.
    implementation project(':microserver-framework-datasource')
}

// 다음 가이드에서 MyBatis 의존성·세션 구성·Framework 매퍼를 추가한다.
```

### 4.5 Starter 프로젝트

`workspace/microserver-framework/microserver-framework-starter/build.gradle`:

```groovy
description = 'MicroServer framework dependency entry point'

dependencies {
    // Runtime이 Starter를 통해 공통 모듈을 사용할 수 있도록 공개한다.
    api project(':microserver-framework-datasource')
    api project(':microserver-framework-mybatis')
}
```

!!! tip "Starter에서 api를 사용하는 이유"
    `api`는 Starter를 사용하는 Runtime에서도 공통 모듈의 공개 타입을 컴파일·실행에 사용할 수 있도록 의존성을 전달한다. 

    **Gradle 문법의 `api` 선언에 대한 자세한 내용은 아래 링크를 클릭해 확인할 수 있습니다.**

    → [Gradle api 의존성 선언 자세히 보기](../gradle/gradle_api_dependency.md)

### 4.6 Framework 인식 확인

Windows PowerShell:

```powershell
Set-Location C:\local-microserver\workspace\microserver-framework
.\gradlew.bat projects
.\gradlew.bat :microserver-framework-starter:jar
```

macOS:

```bash
cd ~/local-microserver/workspace/microserver-framework
./gradlew projects
./gradlew :microserver-framework-starter:jar
```

`projects` 결과에서 루트와 세 하위 프로젝트를 확인하고, Starter의 `build/libs` 아래 일반 JAR이 생성되는지 확인한다. 소스가 없어서 `compileJava`가 `NO-SOURCE`로 표시되는 것은 이 단계에서 정상이다. Starter JAR이 생성되었다는 사실만으로 다른 모듈 JAR이 그 안에 합쳐진 것은 아니다. 공통 모듈은 각자의 JAR과 의존성 관계를 가진다.

## 5. 신규 Runtime 생성과 로컬 Framework 연결

### 5.1 Runtime settings.gradle

Framework와 Runtime을 함께 개발할 때는 **Framework 코드를 변경할 때마다 JAR을 저장소에 게시하고 Runtime에서 다시 내려받는 절차 없이 변경 결과를 확인할 수 있도록** 로컬 Framework를 연결한다.

Runtime의 Starter 의존성을 개발 PC의 Framework 프로젝트로 치환하면, Runtime을 다시 빌드·실행할 때 필요한 Framework 빌드 작업도 Gradle이 함께 처리한다. 이 방식을 Composite Build라고 한다. 빌드 과정에서 로컬 JAR은 생성될 수 있으며, 실행 중인 서버에 변경이 자동으로 반영되는 기능은 아니므로 변경 후 다시 빌드·실행한다.

`workspace/microserver-runtime/settings.gradle`에 다음을 작성한다.

```groovy
// Runtime은 Framework와 별도의 settings.gradle을 갖는 독립 빌드다.
rootProject.name = 'microserver-runtime'

// 개발 PC에서 Framework 소스를 함께 개발할 때 true로 설정한다.
// Runtime 루트의 gradle.properties 또는 명령행 -P 옵션에서 값을 읽는다.
// 속성 문자열을 Boolean으로 변환하고, 미지정이면 false(배포 라이브러리)를 사용한다.
def useLocalFramework = providers.gradleProperty('useLocalFramework')
        .map { it.toBoolean() }
        .getOrElse(false)

// 로컬 사용을 선택한 경우에만 Framework 빌드를 연결한다.
if (useLocalFramework) {
    // 현재 settings.gradle 위치를 기준으로 이웃 Framework 폴더를 찾는다.
    def frameworkDir = file('../microserver-framework')

    // Framework의 Gradle 설정 파일이 없으면 원인을 표시하고 즉시 중단한다.
    // 로컬 연결 실패 시 배포 라이브러리로 자동 전환하지 않는다.
    if (!new File(frameworkDir, 'settings.gradle').isFile()) {
        throw new GradleException("로컬 Framework 빌드를 찾을 수 없습니다: ${frameworkDir}")
    }

    // 독립 Framework 빌드를 포함하여 Runtime과 함께 빌드할 수 있게 한다.
    includeBuild(frameworkDir) {
        dependencySubstitution {
            // Runtime build.gradle의 Starter 라이브러리 요청을
            // 포함된 Framework 빌드의 Starter 프로젝트로 치환한다.
            // Runtime의 의존성 좌표는 바꾸지 않고 로컬 소스를 사용할 수 있다.
            substitute module('io.github.microserverlab:microserver-framework-starter') using project(':microserver-framework-starter')
        }
    }
}
```

로컬 Framework를 함께 개발하는 PC에서는 `workspace/microserver-runtime/gradle.properties`를 생성한다. 이 파일은 개발 PC 전용 설정으로 Git 관리에서 제외한다.

```properties
# Runtime 빌드와 VS Code의 Gradle 가져오기에서 로컬 Framework 사용
useLocalFramework=true
```

!!! tip "로컬 Framework 연결 코드 요약"
    | 주요 코드 | 하는 일 |
    | --- | --- |
    | `rootProject.name` | 독립 Runtime 빌드의 이름 지정 |
    | `providers.gradleProperty` → `map` → `getOrElse` | 속성을 읽어 Boolean으로 변환하고 미지정이면 `false` 사용 |
    | `file`·`isFile` | 이웃 Framework 경로 지정 및 설정 파일 존재 확인 |
    | `includeBuild` | 독립 Framework 빌드를 Runtime과 함께 연결 |
    | `dependencySubstitution` | Starter 라이브러리 요청을 로컬 Starter 프로젝트로 치환 |
    | `gradle.properties`·`-P` | 개발 PC의 기본 선택 저장 및 이번 명령의 선택 지정 |

    **Gradle 문법과 로컬 Framework 연결 설정에 대한 자세한 내용은 아래 링크를 클릭해 확인할 수 있습니다.**

    → [Gradle 로컬 Framework 연결 자세히 보기](../gradle/gradle_local_framework_connection.md)

!!! note "최초 실행과 배포 라이브러리 사용"
    최초 구성에서는 `useLocalFramework=true`로 실행한다. `false`로 실행하려면 Framework가 게시된 저장소 설정과 해당 배포 버전이 준비되어 있어야 한다. 이 값은 Spring의 `local` 실행 프로파일과 별도로 설정한다.

### 5.2 Runtime build.gradle

`workspace/microserver-runtime/build.gradle`:

```groovy
plugins {
    id 'java'
    id 'org.springframework.boot' version '4.1.1'
}

group = 'io.github.microserverlab'
version = '0.0.1-SNAPSHOT'

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(25)
    }
}

repositories {
    mavenCentral()
    // Framework 배포 단계에서 공통 라이브러리 저장소를 추가한다.
}

dependencies {
    implementation platform('org.springframework.boot:spring-boot-dependencies:4.1.1')

    // 프로젝트 경로 대신 배포 시에도 사용할 라이브러리 좌표로 선언한다.
    implementation 'io.github.microserverlab:microserver-framework-starter:0.0.1-SNAPSHOT'

    implementation 'org.springframework.boot:spring-boot-starter-webmvc'
    testImplementation 'org.springframework.boot:spring-boot-starter-webmvc-test'
    testRuntimeOnly 'org.junit.platform:junit-platform-launcher'
}

tasks.withType(JavaCompile).configureEach {
    options.encoding = 'UTF-8'
}

tasks.named('test') {
    useJUnitPlatform()
}
```

독립 빌드들은 버전 설정과 저장소를 자동 공유하지 않는다. Framework와 Runtime에 BOM·Toolchain·저장소를 각각 지정한 이유다. 현재는 Runtime의 BOM과 Framework의 BOM을 같은 버전으로 유지한다.

JDBC·MyBatis·H2·Lombok 의존성은 실제 구현을 옮기는 다음 단계에서 필요한 프로젝트에 추가한다. 소스가 없는 모듈에 의존성을 먼저 넣어 DB 자동 구성이 시작되게 하지 않는다.

### 5.3 애플리케이션 진입점

다음 패키지 경로에 파일을 만든다.

`workspace/microserver-runtime/src/main/java/io/github/microserverlab/microserver/runtime/MicroserverRuntimeApplication.java`:

```java
package io.github.microserverlab.microserver.runtime;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class MicroserverRuntimeApplication {

    public static void main(String[] args) {
        SpringApplication.run(MicroserverRuntimeApplication.class, args);
    }
}
```

Runtime의 업무 코드는 `io.github.microserverlab.microserver.runtime` 아래에 배치한다. Framework는 별도 패키지에서 자동 구성으로 등록할 예정이므로, 여기서 전체 `io.github.microserverlab` 패키지를 넓게 컴포넌트 스캔하지 않는다.

기존 예제의 Business Mapper와 Service를 이관할 때는 새 업무 패키지에 맞추어 Java 패키지, Mapper XML의 `namespace`, 매퍼 스캔 범위를 함께 정리한다. 해당 작업은 다음 가이드에서 진행한다.

## 6. 외부 설정 연결

### 6.1 Runtime application.yml

`workspace/microserver-runtime/src/main/resources/application.yml`:

```yaml
spring:
  application:
    name: microserver-runtime

  config:
    import:
      # Runtime 실행 환경에서 지정한 외부 설정을 읽는다.
      - 'file:${microserver.resource-dir}/config/application-context/${spring.profiles.active}/application-datasource.yml'
      - 'file:${microserver.resource-dir}/config/application-context/${spring.profiles.active}/application-mybatis.yml'

  sql:
    init:
      # SQL 초기화 정책은 명시하고, 검증용 데이터는 후속 테스트에서 준비한다.
      mode: never
```

프로파일과 외부 리소스 위치는 실행 시 전달한다. 경로에 `optional:`을 붙이지 않아 필수 설정 파일이 없으면 기동 중에 발견할 수 있도록 한다. 이 경로 규칙에서는 `local`처럼 환경 프로파일 하나를 지정한다. `local,extra`를 지정하면 환경 디렉터리 이름까지 해당 문자열로 치환되므로 그대로 사용할 수 없다.

현재 Runtime에는 MyBatis 자동 구성 라이브러리가 없으므로 기존 `MybatisAutoConfiguration` 제외 항목을 먼저 복사하지 않는다. 다음 가이드에서 MyBatis 의존성과 두 DB의 명시 구성을 추가할 때 제외 정책도 함께 적용한다.

### 6.2 기존 외부 설정 확인

다음 파일이 기존 외부 리소스에 있는지 확인한다.

| 파일 | 용도 |
| --- | --- |
| `microserver_resource/config/application-context/local/application-datasource.yml` | Framework·Business DB 접속 값 |
| `microserver_resource/config/application-context/local/application-mybatis.yml` | MyBatis 공통 설정 및 Mapper XML 위치 |

기존 설정을 그대로 활용하고, 계정·비밀번호를 Runtime 소스에 복사하지 않는다. 이 단계에서는 YAML이 로딩되는 것만 확인한다. 설정 속성을 읽는 공통 Bean을 아직 구현하지 않았으므로 JDBC URL·드라이버·Mapper 경로가 실제 사용 가능한지는 다음 단계에서 확인해야 한다.

특히 기존 MyBatis YAML이 `classpath:/mybatis/mybatis-config.xml`을 가리키는 경우, 그 파일이 원본 `microserver` 프로젝트에만 있어도 이번 골격 기동은 성공할 수 있다. 다음 가이드에서 해당 XML을 공통 모듈 리소스로 배치하고 세션 생성까지 검증한다.

## 7. VS Code 개발 환경 연결

### 7.1 작업 공간 열기

VS Code에서 두 신규 프로젝트의 상위 폴더인 `workspace`를 연다. 이 문서는 하나의 상위 폴더를 여는 구성을 기준으로 하므로 `${workspaceFolder}`는 `workspace`를 가리킨다.

프로젝트 하위의 `.vscode`를 각각 만들지 않고 `workspace/.vscode`에서 실행·테스트 설정을 관리한다. 기존 `microserver` 프로젝트를 계속 사용하는 경우 기존 실행 항목은 보존하고 아래 신규 항목을 추가한다.

### 7.2 launch.json

`workspace/.vscode/launch.json`의 `configurations` 배열에 아래 항목을 추가한다. 기존 파일이 없을 때만 전체 내용을 새 파일로 사용한다.

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "java",
      "name": "Microserver Runtime (local)",
      "request": "launch",
      "mainClass": "io.github.microserverlab.microserver.runtime.MicroserverRuntimeApplication",
      "projectName": "microserver-runtime",
      "cwd": "${workspaceFolder}/microserver-runtime",
      "vmArgs": [
        "-Dspring.profiles.active=local",
        "-Dmicroserver.resource-dir=${workspaceFolder}/microserver_resource"
      ]
    }
  ]
}
```

`projectName`은 Runtime의 `rootProject.name`과 일치시킨다. VS Code에서 **Run and Debug → Microserver Runtime (local)** 을 선택하여 실행한다. Framework에는 실행 진입점이 없으므로 실행 설정을 만들지 않는다.

### 7.3 테스트 설정

`workspace/.vscode/settings.json`의 기존 설정에 다음 테스트 구성을 통합한다.

```json
{
  "files.encoding": "utf8",
  "java.configuration.updateBuildConfiguration": "interactive",
  "java.test.config": [
    {
      "name": "microserver-runtime-local",
      "vmArgs": [
        "-Dspring.profiles.active=local",
        "-Dmicroserver.resource-dir=${workspaceFolder}/microserver_resource"
      ]
    }
  ],
  "java.test.defaultConfig": "microserver-runtime-local"
}
```

기존 `java.test.config` 배열이 있다면 새 항목을 추가하고, 같은 JSON 키를 중복 정의하지 않는다. 기존 JDK 설정과 나머지 설정은 유지한다. 원본 프로젝트의 `src/test/resources`를 추가하는 `classPaths` 설정은 새 테스트 구성에 복사하지 않는다.

이 설정은 VS Code의 Java 테스트 실행용이다. 터미널의 Gradle 테스트에는 자동 반영되지 않는다. Gradle 테스트에 프로파일과 경로를 전달하는 설정은 테스트를 구현하는 후속 가이드에서 추가한다.

### 7.4 Gradle 프로젝트 다시 읽기

파일을 저장하고 VS Code의 빌드 구성 업데이트 안내가 나타나면 업데이트한다. 필요하면 Gradle 뷰를 새로 고침하고 Runtime과 Framework를 확인한다. Java 프로젝트가 표시되지 않으면 명령 팔레트에서 `Java: Import Java Projects into Workspace`를 실행한다.

VS Code의 Runtime Gradle 가져오기에서도 로컬 Framework 연결을 사용하려면 Runtime 루트의 `gradle.properties`가 필요하다. `launch.json`에 `useLocalFramework`를 지정하는 것은 Gradle 가져오기 설정이 아니다.

## 8. 빌드와 최초 실행

### 8.1 Runtime 의존성 확인

Windows PowerShell:

```powershell
Set-Location C:\local-microserver\workspace\microserver-runtime
.\gradlew.bat --version
.\gradlew.bat dependencyInsight --dependency microserver-framework-starter --configuration runtimeClasspath
.\gradlew.bat classes
.\gradlew.bat dependencies --configuration runtimeClasspath
```

macOS:

```bash
cd ~/local-microserver/workspace/microserver-runtime
./gradlew --version
./gradlew dependencyInsight --dependency microserver-framework-starter --configuration runtimeClasspath
./gradlew classes
./gradlew dependencies --configuration runtimeClasspath
```

`dependencyInsight`에서 Starter 라이브러리 의존성이 포함된 Framework 빌드의 프로젝트로 치환되는지 확인한다. 출력 형식은 Gradle 버전에 따라 달라질 수 있으므로 전체 문자열보다 선택된 프로젝트와 치환 관계를 확인한다. `dependencies`에서는 Starter를 통해 DataSource와 MyBatis 공통 모듈까지 포함되는지 확인한다.

### 8.2 터미널에서 실행

Runtime 루트에서 실행한다. 외부 리소스 경로는 절대 경로로 변환하여 전달한다.

Windows PowerShell:

```powershell
$resourceDir = (Resolve-Path ..\microserver_resource).Path -replace '\\', '/'
$runtimeArgs = '--spring.profiles.active=local --microserver.resource-dir="' + $resourceDir + '"'
.\gradlew.bat bootRun --args=$runtimeArgs
```

macOS:

```bash
resource_dir="$(cd ../microserver_resource && pwd)"
./gradlew bootRun --args="--spring.profiles.active=local --microserver.resource-dir=\"$resource_dir\""
```

`bootRun --args`는 실행할 애플리케이션의 인수를 지정한다. Gradle에 전달한 임의의 `-D` 시스템 속성이 애플리케이션 JVM에 자동 전달된다고 가정하지 않고, 위 명령처럼 애플리케이션 인수를 명시한다.

로그에서 `local` 프로파일 활성화와 `Started MicroserverRuntimeApplication`을 확인한다. 아직 Controller가 없으므로 브라우저에서 루트 URL을 열었을 때 404가 표시될 수 있다. 이번 단계에서는 기동 로그로 확인하고, 확인이 끝나면 `Ctrl+C`로 종료한다.

기존 애플리케이션이 8080 포트를 사용한다면 종료한 뒤 실행하거나, 위 실행 인수에 `--server.port=8081`을 추가한다. VS Code에서는 필요하면 launch 항목에 `"args": "--server.port=8081"`을 추가한다.

### 8.3 VS Code에서 실행

터미널에서 실행한 애플리케이션을 종료한 뒤 Run and Debug에서 신규 Runtime 구성을 실행한다. 같은 `local` 프로파일로 기동하는지 확인하고, 확인 후 디버그 중지 버튼으로 종료한다.

Gradle 실행과 VS Code 실행은 서로 다른 실행 경로이므로 두 경로를 각각 확인한다.

## 9. 파일 관리와 완료 기준

### 9.1 .gitignore

Framework 루트와 Runtime 루트에 각각 `.gitignore`를 만든다. 기존 파일이 있다면 내용을 통합한다.

```gitignore
# Gradle 캐시와 빌드 결과
.gradle/
**/build/

# 개발 PC 전용 로컬 연결 설정
/gradle.properties

# OS 생성 파일
.DS_Store
Thumbs.db
```

Wrapper의 JAR을 포함한 4개 파일은 Git 관리 대상이다. `*.jar`를 일괄 제외하는 설정을 추가하지 않는다. 이번 `gradle.properties`는 개발 PC 전용이므로 제외한다. 공통으로 공유할 빌드 속성이 생기면 공유 설정과 개인 설정의 저장 위치를 다시 정리한다.

Framework와 Runtime은 각각 독립된 Git 저장 단위로 관리하는 방향이다. 원격 저장소, 기존 저장소와의 연결, 초기 커밋·push는 실제 프로젝트를 구성하는 단계에서 확정한다. 외부 리소스의 접속 비밀번호를 소스 저장 대상에 포함하지 않는다.

### 9.2 생성·참조 파일 목록

| 기준 디렉터리 | 파일 | 이번 작업 |
| --- | --- | --- |
| `microserver-framework` | `settings.gradle`, `build.gradle` | 신규 생성 |
| 동일 | 각 공통 모듈의 `build.gradle` | 3개 신규 생성 |
| 동일 | Wrapper 4개 파일 | 기존 프로젝트에서 복사 |
| 동일 | `.gitignore` | 신규 생성 |
| `microserver-runtime` | `settings.gradle`, `build.gradle` | 신규 생성 |
| 동일 | `gradle.properties` | 개발 PC의 로컬 연결 설정 |
| 동일 | `src/main/java/io/github/microserverlab/microserver/runtime/MicroserverRuntimeApplication.java` | 신규 생성 |
| 동일 | `src/main/resources/application.yml` | 신규 생성 |
| 동일 | Wrapper 4개 파일 | 기존 프로젝트에서 복사 |
| 동일 | `.gitignore` | 신규 생성 |
| `workspace/.vscode` | `launch.json`, `settings.json` | 기존 내용에 추가·통합 |
| `microserver_resource` | local 환경의 DataSource·MyBatis YAML | 기존 파일 참조 |

### 9.3 완료 확인

| 확인 대상 | 완료 조건 |
| --- | --- |
| Framework 구성 | `projects`에 공통 프로젝트 3개 표시 |
| 라이브러리 빌드 | Starter 일반 JAR 생성 |
| Runtime 의존성 | Starter가 로컬 Framework 프로젝트로 치환됨 |
| 컴파일 | Runtime의 `classes` 성공 |
| 외부 설정 | 지정한 local 환경 YAML 2개를 읽고 기동 |
| Gradle 실행 | Runtime 기동 완료 로그 확인 |
| VS Code 실행 | 신규 Runtime 실행 설정으로 기동 |

위 내용은 사용자가 실제로 실행할 때의 확인 기준이다. 이 가이드 작성 시 신규 실프로젝트를 생성·실행한 결과를 기록한 것은 아니다.

## 10. 문제 해결

| 증상 | 확인할 내용 |
| --- | --- |
| Starter를 Maven Central에서 찾다가 실패 | Runtime의 `gradle.properties`, `-PuseLocalFramework=true`, Framework의 상대 위치 확인 |
| Framework 빌드를 찾지 못함 | 두 프로젝트가 `workspace` 바로 아래 있는지, Framework의 `settings.gradle`이 있는지 확인 |
| Java 25 Toolchain을 찾지 못함 | Java 25 설치와 Gradle의 JDK 탐지 확인. 본 가이드에는 Toolchain 자동 다운로드 설정이 없음 |
| Boot 플러그인·BOM 해석 실패 | 네트워크·프록시·저장소와 기존 Wrapper 환경의 동작 확인 |
| 외부 YAML을 찾지 못함 | `microserver.resource-dir` 절대 경로, `local` 디렉터리, 파일명 확인 |
| VS Code에서만 의존성 연결 실패 | Runtime의 PC 전용 `gradle.properties`와 Gradle 프로젝트 다시 가져오기 확인 |
| VS Code에서 메인 클래스가 없음 | `mainClass`, `projectName`, Java 패키지 선언 확인 |
| 포트 충돌로 기동 실패 | 기존 애플리케이션 종료 또는 실행 포트 변경 |
| DB 접속 로그·SQL 실행이 없음 | 이번 단계는 공통 구현 배치 전. 다음 가이드에서 DataSource·MyBatis 구현 추가 |

## 11. 다음 단계

다음 **DataSource·MyBatis 공통 프로젝트 구성**에서는 기존 DataSource·트랜잭션·MyBatis 세션 구현을 대응하는 공통 프로젝트에 배치한다. Framework 자동 구성 등록, Runtime 업무 매퍼 등록, Mapper XML의 소유권과 클래스패스도 함께 정리한다.

이번에 만든 프로젝트 골격에 실제 공통 구현을 추가하여 Runtime에서 두 DB를 사용하는 구성으로 진행한다.

## 참고

- [Gradle: Composite Builds](https://docs.gradle.org/current/userguide/composite_builds.html)
- [Gradle: Platforms](https://docs.gradle.org/current/userguide/platforms.html)
- [Spring Boot: Running your Application with Gradle](https://docs.spring.io/spring-boot/gradle-plugin/running.html)
