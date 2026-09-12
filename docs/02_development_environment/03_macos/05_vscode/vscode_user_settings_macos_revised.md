# macOS VS Code User Settings

## 1. 문서 목적

본 문서는 **VS Code Portable 설정**을 완료한 다음 단계로,
MicroServer Portable VS Code에서 사용하는 **User Settings** 중
Java / JDK 관련 설정을 구성하는 방법을 설명한다.

현재 기준:

```text
Java Version : 25
JDK          : Eclipse Temurin 25
macOS JDK    : ~/local-microserver/tools/jdk/temurin-25/Contents/Home
```

macOS Portable Mode의 User Settings는 **해당 Portable VS Code 인스턴스에서 여는 Workspace에 공통 적용**되며,
MicroServer Project Repository에는 저장하지 않는다.

### 사전 문서

- [VS Code 설치](vscode_install.md)
- [VS Code Portable 설정](vscode_portable_setup.md)

!!! note "이 문서의 범위"
    JDK 설치, `JAVA_HOME`, Gradle 환경변수와 Portable 실행환경은 앞 단계에서 이미 구성했다.

    이 문서에서는 같은 내용을 반복하지 않고 **VS Code Java Extension이 사용할 JDK Runtime 설정**에 집중한다.

---

## 2. Java User Settings 구성 기준

MicroServer에서는 다음 두 설정을 사용한다.

| 설정 | 역할 | 기준 |
|---|---|---|
| `java.configuration.runtimes` | VS Code Java Extension에 사용할 JDK 등록 | 구성 |
| `java.jdt.ls.java.home` | Java Language Server 실행 JDK 지정 | 선택 |

역할은 다음과 같이 구분한다.

```text
build.gradle Java Toolchain
→ Project가 요구하는 Java Version
→ Java 25

java.configuration.runtimes
→ VS Code에 설치된 JDK 위치 등록

java.jdt.ls.java.home
→ Java Language Server 자체의 실행 JDK 지정
```

!!! important "Project Java Version과 User Settings는 역할이 다르다"
    User Settings에 Java 25를 등록한다고 Project Java Version이 결정되는 것은 아니다.

    MicroServer Project의 Java Version 기준은 `build.gradle`의 Java Toolchain이다.

    ```groovy
    java {
        toolchain {
            languageVersion = JavaLanguageVersion.of(25)
        }
    }
    ```

---

## 3. macOS JDK Home 확인

MicroServer macOS 표준 JDK Home:

```text
~/local-microserver/tools/jdk/temurin-25/Contents/Home
```

실제 경로를 확인한다.

```bash
echo "$JAVA_HOME"
```

예:

```text
/Users/<USER>/local-microserver/tools/jdk/temurin-25/Contents/Home
```

JDK Home은 `bin` Directory가 아니라 **`Contents/Home`까지의 경로**다.

```text
O ~/local-microserver/tools/jdk/temurin-25/Contents/Home

X ~/local-microserver/tools/jdk/temurin-25/Contents/Home/bin
X ~/local-microserver/tools/jdk/temurin-25/Contents/Home/bin/java
```

!!! note "`JAVA_HOME`과 VS Code User Settings"
    MicroServer Portable 실행환경의 `JAVA_HOME`은 `setup.sh`에서 관리한다.

    User Settings의 JDK 설정은 Java Extension이 사용할 Runtime 위치를 알려주는 역할이다.
    같은 경로를 사용하지만 설정 목적은 다르다.

---

## 4. User Settings 열기

MicroServer Portable VS Code에서 Command Palette를 연다.

```text
Command + Shift + P
```

다음을 실행한다.

```text
Preferences: Open User Settings (JSON)
```

Portable Mode에서는 이 설정이 MicroServer Portable VS Code의 User Data에 저장된다.

```text
~/local-microserver/tools/vscode/
└─ code-portable-data/
   └─ user-data/
      └─ User/
         └─ settings.json
```

---

## 5. `java.configuration.runtimes` 설정

`java.configuration.runtimes`에 MicroServer Java 25 JDK를 등록한다.

```json
"java.configuration.runtimes": [
  {
    "name": "JavaSE-25",
    "path": "/Users/<USER>/local-microserver/tools/jdk/temurin-25/Contents/Home",
    "default": true
  }
]
```

각 항목의 의미:

| 항목 | 의미 |
|---|---|
| `name` | Java Execution Environment |
| `path` | 실제 JDK Home |
| `default` | 등록된 Runtime 중 기본 Runtime |

