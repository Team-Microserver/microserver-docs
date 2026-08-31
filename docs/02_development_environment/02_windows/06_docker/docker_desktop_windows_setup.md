# Windows Docker Desktop 설치 가이드

## 1. 문서 목적

본 문서는 Windows 개발 PC에서 MicroServer 로컬 Container 실행환경을 준비하기 위해
Docker Desktop을 다운로드하고 설치한 뒤 WSL 2 기반 Docker Engine을 검증하는 과정을 설명한다.

Docker Desktop의 공통 개념과 Image / Container / Volume 등의 설명은
[Docker Desktop 개요 및 공통 환경 가이드](docker_desktop_setup.md)를 참고한다.

현재 문서에서는 다음 내용을 진행한다.

- Windows CPU Architecture 확인
- WSL 2 상태 확인
- Docker Desktop 공식 다운로드
- Installer 실행 및 설치
- WSL 2 기반 Linux Container Backend 확인
- Docker CLI / Engine / Compose 확인
- `hello-world` Container 실행 검증

!!! info "MicroServer Windows 기준"
    Docker Desktop은 JDK나 Portable VS Code처럼
    `C:\local-microserver\tools` 아래에 Portable 형태로 넣지 않는다.

    Docker Desktop은 WSL 2, Virtualization, Docker Engine 등
    Windows OS 기능과 연동되는 **개발 PC 공통 Runtime**으로 관리한다.

---

## 2. Windows 사전 확인

Windows에서 Docker Desktop을 설치하기 전에
먼저 WSL 2와 CPU Architecture, 기존 Docker Desktop 설치 여부를 확인한다.

MicroServer는 **Windows Container가 아니라 Linux Container**를 사용하므로
WSL 2 기반 Docker Desktop 환경을 기준으로 한다.

### 2.1 Windows / CPU Architecture 확인

일반적인 Intel / AMD 기반 Windows PC는 `x86_64(AMD64)`용 Docker Desktop을 설치한다.

PowerShell:

```powershell
$env:PROCESSOR_ARCHITECTURE
```

일반적인 Intel / AMD 64-bit PC라면 다음과 같이 표시될 수 있다.

```text
AMD64
```

Windows on ARM 장비라면 ARM64용 설치 Package가 필요하다.

!!! tip "대부분의 일반 Windows 노트북 / 데스크톱"
    Intel Core, Intel Core Ultra, AMD Ryzen CPU를 사용하는 일반적인 Windows PC는
    Docker 다운로드 화면에서 **Windows - AMD64 / x86_64** 항목을 선택하면 된다.

### 2.2 WSL 설치 및 Version 확인

PowerShell에서 다음 명령을 실행한다.

```powershell
wsl --version
```

WSL 상태:

```powershell
wsl --status
```

설치된 Linux Distribution:

```powershell
wsl --list --verbose
```

정상적인 WSL 2 환경의 예:

```text
NAME      STATE      VERSION
Ubuntu    Stopped    2
```

Docker Desktop을 이미 설치한 PC라면 다음 항목이 함께 보일 수 있다.

```text
Ubuntu
docker-desktop
```

`docker-desktop` Distribution이 보인다면
Docker Desktop이 현재 설치되어 있거나 이전에 설치된 이력이 있을 가능성이 높다.

이 경우 바로 재설치하지 말고 먼저 다음을 확인한다.

```powershell
docker --version
docker version
```

또는 Windows Start Menu에서 다음 Application이 존재하는지 확인한다.

```text
Docker Desktop
```

### 2.3 WSL이 없거나 오래된 경우

`wsl --version` 명령이 정상적으로 Version 정보를 표시하지 않거나
WSL 2가 준비되지 않았다면 관리자 PowerShell에서 다음 명령을 사용할 수 있다.

WSL 설치:

```powershell
wsl --install
```

기존 WSL Update:

```powershell
wsl --update
```

설치나 Update 과정에서 Windows 재부팅을 요구할 수 있다.

!!! note "회사 개발 PC"
    회사 보안 정책으로 Microsoft Store, Windows 기능 추가, 관리자 권한 사용이 제한되어 있다면
    임의로 우회하지 말고 사내 Software 설치 / 보안 정책을 먼저 확인한다.

Docker의 최신 Windows 요구사항은 설치 시점에 공식 문서에서 다시 확인한다.

