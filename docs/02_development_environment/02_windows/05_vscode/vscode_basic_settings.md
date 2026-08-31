# Windows VS Code 기본 설정

## 1. 문서 목적

본 문서는 VS Code 설치와 Portable 실행환경 구성이 완료된 뒤,
개발자가 공통으로 알아야 할 **VS Code Editor 기본 사용법과 설정 정책**을 설명한다.

주요 화면, Command Palette, Integrated Terminal, Settings 적용 범위,
UTF-8 Encoding, Auto Save, Format On Save, 공백 및 개행 정책을 다룬다.

Shortcut, 실행 Script, Portable `data` 구성은 이전
**VS Code Portable 설정** 문서를 기준으로 한다.

실제 `settings.json` 구성과 JDK Runtime 등록은 다음
**VS Code User Settings** 문서에서 수행한다.

## 2. VS Code 역할

VS Code는 기본 상태에서는 범용 Source Code Editor이다.

Java 및 Spring Boot 개발 기능은 이후 Extension을 설치하여 추가한다.

```text
VS Code
  │
  ├─ 기본 Editor 기능
  ├─ Terminal
  ├─ Git UI
  └─ Extension Platform
       │
       ├─ Java 개발 기능
       ├─ Spring Boot 개발 기능
       └─ YAML / XML / Container 기능
```

즉, 먼저 VS Code 자체를 정상적으로 사용할 수 있는 상태로 만든 뒤 Extension을 단계적으로 구성한다.

---

## 3. VS Code 주요 화면

VS Code의 주요 영역은 다음과 같다.

| 영역 | 역할 |
|---|---|
| Explorer | 폴더와 파일 탐색 |
| Search | Workspace 전체 검색 |
| Source Control | Git 변경사항 확인 |
| Run and Debug | 실행 및 Debug 관리 |
| Extensions | Extension 검색, 설치, 관리 |
| Terminal | VS Code 내부 Terminal |
| Problems | 오류 및 Warning 확인 |
| Output | VS Code 및 Extension 로그 확인 |
| Status Bar | Encoding, Git Branch 등 상태 확인 |

Java / Spring Boot 개발에서는 Explorer, Extensions, Terminal, Problems, Output을 자주 사용하게 된다.

---

## 4. Command Palette

Command Palette는 VS Code 및 설치된 Extension의 명령을 실행하는 핵심 기능이다.

### Windows / Linux

```text
Ctrl + Shift + P
```

## 5. Extensions 화면

Extensions 화면에서는 VS Code의 개발 기능을 추가하거나 제거할 수 있다.

### Windows / Linux

```text
Ctrl + Shift + X
```

## 6. Integrated Terminal

VS Code는 Editor 하단에서 Terminal을 사용할 수 있다.

메뉴:

```text
Terminal
→ New Terminal
```


향후 Git, Gradle, Docker 등 개발 도구 명령을 실행할 때 사용한다.

현재 단계에서는 실제 Gradle Build나 애플리케이션 실행을 진행하지 않는다.


### 6.1 Portable 실행환경과 Terminal

이전 단계에서 `MicroServer VS Code.lnk`를 통해 실행하도록 구성했으므로
Integrated Terminal은 MicroServer 실행환경을 상속할 수 있다.

Shortcut과 PowerShell Script의 상세 구성은
**[VS Code Portable 설정](vscode_portable_setup.md)** 을 참고한다.

---

## 7. VS Code Settings 확인

VS Code의 `Settings`는 Editor 동작, 파일 처리 방식, Terminal, Extension 동작 등을 설정하는 영역이다.

현재 단계에서는 **Settings 구조와 적용 범위만 이해하고**, 실제 User Settings의 상세 값은 다음 가이드에서 구성한다.

### 7.1 Settings UI 열기

Windows에서 다음 단축키를 사용한다.

```text
Ctrl + ,
```

또는 Command Palette에서 다음 명령을 실행한다.

```text
Preferences: Open Settings (UI)
```

Settings UI에서는 다음과 같은 항목을 검색하여 현재 값을 확인할 수 있다.

```text
Files Encoding
Files Auto Save
Editor Format On Save
Trim Trailing Whitespace
Insert Final Newline
```

### 7.2 설정 적용 범위 이해

VS Code 설정은 적용 범위에 따라 다음과 같이 구분한다.

