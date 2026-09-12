# macOS Docker Desktop 설치 가이드

## 1. 문서 목적

본 문서는 macOS 개발 PC에서 MicroServer 로컬 Container 실행환경을 준비하기 위해
Docker Desktop을 설치하고 실제 Container 실행까지 검증하는 절차를 설명한다.

Docker Engine, CLI, Compose, Image, Container, Volume 등의 공통 개념은
**[Docker Desktop 개요 및 공통 환경](docker_desktop_setup.md)**에서 다룬다.

현재 단계의 목표:

- Mac CPU Architecture 확인
- Architecture에 맞는 Docker Desktop 설치
- Docker Desktop 초기 실행
- Docker CLI / Engine / Compose 확인
- `hello-world` Container 실행 검증

---

## 2. Mac CPU Architecture 확인

Docker Desktop을 다운로드하기 전에 Mac의 CPU Architecture를 확인한다.

Terminal:

```bash
uname -m
```

Apple Silicon:

```text
arm64
```

Intel:

```text
x86_64
```

macOS에서도 확인할 수 있다.

```text
Apple 메뉴
→ 이 Mac에 관하여
→ Chip / Processor
```

Apple Silicon Mac은 Apple Silicon용 Package를 사용하고,
Intel Mac은 Intel용 Package를 사용한다.

---

## 3. Docker Desktop 다운로드

Docker Desktop은 Docker 공식 사이트에서 다운로드한다.

