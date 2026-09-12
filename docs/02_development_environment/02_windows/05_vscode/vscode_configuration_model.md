# VS Code 설정 방식 이해

## 1. 문서 목적

VS Code는 Eclipse나 IntelliJ IDEA와 비교하면 설정과 기능 실행 방식이 다르게 느껴질 수 있다.

특히 Eclipse 환경에 익숙한 개발자는 다음과 같은 차이에서 혼란을 느끼기 쉽다.

- 설정값을 화면의 입력창이나 체크박스에서만 관리하지 않는다.
- 많은 기능이 **Command Palette**를 통해 실행된다.
- 설정값의 실제 내용은 `settings.json` 파일로 관리할 수 있다.
- 프로젝트별 설정은 `.vscode` 디렉터리의 파일로 관리한다.
- Extension이 추가될수록 Command Palette와 설정 항목도 확장된다.

이 문서는 VS Code의 설정 구조를 먼저 이해하고, 이후 진행되는 User Settings, Java/Spring Extension, JDK Runtime, Workspace 설정 문서를 자연스럽게 이해할 수 있도록 하는 것을 목적으로 한다.

---

## 2. Eclipse와 VS Code의 설정 방식 차이

Eclipse는 IDE 내부의 메뉴와 설정 화면을 중심으로 환경을 구성한다.

```text
Eclipse

Window
 └─ Preferences
     ├─ Java
     ├─ Installed JREs
     ├─ Compiler
     ├─ Maven
     └─ Gradle

Project
 └─ Properties
     ├─ Java Build Path
     ├─ Java Compiler
     └─ Run / Debug
```

반면 VS Code는 하나의 설정 화면에 모든 기능을 집중시키지 않는다.

```text
VS Code

Settings UI
     │
     ├─ 사용자 설정
     ├─ Workspace 설정
     └─ Extension 설정
     │
     ▼
settings.json

Command Palette
     │
     ├─ VS Code 명령 실행
     ├─ Java 명령 실행
     ├─ Gradle 명령 실행
     └─ Extension 명령 실행

.vscode/
     ├─ settings.json
     ├─ extensions.json
     ├─ launch.json
     └─ tasks.json
```

따라서 VS Code를 사용할 때는 **설정값 관리**와 **명령 실행**을 구분해서 이해하는 것이 중요하다.

---

## 3. VS Code 설정의 핵심 구성

VS Code 개발환경은 크게 다음 네 가지 구성으로 이해하면 된다.

| 구분 | 역할 | 대표 사용 예 |
|---|---|---|
| Settings UI | 설정값을 GUI에서 조회/변경 | Editor, Terminal, Java 설정 |
| `settings.json` | 설정값을 파일 형태로 관리 | JDK 경로, Formatter, Editor 설정 |
| Command Palette | VS Code와 Extension의 명령 실행 | Java Runtime 설정, Project Refresh |
| `.vscode` | 프로젝트별 개발환경 설정 | Workspace 설정, Debug, Task |

!!! note "핵심"
    Command Palette는 단순한 설정 화면이 아니다.  
    **설정 변경뿐 아니라 VS Code와 Extension이 제공하는 기능을 실행하는 명령 인터페이스**이다.

---

## 4. Settings UI

Settings UI는 VS Code의 설정값을 화면에서 조회하고 변경할 수 있는 GUI 환경이다.

### 실행

Windows:

```text
Ctrl + ,
```

macOS:

```text
Command + ,
```

또는 Command Palette에서 다음 명령을 실행한다.

```text
Preferences: Open Settings (UI)
```

Settings 화면에서는 검색을 이용해 원하는 설정을 찾는 방식이 일반적이다.

예:

```text
java
gradle
terminal
editor
font
format
```

예를 들어 Java 관련 설정을 검색하면 Java Extension이 제공하는 다양한 설정 항목을 확인할 수 있다.

---

## 5. settings.json

Settings UI에서 변경한 대부분의 설정은 내부적으로 `settings.json` 형태의 설정값으로 관리된다.

예:

```json
{
    "editor.fontSize": 14,
    "editor.formatOnSave": true,
    "files.autoSave": "afterDelay"
}
```

Java Runtime을 직접 지정하는 경우 다음과 같은 형태가 될 수 있다.

```json
{
    "java.configuration.runtimes": [
        {
            "name": "JavaSE-21",
            "path": "C:\\local-microserver\\tools\\jdk\\temurin-21",
            "default": true
        }
    ]
}
```