`<USER>`는 실제 macOS 계정명으로 변경한다.

예:

```json
"path": "/Users/jangkwankim/local-microserver/tools/jdk/temurin-25/Contents/Home"
```

!!! note "`default: true`"
    VS Code Java Runtime의 기본 Runtime을 지정한다.

    Gradle Project의 Java Version을 강제하는 설정은 아니며,
    Project Java Version은 `build.gradle`의 Java Toolchain을 따른다.

---

## 6. `java.jdt.ls.java.home` 설정

`java.jdt.ls.java.home`은 **Java Language Server 자체를 실행할 JDK**를 지정한다.

```json
"java.jdt.ls.java.home":
  "/Users/<USER>/local-microserver/tools/jdk/temurin-25/Contents/Home"
```

Java Language Server는 Java Source 분석, 자동완성, 오류 표시, 정의 이동,
Refactoring 등의 Java 개발 기능을 제공한다.

```text
java.configuration.runtimes
→ Project에서 사용할 수 있는 로컬 JDK 등록

java.jdt.ls.java.home
→ Java Language Server 실행 JDK
```

!!! note "`java.jdt.ls.java.home`은 선택 설정"
    Java Extension 환경에 따라 Language Server 실행 Runtime이 별도로 제공될 수 있으므로
    필수 설정은 아니다.

    MicroServer에서는 Java 개발환경을 명확하게 고정하려는 경우 동일한 Temurin 25 경로를 지정할 수 있다.

---

## 7. Git 관리 기준

User Settings는 MicroServer Project Repository 내부 파일이 아니다.

```text
~/local-microserver/tools/vscode/
└─ code-portable-data/
   └─ user-data/
      └─ User/
         └─ settings.json
```

따라서 `settings.json`에 들어가는 macOS 사용자별 JDK 절대경로는
Project Git 관리 대상이 아니다.

!!! important "Project `.gitignore` 대상이 아니다"
    Portable VS Code User Settings 자체가 Project Repository 밖에 있으므로
    Project의 `git add`, `git commit`, `.gitignore` 대상이 아니다.

---

## 8. 완료 확인

- [ ] MicroServer Portable VS Code에서 User Settings JSON을 열었다.
- [ ] JDK Home이 `~/local-microserver/tools/jdk/temurin-25/Contents/Home` 기준인지 확인했다.
- [ ] `java.configuration.runtimes`에 Java 25 Runtime을 등록했다.
- [ ] 필요한 경우 `java.jdt.ls.java.home`을 Temurin 25로 지정했다.
- [ ] Project Java Version은 `build.gradle`의 Java Toolchain이 결정함을 확인했다.
- [ ] User Settings는 Project Git 관리 대상이 아님을 확인했다.

---

## 9. 최종 User Settings

아래 설정에서 `<USER>`를 실제 macOS 계정명으로 변경한 뒤
`settings.json`에 복사하여 사용한다.

```json
{
  "files.encoding": "utf8",
  "files.autoGuessEncoding": false,
  "files.autoSave": "off",
  "editor.formatOnSave": false,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,

  "java.jdt.ls.java.home":
    "/Users/<USER>/local-microserver/tools/jdk/temurin-25/Contents/Home",

  "java.configuration.runtimes": [
    {
      "name": "JavaSE-25",
      "path": "/Users/<USER>/local-microserver/tools/jdk/temurin-25/Contents/Home",
      "default": true
    }
  ]
}
```

현재 Mac 계정이 `jangkwankim`인 경우 최종 설정은 다음과 같다.

```json
{
  "files.encoding": "utf8",
  "files.autoGuessEncoding": false,
  "files.autoSave": "off",
  "editor.formatOnSave": false,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,

  "java.jdt.ls.java.home":
    "/Users/jangkwankim/local-microserver/tools/jdk/temurin-25/Contents/Home",

  "java.configuration.runtimes": [
    {
      "name": "JavaSE-25",
      "path": "/Users/jangkwankim/local-microserver/tools/jdk/temurin-25/Contents/Home",
      "default": true
    }
  ]
}
```

!!! tip "기존 settings.json이 있는 경우"
    기존 설정을 모두 지우고 덮어쓰는 것이 아니라,
    동일한 Key가 있는지 확인한 뒤 Java 관련 설정을 병합한다.

다음 문서:

→ [VS Code Workspace Settings](../../03_project_creation_verification/02_project_environment/vscode_workspace_settings.md)