```text
Default Settings
      ↓
User Settings
      ↓
Workspace Settings
      ↓
Folder / Language-specific Settings
```

- **Default Settings**: VS Code 기본값
- **User Settings**: 현재 Portable VS Code 인스턴스 전체에 적용
- **Workspace Settings**: 특정 프로젝트 또는 Workspace에 적용
- **Language-specific Settings**: Java, YAML 등 특정 언어에만 적용

Portable Mode에서는 User Settings가 일반 Windows 사용자 Profile이 아니라 Portable `data` 영역에서 관리된다.

다만 **User Settings 파일 위치, JSON 작성 방법, JDK Runtime 등록은 다음 `VS Code User Settings` 문서에서 상세히 다룬다.**

!!! note "프로젝트 설정과 전역 성격의 설정을 구분"
    프로젝트 결과에 영향을 주는 Formatter, Target Java Version,
    Gradle Toolchain, 프로젝트별 Line Ending 정책 등은
    프로젝트 생성 이후 Workspace Settings 또는 프로젝트 관리 파일에서 구성하는 것을 기본으로 한다.

### 7.3 설정 문제 확인 기준

설정값이 예상과 다르게 동작하면 다음 순서로 확인한다.

```text
1. User Settings에 값이 있는가?
2. Workspace Settings가 같은 Key를 덮어쓰고 있는가?
3. Language-specific Settings가 있는가?
4. Extension이 자체 설정을 추가했는가?
```

---

## 8. 파일 Encoding 설정

Source와 설정 파일의 문자 Encoding은 개발자별 환경 차이를 줄이기 위해 통일하는 것이 좋다.

MicroServer 프로젝트의 기본 Encoding은 **UTF-8**을 사용한다.

### 8.1 Files: Encoding 확인

Settings에서 다음 항목을 검색한다.

```text
Files: Encoding
```

권장 값:

```text
UTF-8
```

설정 Key:

```json
"files.encoding": "utf8"
```

현재 Settings 화면에서 이미 `UTF-8`로 되어 있다면 별도의 변경은 필요하지 않다.

### 8.2 UTF-8을 사용하는 이유

MicroServer 프로젝트에서는 Java Source뿐 아니라 다음 파일도 UTF-8 기준으로 관리한다.

```text
Java
XML
YAML
Markdown
Properties
Shell Script
JSON
SQL
```

개발자마다 다른 Encoding을 사용하면 다음 문제가 발생할 수 있다.

- 한글 주석이 깨져 보임
- Markdown 문서의 한글이 깨짐
- Properties / YAML의 한글 값이 잘못 표시됨
- Git Diff에서 실제 내용 변경이 없는데 파일 전체가 변경된 것처럼 보임
- Build 또는 Script 처리 시 예상하지 못한 문자 변환 발생

따라서 프로젝트 Source와 설정 파일은 UTF-8을 기준으로 관리한다.

### 8.3 Files: Auto Guess Encoding

Settings에서 다음 항목을 검색한다.

```text
Files: Auto Guess Encoding
```

설정 Key:

```json
"files.autoGuessEncoding": false
```

MicroServer 신규 프로젝트에서는 기본적으로 **활성화하지 않는다.**

`Auto Guess Encoding`을 활성화하면 VS Code가 파일을 열 때 Encoding을 추측한다. 레거시 파일을 다룰 때는 편리할 수 있지만 신규 프로젝트에서는 개발자가 의도하지 않은 Encoding으로 파일이 해석될 가능성을 만들 수 있다.

따라서 기본 기준은 다음과 같다.

```text
Files: Encoding            = UTF-8
Files: Auto Guess Encoding = Off
```

!!! note "레거시 Source와는 구분"
    기존 시스템의 오래된 Source에는 `EUC-KR`, `CP949` 등 다른 Encoding이 사용된 경우가 있다.

    그런 파일을 분석하거나 수정해야 하는 별도 프로젝트에서는 `Auto Guess Encoding` 또는 파일별 Encoding 재열기를 검토할 수 있다.

    MicroServer 신규 프로젝트의 기본 정책은 UTF-8이다.

### 8.4 현재 파일의 Encoding 확인

Editor 오른쪽 아래 Status Bar에서 현재 파일의 Encoding을 확인할 수 있다.

예:

```text
UTF-8
```

