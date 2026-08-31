# 개발환경 구성 핵심원칙

## 1. 문서 목적

이 문서는 MicroServer 프로젝트 개발에 필요한 **표준 개발환경 구성 원칙과 운영 기준**을 정의한다.

개발환경은 Windows와 Apple Silicon 기반 macOS를 지원하며, 운영체제별 특성에 맞는 설치 및 실행 방식을 적용하면서도 다음 항목은 동일한 기준으로 구성한다.

- 개발환경 Directory 및 논리 구조
- JDK 및 Gradle Version 관리
- VS Code 개발환경 및 Extension 구성
- Git / GitHub Repository 운영
- Docker 및 Oracle 로컬 개발환경
- 개발환경 Package 구성 및 배포
- 프로젝트 Workspace 구성
- 개발환경 실행 및 운영 방식

특히 JDK, Gradle, VS Code, Settings, Extension 등 프로젝트에서 관리할 수 있는 개발도구와 설정을 **표준 Root Directory를 중심으로 구성**하여, 개발자별 환경 차이를 최소화하고 동일한 개발환경을 쉽게 구성·복원할 수 있도록 한다.

개발환경은 다음 세 가지 영역으로 구분하여 구성한다.

```text
개발환경 구성 핵심원칙
├─ Windows 개발환경 구성
└─ macOS 개발환경 구성 (Apple Silicon)
```

Windows와 macOS의 실제 설치 명령과 Directory는 분리하되,
개발환경의 **논리 구조, 구성 순서, Version 관리 원칙, Git Repository 경계, Portable 운영 방향**은 동일하게 유지한다.

## 2. 개발환경 구성 목표

MicroServer 개발환경은 특정 장비에 개발도구를 무작위로 설치하는 방식이 아니라,
프로젝트 표준 Root 아래에 가능한 구성요소를 모아 **재현 가능한 개발환경 Package**로 관리하는 것을 목표로 한다.

```text
개발환경 Package 준비
        ↓
표준 Root에 압축 해제
        ↓
초기 Setup Script
        ↓
VS Code Shortcut 생성
        ↓
전용 VS Code Launcher 실행
        ↓
JDK / Gradle / Portable VS Code / Workspace 연결
```

## 3. OS별 표준 Root

### Windows

```text
C:\local-microserver
```

### macOS Apple Silicon

```text
~/local-microserver
```

논리 구조는 동일하게 유지한다.

```text
local-microserver
├─ tools
│  ├─ jdk
│  ├─ gradle
│  └─ vscode
├─ gradle-home
├─ workspace
├─ env
└─ README.md
```

## 4. Portable 운영 범위

| 구성요소 | Windows | macOS Apple Silicon |
| --- | --- | --- |
| JDK | 압축 배포본 | AArch64 압축 배포본 |
| Gradle | Binary ZIP | Binary ZIP |
| VS Code | ZIP + `data` | App + `code-portable-data` |
| VS Code Settings / Extension | Portable Data | Portable Data |
| Gradle Cache | `gradle-home` | `gradle-home` |
| Git | 시스템/조직 표준 Git | Xcode CLT/조직 표준 Git |
| Docker Desktop | 별도 설치 | Apple Silicon용 별도 설치 |
| Oracle | Docker Container | ARM64 Docker Container |

!!! important "Portable의 의미"
    모든 프로그램을 무설치 형태로 만든다는 의미는 아니다.

    JDK, Gradle, VS Code, Settings, Extension, Workspace 등
    **프로젝트가 통제할 수 있는 개발환경을 Root에 모아 전달·복원 가능한 상태로 만드는 것**이 핵심이다.

    Docker Desktop처럼 OS 가상화/권한/서비스와 강하게 결합된 구성은 별도 설치 대상으로 둔다.

## 5. 개발환경 구성 순서

Windows와 macOS 모두 같은 순서로 구성한다.

```text
1. 프로젝트 로컬 개발환경 구성
2. Git / GitHub 환경 구성
3. JDK 설치 및 설정
4. Gradle 빌드환경 설치
5. VS Code 개발환경 설치
6. Docker 개발환경 설치
7. Oracle 개발환경 설치
```

## 6. Git Repository 경계

개발환경 Root 전체를 하나의 Git Repository로 만들지 않는다.

```text
workspace/
├─ microserver/.git
└─ microserver-docs/.git
```

JDK, Gradle, Portable VS Code, 개인 Secret은 Git Repository 바깥에서 관리한다.

## 7. 개발환경 Package 보안 기준

공용 Package에 포함하지 않는 항목:

```text
Password
GitHub Token
SSH Private Key
개인 인증서
local-env.ps1
local-env.sh
Oracle 실제 Data Volume
```

## 8. OS별 실행 UX

### Windows

```text
setup.ps1
→ create-vscode-shortcut.ps1
→ MicroServer VS Code.lnk
→ start-vscode.ps1
```

### macOS

```text
setup.command
→ create-vscode-shortcut.command
→ MicroServer VS Code.command
→ start-vscode.command
```

두 환경 모두 개발자는 최종적으로 **MicroServer 전용 Shortcut을 실행하여 VS Code를 시작**하도록 한다.

## 9. 개발 장비 구성 참고

MicroServer 개발환경을 구성하기 전에 개발 장비가 권장 사양과 운영체제 기준을 충족하는지 확인할 수 있다.
개발 장비의 권장 CPU, Memory, Storage, 운영체제, 필수 Software 및 기본 점검 항목은 다음 문서를 참고한다.

[개발 장비 구성 참고사항](../99_reference/development_device.md)
