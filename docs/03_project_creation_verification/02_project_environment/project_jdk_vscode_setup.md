# 프로젝트 JDK / VS Code Workspace 설정

## 1. 목적

이 문서는 MicroServer Project를 Clone한 개발자가 **JDK와 VS Code 개발환경을 실제로 준비하는 절차**만 다룬다.

개념 설명은 다음 문서를 참고한다.

→ [VS Code Java 개발환경 개념](project_jdk_vscode_concepts.md)

---

## 2. 완료 기준

다음 상태가 되면 이 단계는 완료다.

```text
Project Root를 VS Code로 Open
Workspace Trusted
Launcher가 Temurin 25 환경 전달
build.gradle Toolchain = Java 25
.vscode 공통 설정 존재
권장 Extension 확인
```

---

## 3. Project Root 열기

다음 파일이 있는 Directory가 Project Root다.

```text
microserver/
├─ build.gradle
├─ settings.gradle
├─ gradlew
├─ gradlew.bat
├─ gradle/
└─ src/
```

VS Code에서:

```text
File
→ Open Folder...
→ .../workspace/microserver
```

`workspace` 상위 Folder가 아니라 `build.gradle`이 있는 `microserver`를 연다.

---

## 4. Workspace Trust

처음 열 때 Trust 확인이 표시되면 Repository 출처를 확인하고 **Trust**를 선택한다.

Restricted Mode이면 Java / Gradle Extension, Task, Debug 기능이 제한될 수 있다.

이미 Trusted 상태라면 별도 작업은 하지 않는다.

---

## 5. Launcher로 VS Code 실행

MicroServer는 일반 VS Code 실행이 아니라 **MicroServer 전용 Launcher 실행을 표준**으로 한다.

Launcher는 Folder 내부 Temurin 25를 현재 VS Code Process에 전달한다.

### Windows

VS Code Integrated Terminal:

```powershell
$env:JAVA_HOME
where.exe java
java --version
```

정상 기준:

```text
JAVA_HOME → MicroServer Folder 내부 Temurin 25
java       → Folder 내부 JDK가 우선
Version    → Java 25 / Eclipse Temurin
```

### macOS

VS Code Integrated Terminal:

```bash
echo $JAVA_HOME
which java
java --version
```

정상 기준:

```text
JAVA_HOME → .../temurin-25/Contents/Home
java       → $JAVA_HOME/bin/java
Version    → Java 25 / Eclipse Temurin
```

!!! important
    일반 Terminal이 아니라 **Launcher로 실행한 VS Code의 Integrated Terminal**에서 확인한다.

---

## 6. Java Toolchain 확인

`build.gradle`에서 다음 값을 확인한다.

```groovy
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(25)
    }
}
```

다르면 Project 표준에 맞게 수정한다.

JDK 절대경로는 `build.gradle`에 넣지 않는다.

---

## 7. Project 공통 VS Code 설정

Workspace 설정의 실제 작성은 다음 문서에서 수행한다.

→ [VS Code Workspace Settings](vscode_workspace_settings.md)

이 단계에서는 다음 파일이 존재하는지만 확인한다.

```text
.vscode/settings.json
.vscode/extensions.json
```

---

## 8. JDK 경로 설정 금지 확인

Project `.vscode/settings.json`에 다음 설정을 기본적으로 넣지 않는다.

```text
java.configuration.runtimes
java.jdt.ls.java.home
C:\...\temurin-25
/Users/.../temurin-25/Contents/Home
```

필요한 경우에만 개발자 개인 User Settings에서 사용한다.

---

## 9. 완료 체크리스트

- [ ] `microserver` Project Root를 열었다.
- [ ] Workspace가 Trusted 상태다.
- [ ] Launcher로 VS Code를 실행했다.
- [ ] Integrated Terminal에서 Java 25 / Temurin을 확인했다.
- [ ] `build.gradle` Toolchain이 Java 25다.
- [ ] `.vscode/settings.json`과 `extensions.json`이 존재한다.
- [ ] Project 설정에 개발자 개인 JDK 절대경로가 없다.

다음 단계:

→ [VS Code Workspace Settings](vscode_workspace_settings.md)
