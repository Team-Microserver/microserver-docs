# Windows VS Code User Settings

## 1. 문서 목적

본 문서는 **VS Code Portable 설정**을 완료한 다음 단계로,
MicroServer Portable VS Code에서 사용하는 **User Settings** 중 Java / JDK 관련 설정을 실제로 구성하고 이해하는 방법을 설명한다.

현재 기준:

```text
Java Version : 25
JDK          : Eclipse Temurin 25
Windows JDK  : C:\local-microserver\tools\jdk\temurin-25
```

Windows Portable Mode의 User Settings는 **해당 Portable VS Code 인스턴스에서 여는 Workspace에 공통 적용되는 설정**이며
MicroServer Project Repository에는 저장하지 않는다.

---

### 사전 문서

- [VS Code 설치](vscode_install.md)
- [VS Code Portable 설정](vscode_portable_setup.md)

Portable Mode와 Editor 기본 정책을 먼저 확인한 뒤 이 문서에서 `settings.json`과 JDK Runtime을 구성한다.

---

## 2. 이 문서에서 설정할 항목

Java 관련 User Settings는 다음 두 항목을 구분해서 사용한다.

| 설정 | 역할 | MicroServer 기준 |
|---|---|---|
| `java.configuration.runtimes` | VS Code에 개발 PC의 JDK Version / 설치 위치 등록 | 구성 대상 |
| `java.jdt.ls.java.home` | Java Language Server 자체를 실행할 JDK 지정 | 선택 설정 |

가장 간단하게 기억하면:

```text
java.configuration.runtimes
→ "내 PC의 Java 25 JDK는 여기에 설치되어 있다."


java.jdt.ls.java.home
→ "VS Code의 Java 분석 프로그램 자체를 이 JDK로 실행한다."
```

---

## 3. Project Java Version과 User Settings의 관계

User Settings의 JDK 경로와
Project가 요구하는 Java Version은 서로 다른 개념이다.

MicroServer의 Project Java Version 기준은 `build.gradle`의 Java Toolchain이다.

```groovy
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(25)
    }
}
```

이 설정은 Gradle에게 다음 기준을 전달한다.

```text
"MicroServer Project는 Java 25 Toolchain을 사용한다."
```

Gradle은 이 기준에 맞는 Java Toolchain을
Compile / Test / Java 실행 / Javadoc 등의 작업에 사용한다.

대표적으로:

```text
JavaCompile
→ javac

Test / JavaExec
→ java

Javadoc
→ javadoc
```

따라서 역할을 다음처럼 구분한다.

```text
build.gradle Java Toolchain
→ Project가 요구하는 Java Version
→ Git 공유


VS Code User Settings
→ 개발 PC에 실제 설치된 JDK 경로
→ Git 대상 아님
```

!!! important "User Settings가 Project Java Version을 결정하지 않음"

    User Settings에 Java 25 JDK를 등록했다고 해서
    Project Java Version이 자동으로 Java 25가 되는 것은 아니다.

    Project 기준은 다음 설정이다.

    ```text
    build.gradle
    → JavaLanguageVersion.of(25)
    ```

---

## 4. `java.configuration.runtimes`

`java.configuration.runtimes`는 VS Code Java Extension에
**개발 PC에 설치된 JDK와 실제 JDK Home을 등록하는 설정**이다.

쉽게 말하면 VS Code가 참고하는 **로컬 JDK 목록**이다.

예:

```json
"java.configuration.runtimes": [
  {
    "name": "JavaSE-25",
    "path": "C:\\local-microserver\\tools\\jdk\\temurin-25",
    "default": true
  }
]
```

각 값:

| 항목 | 의미 |
|---|---|
| `name` | Java Execution Environment |
| `path` | 실제 JDK Home |
| `default` | 등록된 Runtime 중 기본 Runtime |

개념적으로:

```text
JavaSE-25
        ↓
VS Code에서 사용할 수 있는 로컬 JDK
        ↓
C:\local-microserver\tools\jdk\temurin-25
```

개발 PC에 여러 JDK가 있다면 여러 Runtime을 등록할 수 있다.

```text
JavaSE-17 → JDK 17 경로
JavaSE-21 → JDK 21 경로
JavaSE-25 → JDK 25 경로
```

!!! note "`default: true`"

    `default: true`는 VS Code Java Runtime의 기본값과 관련된 설정이다.

    Gradle Project를 Java 25로 Build하도록 강제하는 설정은 아니다.

    Gradle Project의 Java 기준은 계속 `build.gradle`의 Java Toolchain이다.

---

## 5. Java Language Server

VS Code 자체는 범용 Code Editor이다.

Java Source의 Type, Method, Classpath, Dependency 등을 분석하는 기능은
Java Extension 뒤에서 실행되는 **Java Language Server(JDT Language Server)**가 담당한다.

대표 기능:

```text
Java Error / Warning 표시
자동완성
Go to Definition
Find References
Rename Refactoring
Import 정리
Code Action
Type / Method 분석
Classpath / Dependency 기반 Project 분석
```

예를 들어:

```java
String name = "MicroServer";

name.
```

라고 입력했을 때 VS Code가:

```text
length()
substring()
toUpperCase()
charAt()
```

등을 자동완성 후보로 보여주는 것은
Java Language Server가 `name`의 Type이 `String`임을 분석하기 때문이다.

!!! tip "Java Language Server를 쉽게 이해하기"

    ```text
    VS Code
    → Editor / 화면 / UI

    Language Support for Java Extension
    → VS Code에 Java 개발 기능 연결

    Java Language Server
    → Java Source / Type / Classpath / Dependency 분석
    → 자동완성 / 오류표시 / 정의이동 / Refactoring 결과 제공
    ```

    Java Language Server 자체도 Java 프로그램이므로
    실행하려면 JVM/JDK가 필요하다.

---

## 6. `java.jdt.ls.java.home`

`java.jdt.ls.java.home`은
**Java Language Server 프로그램 자체를 어떤 JDK로 실행할지 지정**한다.

예:

```json
"java.jdt.ls.java.home":
  "C:\\local-microserver\\tools\\jdk\\temurin-25"
```

정확한 의미:

```text
VS Code 뒤에서 실행되는 Java Language Server를
C:\local-microserver\tools\jdk\temurin-25
JDK로 실행한다.
```

다음 의미는 아니다.

```text
X MicroServer Project를 Java 25로 Build한다.
```

Project Build 기준은 `build.gradle`의 Java Toolchain이다.

### 두 Java 설정 비교

```text
java.configuration.runtimes
→ VS Code에 Project용 로컬 JDK 목록 / 위치 등록


java.jdt.ls.java.home
→ Java Language Server 자체의 실행 JDK 지정
```

같은 JDK 경로를 두 설정에 사용할 수 있지만
사용 목적은 서로 다르다.

```text
C:\local-microserver\tools\jdk\temurin-25
        │
        ├─ Project Runtime 등록
        │   → java.configuration.runtimes
        │
        └─ Language Server 실행
            → java.jdt.ls.java.home
```

!!! note "`java.jdt.ls.java.home`은 선택 설정"

    Java Extension 환경에 따라 Language Server 실행용 Runtime이 제공될 수 있으므로
    `java.jdt.ls.java.home`은 일반적인 Project Java Version 설정의 필수 항목이 아니다.

    현재 설정되어 있고 정상 동작한다면 유지해도 된다.

---

## 7. Windows User Settings 구성

Command Palette:

```text
Ctrl + Shift + P
```

실행:

```text
Preferences: Open User Settings (JSON)
```

현재 JDK Home:

```text
C:\local-microserver\tools\jdk\temurin-25
```

정상 JDK Home:

```text
O C:\local-microserver\tools\jdk\temurin-25
```

잘못된 예:

```text
X C:\local-microserver\tools\jdk\temurin-25\bin
X C:\local-microserver\tools\jdk\temurin-25\bin\java.exe
```

현재 구성 예:

```json
{
  "files.encoding": "utf8",
  "files.autoGuessEncoding": false,
  "files.autoSave": "off",
  "editor.formatOnSave": false,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,

  "java.jdt.ls.java.home":
    "C:\\local-microserver\\tools\\jdk\\temurin-25",

  "java.configuration.runtimes": [
    {
      "name": "JavaSE-25",
      "path": "C:\\local-microserver\\tools\\jdk\\temurin-25",
      "default": true
    }
  ]
}
```

이미 동일한 값이 설정되어 있다면 다시 추가하지 않는다.

---

## 9. Git 관리 기준

User Settings는 MicroServer Repository 내부 파일이 아니다.

따라서 다음 설정에 들어 있는 JDK 절대경로는
Project Git 관리 대상이 아니다.

```text
java.configuration.runtimes
java.jdt.ls.java.home
```

!!! important "`.gitignore`로 제외하는 것이 아님"

    User Settings 자체가 Project Repository 밖에 있으므로
    애초에 `git add`, `git commit`, `.gitignore` 대상이 아니다.

---

## 10. 완료 확인

- [ ] MicroServer Java Version 기준이 Java 25임을 확인했다.
- [ ] `build.gradle`에 `JavaLanguageVersion.of(25)`가 있다.
- [ ] Windows JDK Home이 `C:\local-microserver\tools\jdk\temurin-25`이다.
- [ ] User Settings에 `java.configuration.runtimes`가 등록되어 있다.
- [ ] `java.jdt.ls.java.home`의 역할과 선택 설정임을 이해했다.
- [ ] User Settings의 JDK 절대경로가 Project Git 대상이 아님을 확인했다.

다음 문서:

→ [VS Code Workspace Settings](../../03_project_creation_verification/02_project_environment/vscode_workspace_settings.md)
