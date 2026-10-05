# Windows VS Code 설치

## 1. 문서 목적

본 문서는 MicroServer 개발환경에서 사용할 Visual Studio Code Windows ZIP 배포본을 다운로드하고,
`C:\local-microserver\tools\vscode`에 설치하는 절차를 설명한다.

현재 Windows 표준 환경에서는 **VS Code Windows x64 ZIP 배포본**을 사용하며,
설치형 프로그램처럼 시스템 전역에 설치하지 않고 다음 위치에 압축 해제하여 사용한다.

```text
C:\local-microserver\tools\vscode
```

현재 MicroServer 개발환경의 VS Code 기준 Version은 다음과 같다.

```text
VS Code : 1.134.0
```

이 문서에서는 다음 작업에 집중한다.

- Windows용 VS Code ZIP 배포본 다운로드
- 개발 PC Architecture 확인
- `C:\local-microserver\tools\vscode` Directory 준비
- VS Code ZIP 압축 해제
- `Code.exe` 위치 확인
- VS Code 최초 실행 및 Version 확인

`data` Directory 생성과 Portable Mode 활성화, 실행 Script, Shortcut,
Portable Update, 다른 개발자에게 전달할 Package 구성은 다음 **VS Code Portable 설정** 문서에서 수행한다.

Editor의 Encoding, Auto Save, Format On Save와 Settings 적용 범위는
그 다음 **VS Code 기본 설정** 문서에서 다룬다.

## 2. Windows ZIP 설치

MicroServer의 Windows 표준 VS Code 환경은 **User Installer가 아니라 Windows ZIP 배포본**을 사용한다.

ZIP 설치가 완료된 뒤 다음 문서에서 `data` Directory를 생성하여 Portable Mode를 활성화한다.

일반적인 개인 개발환경에서는 VS Code User Installer가 편리하지만,
MicroServer는 JDK, Gradle, VS Code와 주요 설정을 `C:\local-microserver` 아래에서
독립적으로 관리하고 다른 개발자에게 전달할 수 있는 구조를 지향한다.

### 2.1 Windows 표준 설치 방식

Windows 기준:

```text
배포 형식     : ZIP
설치 방식     : 압축 해제
VS Code 위치  : C:\local-microserver\tools\vscode
Portable Mode : 사용
User Installer: 프로젝트 표준 방식으로 사용하지 않음
```

!!! info "왜 ZIP 배포본을 사용하는가?"
    ZIP 배포본은 Installer를 실행하지 않고 Directory에 압축만 해제하면 실행할 수 있다.

    그리고 실행 Directory에 `data` 폴더를 만들면 VS Code Portable Mode를 사용할 수 있어
    Settings와 Extension을 VS Code Directory 가까이에 함께 보관할 수 있다.

### 2.2 Windows ZIP 다운로드

Visual Studio Code 공식 Download 페이지에서 Windows용 ZIP 배포본을 다운로드한다.