Encoding 표시를 클릭하면 다음과 같은 기능을 사용할 수 있다.

```text
Reopen with Encoding
Save with Encoding
```

`Reopen with Encoding`은 파일 내용을 다른 Encoding으로 다시 해석할 때 사용하고, `Save with Encoding`은 실제 파일 저장 Encoding을 변경할 때 사용한다.

!!! warning "Save with Encoding 사용 시 주의"
    `Save with Encoding`은 실제 파일의 저장 Encoding을 변경할 수 있다.

    프로젝트 정책과 다른 Encoding으로 저장하면 Git Diff 또는 문자 깨짐이 발생할 수 있으므로 특별한 이유가 없다면 UTF-8을 유지한다.

---

## 9. Auto Save 설정

`Auto Save`는 파일을 직접 저장하지 않아도 특정 조건에서 자동으로 저장하는 기능이다.

Settings 검색:

```text
Files: Auto Save
```

설정 Key:

```json
"files.autoSave": "off"
```

대표적인 값은 다음과 같다.

| 값 | 의미 |
|---|---|
| `off` | 자동 저장하지 않음 |
| `afterDelay` | 일정 시간이 지나면 자동 저장 |
| `onFocusChange` | 다른 Editor로 이동할 때 저장 |
| `onWindowChange` | 다른 Window로 이동할 때 저장 |

MicroServer 프로젝트에서는 Auto Save를 **팀 공통 설정으로 강제하지 않는다.**

Auto Save는 개발자의 편의 기능에 가깝고 Source의 최종 형식을 결정하는 프로젝트 표준 설정은 아니기 때문이다.

현재 단계에서는 다음 정도로 이해하면 된다.

```text
Files: Auto Save = off 또는 개발자 개인 선호값
```

!!! tip "처음에는 off로 사용해도 충분"
    Java / Spring Boot 개발환경을 처음 구성할 때는 파일 저장 시점을 명확히 인지할 수 있도록 `off` 상태로 사용해도 좋다.

    이후 개발 방식에 익숙해진 뒤 개인 취향에 따라 변경할 수 있다.

---

## 10. Format On Save 설정

`Format On Save`는 파일을 저장할 때 Formatter를 자동 실행하는 기능이다.

Settings 검색:

```text
Editor: Format On Save
```

설정 Key:

```json
"editor.formatOnSave": false
```

현재 단계에서는 **활성화를 강제하지 않는다.**

아직 다음 항목이 정해지지 않았기 때문이다.

- Java Formatter
- 프로젝트 Code Style
- XML / YAML Formatter
- 언어별 Default Formatter
- Formatter Profile

Formatter 정책이 없는 상태에서 `Format On Save`를 먼저 활성화하면 개발자마다 설치된 Extension이나 Formatter에 따라 파일 전체가 불필요하게 변경될 수 있다.

따라서 현재 기준은 다음과 같다.

```text
Editor: Format On Save
→ 프로젝트 Formatter 정책 확정 전까지 팀 공통으로 강제하지 않음
```

프로젝트 생성 이후 Formatter 정책이 확정되면 Workspace Settings에서 설정할 수 있다.

예:

```json
{
  "editor.formatOnSave": true
}
```

언어별 설정도 가능하다.

```json
{
  "[java]": {
    "editor.formatOnSave": true
  },
  "[yaml]": {
    "editor.formatOnSave": true
  }
}
```

!!! warning "User Settings에서 전역 활성화 시 주의"
    `editor.formatOnSave`를 User Settings에서 전역으로 활성화하면 MicroServer가 아닌 다른 프로젝트에도 동일한 설정이 적용된다.

    레거시 Source까지 자동 Formatting될 수 있으므로 프로젝트 공통 Formatter 정책은 가능하면 프로젝트 생성 이후 Workspace Settings에서 관리한다.

---

## 11. 공백 및 파일 끝 처리 설정

Source 파일은 내용뿐 아니라 줄 끝 공백, 마지막 개행, Line Ending 차이 때문에도 Git Diff가 발생할 수 있다.

VS Code에서는 이러한 항목을 Settings에서 제어할 수 있다.

### 11.1 Trim Trailing Whitespace

Settings 검색:

```text
Files: Trim Trailing Whitespace
```

설정 Key:

```json
"files.trimTrailingWhitespace": true
```

