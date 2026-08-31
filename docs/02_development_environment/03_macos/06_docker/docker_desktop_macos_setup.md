# macOS Docker Desktop 설치 가이드

## 1. 문서 목적

본 문서는 macOS 개발 PC에서 MicroServer 로컬 Container 실행환경을 준비하기 위해
Docker Desktop을 다운로드하고 설치한 뒤 Docker Engine과 Compose를 검증하는 과정을 설명한다.

Docker Desktop의 공통 개념과 Image / Container / Volume 등의 설명은
[Docker Desktop 개요 및 공통 환경 가이드](docker_desktop_setup.md)를 참고한다.

현재 문서에서는 다음 내용을 진행한다.

- Mac CPU Architecture 확인
- Apple Silicon / Intel Package 구분
- Docker Desktop 공식 다운로드
- `Docker.dmg` 설치
- Docker Desktop 초기 실행
- Docker CLI / Engine / Compose 확인
- `hello-world` Container 실행 검증

---

## 2. Mac CPU Architecture 확인

macOS에서는 Docker Desktop 다운로드 전에
Mac이 Apple Silicon인지 Intel인지 먼저 확인한다.

Terminal:

```bash
uname -m
```

Apple Silicon Mac:

```text
arm64
```

Intel Mac:

```text
x86_64
```

또는 macOS의 다음 화면에서도 확인할 수 있다.

```text
Apple 메뉴
→ 이 Mac에 관하여(About This Mac)
→ Chip / Processor
```

Apple Silicon:

```text
Apple M1 / M2 / M3 / M4 / ...
```

Intel Mac:

```text
Intel ...
```

Docker Desktop은 Mac Architecture에 맞는 설치 Package를 사용한다.

---

## 3. macOS Docker Desktop 다운로드

Docker Desktop은 Docker 공식 사이트에서 다운로드한다.

### 3.1 공식 다운로드 페이지 접속

Docker Desktop은 반드시 Docker 공식 사이트에서 다운로드한다.

