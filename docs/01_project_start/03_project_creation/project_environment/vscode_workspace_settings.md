# VS Code Workspace Settings 가이드

## 1. 문서 목적

본 문서는 MicroServer Project Repository에서
팀이 공통으로 사용할 **VS Code Workspace 설정**을 구성한다.

User Settings의 JDK 경로 설정은 다음 문서에서 별도로 관리한다.

→ [VS Code User Settings](vscode_user_settings.md)

현재 Project Root:

```text
C:\local-microserver\workspace\microserver
```

---

## 2. Workspace Settings란

Workspace Settings는 특정 Project에 적용되는 VS Code 설정이다.

MicroServer에서는 Project Root의 `.vscode` Directory를 사용한다.

현재 Project의 `.vscode` 구조는 다음과 같이 본다.

```text
microserver/
├─ .vscode/
│  ├─ extensions.json
│  ├─ NEWLY_CREATED_BY_SPRING_INITIALIZR
│  └─ settings.json
├─ build.gradle
├─ settings.gradle
├─ gradlew
├─ gradlew.bat
└─ src/
```

각 파일의 역할:

| 파일 | 역할 | Git |
|---|---|---|
| `.vscode/settings.json` | Project 공통 VS Code 설정 | O |
| `.vscode/extensions.json` | Project 권장 Extension 목록 | O |
| `.vscode/NEWLY_CREATED_BY_SPRING_INITIALIZR` | Spring Initializr가 생성한 Project임을 표시하는 Marker | 기존 파일 유지 |

!!! note "`NEWLY_CREATED_BY_SPRING_INITIALIZR`는 삭제하지 않음"

    Spring Initializr Extension으로 Project를 생성하면
    다음 Marker File이 생성될 수 있다.

    ```text
    .vscode/NEWLY_CREATED_BY_SPRING_INITIALIZR
    ```

    이 파일은 Spring Initializr가 생성한 Project임을 식별하는 데 사용되는 Marker이다.

    현재 Project에 이미 생성되어 있다면
    특별한 이유가 없는 한 삭제하지 않고 그대로 유지한다.

    즉 `.vscode` Directory를 정리할 때 다음 두 파일만 남기는 구조로 바꾸지 않는다.

    ```text
    X .vscode/
      ├─ settings.json
      └─ extensions.json
    ```

    현재 생성된 Marker까지 포함하여 유지한다.

!!! important "개발자 개인 JDK 절대경로는 저장하지 않음"

    다음 항목은 User Settings에서 관리한다.

    ```text
    java.configuration.runtimes
    java.jdt.ls.java.home
    ```

    `.vscode/settings.json`에는 개발 PC별 JDK 절대경로를 넣지 않는다.

## 3. Project Root 열기

VS Code:

```text
File
→ Open Folder...
→ C:\local-microserver\workspace\microserver
```

Explorer에서 다음 구조를 확인한다.

```text
microserver
├─ gradle/
├─ src/
├─ build.gradle
├─ settings.gradle
├─ gradlew
└─ gradlew.bat
```

!!! important "Project Root를 정확히 열기"

    ```text
    X C:\local-microserver\workspace
    O C:\local-microserver\workspace\microserver
    ```

---

## 4. Workspace Trust

VS Code는 Project Folder를 처음 열 때
해당 Folder의 코드와 설정을 신뢰하고 실행해도 되는지 확인할 수 있다.

이를 **Workspace Trust**라고 한다.

Project를 Trust하면 Java / Gradle Extension, Task, Debugger 등
Project 개발 기능을 정상적으로 사용할 수 있다.

Trust하지 않으면 **Restricted Mode**로 열리며
일부 Extension / Task / Debug 기능이 제한될 수 있다.

!!! tip "MicroServer에서는"

    직접 생성하고 관리하는 MicroServer Project라면
    Trust 요청이 나타날 때 Project 출처를 확인한 후 **Trust**를 선택한다.

    Trust 요청이 나타나지 않고 Java / Gradle 기능이 정상 동작한다면
    별도 작업 없이 다음 단계로 진행한다.

    Workspace Trust는 Git 권한, Java Version, JDK 경로를 설정하는 기능이 아니라
    **Project 내부 코드와 설정의 실행을 허용할지 판단하는 VS Code 보안 기능**이다.

---

## 5. `.vscode/settings.json`

Project Root 아래에 다음 파일을 생성한다.

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

`build.gradle`이나 `settings.gradle`이 변경되면
Java Extension이 Project Classpath / Build Configuration을 갱신할 수 있다.

!!! important "JDK 절대경로를 넣지 않음"

    다음 값은 `.vscode/settings.json`에 작성하지 않는다.

    ```text
    java.configuration.runtimes
    java.jdt.ls.java.home
    C:\local-microserver\tools\jdk\temurin-25
    ```

    개발 PC별 JDK 경로는 VS Code User Settings에서 관리한다.

---

## 6. `.vscode/extensions.json`

Project Root 아래의 다음 파일을 사용한다.

```text
microserver/.vscode/extensions.json
```

권장 설정:

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

### 6.1 이미 설치했는데 왜 `extensions.json`에 다시 적는가

`extensions.json`의 `recommendations`는
**Extension을 다시 설치하는 설정이 아니다.**

현재 PC에 이미 설치되어 있는 Extension이라면
이 파일 때문에 중복 설치되거나 다시 설치되지 않는다.

이 파일의 목적은:

```text
"이 Project를 개발하려면
이 Extension들을 사용하는 것을 권장한다."
```

라는 **Project 개발환경 정보를 Repository에 남기는 것**이다.

