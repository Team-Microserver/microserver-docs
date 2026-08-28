# 프로젝트 JDK / VS Code Workspace 설정

## 1. 문서 목적

본 문서는 MicroServer 프로젝트에서 실제로 필요한
JDK / VS Code Workspace 설정을 적용한다.

개념 설명은 다음 문서를 먼저 참고한다.

→ [프로젝트 JDK / VS Code 개념](project_jdk_vscode_concepts.md)

현재 기준:

```text
Java Version : 25
Windows JDK  : C:\local-microserver\tools\jdk\temurin-25
```

---

## 2. 실제 작업 요약

이 문서에서 실제로 수행할 작업은 다음 세 가지이다.

| 순서 | 작업 | 저장 위치 | Git |
|---|---|---|---|
| 1 | Java 25 Runtime 등록 | VS Code User Settings | 대상 아님 |
| 2 | Workspace 공통 설정 | `.vscode/settings.json` | O |
| 3 | 권장 Extension 설정 | `.vscode/extensions.json` | O |

추가로 `build.gradle`의 Java Toolchain이 25인지 확인한다.

---

## 3. Project Root 열기

VS Code에서 다음 Directory를 연다.

```text
C:\local-microserver\workspace\microserver
```

```text
File
→ Open Folder...
→ C:\local-microserver\workspace\microserver
```

Explorer:

```text
microserver
├─ gradle/
├─ src/
├─ build.gradle
├─ settings.gradle
├─ gradlew
└─ gradlew.bat
```

!!! important "Project Root"

    ```text
    X C:\local-microserver\workspace
    O C:\local-microserver\workspace\microserver
    ```

---

## 4. Workspace Trust 확인

VS Code는 Project Folder를 처음 열 때
해당 Folder의 코드와 설정을 **신뢰하고 실행해도 되는지** 확인할 수 있다.

이 기능을 **Workspace Trust**라고 한다.

VS Code는 단순히 파일만 보여주는 Editor가 아니라
Project를 열면 Extension, Task, Debugger, Build Tool 등이
Project 내부의 설정과 Script를 읽고 실행할 수 있다.

예를 들어 Java / Gradle Project에서는 다음과 같은 기능이 동작할 수 있다.

```text
Project Folder Open
        ↓
VS Code가 Project 설정 확인
        ↓
Java Extension 실행
Gradle Extension 실행
Task / Debug 설정 사용
Build Script 분석
```

따라서 출처가 불분명한 Repository를 바로 신뢰하면
Project 내부의 설정이나 Script가 실행될 수 있으므로
VS Code가 먼저 신뢰 여부를 확인하는 것이다.

### 4.1 Trust한 경우

Workspace를 Trust하면 Java / Gradle Extension과
Task, Debugger 등 Project 개발 기능을 정상적으로 사용할 수 있다.

```text
Trusted Workspace
        ↓
Java Extension 정상 동작
Gradle Extension 정상 동작
Task / Debug 사용 가능
Project 분석 기능 사용 가능
```

### 4.2 Trust하지 않은 경우

신뢰하지 않은 Workspace는
**Restricted Mode(제한 모드)**로 열릴 수 있다.

Restricted Mode에서는 파일을 열어보는 것은 가능하지만
보안을 위해 일부 Project 기능이 제한될 수 있다.

예:

```text
Java / Gradle Extension 일부 기능 제한
Task 실행 제한
Debug 기능 제한
일부 Project 자동 인식 기능 제한
```

!!! tip "Workspace Trust는 Git 권한이나 Java Version 설정이 아님"

    Workspace Trust는 다음을 설정하는 기능이 아니다.

    ```text
    Git 인증 / 권한
    Java Version
    JDK 경로
    Gradle Version
    ```

    단순히 다음을 판단하는 **VS Code 보안 기능**이다.

    ```text
    "이 Project 안의 코드 / 설정 / Task / Extension 동작을
    VS Code가 신뢰하고 실행해도 되는가?"
    ```

### 4.3 MicroServer에서는 무엇을 하면 되는가

현재 MicroServer처럼 직접 생성하고 관리하는 Project라면
Workspace Trust 요청이 나타날 때 내용을 확인한 후 **Trust**를 선택한다.

```text
Workspace Trust 요청 표시
        ↓
Project 출처 확인
        ↓
직접 생성 / 관리하는 MicroServer Project
        ↓
Trust 선택
```

!!! note "Trust 요청이 나타나지 않으면 별도 작업하지 않음"

    이전에 이미 해당 Folder 또는 상위 Folder를 Trust했거나
    현재 VS Code 설정에 따라 Trust 확인 창이 나타나지 않을 수 있다.

    이런 경우에는 별도로 Trust 설정을 다시 변경할 필요가 없다.

    Java / Gradle 기능이 정상적으로 동작한다면 다음 단계로 진행한다.

## 5. `build.gradle` Java Toolchain 확인

현재 MicroServer Java 기준은 **25**이다.

`build.gradle`:

```groovy
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(25)
    }
}
```

확인할 값:

```text
JavaLanguageVersion.of(25)
```

!!! note "현재 단계에서는 확인만"

    이미 Java 25가 설정되어 있다면 수정하지 않는다.

