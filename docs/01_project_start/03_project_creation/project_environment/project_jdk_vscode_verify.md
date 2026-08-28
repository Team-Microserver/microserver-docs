# 프로젝트 JDK / VS Code 통합 인식 확인 가이드

## 1. 문서 목적

본 문서는 앞 단계에서 구성한 **VS Code User Settings**와 **Workspace Settings**가
MicroServer Project에서 정상적으로 적용되고 있는지 최종 확인한다.

선행 문서:

- → [VS Code User Settings](vscode_user_settings.md)
- → [VS Code Workspace Settings](vscode_workspace_settings.md)

앞 문서에서 이미 다음 설정을 완료했다.

```text
VS Code User Settings
→ Java 25 Runtime / JDK Home 등록
→ 개발자 개인 JDK 경로 관리

VS Code Workspace Settings
→ .vscode/settings.json
→ .vscode/extensions.json
→ Project 공통 설정 및 권장 Extension 관리
→ Java Project 자동 Import 개념 확인
```

따라서 이 문서에서는 동일한 설정 방법을 다시 설명하지 않는다.

현재 단계의 목적은 다음 네 가지가 **실제로 정상 인식되는지 확인하는 것**이다.

```text
Java Runtime
        ↓
Java Project
        ↓
Gradle Project
        ↓
Spring Boot Application
```

!!! important "현재 문서는 설정 문서가 아니라 검증 문서"

    설정값을 새로 작성하거나 다시 구성하는 단계가 아니다.

    문제가 발견되면 해당 설정을 설명하는 선행 문서로 돌아가 수정한 후
    다시 이 문서의 확인 절차를 수행한다.

!!! warning "현재 단계에서는 Build / Run을 수행하지 않음"

    이 문서에서는 VS Code가 Project를 정상적으로 인식하는지만 확인한다.

    실제 Gradle Build와 Spring Boot Run은 이후 단계에서 별도로 검증한다.

---

## 2. 문서별 역할 구분

세 문서의 역할을 다음처럼 구분한다.

| 문서 | 주요 역할 | 설정 변경 |
|---|---|---|
| VS Code User Settings | 개발 PC의 Java Runtime / JDK Home 관리 | O |
| VS Code Workspace Settings | Project 공통 VS Code 설정 / 권장 Extension 관리 | O |
| **현재 문서** | Java / Gradle / Spring Boot 통합 인식 상태 확인 | **원칙적으로 X** |

쉽게 구분하면:

```text
User Settings
→ 내 PC의 JDK는 어디에 있는가?

Workspace Settings
→ 이 Project에서 어떤 VS Code 설정을 공유할 것인가?

현재 문서
→ 앞의 설정 결과로 Project가 정상 인식되는가?
```

---

## 3. 전체 확인 흐름

```mermaid
flowchart LR
    A["Project Root Open"] --> B["Java Runtime 확인"]
    B --> C["JAVA PROJECTS 확인"]
    C --> D["Gradle Project 확인"]
    D --> E["Spring Boot Dashboard 확인"]
    E --> F["Workspace / Git 상태 확인"]
```

정상 완료 기준:

| 확인 항목 | 정상 기준 |
|---|---|
| Java Runtime | Java 25 / 올바른 JDK Home |
| Java Project | `JAVA PROJECTS`에 `microserver` 표시 |
| Gradle Project | Gradle View에 `microserver` 표시 |
| Spring Boot | Spring Boot Dashboard에 Application 표시 |
| Workspace | 공통 설정 존재 / 개인 JDK 절대경로 없음 |
| Git | Project 공통 설정만 Repository 변경사항으로 관리 |

---

## 4. Project Root 확인

VS Code에서 다음 Directory를 Project Root로 열어 둔 상태인지 확인한다.

```text
C:\local-microserver\workspace\microserver
```

정상:

```text
O C:\local-microserver\workspace\microserver
```

잘못된 예:

```text
X C:\local-microserver\workspace
```

Explorer에서 최소한 다음 Project 파일을 확인할 수 있어야 한다.

```text
microserver
├─ .vscode/
├─ gradle/
├─ src/
├─ build.gradle
├─ settings.gradle
├─ gradlew
└─ gradlew.bat
```

!!! note "Project Root 설정 방법은 반복하지 않음"

    Project Root를 여는 방법과 Workspace Trust에 대한 상세 설명은
    [VS Code Workspace Settings](vscode_workspace_settings.md)를 참고한다.

---

## 5. Java Runtime 확인

Command Palette를 연다.

```text
Ctrl + Shift + P
```

다음 명령을 실행한다.

```text
Java: Configure Java Runtime
```

현재 MicroServer 기준으로 다음 내용을 확인한다.

```text
Java Version : 25
JDK Home     : C:\local-microserver\tools\jdk\temurin-25
Project      : microserver
```

