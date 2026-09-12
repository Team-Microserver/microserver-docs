# macOS VS Code User Settings

## 1. 문서 목적

본 문서는 **VS Code Portable 설정**을 완료한 다음 단계로,
MicroServer Portable VS Code에서 사용하는 **User Settings**를 구성하는 방법을 설명한다.

현재 MicroServer Java 기준:

```text
Java Version : 25
JDK          : Eclipse Temurin 25
JDK 위치     : ~/local-microserver/tools/jdk/temurin-25/Contents/Home
```

macOS Portable Mode의 User Settings는 해당 Portable VS Code 인스턴스에 적용되며,
MicroServer Project Repository에는 저장하지 않는다.

### 사전 문서

- [VS Code 설치](vscode_install.md)
- [VS Code Portable 설정](vscode_portable_setup.md)

!!! note "이 문서의 범위"
    JDK 설치, `JAVA_HOME`, Gradle 환경변수와 Portable 실행환경은 앞 단계에서 이미 구성했다.

    이 문서에서는 같은 내용을 반복하지 않고,
    **MicroServer Portable VS Code의 공통 User Settings**만 구성한다.

---

## 2. Java 환경 관리 원칙

MicroServer macOS 환경에서는 Java 관련 기준을 다음과 같이 분리한다.

```text
setup.sh
→ MicroServer VS Code 실행환경의 JAVA_HOME 설정
→ ~/local-microserver/tools/jdk/temurin-25/Contents/Home

build.gradle Java Toolchain
→ Project가 요구하는 Java Version 정의
→ Java 25

VS Code User Settings
→ Editor 공통 설정
→ 사용자 계정명이 포함된 JDK 절대경로는 기본 설정에 넣지 않음
```

이 방식의 목적은 개발자마다 다른 macOS Home Directory를
`settings.json`에 직접 작성하지 않는 것이다.

예를 들어 다음과 같은 설정은 표준 User Settings에 넣지 않는다.

```json
"java.jdt.ls.java.home":
  "/Users/<USER>/local-microserver/tools/jdk/temurin-25/Contents/Home"
```

```json
"java.configuration.runtimes": [
  {
    "name": "JavaSE-25",
    "path": "/Users/<USER>/local-microserver/tools/jdk/temurin-25/Contents/Home"
  }
]
```

!!! important "`~`는 settings.json의 공통 경로 치환 문법이 아니다"
    Terminal의 zsh에서는 `~`를 Home Directory로 해석하지만,
    VS Code Extension 설정의 문자열 값이 항상 Shell처럼 `~`를 확장하는 것은 아니다.

    따라서 Java Extension의 JDK 경로 설정에
    `~/local-microserver/...`를 억지로 넣어 Portable하게 만들지 않는다.

---

## 3. MicroServer Java 실행환경

MicroServer Portable VS Code는 `start-vscode.command`를 통해 실행한다.

```text
start-vscode.command
        ↓
setup.sh
        ↓
JAVA_HOME / GRADLE_HOME 설정
        ↓
MicroServer Portable VS Code 실행
```

`setup.sh`의 Java 기준:

```bash
export JAVA_HOME="$LOCAL_MICROSERVER/tools/jdk/temurin-25/Contents/Home"
```

따라서 개발자 Home Directory가 달라도 다음 구조만 동일하면 된다.

```text
~/local-microserver/tools/jdk/temurin-25/Contents/Home
```

Integrated Terminal에서 확인:

```bash
echo "$JAVA_HOME"
java -version
```

예상:

```text
/Users/<USER>/local-microserver/tools/jdk/temurin-25/Contents/Home
```

!!! tip "Java 경로의 기준은 setup.sh"
    MicroServer 전용 JDK 경로는 `setup.sh` 한 곳에서 관리한다.

    같은 JDK 절대경로를 `setup.sh`, `settings.json` 여러 곳에 중복 작성하지 않는다.

---

## 4. Project Java Version

MicroServer Project의 Java Version은
VS Code User Settings가 아니라 `build.gradle`의 Java Toolchain으로 관리한다.

```groovy
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(25)
    }
}
```

역할:

```text
JAVA_HOME
→ MicroServer VS Code / Terminal의 기본 Java 실행환경

Gradle Java Toolchain
→ Project Build에 사용할 Java Version

VS Code User Settings
→ Editor 공통 사용자 설정
```

!!! important "Project Java 기준은 build.gradle"
    Java 25를 Project 표준으로 강제하는 기준은
    `java.configuration.runtimes`가 아니라 Gradle Java Toolchain이다.

---

## 5. Java Extension Runtime 설정 기준

### `java.jdt.ls.java.home`

`java.jdt.ls.java.home`은 Java Language Server 자체의 실행 JDK를
명시적으로 지정할 때 사용하는 설정이다.

MicroServer 표준 User Settings에서는 **기본적으로 설정하지 않는다.**

이유:

```text
사용자별 /Users/<USER>/... 절대경로를 settings.json에 넣지 않기 위함
        +
Java Language Server 실행 Runtime과
Project Java Version을 불필요하게 결합하지 않기 위함
```

Java Extension이 정상 동작한다면 별도 설정은 필요하지 않다.

특정 개발환경에서 Java Language Server Runtime을 명시적으로 고정해야 하는 경우에만
개발자 개인 설정으로 추가한다.

---

### `java.configuration.runtimes`

`java.configuration.runtimes`는 여러 로컬 JDK를 VS Code Java Extension에
명시적으로 등록해야 할 때 사용하는 설정이다.