파일 저장 시 각 줄 끝의 불필요한 공백을 제거하는 기능이다.

예:

```text
변경 전
String name = "microserver";····

변경 후
String name = "microserver";
```

신규 프로젝트에서는 불필요한 공백을 줄이는 데 도움이 된다.

다만 User Settings에 전역 적용하면 다른 프로젝트 파일에도 영향을 줄 수 있으므로, 프로젝트 정책으로 강제할 경우 프로젝트 생성 이후 `.editorconfig` 또는 Workspace Settings를 사용하는 것이 좋다.

### 11.2 Insert Final Newline

Settings 검색:

```text
Files: Insert Final Newline
```

설정 Key:

```json
"files.insertFinalNewline": true
```

활성화하면 파일 마지막에 개행 문자가 없을 경우 저장 시 자동으로 추가한다.

Source 관리 도구와 Unix 계열 도구에서는 파일 마지막 개행이 있는 형태를 일반적으로 사용하므로 신규 프로젝트에서 통일된 파일 형식을 유지하는 데 도움이 된다.

### 11.3 Line Ending 확인

VS Code Status Bar에서는 현재 파일의 Line Ending을 확인할 수 있다.

대표적인 값:

```text
LF
CRLF
```

운영체제 기본 경향은 다음과 같다.

```text
Windows      → CRLF
macOS/Linux  → LF
```

하지만 Git 설정이나 `.gitattributes` 정책에 따라 Repository 저장 기준은 별도로 통일할 수 있다.

현재 VS Code 설치 단계에서는 Line Ending을 User Settings에서 강제로 변경하지 않는다.

실제 프로젝트의 개행 정책은 프로젝트가 생성된 이후 Git / `.gitattributes` / `.editorconfig` 기준과 함께 정하는 것이 안전하다.

!!! note "공백/개행 설정은 프로젝트 정책과 함께 관리"
    `Trim Trailing Whitespace`, `Insert Final Newline`, `Line Ending`은 개발자 편의 설정처럼 보이지만 Git Diff에 직접 영향을 줄 수 있다.

    따라서 최종 프로젝트 공통 기준은 Workspace Settings나 `.editorconfig`로 관리하는 것이 좋다.

---

## 12. 기본 설정 체크리스트

### 12.1 기본 기능

- [ ] MicroServer Portable VS Code가 정상 실행된다.
- [ ] Explorer, Extensions, Terminal, Problems, Output을 사용할 수 있다.
- [ ] Command Palette를 사용할 수 있다.
- [ ] Status Bar에서 Encoding과 Line Ending을 확인할 수 있다.

### 12.2 Editor 기본 설정

- [ ] Settings UI를 열 수 있다.
- [ ] `Files: Encoding`이 UTF-8 기준임을 확인했다.
- [ ] `Files: Auto Guess Encoding`을 신규 프로젝트에서 기본적으로 사용하지 않는 이유를 이해했다.
- [ ] Auto Save는 개발자 편의 설정임을 이해했다.
- [ ] Format On Save는 프로젝트 Formatter 정책 확정 전에는 공통으로 강제하지 않는다.
- [ ] Trim Trailing Whitespace와 Insert Final Newline의 역할을 이해했다.
- [ ] User Settings와 Workspace Settings의 적용 범위가 다름을 이해했다.
- [ ] 실제 User Settings와 JDK Runtime 등록은 다음 가이드에서 진행함을 이해했다.

---

## 13. 다음 단계

VS Code Editor의 기본 동작과 설정 정책을 확인했으면 실제 User Scope 설정을 구성한다.

```mermaid
flowchart LR
    A["VS Code 설치"]
    --> B["VS Code Portable 설정"]
    --> C["VS Code 기본 설정"]
    --> D["VS Code User Settings"]
    D --> E["Java 개발 Extension 구성"]
    --> F["Spring Boot Extension 구성"]
```

다음 문서:

**[VS Code User Settings](vscode_user_settings.md)**

---

## 14. 공식 참고

- [VS Code 공식 Download](https://code.visualstudio.com/Download)
- [VS Code Portable Mode](https://code.visualstudio.com/docs/setup/portable)
- [VS Code Settings](https://code.visualstudio.com/docs/configure/settings)
- [VS Code Command Line Interface](https://code.visualstudio.com/docs/configure/command-line)
