# Java / Gradle / Spring Boot 인식 확인

## 1. 목적

이 문서는 앞 단계의 설정을 다시 설명하지 않고 **VS Code가 Project를 정상 인식했는지만 검증**한다.

이 단계에서는 Build 또는 Application Run을 수행하지 않는다.

---

## 2. 확인 순서

```text
Java Runtime
    ↓
JAVA PROJECTS
    ↓
GRADLE PROJECTS
    ↓
Spring Boot Dashboard
```

---

## 3. Java Runtime 확인

Command Palette:

```text
Windows / Linux : Ctrl + Shift + P
macOS           : Cmd + Shift + P
```

실행:

```text
Java: Configure Java Runtime
```

확인:

```text
Java Version → 25
Project      → microserver
```

JDK가 잘못 인식되면 Project Settings에 절대경로를 추가하지 말고 Launcher 실행환경부터 확인한다.

→ [프로젝트 JDK / VS Code Workspace 설정](project_jdk_vscode_setup.md)

---

## 4. Java Project 확인

`JAVA PROJECTS` View:

```text
JAVA PROJECTS
└─ microserver
```

보이면 정상 Import 상태다.

정상 상태에서는 다음 명령을 실행하지 않는다.

```text
Java: Import Java Projects in Workspace
```

---

## 5. Gradle Project 확인

Gradle View 또는 `GRADLE PROJECTS`에서 확인한다.

```text
GRADLE PROJECTS
└─ microserver
```

여기서는 Task를 실행하지 않는다.

---

## 6. Spring Boot 확인

Spring Boot Dashboard에서 MicroServer Application이 표시되는지 확인한다.

```text
Java Project 인식
        ↓
Gradle Project 인식
        ↓
Spring Boot Application 인식
```

표시 여부만 확인하고 Run / Debug는 아직 수행하지 않는다.

---

## 7. 문제가 있을 때

### Java Project가 보이지 않는 경우

다음 순서로 확인한다.

```text
1. microserver Project Root를 열었는가?
2. Workspace가 Trusted 상태인가?
3. build.gradle / settings.gradle이 Root에 있는가?
4. Java Extension이 설치되어 있는가?
5. Gradle for Java가 설치되어 있는가?
6. Launcher로 VS Code를 실행했는가?
7. Integrated Terminal의 java --version이 Java 25인가?
```

모두 정상인데도 인식되지 않을 때만:

```text
Java: Import Java Projects in Workspace
```

Java 분석 상태가 계속 비정상일 때 최종 문제 해결 수단으로:

```text
Java: Clean Java Language Server Workspace
```

---

## 8. 완료 체크리스트

- [ ] Java Runtime이 Java 25다.
- [ ] `JAVA PROJECTS`에 `microserver`가 표시된다.
- [ ] Gradle View에 `microserver`가 표시된다.
- [ ] Spring Boot Dashboard에 Application이 표시된다.
- [ ] 정상 상태에서 수동 Import / Clean을 반복하지 않았다.
- [ ] 아직 Build / Run을 수행하지 않았다.

다음 단계:

→ [Gradle Wrapper 확인 및 Build 기준](project_gradle_setup.md)