MicroServer는 현재:

```text
Project Build
→ Gradle

Project Java Version
→ Java Toolchain 25

MicroServer 실행환경
→ JAVA_HOME = Temurin 25
```

을 기준으로 하므로 **기본 User Settings에서는 생략한다.**

다음과 같은 경우에만 추가 구성을 검토한다.

```text
여러 JDK Version을 동시에 운영
Unmanaged Java Folder 사용
VS Code Java Runtime을 별도로 선택해야 하는 경우
```

!!! note "필요할 때만 개발자별로 설정"
    `java.configuration.runtimes`를 사용해야 한다면
    실제 JDK Home의 절대경로를 해당 개발자의 User Settings에 설정한다.

    이 설정은 공통 MicroServer Project 설정으로 관리하지 않는다.

---

## 6. User Settings 열기

MicroServer Portable VS Code에서 Command Palette를 연다.

```text
Command + Shift + P
```

다음을 실행한다.

```text
Preferences: Open User Settings (JSON)
```

Portable Mode에서는 다음 위치에 저장된다.

```text
~/local-microserver/tools/vscode/
└─ code-portable-data/
   └─ user-data/
      └─ User/
         └─ settings.json
```

---

## 7. MicroServer 기본 User Settings

기본 User Settings에서는
개발자 Home Directory가 포함되는 Java 절대경로를 넣지 않는다.

설정:

```json
{
  "files.encoding": "utf8",
  "files.autoGuessEncoding": false,
  "files.autoSave": "off",
  "editor.formatOnSave": false,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true
}
```

각 설정:

| 설정 | 의미 |
|---|---|
| `files.encoding` | 기본 파일 인코딩 UTF-8 |
| `files.autoGuessEncoding` | Encoding 자동 추측 비활성화 |
| `files.autoSave` | 자동 저장 비활성화 |
| `editor.formatOnSave` | 저장 시 자동 Format 비활성화 |
| `files.trimTrailingWhitespace` | 저장 시 불필요한 후행 공백 제거 |
| `files.insertFinalNewline` | 파일 마지막 줄에 Newline 추가 |

---

## 8. Java 환경 확인

User Settings 저장 후
MicroServer Portable VS Code의 새 Integrated Terminal에서 확인한다.

```bash
echo "$JAVA_HOME"
java -version
```

Gradle 환경:

```bash
echo "$GRADLE_HOME"
echo "$GRADLE_USER_HOME"
gradle --version
```

Project에 Gradle Wrapper가 있다면 실제 Build는 Wrapper를 사용한다.

```bash
./gradlew --version
```

Java Extension이 설치된 이후에는 Command Palette에서 다음 명령으로
현재 Java Runtime 상태를 확인할 수 있다.

```text
Java: Configure Java Runtime
```

---

## 9. Git 관리 기준

Portable User Settings 위치:

```text
~/local-microserver/tools/vscode/
└─ code-portable-data/
   └─ user-data/
      └─ User/
         └─ settings.json
```

이 파일은 MicroServer Project Repository 밖에 있으므로
Project Git 관리 대상이 아니다.

!!! important "Project .gitignore 대상이 아니다"
    Portable VS Code User Settings는 Project Repository 내부 파일이 아니다.

    따라서 Project의 `git add`, `git commit`, `.gitignore`와 별개다.

---

## 10. 완료 확인

- [ ] MicroServer Portable VS Code에서 User Settings JSON을 열었다.
- [ ] 기본 Editor User Settings를 적용했다.
- [ ] User Settings에 개발자별 JDK 절대경로를 넣지 않았다.
- [ ] `JAVA_HOME`은 `setup.sh`에서 관리한다.
- [ ] Integrated Terminal에서 Java 25가 정상 적용됨을 확인했다.
- [ ] Project Java Version은 `build.gradle` Java Toolchain으로 관리한다.
- [ ] `java.jdt.ls.java.home`은 필요한 경우에만 개인 설정으로 사용한다.
- [ ] `java.configuration.runtimes`는 여러 JDK Runtime 관리가 필요한 경우에만 사용한다.

---

## 11. 최종 User Settings

MicroServer macOS Portable VS Code의 기본 `settings.json`은
다음 내용을 그대로 복사하여 사용한다.

```json
{
  "files.encoding": "utf8",
  "files.autoGuessEncoding": false,
  "files.autoSave": "off",
  "editor.formatOnSave": false,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true
}
```

Java 환경은 `settings.json`에 사용자별 절대경로를 작성하지 않고
다음 기준으로 관리한다.

```text
MicroServer 실행 JDK
→ ~/local-microserver/env/setup.sh
→ JAVA_HOME
→ ~/local-microserver/tools/jdk/temurin-25/Contents/Home

Project Java Version
→ build.gradle
→ Java Toolchain
→ Java 25

Java Language Server Runtime
→ Java Extension 기본 Runtime 사용
→ 필요할 경우에만 개발자 개인 설정으로 별도 지정
```

!!! tip "MicroServer macOS 설정의 핵심"
    ```text
    JDK 실제 위치
    ~/local-microserver/tools/jdk/temurin-25/Contents/Home

    실행환경
    setup.sh → JAVA_HOME

    Project Java Version
    build.gradle → Java Toolchain 25

    VS Code User Settings
    사용자별 JDK 절대경로 없음
    ```

다음 문서:

→ [VS Code Workspace Settings](../../03_project_creation_verification/02_project_environment/vscode_workspace_settings.md)
