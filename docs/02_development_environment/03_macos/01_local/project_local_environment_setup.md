# macOS 프로젝트 로컬 개발환경 구성

## 1. 문서 목적

이 문서는 Apple Silicon 기반 macOS 개발장비에서 MicroServer 프로젝트의 **표준 로컬 개발환경 Root와 Directory 구조, 개발도구 배치 기준, Workspace 구성, 실행 Script 및 개발환경 Package 운영 방법**을 정의한다.

MicroServer macOS 개발환경은 개발자별 환경 차이를 줄이고 다른 개발장비에서도 동일한 구조를 쉽게 복원할 수 있도록 다음 표준 Root를 사용한다.

```text
~/local-microserver
```

개발자는 해당 Root 아래에서 JDK, Gradle, VS Code, Gradle Cache, Workspace 및 실행 Script를 일관된 구조로 관리한다.

---

## 2. 표준 Directory 구조

```text
~/local-microserver
├─ tools
│  ├─ jdk
│  │  └─ temurin-25.jdk
│  │     └─ Contents
│  │        └─ Home
│  ├─ gradle
│  │  └─ gradle-<version>
│  └─ vscode
│     ├─ Visual Studio Code.app
│     └─ code-portable-data
│        ├─ user-data
│        └─ extensions
│
├─ gradle-home
│
├─ workspace
│  ├─ microserver
│  └─ microserver-docs
│
├─ env
│  ├─ setup.command
│  ├─ create-vscode-shortcut.command
│  ├─ start-vscode.command
│  ├─ local-env.example.sh
│  └─ local-env.sh
│
└─ README.md
```

Directory 이름은 가능한 한 표준 구조를 유지한다. 개발자마다 임의의 위치에 JDK, Gradle, VS Code를 배치하면 환경 재현성과 문제 분석이 어려워진다.

---

## 3. 하나의 Root로 관리하는 이유

`~/local-microserver`를 개발환경 기준 Root로 사용하면 다음 장점이 있다.

- JDK / Gradle / VS Code Version을 프로젝트 기준으로 통제할 수 있다.
- 개인 macOS 환경과 MicroServer 개발환경을 분리할 수 있다.
- 다른 Mac으로 개발환경을 옮길 때 동일 Directory 구조를 쉽게 복원할 수 있다.
- 개발도구, Settings, Extension, Cache, Workspace의 관계를 명확하게 관리할 수 있다.
- 문서의 경로 예제와 실제 개발환경의 경로를 일치시킬 수 있다.
- 개발자 Home Directory의 임의 경로에 대한 의존성을 최소화할 수 있다.

!!! important "표준 Root 사용"
    MicroServer 관련 개발도구와 Workspace는 가능한 한 `~/local-microserver` 아래에 배치한다.

    단, Docker Desktop처럼 macOS 시스템 서비스 및 가상화 환경과 결합되는 Software는 별도 설치 대상으로 관리한다.

---

## 4. 개발도구 배치 기준

### 4.1 JDK

Apple Silicon용 JDK 압축 배포본을 다음 위치에 배치한다.

```text
~/local-microserver/tools/jdk/temurin-25.jdk/Contents/Home
```

MicroServer 개발환경을 위해 macOS 시스템 전체의 Java 설정을 불필요하게 변경하지 않는다.

VS Code 실행 Script 또는 개발 Session에서 필요한 JDK를 선택하도록 구성한다.

### 4.2 Gradle

검증된 Gradle Binary Distribution은 다음 위치에 배치한다.

```text
~/local-microserver/tools/gradle/gradle-<version>
```

프로젝트 생성 이후 실제 Build는 Gradle Wrapper 사용을 기본으로 한다.

```bash
./gradlew build
```

### 4.3 VS Code

VS Code는 다음 구조로 관리한다.

```text
~/local-microserver/tools/vscode
├─ Visual Studio Code.app
└─ code-portable-data
```

`code-portable-data`에는 Portable User Data와 Extension을 보관한다.

---

## 5. Gradle Cache 관리

Gradle Cache를 프로젝트 개발환경과 함께 분리 관리하기 위해 다음 Directory를 사용한다.

```text
~/local-microserver/gradle-home
```

실행 환경에서는 다음과 같이 사용할 수 있다.

```bash
export GRADLE_USER_HOME="$HOME/local-microserver/gradle-home"
```

### 5.1 개발환경 Package에 Cache 포함 여부

Gradle Cache는 용량이 크고 재생성 가능하므로 **기본 개발환경 Package에는 포함하지 않는 것을 권장**한다.

다만 인터넷 접근이 제한된 개발망에서 사전 검증된 Dependency Cache를 함께 배포해야 하는 경우에는 별도 정책에 따라 포함할 수 있다.