macOS에서는 경로 표현만 달라진다.

```json
{
    "java.configuration.runtimes": [
        {
            "name": "JavaSE-21",
            "path": "/Users/<USER>/local-microserver/tools/jdk/temurin-21",
            "default": true
        }
    ]
}
```

!!! tip "GUI와 JSON은 서로 다른 설정 체계가 아니다"
    Settings UI와 `settings.json`은 별개의 설정 방식이 아니다.

    Settings UI는 설정을 편하게 변경하기 위한 GUI이며,  
    `settings.json`은 동일한 설정을 파일 형태로 직접 관리하는 방식이다.

---

## 6. Command Palette

Command Palette는 VS Code 사용에서 매우 중요한 기능이다.

### 실행

Windows:

```text
Ctrl + Shift + P
```

macOS:

```text
Command + Shift + P
```

Command Palette에서는 VS Code 자체 기능뿐 아니라 설치된 Extension의 명령도 함께 실행할 수 있다.

Java Extension이 설치되어 있다면 다음과 같은 명령을 사용할 수 있다.

```text
Java: Configure Java Runtime
Java: Clean Java Language Server Workspace
Java: Import Java Projects
Java: Open Java Formatter Settings
```

Gradle Extension을 설치하면 다음과 같은 명령이 추가될 수 있다.

```text
Gradle: Refresh Gradle Project
Gradle: Run a Gradle Build
```

즉 Extension을 설치하면 VS Code의 기능이 다음과 같이 확장된다.

```text
VS Code
   │
   ├─ 기본 Command
   │
   ├─ Java Extension
   │      └─ Java Command
   │
   ├─ Spring Boot Extension
   │      └─ Spring Command
   │
   └─ Gradle Extension
          └─ Gradle Command
```

---

## 7. Command Palette와 Settings의 차이

처음 VS Code를 사용할 때 가장 많이 혼동하는 부분이다.

### Settings

설정값을 변경한다.

예:

```text
Editor Font Size = 14
Format On Save = true
Java Runtime Path = ...
```

### Command Palette

기능이나 작업을 실행한다.

예:

```text
Java: Configure Java Runtime
Java: Clean Java Language Server Workspace
Developer: Reload Window
Git: Clone
Terminal: Create New Terminal
```

따라서 다음과 같이 이해하면 된다.

```text
Settings
    ↓
환경의 상태와 값을 정의

Command Palette
    ↓
특정 기능이나 작업을 실행
```

---

## 8. User Settings와 Workspace Settings

VS Code 설정은 적용 범위에 따라 구분된다.

```text
User Settings
      │
      ├─ VS Code 사용자 전체에 적용
      │
      ▼
Workspace Settings
      │
      ├─ 특정 Workspace에 적용
      │
      ▼
Project Settings
```

### User Settings

사용자의 VS Code 전체 환경에 적용된다.

대표적인 설정:

- 글꼴
- Theme
- Terminal 기본 Profile
- Editor 표시 방식
- 개인 편의 기능

### Workspace Settings

현재 프로젝트 또는 Workspace에만 적용된다.

보통 다음 위치에서 관리한다.

```text
.vscode/settings.json
```

대표적인 설정:

- 프로젝트 JDK
- Formatter
- Java Compiler 관련 설정
- 프로젝트별 파일 제외 설정
- 프로젝트별 Extension 동작 설정

---

## 9. .vscode 디렉터리

프로젝트 루트에 `.vscode` 디렉터리를 만들면 프로젝트 단위 VS Code 개발환경을 구성할 수 있다.

```text
microserver/
├─ .vscode/
│  ├─ settings.json
│  ├─ extensions.json
│  ├─ launch.json
│  └─ tasks.json
├─ src/
├─ build.gradle
├─ settings.gradle
└─ gradlew
```

각 파일의 역할은 다음과 같다.

| 파일 | 역할 |
|---|---|
| `settings.json` | 프로젝트별 VS Code 설정 |
| `extensions.json` | 프로젝트 권장 Extension 정의 |
| `launch.json` | 실행 및 Debug 설정 |
| `tasks.json` | Build, Test 등 Task 정의 |

이를 Git Repository에서 함께 관리하면 개발자가 프로젝트를 Clone한 이후 동일한 개발환경을 빠르게 구성할 수 있다.

---

## 10. Eclipse와 VS Code 대응 관계

