# VS Code Java / Spring Boot 개발환경 구성

## 1. 문서 목적

본 문서는 MicroServer 프로젝트의 표준 개발 도구인 **Visual Studio Code(VS Code)** 개발환경 구성에 대한 전체 방향과 세부 가이드의 진행 순서를 설명한다.

VS Code 환경 구성은 하나의 문서에서 모든 내용을 다루지 않고 다음과 같이 역할별로 분리한다.

```text
VS Code 개발환경 구성
 ├─ 구성 개요
 ├─ VS Code 설치 및 기본 설정
 ├─ Java 개발 Extension 구성
 ├─ Spring Boot Extension 구성
 ├─ 개발 지원 Extension 및 Profile 구성
 └─ JDK 연계 및 개발환경 운영
```

현재 단계에서는 아직 MicroServer Spring Boot 프로젝트를 생성하지 않는다.

따라서 다음 작업은 이후 가이드에서 진행한다.

- Spring Boot 프로젝트 생성
- `build.gradle` / `settings.gradle` 작성 및 수정
- Gradle Dependency 구성
- Java Package / Class 작성
- `application.yml` 작성
- 애플리케이션 실행
- Debug 실행
- JUnit 테스트 작성
- Database 연결

본 단계의 목표는 **프로젝트를 생성하기 전에 VS Code를 Java / Spring Boot 개발용 IDE로 사용할 수 있도록 준비하는 것**이다.

---

## 2. 전체 개발환경 구성 순서

MicroServer 개발환경은 다음 순서로 구성한다.

```mermaid
flowchart LR
    A[Git / GitHub 환경 구성] --> B[Temurin JDK 준비]
    B --> C[Gradle 기본 환경]
    C --> D[VS Code 설치]
    D --> E[Java Extension 구성]
    E --> F[Spring Boot Extension 구성]
    F --> G[지원 Extension / Profile 구성]
    G --> H[JDK 연계 방식 확인]
    H --> I[Spring Boot 프로젝트 생성]
    I --> J[프로젝트 JDK / Gradle / VS Code 설정]
```

현재 가이드는 다음 범위를 담당한다.

```mermaid
flowchart LR
    JDK[Temurin JDK 준비] --> GRADLE[Gradle 준비]

    subgraph VSCODE["VS Code 개발환경 구성"]
        direction LR
        VS1[VS Code 설치]
        VS2[Java Extension]
        VS3[Spring Boot Extension]
        VS4[지원 Extension]
        VS5[Profile]
        VS6[JDK 연계 방식 확인]

        VS1 --> VS2 --> VS3 --> VS4 --> VS5 --> VS6
    end

    SPRING[Spring Boot 프로젝트 생성]
    PROJECT[프로젝트 개발환경 설정]

    GRADLE --> VSCODE
    VSCODE --> SPRING
    SPRING --> PROJECT
```

---

## 3. VS Code 환경 구성 원칙

MicroServer 프로젝트에서는 다음 원칙으로 VS Code 개발환경을 구성한다.

### 3.1 VS Code를 표준 IDE로 사용

프로젝트의 기본 개발 IDE는 VS Code로 통일한다.

개발자별로 다른 IDE를 사용하면 다음 항목에서 차이가 발생할 수 있다.

- JDK 인식 방식
- Build Tool 연계 방식
- Formatter
- Debug 설정
- Extension 지원
- Workspace 설정

따라서 프로젝트 가이드와 예제는 VS Code를 기준으로 작성한다.

### 3.2 Java 기능은 Extension Pack으로 구성

Java 개발 기능은 개별 Extension을 임의로 조합하기보다 **Extension Pack for Java**를 기본 구성으로 사용한다.

이를 통해 개발자별 Extension 누락을 줄일 수 있다.

### 3.3 Spring Boot 기능은 Spring Boot Extension Pack으로 구성

Spring Boot 개발 기능은 **Spring Boot Extension Pack**을 기본 구성으로 사용한다.

Java Extension이 Java 언어 자체의 개발환경을 제공한다면 Spring Boot Extension은 그 위에 Spring 전용 개발 기능을 추가한다.

### 3.4 프로젝트별 JDK 운영

JDK는 OS 전체에 하나의 Java 버전을 고정하는 방식보다, 앞 단계에서 준비한 Eclipse Temurin JDK를 **프로젝트별 VS Code Workspace에서 선택하는 방식**을 기본으로 한다.

```text
Developer PC
 ├─ Temurin JDK 17
 ├─ Temurin JDK 21
 ├─ Temurin JDK 25/26
 └─ VS Code
      ├─ Project A → JDK A
      └─ Project B → JDK B
```