!!! info "Windows 설치 전 공식 문서 확인"
    Docker Desktop의 지원 Windows Version, WSL 2 요구사항, CPU Architecture 조건은
    Version에 따라 변경될 수 있으므로 설치 시점의 공식 문서를 기준으로 확인한다.

    - [Docker Desktop for Windows 공식 설치 문서](https://docs.docker.com/desktop/setup/install/windows-install/)
    - [Docker Desktop 공식 다운로드 페이지](https://www.docker.com/products/docker-desktop/)

---

## 3. Windows Docker Desktop 다운로드

Docker Desktop은 임의의 Software 배포 사이트가 아니라
**Docker 공식 사이트에서 다운로드**한다.

### 3.1 다운로드 페이지 접속

Docker Desktop은 반드시 Docker 공식 사이트에서 다운로드한다.

!!! info "Docker Desktop for Windows 다운로드"
    **권장:** 먼저 Docker Desktop 공식 다운로드 페이지에 접속하여
    Windows용 Installer를 선택한다.

    - [Docker Desktop 공식 다운로드 페이지](https://www.docker.com/products/docker-desktop/)
    - [Docker Desktop for Windows 공식 설치 문서](https://docs.docker.com/desktop/setup/install/windows-install/)

    일반적인 Intel / AMD 기반 Windows PC라면 다음 절에서 설명하는
    **Windows AMD64(x86_64)** Package를 선택한다.

### 3.2 Windows용 Package 선택

다운로드 화면에는 운영체제와 CPU Architecture별 Package가 표시될 수 있다.

일반적인 Intel / AMD Windows PC:

```text
Download for Windows - AMD64
```

또는 문서에 따라:

```text
Docker Desktop for Windows - x86_64
```

를 선택한다.

Windows on ARM 장비에서만 ARM64 Package를 선택한다.

!!! warning "Mac용 Package와 혼동하지 않음"
    다음 항목은 Windows PC용이 아니다.

    ```text
    Mac - Apple Silicon
    Mac - Intel
    ```

### 3.3 다운로드 파일 확인

정상적으로 다운로드하면 일반적으로 다음 Installer 파일을 받게 된다.

```text
Docker Desktop Installer.exe
```

Browser의 기본 Download Directory를 사용했다면 보통 다음 위치에서 확인할 수 있다.

```text
C:\Users\<사용자>\Downloads\Docker Desktop Installer.exe
```

예:

```text
C:\Users\USER\Downloads\Docker Desktop Installer.exe
```

!!! note "C:\\local-microserver 아래에 설치하지 않는 이유"
    JDK, Gradle, Portable VS Code처럼 단순한 Directory 기반 개발도구와 달리
    Docker Desktop은 WSL 2, Virtualization, Docker Engine 등의 OS 기능과 연동된다.

    따라서 MicroServer 표준에서는 Docker Desktop Binary를
    `C:\local-microserver\tools` 아래에 억지로 Portable 형태로 구성하지 않는다.

    Docker Desktop은 **Windows에 설치되는 개발 PC 공통 Runtime**으로 분류하고,
    `C:\local-microserver`에는 프로젝트 Source와 Portable 개발도구를 관리한다.

---

## 4. Windows Docker Desktop 설치

다운로드한 `Docker Desktop Installer.exe`를 실행한다.

### 4.1 Installer 실행

Windows Explorer에서 다음 파일을 찾아 Double Click한다.

```text
Docker Desktop Installer.exe
```

예:

```text
Downloads
→ Docker Desktop Installer.exe
→ Double Click
```

Windows에서 보안 / 권한 확인창이 표시되면
Docker 공식 Installer가 맞는지 확인한 뒤 진행한다.

### 4.2 설치 Mode 선택

최근 Docker Desktop for Windows는 크게 다음과 같은 설치 Mode를 제공할 수 있다.

| 설치 Mode | 대표 설치 위치 | 관리자 권한 | 권장 용도 |
|---|---|---:|---|
| Per-user | `%LOCALAPPDATA%\Programs\DockerDesktop` | 일반적으로 불필요 | 개인 개발 PC, 일반 개발자 |
| All users | `C:\Program Files\Docker\Docker` | 필요 | 여러 Windows 계정 공용 설치 |

일반적인 개발 PC에서는 Docker 공식 문서가 안내하는 **Per-user 설치**를 우선 사용할 수 있다.

회사에서 별도의 설치 경로나 관리자 설치 기준을 정해두었다면
사내 정책을 우선한다.

### 4.3 WSL 2 Backend 선택

Installer의 Configuration 화면에서 Backend 선택 항목이 나오면
MicroServer 개발환경은 **WSL 2 기반 Linux Container**를 사용한다.

다음과 유사한 항목이 보이면 WSL 2를 선택한다.

```text
Use WSL 2 instead of Hyper-V
```

환경에 따라 Docker Desktop이 사용 가능한 Backend를 자동 선택할 수도 있다.

MicroServer에서는 다음 방향을 기준으로 한다.

```text
Windows
  ↓
WSL 2
  ↓
Docker Desktop
  ↓
Docker Engine
  ↓
Linux Container
```

### 4.4 설치 완료

Installer 안내에 따라 설치를 진행한다.

설치가 정상적으로 끝나면:

```text
Close
```

또는 설치 완료 버튼을 선택하여 Installer를 종료한다.

환경에 따라 로그아웃 또는 Windows 재부팅이 요구될 수 있다.
요구되는 경우 안내에 따라 진행한다.

### 4.5 Docker Desktop 실행

Windows Start Menu를 열고 다음을 검색한다.

```text
Docker Desktop
```

실행:

```text
Start
→ Docker Desktop
```

처음 실행할 때 Docker Subscription Service Agreement가 표시될 수 있다.
내용을 확인하고 동의해야 Docker Desktop을 사용할 수 있다.

초기 설정 화면이 나타나면
특별한 사내 기준이 없는 일반 개발환경에서는 **Recommended Settings**를 기준으로 시작한다.

### 4.6 Docker Engine 시작 대기

Docker Desktop Application이 열렸다고 해서
Docker Engine이 즉시 준비된 것은 아닐 수 있다.

Docker Desktop 화면에서 Engine이 시작될 때까지 기다린다.

정상 준비 상태에서는 Docker Desktop UI에서
Containers / Images 등의 메뉴를 사용할 수 있고,
PowerShell에서 Server와 연결할 수 있다.

---

## 2. Windows WSL 2 / Docker Engine 확인

Docker Desktop 설치 후
WSL 2 Backend와 Docker Engine 상태를 확인한다.

### 2.1 WSL Distribution 확인

새 PowerShell:

```powershell
wsl --list --verbose
```

Docker Desktop이 WSL 2 기반으로 정상 구성되어 있다면
다음과 유사한 항목을 확인할 수 있다.

```text
NAME              STATE           VERSION
Ubuntu            Running         2
docker-desktop    Running         2
```

실제 `STATE`는 Docker Desktop 실행 여부에 따라 `Running` 또는 `Stopped`로 달라질 수 있다.

중요한 것은 Docker Desktop을 실행한 상태에서
`docker-desktop`이 WSL 2 기반으로 동작할 수 있는지 확인하는 것이다.

### 2.2 Docker Desktop General 설정

Docker Desktop:

```text
Settings
→ General
```

WSL 2 관련 Engine 설정이 제공되는 Version이라면
WSL 2 기반 Backend가 사용되는지 확인한다.

### 2.3 WSL Integration

Docker Desktop:

```text
Settings
→ Resources
→ WSL Integration
```

Ubuntu 내부에서도 직접 `docker` 명령을 사용할 계획이라면
해당 Distribution과의 Integration을 확인할 수 있다.

다만 MicroServer 개발환경에서 Windows PowerShell을 기준으로 Docker CLI를 사용할 경우
Ubuntu Integration을 반드시 활성화해야 하는 것은 아니다.

---

## 3. Windows Docker CLI / Engine 최종 확인

Docker Desktop이 실행된 상태에서
**새 PowerShell Window**를 연다.

설치 전에 열어두었던 PowerShell은 PATH 변경사항을 반영하지 못할 수 있으므로
새 Window에서 확인하는 것이 좋다.

### 3.1 Docker CLI 확인

```powershell
docker --version
```

정상이라면 다음과 같이 Docker Version이 표시된다.

```text
Docker version ...
```

### 3.2 Client / Server 연결 확인

단순히 `docker --version`이 실행된다고 Docker Engine까지 정상인 것은 아니다.

다음 명령으로 Client와 Server를 함께 확인한다.

```powershell
docker version
```

정상 상태에서는 결과에 다음 두 영역이 모두 표시된다.

```text
Client:
  ...

Server:
  ...
```

`Client`만 나오고 `Server` 연결 오류가 발생한다면
Docker Desktop이 실행 중인지 먼저 확인한다.

### 3.3 Docker Engine 상세 상태 확인

```powershell
docker info
```

정상적으로 Server 정보까지 조회되어야 한다.

### 3.4 Docker Compose 확인

```powershell
docker compose version
```

Docker Desktop에 포함된 Compose Plugin이 정상이라면
Docker Compose Version이 표시된다.

### 3.5 실제 Container 실행 확인

마지막으로 Docker Engine이 Image를 Pull하고 Container를 실행할 수 있는지 확인한다.

```powershell
docker run --rm hello-world
```

이 명령이 정상적으로 완료되면 다음 경로가 모두 동작하는 것이다.

```text
PowerShell
  ↓
Docker CLI
  ↓
Docker Desktop
  ↓
Docker Engine
  ↓
Image Pull
  ↓
Container 생성 / 실행
```

### 3.6 Windows 설치 완료 판정

다음 명령이 모두 정상이어야 한다.

```powershell
wsl --list --verbose
docker --version
docker version
docker info
docker compose version
docker run --rm hello-world
```

정리:

```text
WSL 2                ✅
Docker Desktop       ✅
Docker CLI           ✅
Docker Engine        ✅
Docker Compose       ✅
Container 실행       ✅
```

이 상태가 되면 다음 Oracle Database Container 구성 단계로 넘어갈 수 있다.

---

## 7. Windows 자주 발생하는 문제

### 7.1 `docker` 명령을 찾을 수 없음

```powershell
docker --version
```

명령을 찾지 못하면 다음을 확인한다.

- Docker Desktop 설치 여부
- Docker Desktop 설치 후 새 PowerShell을 열었는지
- Windows PATH 반영 여부
- 회사 PC의 Software 설치 정책

### 7.2 `docker version`에서 Server 연결 실패

예:

```text
failed to connect to the docker API ...
dockerDesktopLinuxEngine
```

이 경우 Docker CLI는 설치되어 있지만 Docker Engine이 아직 실행되지 않았을 수 있다.

확인 순서:

```powershell
wsl --list --verbose
docker version
```

Docker Desktop을 실행하고 Engine 시작을 기다린다.

필요한 경우:

```powershell
wsl --shutdown
```

실행 후 Docker Desktop을 다시 시작한다.

### 7.3 WSL 관련 오류

```powershell
wsl --status
wsl --list --verbose
```

Docker Desktop을 실행한 상태에서 `docker-desktop` Distribution 상태를 확인한다.

---

## 8. Windows 체크리스트

- [ ] Windows CPU Architecture를 확인했다.
- [ ] WSL 2가 설치되어 있고 정상 동작한다.
- [ ] Docker 공식 사이트에서 Windows용 Installer를 다운로드했다.
- [ ] Intel / AMD PC에서는 AMD64(x86_64) Package를 선택했다.
- [ ] `Docker Desktop Installer.exe`를 실행하여 설치했다.
- [ ] Linux Container / WSL 2 기반 Backend를 사용한다.
- [ ] Docker Desktop을 실행했다.
- [ ] `wsl --list --verbose`에서 Docker 관련 Distribution을 확인했다.
- [ ] `docker --version`이 정상 실행된다.
- [ ] `docker version`에서 Client / Server 정보가 모두 표시된다.
- [ ] `docker info`가 정상 실행된다.
- [ ] `docker compose version`이 정상 실행된다.
- [ ] `docker run --rm hello-world`가 정상 실행된다.

---

## 9. 다음 단계

Windows Docker Desktop 구성이 완료되면 다음 문서로 이동한다.

```text
Oracle Database Free 로컬 개발환경 구성
```

---

## 10. 공식 참고 자료

!!! tip "Windows Docker 공식 문서"
    - [Docker Desktop 공식 다운로드 페이지](https://www.docker.com/products/docker-desktop/)
    - [Docker Desktop for Windows 설치](https://docs.docker.com/desktop/setup/install/windows-install/)
    - [Docker Desktop WSL 2 Backend](https://docs.docker.com/desktop/features/wsl/)

    Docker Desktop Version과 다운로드 경로는 변경될 수 있으므로
    제3자 사이트보다 Docker 공식 문서를 기준으로 한다.
