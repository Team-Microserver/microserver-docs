# 프로젝트 JDK / VS Code 설정 확인 가이드

## 1. 문서 목적

본 문서는 JDK / VS Code 설정 후
MicroServer 프로젝트가 정상적으로 인식되는지 확인한다.

선행 문서:

→ [프로젝트 JDK / VS Code Workspace 설정](project_jdk_vscode_setup.md)

현재 단계에서는 **Build / Run을 수행하지 않는다.**

---

## 2. 확인 항목 요약

| 확인 항목 | 정상 기준 |
|---|---|
| Java Runtime | Java 25 / 올바른 JDK Home |
| Java Project | `JAVA PROJECTS`에 `microserver` |
| Gradle Project | Gradle View에 `microserver` |
| Spring Boot | Dashboard에 Application |
| Workspace 설정 | JDK 절대경로 없음 |
| Git | `.vscode` 공통 설정만 변경 |

---

## 3. Java Runtime 확인

Command Palette:

```text
Java: Configure Java Runtime
```

확인:

```text
Java Version : 25
JDK Home     : C:\local-microserver\tools\jdk\temurin-25
Project      : microserver
```

UI 이름이나 표시 방식은 Extension Version에 따라 달라질 수 있다.

핵심은 **Java 25와 올바른 JDK Home이 인식되는지**이다.

---

## 4. Java Project 자동 Import 확인

`JAVA PROJECTS` View:

```text
JAVA PROJECTS
└─ microserver
```

이렇게 보이면 자동 Import가 이미 완료된 상태이다.

따라서 다음 명령을 실행하지 않는다.

```text
Java: Import Java Projects in Workspace
```

### View 위치

`JAVA PROJECTS`는 Explorer 아래쪽에 표시될 수 있다.

화면 구성이 불편하면 다른 Sidebar 또는 Secondary Sidebar로 이동할 수 있다.

이것은 UI 배치만 변경하며 Java Project 인식 상태와 관계없다.

---

## 5. Gradle Project 확인

Gradle View 또는 `GRADLE PROJECTS` View에서:

```text
microserver
```

가 표시되는지 확인한다.

현재 단계에서는 Gradle Task를 실행하지 않는다.

---

## 6. Spring Boot Dashboard 확인

Spring Boot Dashboard에서 Application이 표시되는지 확인한다.

```text
Gradle Project 인식
        ↓
Java Project 인식
        ↓
Spring Boot Application 인식
        ↓
Dashboard 표시
```

!!! warning "아직 Run하지 않음"

    Application이 보이는지만 확인한다.

    실행은 이후 **초기 Build / Run 검증** 단계에서 수행한다.

---

## 7. Workspace 설정 확인

### `.vscode/settings.json`

다음과 유사해야 한다.

```json
{
  "files.encoding": "utf8",
  "java.configuration.updateBuildConfiguration": "automatic"
}
```

다음 값이 들어 있지 않은지 확인한다.

```text
C:\local-microserver\tools\jdk\temurin-25
java.configuration.runtimes
java.jdt.ls.java.home
```

### `.vscode/extensions.json`

권장 Extension 목록이 존재하는지 확인한다.

---

## 8. 문제가 있을 때만 수행

### Java Project가 보이지 않음

먼저 확인:

```text
Project Root를 정확히 열었는가?
build.gradle이 Root에 있는가?
settings.gradle이 Root에 있는가?
Java Extension이 설치되어 있는가?
Gradle for Java가 설치되어 있는가?
Workspace가 Trusted 상태인가?
```

모두 정상인데 Project가 보이지 않는 경우:

```text
Ctrl + Shift + P
→ Java: Import Java Projects in Workspace
```

### Java Language Server 문제

Cache 문제 등이 의심될 때:

```text
Ctrl + Shift + P
→ Java: Clean Java Language Server Workspace
```

!!! warning "정상 상태에서는 실행하지 않음"

    위 명령들은 문제 해결용이다.

---

## 9. Git 변경사항 확인

Project Root:

```text
C:\local-microserver\workspace\microserver
```

실행:

```powershell
git status
```

이번 단계의 주요 변경:

```text
.vscode/settings.json
.vscode/extensions.json
```

User Settings의 JDK 경로는 Repository 밖에 있으므로
`git status`에 나타나지 않는 것이 정상이다.

---

## 10. Commit

```powershell
git add .vscode/settings.json .vscode/extensions.json
git status
```

```powershell
git commit -m "chore: configure VS Code workspace"
```

```powershell
git push
```

---

## 11. 완료 체크리스트

### 설정

- [ ] `build.gradle`에 `JavaLanguageVersion.of(25)`가 있다.
- [ ] User Settings에 Java 25 Runtime이 등록되어 있다.
- [ ] `.vscode/settings.json`에 공통 설정이 있다.
- [ ] `.vscode/extensions.json`에 권장 Extension이 있다.
- [ ] `.vscode/settings.json`에 JDK 절대경로가 없다.

### 인식

- [ ] `Java: Configure Java Runtime`에서 Java 25를 확인했다.
- [ ] `JAVA PROJECTS`에 `microserver`가 보인다.
- [ ] Gradle View에 `microserver`가 보인다.
- [ ] Spring Boot Dashboard에 Application이 보인다.
- [ ] 정상 상태에서는 수동 Import를 실행하지 않았다.

### Git

- [ ] `.vscode/settings.json`이 Git 관리 대상이다.
- [ ] `.vscode/extensions.json`이 Git 관리 대상이다.
- [ ] User Settings의 JDK 경로는 Git 대상이 아니다.
- [ ] Commit / Push를 완료했다.

---

## 12. 다음 단계

→ [Gradle Wrapper 및 프로젝트 Gradle 설정](project_gradle_setup.md)

```text
JDK / VS Code 개념
        ↓
JDK / VS Code 실제 설정
        ↓
JDK / VS Code 설정 확인        ← 현재
        ↓
Gradle Wrapper / Gradle 설정
        ↓
초기 Build / Run 검증
```
