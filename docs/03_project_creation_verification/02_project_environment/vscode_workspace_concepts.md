# VS Code Workspace / User Settings 구조

## 1. 목적

VS Code의 User Settings와 Workspace Settings를 어디에 사용해야 하는지 설명한다.

## 2. 설정 범위

```text
User Settings
→ 특정 개발자 / 특정 PC

Workspace Settings
→ 특정 Project / 팀 공유
```

MicroServer에서는 Repository의 `.vscode/settings.json`을 Workspace 공통 설정으로 사용한다.

## 3. Git 공유 기준

공유하기 좋은 값:

```text
Encoding
Format 정책
Build Configuration 갱신 정책
Null Analysis 정책
권장 Extension
```

공유하면 안 되는 값:

```text
개발자 Home Directory
Windows / macOS 절대경로
개인 JDK 경로
Credential
개인 UI 취향
```

## 4. `extensions.json`

`extensions.json`은 Extension을 설치하는 Script가 아니라 Project의 권장 Extension 목록이다.

새 개발자는 Repository를 Clone한 뒤 Project에 필요한 Extension을 쉽게 확인할 수 있다.

## 5. Workspace Trust

Workspace Trust는 Java Version이나 Git 권한 설정이 아니다. Project 내부 Script, Task, Extension 기능의 실행을 허용할지 결정하는 VS Code 보안 기능이다.

## 6. Java Project Import

Project Root를 열면 Extension이 Build Script를 분석해 Project Model을 만든다. 정상적으로 자동 Import되면 수동 Import 명령을 반복할 필요가 없다.