---

## 6. Workspace 배치 기준

실제 Source Repository는 `workspace` 아래에 배치한다.

```text
~/local-microserver/workspace
├─ microserver
└─ microserver-docs
```

Workspace는 개발도구 Directory와 분리한다.

```text
tools      → 개발도구
workspace  → Source Repository
gradle-home → Build Cache
env        → 실행환경 Script 및 개인 환경설정
```

이 구조를 사용하면 개발도구를 교체하거나 Version을 올리더라도 Source Repository에 영향을 주지 않는다.

---

## 7. Git Repository와 개발환경 Package의 경계

`~/local-microserver` 전체를 하나의 Git Repository로 만들지 않는다.

각 프로젝트는 `workspace` 아래에서 독립 Repository로 관리한다.

```text
~/local-microserver/workspace/microserver/.git
~/local-microserver/workspace/microserver-docs/.git
```

다음 항목은 Source Repository에 포함하지 않는다.

```text
JDK Binary
Gradle Binary
VS Code Application
VS Code Portable User Data 전체
Gradle Cache
개인 Secret
Docker / Oracle 실제 Data Volume
```

!!! note "개발환경 Package와 Git Repository"
    Git Repository는 Source와 프로젝트 설정을 Version 관리하기 위한 영역이다.

    개발환경 Package는 개발자가 동일한 개발도구와 Directory 구조를 빠르게 구성하기 위한 배포 단위이다.

    두 영역은 목적이 다르므로 분리해서 관리한다.

---

## 8. Local 환경설정 파일

공용 예제 파일과 개인 설정 파일을 구분한다.

```text
local-env.example.sh  → 공용 Example
local-env.sh          → 개발자 개인 설정
```

`local-env.example.sh`에는 필요한 환경변수의 이름과 작성 예제를 제공한다.

```bash
# export MICROSERVER_DB_USER="microserver"
# export MICROSERVER_DB_PASSWORD="change-me"
```

개발자는 이를 복사하여 자신의 `local-env.sh`를 구성한다.

```bash
cp ~/local-microserver/env/local-env.example.sh \
   ~/local-microserver/env/local-env.sh
```

`local-env.sh`에는 Password, Token 등 개인 또는 보안정보가 포함될 수 있으므로 Git Repository와 공용 개발환경 Package에 포함하지 않는다.

---

## 9. 실행 Script 역할

### 9.1 `setup.command`

초기 Directory와 Local 환경파일을 준비한다.

```text
개발환경 Package 압축 해제
        ↓
setup.command 실행
        ↓
Directory / 권한 / local-env 초기화
```

### 9.2 `create-vscode-shortcut.command`

개발자가 Finder 또는 Desktop에서 쉽게 MicroServer 개발환경을 시작할 수 있도록 실행 Shortcut을 구성한다.

예:

```text
~/Desktop/MicroServer VS Code.command
```

### 9.3 `start-vscode.command`

MicroServer 전용 Session 환경을 구성하고 VS Code를 실행한다.

주요 역할:

```text
JAVA_HOME 설정
GRADLE_HOME 설정
GRADLE_USER_HOME 설정
PATH 구성
local-env.sh 적용
VS Code 실행
workspace 열기
```

---

## 10. 초기 개발환경 구성 절차

개발환경 Package를 전달받은 후 다음 순서로 구성한다.

### 10.1 Package 압축 해제

```text
~/local-microserver
```

### 10.2 Script 실행 권한 부여

```bash
chmod +x ~/local-microserver/env/*.command
```

### 10.3 초기 Setup 실행

```bash
~/local-microserver/env/setup.command
```

### 10.4 VS Code Shortcut 생성

```bash
~/local-microserver/env/create-vscode-shortcut.command
```

### 10.5 MicroServer VS Code 실행

```text
MicroServer VS Code.command
```

최종적으로 `start-vscode.command`가 개발환경 변수를 적용하고 VS Code를 실행한다.

---

## 11. 개발환경 전달 방식

다른 개발자에게 개발환경을 전달할 때는 다음과 같은 Package 구조를 기본으로 한다.

```text
local-microserver
├─ tools
├─ workspace        # 필요 시 제외 가능
├─ env
├─ gradle-home      # 기본적으로 제외 권장
└─ README.md
```

### 11.1 기본 포함 권장

```text
JDK
Gradle
VS Code
VS Code Portable 기본 Settings
표준 Extension
환경 Setup Script
Launcher Script
Example 환경설정 파일
```

### 11.2 기본 제외 권장

```text
개인 Password / Token
SSH Private Key
local-env.sh
Gradle Cache
Oracle Data Volume
개인 작업 파일
```