!!! info "Docker Desktop for Mac 다운로드"
    Mac의 CPU Architecture를 먼저 확인한 뒤 공식 다운로드 페이지에서
    Apple Silicon 또는 Intel에 맞는 Package를 선택한다.

    - [Docker Desktop 공식 다운로드 페이지](https://www.docker.com/products/docker-desktop/)
    - [Docker Desktop for Mac 공식 설치 문서](https://docs.docker.com/desktop/setup/install/mac-install/)

### 3.2 Architecture에 맞는 Package 선택

Apple Silicon Mac:

```text
Download for Mac - Apple Silicon
```

Intel Mac:

```text
Download for Mac - Intel
```

Apple Silicon Mac에서 Intel용 Package를 일부러 선택하지 않는다.

### 3.3 다운로드 파일 확인

다운로드가 완료되면 일반적으로 다음 파일을 확인할 수 있다.

```text
Docker.dmg
```

보통 Finder의 `Downloads` Directory에 저장된다.

```text
~/Downloads/Docker.dmg
```

---

## 4. macOS Docker Desktop 설치

### 4.1 DMG 열기

Finder:

```text
Downloads
→ Docker.dmg
→ Double Click
```

### 4.2 Applications로 복사

Installer Window가 열리면
Docker Icon을 Applications Folder로 Drag한다.

```text
Docker.app
   ↓ Drag
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

또는 Launchpad / Spotlight에서:

```text
Docker
```

를 검색하여 실행한다.

macOS가 처음 실행하는 Application에 대한 보안 확인이나 권한을 요청할 수 있다.
Docker 공식 Application임을 확인하고 설치 절차에 따라 허용한다.

### 4.4 약관 및 초기 설정

처음 실행하면 Docker Subscription Service Agreement가 표시될 수 있다.
내용을 확인하고 동의한다.

초기 설정 선택 화면이 나타나는 Version에서는
특별한 요구사항이 없다면 Docker가 제시하는 **Recommended Settings**를 기준으로 시작한다.

macOS Password가 필요한 System 설정을 요청할 수 있다.

### 4.5 Engine 시작 대기

Docker Desktop을 실행한 뒤
Engine이 완전히 시작될 때까지 기다린다.

Docker Desktop 메뉴나 Application 화면에서
Engine이 정상 실행 중인지 확인한다.

---

## 5. macOS Docker CLI / Engine 확인

Docker Desktop이 실행된 상태에서
새 Terminal을 열고 다음 명령을 순서대로 실행한다.

Docker CLI:

```bash
docker --version
```

Client / Server:

```bash
docker version
```

Docker Engine:

```bash
docker info
```

Docker Compose:

```bash
docker compose version
```

기본 Container 실행:

```bash
docker run --rm hello-world
```

정상 상태에서는 `docker version`에서
Client뿐 아니라 Server 정보도 확인할 수 있어야 한다.

```text
Docker CLI           ✅
Docker Desktop       ✅
Docker Engine        ✅
Docker Compose       ✅
Container 실행       ✅
```

Apple Silicon에서 Oracle Database Free를 사용할 경우
추가 Architecture 검증은 별도의 다음 문서에서 수행한다.

```text
Apple Silicon Oracle Docker 지원 및 검증 가이드
```

---

## 6. macOS 자주 발생하는 문제

### 6.1 Docker Desktop이 실행되지 않음

다음 항목을 확인한다.

- Mac CPU Architecture와 설치 Package 일치 여부
- macOS 보안 / 권한 Prompt
- Docker Desktop 지원 macOS Version
- Virtualization 관련 환경
- Docker Desktop Logs

### 6.2 `docker version`에서 Server 연결 실패

Docker Desktop Application이 실행 중인지 확인한다.

```bash
docker version
docker info
```

Client만 표시되고 Server가 조회되지 않으면
Docker Engine이 아직 준비되지 않았을 수 있다.

### 6.3 Apple Silicon에서 x86_64 Image 사용

Apple Silicon에서는 Image가 `linux/arm64`를 지원하는지 확인해야 한다.

Oracle Database Free의 Apple Silicon 지원 및 Architecture 검증은
별도 문서에서 진행한다.

```text
oracle_docker_apple_silicon_support.md
```

---

## 7. macOS 체크리스트

- [ ] `uname -m`으로 Mac Architecture를 확인했다.
- [ ] Apple Silicon 또는 Intel에 맞는 Docker Desktop Package를 선택했다.
- [ ] Docker 공식 사이트에서 `Docker.dmg`를 다운로드했다.
- [ ] Docker.app을 `/Applications`에 설치했다.
- [ ] Docker Desktop을 실행했다.
- [ ] `docker --version`이 정상 실행된다.
- [ ] `docker version`에서 Client / Server 정보가 모두 표시된다.
- [ ] `docker info`가 정상 실행된다.
- [ ] `docker compose version`이 정상 실행된다.
- [ ] `docker run --rm hello-world`가 정상 실행된다.
- [ ] Apple Silicon에서 Oracle을 사용할 경우 별도 Architecture 검증 문서를 확인한다.

---

## 8. 다음 단계

macOS Docker Desktop 구성이 완료되면 다음 문서로 이동한다.

```text
Oracle Database Free 로컬 개발환경 구성
```

Apple Silicon Mac에서는 필요에 따라 다음 문서도 확인한다.

```text
Apple Silicon Oracle Docker 지원 및 검증
```

---

## 9. 공식 참고 자료

!!! tip "macOS Docker 공식 문서"
    - [Docker Desktop 공식 다운로드 페이지](https://www.docker.com/products/docker-desktop/)
    - [Docker Desktop for Mac 설치](https://docs.docker.com/desktop/setup/install/mac-install/)
    - [Docker Compose 설치 및 사용](https://docs.docker.com/compose/install/)

    Docker Desktop Version과 다운로드 경로는 변경될 수 있으므로
    제3자 사이트보다 Docker 공식 문서를 기준으로 한다.