실제 Workspace 설정은 프로젝트 생성 이후 적용한다.

---

## 4. 세부 가이드 구성

### 4.1 VS Code 설치 및 기본 설정

다음 내용을 다룬다.

- Windows VS Code 설치
- macOS VS Code 설치
- `code` 명령 등록
- 주요 화면 구성
- Command Palette
- Extensions 화면
- Terminal
- UTF-8 등 기본 Editor 설정
- User Settings와 Workspace Settings의 차이

→ [VS Code 설치 및 기본 설정](vscode_install_basic_setup.md)

### 4.2 Java 개발 Extension 구성

다음 내용을 다룬다.

- Extension Pack for Java 설치
- Java Extension Pack을 사용하는 이유
- Language Support for Java
- Debugger for Java
- Test Runner for Java
- Gradle for Java
- Maven for Java (비교/호환)
- Project Manager for Java
- Visual Studio IntelliCode
- 각 Extension의 역할과 이후 사용 시점

→ [Java 개발 Extension 구성](java_extension_setup.md)

### 4.3 Spring Boot Extension 구성

다음 내용을 다룬다.

- Spring Boot Extension Pack 설치
- Spring Boot Tools
- Spring Initializr Java Support
- Spring Boot Dashboard
- Java Extension과 Spring Extension의 관계
- 현재 단계와 프로젝트 생성 이후 단계의 구분

→ [Spring Boot Extension 구성](spring_boot_extension_setup.md)

### 4.4 개발 지원 Extension 및 Profile 구성

다음 내용을 다룬다.

- YAML
- XML
- Container Tools
- CLI 일괄 설치
- 설치 상태 확인
- VS Code Profile
- Java Spring Profile Template
- Extension 자동 업데이트와 운영 원칙

→ [개발 지원 Extension 및 Profile 구성](support_extension_profile_setup.md)

### 4.5 JDK 연계 및 개발환경 운영

다음 내용을 다룬다.

- VS Code와 JDK의 관계
- `Java: Configure Java Runtime`
- 프로젝트별 JDK 운영 방향
- `JAVA_HOME` 의존 최소화
- Extension 문제 확인
- Output / Reload
- 현재 단계에서 하지 않는 작업
- 최종 환경 확인 체크리스트

→ [JDK 연계 및 개발환경 운영](jdk_workspace_environment_setup.md)

---

## 5. 완료 기준

VS Code 환경 구성 단계가 끝났을 때 다음 상태가 되어 있어야 한다.

```mermaid
flowchart TB
    PC[Developer PC]

    PC --> JDK[Eclipse Temurin JDK]
    PC --> GIT[Git]
    PC --> VS[Visual Studio Code]

    VS --> JAVA[Extension Pack for Java]
    VS --> SPRING[Spring Boot Extension Pack]
    VS --> SUPPORT[Support Extensions]

    SUPPORT --> YAML[YAML]
    SUPPORT --> XML[XML]
    SUPPORT --> CT[Container Tools]

    JAVA --> READY[Java 개발환경 준비]
    SPRING --> READY
    JDK --> READY
```

완료 기준:

- VS Code가 정상 설치되어 있다.
- Java 개발용 Extension이 준비되어 있다.
- Spring Boot 개발용 Extension이 준비되어 있다.
- YAML / XML / Container 개발 지원 Extension이 준비되어 있다.
- Eclipse Temurin JDK가 준비되어 있다.
- VS Code에서 프로젝트별 JDK를 연결할 수 있는 구조를 이해했다.
- 아직 Spring Boot 프로젝트를 생성하지 않았다.

---

## 6. 다음 단계

VS Code 환경 구성이 끝나면 **Spring Boot 프로젝트 생성 단계**로 진행한다.

```text
JDK 설치 및 설정
        ↓
Gradle 설치 및 기본 환경 구성
        ↓
VS Code 개발환경 구성       ← 현재
        ↓
Spring Boot 프로젝트 생성
        ↓
프로젝트 JDK / Gradle / VS Code 설정
```

JDK와 Gradle 기본 환경은 앞 단계에서 이미 준비되어 있다.

VS Code 단계에서는 IDE와 Java / Spring Boot 개발 Extension을 준비하고,
실제 프로젝트 JDK Runtime, Gradle Wrapper, `build.gradle`, `settings.gradle`, Workspace 설정 등은
Spring Boot 프로젝트가 생성된 이후의 **프로젝트 개발환경 설정 단계**에서 적용한다.