UI의 이름이나 표시 위치는 Java Extension Version에 따라 일부 달라질 수 있다.

핵심 확인 항목은 다음 두 가지다.

```text
Java Version
→ 25

JDK Home
→ C:\local-microserver\tools\jdk\temurin-25
```

!!! important "Runtime이 잘못된 경우"

    이 화면에서 임의로 Project 설정을 추가하기보다
    [VS Code User Settings](vscode_user_settings.md)의
    `java.configuration.runtimes` 설정을 먼저 확인한다.

    Project Java Version 자체의 기준은 계속 `build.gradle`의 Java Toolchain이다.

---

## 6. Java Project 인식 확인

VS Code의 `JAVA PROJECTS` View를 확인한다.

정상 예:

```text
JAVA PROJECTS
└─ microserver
```

`microserver`가 표시되면
VS Code Java Extension이 현재 Project를 Java Project로 정상 인식한 상태이다.

앞의 Workspace Settings 문서에서 설명한 것처럼
여기서 말하는 **Import**는 Project 파일을 복사하거나 가져오는 작업이 아니다.

```text
Project Root Open
        ↓
build.gradle / settings.gradle 감지
        ↓
Project 구조 분석
        ↓
Java Project Model 생성
        ↓
JAVA PROJECTS에 표시
```

!!! important "정상 상태에서는 수동 Import하지 않음"

    `JAVA PROJECTS`에 `microserver`가 이미 보이면 다음 명령은 실행하지 않는다.

    ```text
    Java: Import Java Projects in Workspace
    ```

    이 명령은 자동 인식이 되지 않는 경우에만 문제 해결용으로 사용한다.

---

## 7. Gradle Project 인식 확인

Gradle View 또는 `GRADLE PROJECTS` View를 확인한다.

정상 예:

```text
GRADLE PROJECTS
└─ microserver
```

확인할 사항:

- `microserver` Project가 표시되는가?
- Gradle 관련 View가 정상적으로 열리는가?
- Project 인식 오류가 표시되지 않는가?

현재 단계에서는 Gradle Task를 실행하지 않는다.

```text
현재 단계
→ Gradle Project 인식 확인

다음 단계
→ Gradle Wrapper / Project Gradle 설정

이후 단계
→ 실제 Gradle Build
```

---

## 8. Spring Boot Application 인식 확인

Spring Boot Dashboard를 확인한다.

정상적인 경우 MicroServer Spring Boot Application이 Dashboard에 표시된다.

개념적으로:

```text
Project Root Open
        ↓
Java / Gradle Project 인식
        ↓
Spring Boot Application 구조 인식
        ↓
Spring Boot Dashboard에 Application 표시
```

!!! warning "아직 Application을 실행하지 않음"

    현재는 Application이 Dashboard에 표시되는지만 확인한다.

    `Run`, `Debug`, `Start` 등 실제 실행은
    이후 **초기 Build / Run 검증** 단계에서 수행한다.

---

## 9. Workspace 설정 결과 확인

Workspace Settings의 상세 설정값은 앞 문서에서 이미 구성했으므로
이 문서에서는 **결과만 간단히 확인**한다.

Project Root:

```text
microserver/
└─ .vscode/
   ├─ settings.json
   └─ extensions.json
```

확인:

- `.vscode/settings.json`이 존재한다.
- `.vscode/extensions.json`이 존재한다.
- `settings.json`에 Project 공통 설정이 들어 있다.
- 개발자 개인 JDK 절대경로가 `settings.json`에 들어 있지 않다.

현재 권장 Workspace 정책 기준으로는 다음 설정이 관리된다.

```text
files.encoding
java.configuration.updateBuildConfiguration
java.compile.nullAnalysis.mode
```

반면 다음 항목은 Project Workspace 설정에 두지 않는다.

```text
java.configuration.runtimes
java.jdt.ls.java.home
C:\local-microserver\tools\jdk\temurin-25
```

이 항목들은 VS Code User Settings의 영역이다.

!!! note "설정 내용이 다르면"

    이 문서에서 설정 방법을 다시 설명하지 않는다.

    [VS Code Workspace Settings](vscode_workspace_settings.md)에서
    Project 공통 설정 기준을 확인한다.

---

## 10. 문제가 있을 때만 확인

정상 상태에서는 아래 명령을 실행할 필요가 없다.

### 10.1 Java Project가 보이지 않음

먼저 다음 항목을 확인한다.

```text
Project Root를 microserver로 정확히 열었는가?
build.gradle이 Root에 있는가?
settings.gradle이 Root에 있는가?
Java Extension이 설치되어 있는가?
Gradle for Java가 설치되어 있는가?
Workspace가 Trusted 상태인가?
Java 25 Runtime이 정상 등록되어 있는가?
```

