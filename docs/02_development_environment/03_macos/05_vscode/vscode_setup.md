# macOS VS Code 개발환경 구성 원칙

## 1. 문서 목적

본 문서는 MicroServer macOS 개발환경에서 Visual Studio Code를 어떤 기준으로 설치하고 운영할지 정의한다.

Windows 최신 가이드와 동일하게 **설치 단계**와 **개발환경 설정 단계**를 분리한다. macOS에서도 VS Code 자체 설치, Portable Mode 구성, Editor 기본 설정을 먼저 완료한 뒤 Java / Spring Boot 개발환경을 구성한다.

---

## 2. MicroServer macOS VS Code 구성 방향

```text
~/local-microserver
├─ tools
│  ├─ jdk
│  │  └─ temurin-25
│  │     └─ Contents
│  │        └─ Home
│  ├─ gradle
│  │  └─ gradle-9.7.1
│  └─ vscode
│     ├─ Visual Studio Code.app
│     └─ code-portable-data
│        ├─ user-data
│        └─ extensions
├─ gradle-home
├─ workspace
└─ env
```

!!! important "JDK Directory와 JAVA_HOME 구분"
    JDK 보관 Directory는 `~/local-microserver/tools/jdk/temurin-25/Contents/Home`이지만 실제 `JAVA_HOME`은 다음 경로다.

    ```text
    ~/local-microserver/tools/jdk/temurin-25/Contents/Home
    ```

---

## 3. 전체 구성 순서

```mermaid
flowchart LR
    A[VS Code 설치] --> B[Portable Mode 설정]
    B --> C[VS Code 기본 설정]
    C --> D[VS Code 설정 방식 이해]
    D --> E[User Settings]
    E --> F[Java Extension]
    F --> G[Spring Boot Extension]
    G --> H[지원 Extension / Profile]
    H --> I[JDK 연계 및 운영]
```

## 4. 설정 범위 원칙

| 범위 | 용도 |
|---|---|
| Default Settings | VS Code 기본값 |
| User Settings | 해당 Portable VS Code 인스턴스 공통 설정 |
| Profile | 목적별 Extension / Settings 묶음 |
| Workspace Settings | 프로젝트별 공통 설정 |
| `.vscode` | 프로젝트에 포함할 VS Code 설정 |

현재 단계에서는 Portable VS Code의 User Settings와 Extension 환경을 준비한다. 실제 프로젝트별 `.vscode/settings.json` 구성은 프로젝트 생성 이후에 수행한다.

## 5. macOS Portable Mode 운영 원칙

- Windows: VS Code ZIP Directory 내부에 `data` Directory 생성
- macOS: `Visual Studio Code.app`의 **형제 Directory**로 `code-portable-data` 생성
- macOS Stable: `code-portable-data`
- macOS Insiders: `code-insiders-portable-data`

Portable Mode는 VS Code의 User Data와 Extension을 독립화하는 기능이다. JDK, Gradle, Git 등 외부 개발도구 자체를 설치하는 기능은 아니다.

## 6. MicroServer 운영 원칙

### 6.1 시스템 전역 설정 최소화
가능하면 개발환경을 `~/local-microserver` 아래에 모아 관리한다.

### 6.2 JDK 표준 경로
```text
JAVA_HOME
~/local-microserver/tools/jdk/temurin-25/Contents/Home
```

### 6.3 Gradle 프로젝트 Build는 Wrapper 우선
```bash
./gradlew build
```

### 6.4 개인 설정과 프로젝트 설정 분리
개인 UI 편의 설정은 User Settings 또는 Profile에 두고, 팀 전체가 공유해야 할 프로젝트 설정은 프로젝트 생성 이후 `.vscode`에서 관리한다.

## 7. 가이드 문서 구성

### VS Code 설치
1. `vscode_setup.md` — 개발환경 구성 원칙
2. `vscode_install.md` — macOS VS Code 설치
3. `vscode_portable_setup.md` — macOS Portable Mode 설정
4. `vscode_basic_settings.md` — VS Code 기본 설정

### VS Code 개발환경 설정
1. `vscode_configuration_model.md`
2. `vscode_user_settings.md`
3. `java_extension_setup.md`
4. `spring_boot_extension_setup.md`
5. `support_extension_profile_setup.md`
6. `jdk_workspace_environment_setup.md`

## 8. 완료 기준

- [ ] VS Code Application이 `~/local-microserver/tools/vscode` 아래에 있다.
- [ ] `code-portable-data`의 역할을 이해했다.
- [ ] 실제 `JAVA_HOME`이 `~/local-microserver/tools/jdk/temurin-25/Contents/Home`임을 이해했다.
- [ ] User Settings와 Workspace Settings의 역할을 구분할 수 있다.

## 9. 다음 단계

→ [macOS VS Code 설치](vscode_install.md)