Eclipse 경험이 있는 개발자는 다음과 같이 대응하여 이해하면 편하다.

| Eclipse | VS Code |
|---|---|
| Preferences | Settings UI / User `settings.json` |
| Project Properties | Workspace `.vscode/settings.json` |
| Installed JREs | Java Runtime 설정 |
| Run Configuration | `.vscode/launch.json` |
| External Tools / Builder | `.vscode/tasks.json` |
| Plug-ins | Extensions |
| Perspective / View | Activity Bar / Panel / View |
| 각종 메뉴 기능 | Command Palette |
| Workspace | Folder / Multi-root Workspace |

완전히 동일한 개념은 아니지만 기존 Eclipse 개발자가 VS Code의 구조를 이해하는 데 유용한 기준이 된다.

---

## 11. MicroServer 개발환경의 설정 원칙

MicroServer 프로젝트에서는 VS Code 설정을 다음 원칙으로 관리한다.

### 11.1 개인 편의 설정은 User Settings로 관리

다음과 같이 개발자 개인 취향에 해당하는 설정은 User Settings에서 관리한다.

```text
Theme
Font
Terminal 표시 방식
Editor Zoom
개인 Key Binding
```

### 11.2 프로젝트 표준 설정은 Workspace에서 관리

프로젝트 구성원에게 동일하게 적용되어야 하는 설정은 프로젝트 설정으로 관리한다.

```text
.vscode/
├─ settings.json
├─ extensions.json
├─ launch.json
└─ tasks.json
```

### 11.3 가능한 설정은 파일로 명시

프로젝트 표준 개발환경을 재현할 수 있도록 중요한 설정은 GUI 클릭에만 의존하지 않고 파일로 명시한다.

```text
개발환경 표준
      │
      ├─ JDK Version
      ├─ Extension
      ├─ Formatter
      ├─ Build / Test Task
      └─ Debug 환경
      │
      ▼
.vscode 설정 파일
      │
      ▼
Git Repository
      │
      ▼
개발자 환경 재현
```

### 11.4 Command Palette는 작업 실행에 활용

Command Palette는 모든 설정을 직접 입력하는 장소가 아니라 다음과 같은 작업 수행에 활용한다.

- Java Runtime 확인
- Java Language Server 초기화
- Gradle Project Refresh
- VS Code Reload
- Git 명령 실행
- Extension 명령 실행

---

## 12. 권장 사용 방식

VS Code에 익숙하지 않은 초기에는 다음 순서로 사용하는 것을 권장한다.

### 설정값을 변경하고 싶을 때

```text
Settings UI 검색
        ↓
필요한 설정 확인
        ↓
프로젝트 표준 설정이면 settings.json 확인
```

### 특정 기능을 실행하고 싶을 때

```text
Command Palette 실행
        ↓
Java / Gradle / Git 등 키워드 검색
        ↓
원하는 Command 실행
```

### 프로젝트 표준 설정을 만들 때

```text
User Settings와 Workspace Settings 구분
        ↓
공통 설정은 .vscode에 정의
        ↓
Git으로 관리
```

---

## 13. 정리

VS Code는 Eclipse처럼 모든 설정과 기능을 하나의 GUI 메뉴 체계에서 제공하는 IDE가 아니다.

대신 다음 요소를 조합하여 개발환경을 구성한다.

```text
VS Code 개발환경

Settings UI
     +
settings.json
     +
Command Palette
     +
Extension
     +
.vscode
     │
     ▼
재현 가능한 프로젝트 개발환경
```

처음에는 Command Palette와 JSON 기반 설정 방식이 Eclipse보다 불편하게 느껴질 수 있다.

하지만 프로젝트의 표준 설정을 파일로 관리하고 Git Repository에 포함할 수 있기 때문에 여러 개발자의 환경을 동일하게 유지해야 하는 프로젝트에서는 강력한 장점이 된다.

MicroServer 프로젝트에서는 이러한 VS Code의 특성을 활용하여 **개발자가 개별 설정 방법을 모두 알지 못하더라도 표준 개발환경을 동일하게 사용할 수 있도록 구성하는 것**을 목표로 한다.

---

## 다음 문서

이 문서를 이해한 후 다음 단계로 진행한다.

1. VS Code User Settings
2. Java 개발 Extension 구성
3. Spring Boot Extension 구성
4. 개발 지원 Extension 및 Profile 구성
5. JDK 연계 및 개발환경 운영
