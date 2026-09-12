# macOS VS Code Portable 설정

## 1. 문서 목적

본 문서는 `~/local-microserver/tools/vscode`에 설치한 VS Code를 macOS Portable Mode로 구성하는 방법을 설명한다.

## 2. macOS Portable Mode 구조

```text
~/local-microserver/tools/vscode/
├─ Visual Studio Code.app
└─ code-portable-data/
   ├─ user-data/
   └─ extensions/
```

!!! important "Windows와 구조가 다름"
    Windows ZIP Portable Mode에서는 VS Code Directory 내부에 `data`를 만든다.

    macOS에서는 `Visual Studio Code.app`의 **형제 Directory**로 `code-portable-data`를 만들어야 한다.

Stable은 `code-portable-data`, Insiders는 `code-insiders-portable-data`를 사용한다.

## 3. Portable Directory 생성

VS Code를 완전히 종료한 뒤:

```bash
mkdir -p "$HOME/local-microserver/tools/vscode/code-portable-data"
```

확인:

```bash
ls -la "$HOME/local-microserver/tools/vscode"
```

## 4. Portable Mode 실행 및 확인

```bash
open "$HOME/local-microserver/tools/vscode/Visual Studio Code.app"
```

실행 후:

```bash
find "$HOME/local-microserver/tools/vscode/code-portable-data"   -maxdepth 2 -type d
```

Portable 환경에서는 User Data와 Extension이 `code-portable-data` 아래에서 관리된다.

## 5. 기존 VS Code 환경 Migration

기존 macOS User Data:

```text
~/Library/Application Support/Code
```

기존 Extension:

```text
~/.vscode/extensions
```

Migration 시 Portable 구조:

```text
code-portable-data/
├─ user-data/
└─ extensions/
```

!!! warning "배포용 환경"
    개인이 장기간 사용한 User Data를 그대로 팀 배포 Package로 만들지 않는다. 개인 Profile, 로그인 상태, UI 상태 등이 포함될 수 있으므로 배포용 Portable Instance는 별도로 깨끗하게 구성한다.

## 6. quarantine 문제

Portable Mode가 동작하지 않을 때:

```bash
xattr "$HOME/local-microserver/tools/vscode/Visual Studio Code.app"
```

필요 시:

```bash
xattr -dr com.apple.quarantine   "$HOME/local-microserver/tools/vscode/Visual Studio Code.app"
```

## 7. MicroServer 실행 Script

```bash
#!/bin/zsh

export LOCAL_MICROSERVER="$HOME/local-microserver"
export JAVA_HOME="$LOCAL_MICROSERVER/tools/jdk/temurin-25/Contents/Home"
export GRADLE_HOME="$LOCAL_MICROSERVER/tools/gradle/gradle-9.7.1"
export GRADLE_USER_HOME="$LOCAL_MICROSERVER/gradle-home"

export PATH="$JAVA_HOME/bin:$GRADLE_HOME/bin:$PATH"

open "$LOCAL_MICROSERVER/tools/vscode/Visual Studio Code.app" --args   "$LOCAL_MICROSERVER/workspace"
```

예:

```text
~/local-microserver/env/start-vscode.command
```

실행 권한:

```bash
chmod +x ~/local-microserver/env/start-vscode.command
```

`.command` Script가 환경을 설정한 뒤 VS Code를 직접 실행하면 VS Code Process가 해당 환경을 상속한다.

## 8. Portable Mode와 CLI Directory 옵션

Portable Mode가 활성화되면 `code-portable-data`가 User Data와 Extension 위치를 결정한다.

따라서 기본 구성에서는 다음 옵션을 별도로 사용하지 않는다.

```text
--user-data-dir
--extensions-dir
```

Portable Mode의 Data Directory가 이 옵션들보다 우선한다.

## 9. 저장 위치

Extension:

```text
~/local-microserver/tools/vscode/code-portable-data/extensions
```

User Data:

```text
~/local-microserver/tools/vscode/code-portable-data/user-data
```

User Settings:

```text
~/local-microserver/tools/vscode/code-portable-data/user-data/User/settings.json
```

## 10. VS Code Update

macOS Portable Mode에서는 일반적인 Application 자동 Update가 동작할 수 있다. `code-portable-data`는 Application과 별도 Directory이므로 User Data를 유지할 수 있다.

Windows ZIP Portable Mode처럼 새 ZIP에 `data` Directory를 옮기는 방식과 동일하게 취급하지 않는다.

## 11. 체크리스트

- [ ] `Visual Studio Code.app`과 `code-portable-data`가 같은 Directory에 있다.
- [ ] Portable User Data와 Extension 저장 위치를 확인했다.
- [ ] 실제 `JAVA_HOME`이 `temurin-25/Contents/Home`임을 확인했다.
- [ ] Portable Mode 문제 시 quarantine 여부를 확인할 수 있다.
- [ ] macOS Portable Mode의 Update 방식이 Windows ZIP 방식과 다름을 이해했다.

## 12. 다음 단계

→ [macOS VS Code 기본 설정](vscode_basic_settings.md)