!!! tip "공식 Download 페이지"
    다음 페이지에서 VS Code의 운영체제별 배포본을 다운로드할 수 있다.

    **[Visual Studio Code 공식 Download](https://code.visualstudio.com/Download)**

    Windows 영역에는 다음과 같이 여러 배포 방식이 표시된다.

    ```text
    Windows
    ├─ User Installer
    ├─ System Installer
    ├─ .zip
    └─ CLI
    ```

    MicroServer에서는 이 중 **`.zip`** 을 사용한다.

#### 2.2.1 Download 페이지에서 ZIP 선택

공식 Download 페이지를 연다.

```text
https://code.visualstudio.com/Download
```

Windows 영역에서 다음 행을 찾는다.

```text
.zip
```

그다음 개발 PC Architecture에 맞는 항목을 선택한다.

```text
.zip
├─ x64
└─ Arm64
```

일반적인 Intel / AMD 기반 Windows 10·11 개발 PC:

```text
Operating System : Windows
Architecture     : x64
Distribution     : ZIP
Channel          : Stable
```

따라서 대부분의 일반적인 회사용 Windows 노트북과 Desktop에서는
**`.zip → x64`** 를 선택하면 된다.

#### 2.2.2 PC Architecture를 모르는 경우

Windows에서 다음 위치에서 확인할 수 있다.

```text
설정
→ 시스템
→ 정보
→ 시스템 종류
```

예:

```text
64비트 운영 체제, x64 기반 프로세서
```

이면:

```text
Windows x64 ZIP
```

을 선택한다.

ARM 기반 Processor라고 표시되는 Windows 장비라면:

```text
Windows Arm64 ZIP
```

을 선택한다.

!!! note "MicroServer 기본 문서는 Windows x64 기준"
    현재 MicroServer Windows 개발환경 가이드는
    일반적인 Intel / AMD 기반 **Windows x64 개발 PC**를 기본 기준으로 작성한다.

    Windows Arm64에서도 VS Code Portable Mode 자체는 사용할 수 있지만
    JDK와 기타 개발도구의 Architecture 지원 여부는 각 도구 가이드에서 별도로 확인한다.

#### 2.2.3 최신 Stable ZIP 직접 다운로드

Download 페이지를 거치지 않고 최신 Stable ZIP을 바로 받을 수도 있다.

**Windows x64:**

**[VS Code Windows x64 ZIP - Latest Stable 직접 다운로드](https://update.code.visualstudio.com/latest/win32-x64-archive/stable)**

**Windows Arm64:**

**[VS Code Windows Arm64 ZIP - Latest Stable 직접 다운로드](https://update.code.visualstudio.com/latest/win32-arm64-archive/stable)**

!!! info "`latest` 주소의 의미"
    위 직접 다운로드 주소의 `latest`는
    **현재 제공되는 최신 Stable Version**을 의미한다.

    예를 들어 새로운 Stable Version이 Release되면
    같은 URL로 접속해도 새 Version의 ZIP을 다운로드하게 된다.

    따라서 처음 개발환경을 구성할 때는 편리하지만,
    프로젝트 배포 Package를 운영할 때는 실제 검증한 VS Code Version을 별도로 기록한다.

#### 2.2.4 다운로드 파일 확인

Windows x64 ZIP의 파일명은 Version에 따라 다음과 같은 형태가 된다.

```text
VSCode-win32-x64-<version>.zip
```

현재 MicroServer 기준 예:

```text
VSCode-win32-x64-1.134.0.zip
```

일반 형식:

```text
VSCode-win32-x64-<version>.zip
```

!!! warning "User Installer와 혼동하지 않음"
    다음과 같은 Installer 파일을 다운로드한 경우 현재 가이드의 Portable Mode 대상이 아니다.

    ```text
    VSCodeUserSetup-*.exe
    VSCodeSetup-*.exe
    ```

    MicroServer Windows 개발환경 Package를 구성할 때는
    **`VSCode-win32-x64-*.zip` 형태의 ZIP 배포본**을 사용한다.

    Installer 방식은 일반 개인 설치 방식으로는 정상적인 방법이지만,
    이번 프로젝트의 Portable 개발환경 표준과는 목적이 다르다.

#### 2.2.5 다운로드 후 다음 작업

ZIP 다운로드가 완료되면 아직 Installer를 실행하는 과정은 없다.

다음 단계에서 ZIP의 내용을 아래 Directory에 압축 해제한다.

```text
C:\local-microserver\tools\vscode
```

진행 흐름:

```mermaid
flowchart LR
    A["VS Code 공식 Download"]
    --> B["Windows .zip 선택"]
    --> C["x64 선택"]
    --> D["VSCode-win32-x64-*.zip 다운로드"]
    --> E["C:\local-microserver\tools\vscode 에 압축 해제"]

```

### 2.3 VS Code Directory 준비

다음 Directory를 준비한다.

```text
C:\local-microserver\tools\vscode
```

PowerShell:

```powershell
New-Item -ItemType Directory -Force C:\local-microserver\tools\vscode
```

다운로드한 VS Code ZIP의 내용을 위 Directory에 압축 해제한다.

정상 구조의 예:

```text
C:\local-microserver\tools\vscode
├─ Code.exe
├─ bin\
├─ appx\
├─ policies\
├─ tools\
├─ ...
└─ ...
```

!!! note "VS Code Version에 따라 내부 Directory 구조가 달라질 수 있음"
    ZIP 배포본의 내부 Directory 구성은 VS Code Version에 따라 달라질 수 있다.

    예를 들어 일부 Version이나 기존 문서에서는 `resources` Directory가 보일 수 있지만,
    현재 사용하는 VS Code 1.134.0 ZIP에서는 해당 Directory가 최상위에 보이지 않을 수 있다.

    Portable 구성에서 반드시 확인할 핵심은 다음 항목이다.

    ```text
    C:\local-microserver\tools\vscode\Code.exe
    C:\local-microserver\tools\vscode\bin\code.cmd
    ```

    따라서 `resources` Directory의 존재 여부를 Portable Mode 정상 여부의 판단 기준으로 사용하지 않는다.

중요한 것은 `Code.exe`가 바로 다음 위치에 존재하도록 정리하는 것이다.

```text
C:\local-microserver\tools\vscode\Code.exe
```


## 3. 설치 확인

다음 파일이 존재하는지 확인한다.

```text
C:\local-microserver\tools\vscode\Code.exe
C:\local-microserver\tools\vscode\bin\code.cmd
```

```powershell
Test-Path C:\local-microserver\tools\vscode\Code.exe
Test-Path C:\local-microserver\tools\vscode\bin\code.cmd
```

VS Code 최초 실행:

```powershell
& "C:\local-microserver\tools\vscode\Code.exe"
```

Version 확인:

```powershell
& "C:\local-microserver\tools\vscode\bin\code.cmd" --version
```

!!! note "현재 단계에서는 Portable Mode를 구성하지 않음"
    현재 단계는 VS Code 실행파일을 표준 위치에 설치하고 정상 실행을 확인하는 단계이다.
    `data` Directory는 다음 **VS Code Portable 설정** 단계에서 생성한다.

## 4. 체크리스트

- [ ] Windows x64용 VS Code ZIP 배포본을 준비했다.
- [ ] `C:\local-microserver\tools\vscode`에 압축 해제했다.
- [ ] `Code.exe`가 존재한다.
- [ ] `bin\code.cmd`가 존재한다.
- [ ] VS Code가 정상 실행된다.
- [ ] Version을 확인했다.
- [ ] Portable Mode 구성은 다음 단계에서 수행한다.

## 5. 다음 단계

```mermaid
flowchart LR
    A["VS Code ZIP 설치"]
    --> B["Code.exe 실행 확인"]
    --> C["VS Code Portable 설정"]
```

**[VS Code Portable 설정](vscode_portable_setup.md)**

## 6. 공식 참고

- [VS Code 공식 Download](https://code.visualstudio.com/Download)
- [Installing VS Code on Windows](https://code.visualstudio.com/docs/setup/windows)