- [Docker Desktop 공식 다운로드](https://www.docker.com/products/docker-desktop/)
- [Docker Desktop for Mac 공식 설치 문서](https://docs.docker.com/desktop/setup/install/mac-install/)

Architecture에 맞는 Package를 선택한다.

Apple Silicon:

```text
Download for Mac - Apple Silicon
```

Intel:

```text
Download for Mac - Intel
```

다운로드가 완료되면 일반적으로 다음 파일을 확인할 수 있다.

```text
~/Downloads/Docker.dmg
```

!!! important "공식 Package 사용"
    Apple Silicon Mac에서 Intel용 Package를 일부러 선택하지 않는다.

    Docker Desktop Version과 다운로드 방식은 변경될 수 있으므로
    제3자 사이트가 아닌 Docker 공식 페이지를 기준으로 한다.

---

## 4. Docker Desktop 설치

### 4.1 DMG 실행

Finder에서 다운로드한 파일을 연다.

```text
Downloads
→ Docker.dmg
→ Double Click
```

### 4.2 Applications에 설치

Installer Window에서 Docker Icon을 Applications Folder로 Drag한다.

```text
Docker.app
   ↓
Applications
```

기본 설치 위치:

```text
/Applications/Docker.app
```

### 4.3 Docker Desktop 실행

Finder:

```text
Applications
→ Docker
```

또는 Spotlight에서 `Docker`를 검색하여 실행한다.

처음 실행할 때 macOS 보안 확인이나 권한 요청이 나타날 수 있다.
Docker 공식 Application인지 확인한 뒤 설치 절차에 따라 허용한다.

### 4.4 약관 및 초기 설정

처음 실행하면 Docker Subscription Service Agreement가 표시될 수 있다.

내용을 확인하고 동의한다.

초기 설정 선택 화면이 표시되는 Version에서는 특별한 프로젝트 요구사항이 없다면
Docker가 제공하는 Recommended Settings를 기준으로 시작한다.

System 설정을 변경하기 위해 macOS Password가 요구될 수 있다.

!!! note "회사 개발 PC"
    회사 장비에서는 Docker Desktop 사용 정책, Subscription 및 관리자 권한 정책을 먼저 확인한다.

    자세한 운영 기준은 공통 Docker Desktop 문서를 참고한다.

### 4.5 Docker Engine 시작 확인

Docker Desktop을 실행한 뒤 Docker Engine이 완전히 시작될 때까지 기다린다.

Docker Desktop 화면 또는 Menu Bar에서 Engine이 정상 실행 중인지 확인한다.

---

## 5. Docker 실행 검증

Docker Desktop이 실행된 상태에서 새 Terminal을 열고 다음 순서로 확인한다.

### 5.1 Docker CLI

```bash
docker --version
```

Docker CLI Version이 표시되어야 한다.

### 5.2 Client / Server

```bash
docker version
```

정상 상태에서는 **Client와 Server 정보가 모두 표시**되어야 한다.

!!! warning "Server 연결 오류"
    Client 정보만 표시되고 Server 연결 오류가 발생하면
    Docker Desktop 또는 Docker Engine이 아직 정상적으로 시작되지 않았을 수 있다.

### 5.3 Docker Engine

```bash
docker info
```

Docker Engine 정보가 정상적으로 조회되어야 한다.

### 5.4 Docker Compose

```bash
docker compose version
```

Docker Compose Version이 표시되어야 한다.

### 5.5 Container 실행

```bash
docker run --rm hello-world
```

`hello-world` Image가 없으면 Docker가 Image를 내려받은 뒤 Container를 실행한다.

정상적으로 완료되면 Docker Desktop의 기본 Container 실행환경이 준비된 것이다.

```text
Docker CLI           ✅
Docker Desktop       ✅
Docker Engine        ✅
Docker Compose       ✅
Container 실행       ✅
```

---

## 6. macOS 문제 확인

### 6.1 Docker Desktop이 실행되지 않음

다음을 확인한다.

- Mac CPU Architecture와 설치 Package가 일치하는지
- macOS 보안 / 권한 Prompt가 남아 있는지
- 현재 macOS Version을 Docker Desktop이 지원하는지
- Docker Desktop Log에 오류가 있는지

### 6.2 `docker version`에서 Server 연결 실패

Docker Desktop이 실행 중이고 Engine 시작이 완료되었는지 확인한다.

```bash
docker version
docker info
```

Client는 조회되지만 Server가 조회되지 않는다면 Docker Engine 상태를 먼저 확인한다.

### 6.3 Apple Silicon과 Container Image

Apple Silicon에서는 사용할 Container Image가 `linux/arm64`를 지원하는지 확인할 필요가 있다.

MicroServer에서 사용할 Oracle Database Free Image의 Apple Silicon 지원 여부와
실제 실행 검증은 Oracle 관련 별도 문서에서 진행한다.

---

## 7. 체크리스트

- [ ] `uname -m`으로 Mac Architecture를 확인했다.
- [ ] Architecture에 맞는 Docker Desktop Package를 선택했다.
- [ ] Docker 공식 사이트에서 `Docker.dmg`를 다운로드했다.
- [ ] Docker.app을 `/Applications`에 설치했다.
- [ ] Docker Desktop을 실행하고 Engine 시작을 확인했다.
- [ ] `docker --version`이 정상 실행된다.
- [ ] `docker version`에서 Client / Server 정보가 모두 표시된다.
- [ ] `docker info`가 정상 실행된다.
- [ ] `docker compose version`이 정상 실행된다.
- [ ] `docker run --rm hello-world`가 정상 실행된다.

---

## 8. 다음 단계

macOS Docker Desktop 설치와 실행 검증이 완료되면
**Oracle Database Free 로컬 개발환경 구성** 단계로 이동한다.

Apple Silicon Mac에서는 Oracle Database Image를 사용하기 전에
Architecture 지원 여부를 Oracle 관련 가이드에서 확인한다.

```text
Docker Desktop 설치 / 검증       ← 현재 완료
        ↓
Oracle Image Architecture 확인
        ↓
Oracle Database Free Container 구성
```

## 참고

- [Docker Desktop 공식 다운로드](https://www.docker.com/products/docker-desktop/)
- [Docker Desktop for Mac 설치](https://docs.docker.com/desktop/setup/install/mac-install/)
- [Docker Compose](https://docs.docker.com/compose/)