Source Repository는 Package에 고정해서 넣기보다 Git에서 Clone하도록 운영할 수도 있다. 프로젝트 배포 방식에 따라 `workspace` 포함 여부를 결정한다.

---

## 12. 사용자 경로 의존 최소화

Script와 설정에서는 개발자의 실제 사용자명을 직접 사용하지 않는다.

잘못된 예:

```text
/Users/kim/local-microserver
```

권장:

```text
~/local-microserver
$HOME/local-microserver
```

Script에서는 가능한 한 Script 자신의 위치를 기준으로 Root를 계산한다.

```bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
```

이를 통해 개발환경 Directory 전체를 다른 Mac으로 옮겨도 Script 수정 범위를 줄일 수 있다.

---

## 13. 상대경로 사용 원칙

설정 파일에서 개발환경 Root 내부 파일을 참조할 때는 가능한 경우 상대적인 구조를 유지한다.

예:

```text
env/start-vscode.command
../tools/jdk
../tools/gradle
../workspace
```

절대경로가 필요한 경우 `$HOME/local-microserver` 또는 Script에서 계산한 Root를 사용한다.

---

## 14. macOS 실행 권한 및 Gatekeeper

`.command` Script에는 실행 권한이 필요하다.

```bash
chmod +x ~/local-microserver/env/*.command
```

다운로드한 Application이나 Script가 macOS Gatekeeper 정책의 영향을 받을 수 있으므로 회사 장비에서는 조직 보안정책을 우선한다.

실행이 차단되는 경우 무조건 보안기능을 해제하기보다 파일 출처와 조직 정책을 먼저 확인한다.

---

## 15. 개발환경 기본 검증

### Architecture

```bash
uname -m
```

Apple Silicon에서는 일반적으로 다음이 표시된다.

```text
arm64
```

### Git

```bash
git --version
```

### Java

```bash
java -version
javac -version
```

### Gradle

```bash
gradle --version
```

프로젝트 생성 이후에는 다음 명령도 확인한다.

```bash
./gradlew --version
```

---

## 16. 권장 구성 순서

macOS 개발환경은 다음 순서로 구성한다.

```text
프로젝트 로컬 개발환경 구성
        ↓
Git / GitHub 환경 구성
        ↓
JDK 설치 및 설정
        ↓
Gradle 빌드환경 설치
        ↓
VS Code 개발환경 설치
        ↓
Docker 개발환경 설치
        ↓
Oracle 개발환경 설치
```

각 단계가 완료된 후 다음 단계로 이동한다.

---

## 17. 구성 완료 기준

- [ ] `~/local-microserver` 표준 Root가 존재한다.
- [ ] `tools`, `workspace`, `gradle-home`, `env` Directory가 구분되어 있다.
- [ ] Apple Silicon용 JDK가 `tools/jdk` 아래에 있다.
- [ ] Gradle Binary가 `tools/gradle` 아래에 있다.
- [ ] VS Code와 `code-portable-data`가 `tools/vscode` 아래에 있다.
- [ ] 각 Source는 `workspace` 아래에서 독립 Git Repository로 관리된다.
- [ ] `local-env.example.sh`와 개인 `local-env.sh`의 역할을 구분한다.
- [ ] `.command` Script에 실행 권한이 있다.
- [ ] `setup.command`가 정상 실행된다.
- [ ] VS Code Shortcut이 생성된다.
- [ ] Shortcut을 통해 MicroServer 전용 VS Code가 실행된다.
- [ ] VS Code Terminal에서 JDK와 Gradle이 정상 인식된다.
- [ ] 개인 Secret과 Cache가 공용 Package에 포함되지 않는다.

---

## 18. 관련 가이드

다음 순서로 문서를 참고한다.

1. Git / GitHub 환경 구성
2. JDK 설치 및 설정
3. Gradle 빌드환경 설치
4. VS Code 개발환경 설치
5. Docker 개발환경 설치
6. Oracle 개발환경 설치

---

## 19. 정리

macOS MicroServer 개발환경은 `~/local-microserver`를 기준으로 개발도구, Cache, Workspace, 실행 Script를 분리하여 관리한다.

핵심 운영 원칙은 다음과 같다.

```text
표준 Root 사용
+ 개발도구와 Source 분리
+ Git Repository 독립 관리
+ 개인 Secret 분리
+ Portable VS Code 운영
+ Script 기반 실행환경 구성
+ 사용자별 절대경로 의존 최소화
```

이 구조를 유지하면 Apple Silicon 기반 macOS 개발장비에서도 MicroServer 프로젝트의 개발환경을 일관되게 구성하고 다른 장비로 쉽게 복원할 수 있다.