즉 개발자 개인 PC에 이미 설치되어 있는지와는 별개로
Project가 요구하거나 권장하는 VS Code Extension 목록을 문서화한다.

!!! tip "`extensions.json`은 Project용 Extension 가이드"

    다음 두 개념을 구분한다.

    ```text
    내 PC에 Extension 설치
    → 현재 개발자 개인 VS Code 환경


    .vscode/extensions.json
    → 이 Project에서 권장하는 Extension 목록
    → Git으로 팀에 공유
    ```

    따라서 현재 개발 PC에 모든 Extension이 이미 설치되어 있어도
    `extensions.json`을 작성하는 의미가 있다.

### 6.2 다른 개발자에게 어떤 도움이 되는가

새 개발자가 Repository를 Clone하고 VS Code로 열었을 때
`extensions.json`의 추천 목록을 기준으로
Project에 필요한 Extension을 확인할 수 있다.

예:

```text
개발자 A
→ 이미 Java / Gradle / Spring Extension 설치
→ 별도 설치 필요 없음


개발자 B
→ 새 PC에서 Repository Clone
→ VS Code가 Project 권장 Extension 확인 가능
→ 필요한 Extension 설치


개발자 C
→ 일부 Extension만 설치
→ 누락된 권장 Extension 확인 가능
```

따라서 `extensions.json`은
**개발자별 VS Code 환경 차이를 줄이는 역할**을 한다.

### 6.3 무엇을 하지 않는가

`extensions.json`은 다음 기능을 하지 않는다.

```text
Extension을 강제로 설치
설치된 Extension을 다시 설치
Extension Version을 고정
Extension 설정값을 저장
```

즉:

```text
extensions.json
→ 권장 Extension 목록

settings.json
→ Project 공통 VS Code 설정
```

으로 역할을 구분한다.

!!! note "Maven View가 표시될 수 있음"

    Extension Pack for Java에는 Maven 관련 Extension이 포함될 수 있다.

    MicroServer는 다음 파일을 사용하는 **Gradle Project**이다.

    ```text
    build.gradle
    settings.gradle
    gradlew
    gradlew.bat
    ```

    Maven을 사용하지 않는다면 Maven View는 숨겨도 된다.

## 7. Java Project 자동 인식

VS Code에서 `microserver` Project Root를 열면
Java / Gradle Extension이 `build.gradle`과 `settings.gradle`을 감지한다.

```mermaid
flowchart TB
    OPEN["microserver Project Root Open"]
    BUILD["build.gradle / settings.gradle 감지"]
    ANALYZE["Gradle Project 구조 / Source / Dependency 분석"]
    MODEL["Java Project Model 생성"]
    VIEW["JAVA PROJECTS에 microserver 표시"]

    OPEN --> BUILD
    BUILD --> ANALYZE
    ANALYZE --> MODEL
    MODEL --> VIEW
```

이 과정을 Java Project **Import**라고 한다.

여기서 Import는 Project 파일을 복사하거나 가져오는 작업이 아니라
VS Code가 현재 Project를 Java Project로 인식하는 과정이다.

!!! important "자동 Import가 기본"

    `JAVA PROJECTS` View에 `microserver`가 보이면
    이미 자동 Import된 상태이다.

    정상 상태에서는 다음 명령을 별도로 실행하지 않는다.

    ```text
    Java: Import Java Projects in Workspace
    ```

    이 명령은 Project가 자동 인식되지 않거나
    Build Script 변경 후 Project Model이 갱신되지 않는 경우에 사용한다.

---

## 8. `.gitignore` 확인

다음 파일은 팀 공통 Workspace 설정이므로 Git으로 공유한다.

```text
.vscode/settings.json
.vscode/extensions.json
```

또한 Spring Initializr가 생성한 다음 Marker File이 이미 존재한다면 유지한다.

```text
.vscode/NEWLY_CREATED_BY_SPRING_INITIALIZR
```

따라서 `.gitignore`에 다음 항목이 있으면 현재 정책과 충돌한다.

```gitignore
.vscode/
```

!!! note "User Settings와 구분"

    User Settings의 JDK 절대경로는 Repository 밖에 있으므로
    `.gitignore`로 제외할 필요가 없다.

    Git은 JSON 내부의 특정 설정 Key가 아니라
    Repository 안의 파일을 관리한다.

---

## 9. 설정 완료 확인

Workspace 구성:

```text
.vscode/settings.json
→ Project 공통 설정

.vscode/extensions.json
→ Project 권장 Extension 목록

.vscode/NEWLY_CREATED_BY_SPRING_INITIALIZR
→ Spring Initializr 생성 Marker
→ 기존 파일 유지
```

확인:

- [ ] Project Root를 `microserver`로 열었다.
- [ ] Workspace Trust 상태를 확인했다.
- [ ] `.vscode/settings.json`을 생성했다.
- [ ] `.vscode/extensions.json`에 Project 권장 Extension 목록이 있다.
- [ ] `NEWLY_CREATED_BY_SPRING_INITIALIZR`가 기존에 존재한다면 삭제하지 않고 유지했다.
- [ ] `extensions.json`은 Extension 재설치가 아니라 Project 권장 목록임을 이해했다.
- [ ] `.vscode/settings.json`에 JDK 절대경로가 없다.
- [ ] `JAVA PROJECTS`에 `microserver`가 표시된다.
- [ ] `.vscode` 공통 설정 파일이 Git 공유 대상임을 확인했다.

다음 단계에서는 Java / Gradle / Spring Boot 인식 상태를 상세 확인하거나
Gradle Wrapper / Project Gradle 설정을 진행한다.