---

## 6. Windows User Settings 설정

### 6.1 User Settings 열기

Command Palette:

```text
Ctrl + Shift + P
```

```text
Preferences: Open User Settings (JSON)
```

!!! warning "Project 설정 파일이 아님"

    지금 수정하는 것은 다음 Project 파일이 아니다.

    ```text
    X microserver/.vscode/settings.json
    ```

    VS Code **User Settings JSON**이다.

### 6.2 JDK Home

현재 Windows 기준:

```text
C:\local-microserver\tools\jdk\temurin-25
```

정상:

```text
O C:\local-microserver\tools\jdk\temurin-25
```

잘못된 예:

```text
X C:\local-microserver\tools\jdk\temurin-25\bin
X C:\local-microserver\tools\jdk\temurin-25\bin\java.exe
```

### 6.3 Java Runtime 등록

기존 User Settings에 다음 항목을 병합한다.

```json
"java.configuration.runtimes": [
  {
    "name": "JavaSE-25",
    "path": "C:\\local-microserver\\tools\\jdk\\temurin-25",
    "default": true
  }
]
```

이미 동일하게 등록되어 있다면 다시 추가하지 않는다.

### 6.4 선택 설정

현재 환경에서 Java Language Server도 Portable JDK 25로 명시적으로 실행하려면
다음 설정을 User Settings에 유지할 수 있다.

```json
"java.jdt.ls.java.home": "C:\\local-microserver\\tools\\jdk\\temurin-25"
```

이 값은 선택 설정이며 Project Java Version을 결정하지 않는다.

---

## 7. macOS User Settings

macOS에서도 동일한 원칙을 사용한다.

예:

```text
/Users/<USER>/dev/jdks/temurin-25.jdk/Contents/Home
```

```json
"java.configuration.runtimes": [
  {
    "name": "JavaSE-25",
    "path": "/Users/<USER>/dev/jdks/temurin-25.jdk/Contents/Home",
    "default": true
  }
]
```

실제 설치 방식에 따라 JDK Home은 다를 수 있으므로
해당 개발 PC에서 확인한 경로를 사용한다.

---

## 8. `.vscode` Directory 생성

Project Root 아래에 생성한다.

```text
microserver/
├─ .vscode/
├─ gradle/
├─ src/
├─ build.gradle
├─ settings.gradle
├─ gradlew
└─ gradlew.bat
```

---

## 9. `.vscode/settings.json`

파일:

```text
microserver/.vscode/settings.json
```

권장 설정:

```json
{
  "files.encoding": "utf8",
  "java.configuration.updateBuildConfiguration": "automatic"
}
```

역할:

| 설정 | 역할 |
|---|---|
| `files.encoding` | Workspace 기본 Encoding |
| `java.configuration.updateBuildConfiguration` | Gradle Build 설정 변경 시 Java Project 구성 자동 갱신 |

!!! important "JDK 절대경로 금지"

    다음 값은 Project의 `.vscode/settings.json`에 넣지 않는다.

    ```text
    java.configuration.runtimes
    java.jdt.ls.java.home
    C:\local-microserver\tools\jdk\temurin-25
    ```

    개발 PC별 JDK 경로는 User Settings에서 관리한다.

---

## 10. `.vscode/extensions.json`

파일:

```text
microserver/.vscode/extensions.json
```

권장:

```json
{
  "recommendations": [
    "vscjava.vscode-java-pack",
    "vscjava.vscode-gradle",
    "vmware.vscode-boot-dev-pack",
    "redhat.vscode-yaml",
    "redhat.vscode-xml",
    "ms-azuretools.vscode-containers"
  ]
}
```

주요 Extension:

| Extension | 역할 |
|---|---|
| Extension Pack for Java | Java 개발 |
| Gradle for Java | Gradle Project / Task |
| Spring Boot Extension Pack | Spring Boot / Dashboard |
| YAML | YAML 편집 |
| XML | XML 편집 |
| Container Tools | Container 관련 기능 |

!!! note "Maven View"

    Extension Pack for Java에는 Maven 관련 Extension이 포함될 수 있어
    Maven View가 표시될 수 있다.

    MicroServer는 `build.gradle` 기반의 Gradle Project이므로
    Maven을 사용하지 않는다면 해당 View는 숨겨도 된다.

---

## 11. `.gitignore` 확인

다음 파일은 Git 공유 대상이다.

```text
.vscode/settings.json
.vscode/extensions.json
```

따라서 `.gitignore`에 다음 항목이 있다면 현재 정책과 충돌한다.

```gitignore
.vscode/
```

JDK 절대경로는 User Settings에 저장하므로
`.gitignore`로 별도 제외하는 구조가 아니다.

---

## 12. 설정 완료 기준

```text
build.gradle
→ Java 25 확인

VS Code User Settings
→ java.configuration.runtimes 등록

.vscode/settings.json
→ 공통 설정 생성

.vscode/extensions.json
→ 권장 Extension 생성
```

다음 문서에서 실제 인식 상태를 확인한다.

→ [프로젝트 JDK / VS Code 설정 확인](project_jdk_vscode_verify.md)
