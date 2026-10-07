# VS Code Java 개발환경 개념

## 1. 문서 목적

이 문서는 MicroServer의 **Java 개발환경이 어떤 원리로 동작하는지** 설명한다.  
실제 설정 작업은 이 문서에서 수행하지 않는다.

현재 표준:

```text
Java        : 25
JDK         : Eclipse Temurin 25
Build Tool  : Gradle
IDE         : VS Code
```

실제 작업은 다음 문서에서 진행한다.

→ [프로젝트 JDK / VS Code Workspace 설정](project_jdk_vscode_setup.md)

---

## 2. MicroServer Java 환경 원칙

MicroServer는 Windows와 macOS 모두 OS 전역 Java 설정에 의존하지 않는다.

```text
MicroServer Folder 내부 JDK
        ↓
운영체제별 Launcher
        ↓
JAVA_HOME / PATH를 현재 Process에 주입
        ↓
VS Code
        ↓
Java Extension / Terminal / Gradle Wrapper
```

Project가 요구하는 Java Version은 `build.gradle`의 Toolchain으로 선언한다.

```groovy
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(25)
    }
}
```

즉 다음 두 역할을 분리한다.

| 구분 | 역할 |
|---|---|
| `build.gradle` Toolchain | Project가 요구하는 Java Version |
| Launcher | 실제 JDK 위치를 VS Code Process에 전달 |

---

## 3. Windows와 macOS의 차이

정책은 같고 실제 JDK Home 경로만 다르다.

```text
Windows
<MicroServer Root>\tools\jdk\temurin-25

macOS
<MicroServer Root>/tools/jdk/temurin-25/Contents/Home
```

macOS JDK는 Bundle 구조이므로 `Contents/Home`이 실제 `JAVA_HOME`이다.

OS별 절대경로는 Git으로 공유되는 `.vscode/settings.json`에 기록하지 않는다.

---

## 4. VS Code Java 설정의 역할

다음 설정은 서로 역할이 다르다.

| 설정 | 역할 | MicroServer 기본 정책 |
|---|---|---|
| `build.gradle` Java Toolchain | Project Build Java 기준 | 사용 |
| `java.configuration.runtimes` | Java Extension에 로컬 JDK 위치 등록 | 기본 미사용 |
| `java.jdt.ls.java.home` | Java Language Server 실행 JDK 지정 | 기본 미사용 |

Launcher가 JDK 환경을 전달하므로 후자의 두 설정을 Project에 중복 기록하지 않는다.

필요한 경우에만 개발자 개인 **User Settings**에서 진단용 또는 예외 설정으로 사용한다.

---

## 5. Java Language Server

VS Code 자체는 범용 Editor다. Java의 다음 기능은 Java Language Server가 제공한다.

```text
자동완성
오류 / Warning 분석
Go to Definition
Find References
Rename Refactoring
Classpath / Dependency 분석
```

`java.jdt.ls.java.home`은 이 분석 프로그램 자체를 실행할 JDK를 지정하는 설정이지 Project의 Java Version을 정하는 설정이 아니다.

---

## 6. Java Project Import

VS Code에서 Gradle Project Root를 열면 Java / Gradle Extension이 다음 과정을 수행한다.

```text
build.gradle / settings.gradle 감지
        ↓
Source / Dependency / Classpath 분석
        ↓
Java Project Model 생성
        ↓
JAVA PROJECTS에 Project 표시
```

이 과정을 **Java Project Import**라고 한다. 파일을 복사하거나 별도로 가져오는 작업이 아니다.

`JAVA PROJECTS`에 `microserver`가 보이면 이미 Import된 상태이므로 정상 상태에서 수동 Import를 반복하지 않는다.

---

## 7. 관련 이론 문서

더 자세한 내용은 다음 문서를 참고한다.

- [Java Runtime / Toolchain / Launcher 구조](project_java_runtime_architecture.md)
- [VS Code Workspace / User Settings 구조](vscode_workspace_concepts.md)
- [Gradle Wrapper / Build 기준 개념](gradle_wrapper_build_concepts.md)

---

## 8. 다음 단계

→ [프로젝트 JDK / VS Code Workspace 설정](project_jdk_vscode_setup.md)