위 항목이 정상인데도 `JAVA PROJECTS`에 Project가 표시되지 않는 경우:

```text
Ctrl + Shift + P
→ Java: Import Java Projects in Workspace
```

수동 Import는 **자동 인식 실패 시에만** 수행한다.

### 10.2 Java Language Server 상태가 이상함

다음과 같은 현상이 지속될 때만 검토한다.

```text
Java Source 분석이 되지 않음
자동완성이 동작하지 않음
정상 Source에 지속적인 Java 오류 표시
JAVA PROJECTS가 갱신되지 않음
```

마지막 문제 해결 수단으로:

```text
Ctrl + Shift + P
→ Java: Clean Java Language Server Workspace
```

!!! warning "정상 상태에서는 실행하지 않음"

    `Java: Import Java Projects in Workspace`와
    `Java: Clean Java Language Server Workspace`는
    일상적인 설정 절차가 아니라 **문제 해결 명령**이다.

---

## 11. Import와 Build 구분

Java Project가 정상 인식되었다고 해서
Gradle Build까지 성공했다는 의미는 아니다.

```text
Java Project Import
→ VS Code가 Project 구조를 IDE에서 인식

Gradle Build
→ Source Compile / Test / Resource 처리 등 실제 Build 수행
```

따라서:

```text
JAVA PROJECTS에 microserver 표시
        ≠
gradlew build 성공
```

현재 문서에서는 왼쪽의 **Project 인식 상태**까지만 확인한다.

실제 Build 검증은 이후 단계에서 수행한다.

---

## 12. Git 변경사항 확인

Project Root에서 다음 명령을 실행한다.

```powershell
git status
```

앞 단계에서 Workspace 설정 파일을 새로 생성하거나 수정했다면
대표적으로 다음 파일이 변경사항으로 표시될 수 있다.

```text
.vscode/settings.json
.vscode/extensions.json
```

반면 VS Code User Settings에 등록한 다음 설정은
Project Repository 밖에 있으므로 `git status`에 나타나지 않는 것이 정상이다.

```text
java.configuration.runtimes
java.jdt.ls.java.home
```

즉:

```text
VS Code User Settings
→ 개발자 개인 설정
→ Repository 밖
→ Git 대상 아님

.vscode/settings.json
.vscode/extensions.json
→ Project 공통 설정
→ Repository 안
→ Git 공유
```

---

## 13. Commit / Push

현재 단계까지의 Workspace 설정을 아직 Commit하지 않았다면
변경사항을 확인한 후 Commit한다.

```powershell
git add .vscode/settings.json .vscode/extensions.json
git status
```

Commit:

```powershell
git commit -m "chore: configure VS Code workspace"
```

Remote Repository 반영:

```powershell
git push
```

!!! note "이미 앞 단계에서 Commit했다면"

    동일 내용을 다시 Commit할 필요는 없다.

    `git status`가 clean 상태라면 그대로 다음 단계로 진행한다.

---

## 14. 완료 체크리스트

### Project / Runtime

- [ ] VS Code에서 `microserver` Project Root를 열었다.
- [ ] Java Runtime이 Java 25로 인식된다.
- [ ] JDK Home이 `C:\local-microserver\tools\jdk\temurin-25`로 확인된다.

### Project 인식

- [ ] `JAVA PROJECTS`에 `microserver`가 표시된다.
- [ ] Gradle View에 `microserver`가 표시된다.
- [ ] Spring Boot Dashboard에 Application이 표시된다.
- [ ] 정상 상태에서 수동 Java Import를 실행하지 않았다.

### Workspace / Git

- [ ] `.vscode/settings.json`이 존재한다.
- [ ] `.vscode/extensions.json`이 존재한다.
- [ ] Workspace Settings에 개발자 개인 JDK 절대경로가 없다.
- [ ] User Settings의 JDK 경로가 Git 대상이 아님을 확인했다.
- [ ] 필요한 Workspace 변경사항을 Commit / Push했다.

### 현재 단계 범위

- [ ] Gradle Task를 실행하지 않았다.
- [ ] Spring Boot Application을 아직 Run하지 않았다.
- [ ] Project 인식 확인과 실제 Build 검증의 차이를 이해했다.

---

## 15. 다음 단계

현재 단계까지 완료되면
VS Code에서 MicroServer Project를 개발하기 위한 기본 IDE 인식 상태가 준비된 것이다.

다음 단계:

→ [Gradle Wrapper 및 프로젝트 Gradle 설정](project_gradle_setup.md)

```text
VS Code User Settings
        ↓
VS Code Workspace Settings
        ↓
JDK / Java / Gradle / Spring Boot 통합 인식 확인    ← 현재
        ↓
Gradle Wrapper / Project Gradle 설정
        ↓
초기 Build / Run 검증
```
