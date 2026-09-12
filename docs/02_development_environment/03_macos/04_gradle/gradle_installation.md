# macOS Gradle 설치 및 기본 환경 구성

## 1. 문서 목적

본 문서는 MicroServer **macOS 표준 로컬 개발환경**에 Gradle 9.7.1을 배치하고, Eclipse Temurin JDK 25 LTS와 연계하여 기본 실행환경을 확인하는 방법을 설명한다.

이 문서는 Windows와 macOS 설치 절차를 한 문서에 혼합하지 않는다.

Windows에서 먼저 확정한 MicroServer 로컬 개발환경 운영 원칙을 유지하되,
macOS에서 확정한 표준 Root와 Directory 구조에 맞추어 Gradle 환경을 구성한다.

```text
macOS 표준 Root
~/local-microserver
```

중요한 점은 다음과 같다.

> 개발 PC에 Gradle을 설치하는 것과 실제 프로젝트가 사용하는 Gradle Version은 별개의 개념이다.

MicroServer 프로젝트의 실제 Build는 프로젝트에 포함되는 **Gradle Wrapper**를 기준으로 한다.

따라서 개발 PC Gradle 설치는 다음 목적의 **기본 개발도구 준비 단계**로 이해한다.

- Gradle 명령 학습
- Gradle Version 확인
- Wrapper가 없는 프로젝트의 초기 Wrapper 생성
- Build 환경 점검 및 관리

Wrapper의 상세 개념은 별도 문서에서 설명한다.

→ [Gradle Wrapper 및 프로젝트 운영 원칙](gradle_wrapper.md)

---

## 2. 사전 준비

Gradle은 JVM 위에서 실행되므로 JDK가 필요하다.

MicroServer에서는 앞 단계에서 **Eclipse Temurin JDK 25 LTS** 환경을 준비한다.

Gradle 9.7.1은 Java 25 JVM에서 실행할 수 있으므로
MicroServer의 **Temurin 25 LTS + Gradle 9.7.1** 조합을 사용할 수 있다.

!!! info "Gradle / Java 호환성"
    Gradle 9.7.1 공식 Compatibility Matrix에서는 Gradle 실행 JVM으로 Java 17부터 26까지를 지원한다.

    따라서 프로젝트 표준인 Java 25 LTS는 Gradle 9.7.1 실행환경으로 지원 범위에 포함된다.

    **[Gradle Compatibility Matrix](https://docs.gradle.org/current/userguide/compatibility.html)**

먼저 Java가 정상적으로 실행되는지 확인한다.


macOS Terminal:

```bash
java -version
javac -version
```

MicroServer에서는 OS 전체 `JAVA_HOME`을 하나의 JDK로 영구 고정하기보다  
프로젝트 및 Terminal Session에서 필요한 JDK를 명시적으로 선택하는 방식을 기본으로 한다.

---

## 3. macOS 표준 개발환경 구조 확인

Gradle을 설치하기 전에 macOS MicroServer 개발환경의 표준 Directory 구조를 확인한다.

```text
~/local-microserver
├─ tools
│  ├─ jdk
│  │  └─ temurin-25
│  ├─ gradle
│  │  └─ gradle-9.7.1
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

Gradle 관련 위치는 다음 세 영역으로 구분한다.

| 구분 | 표준 위치 | 역할 |
|---|---|---|
| Local Gradle | `~/local-microserver/tools/gradle/gradle-9.7.1` | Gradle 학습, 확인, Wrapper 생성/복구 |
| Gradle User Home | `~/local-microserver/gradle-home` | Cache, Wrapper Distribution, Daemon 등 |
| 프로젝트 Wrapper | `~/local-microserver/workspace/<project>/gradlew` | 실제 프로젝트 Build 기준 |

!!! important "경로 기준"
    이 문서에서는 임의의 `~/dev`, `~/dev/tools`, `~/dev/jdks` 경로를 사용하지 않는다.

    JDK, Gradle, VS Code, Workspace는 모두 이미 정의한
    `~/local-microserver` 표준 Root를 기준으로 설명한다.

---

## 4. Gradle 공식 다운로드

Gradle은 반드시 **공식 Gradle 사이트**에서 다운로드한다.

### 4.1 공식 Releases 페이지

[Gradle 공식 Releases 페이지](https://gradle.org/releases/)

현재 프로젝트 기준 Version은 다음과 같다.

```text
Gradle 9.7.1
```

다운로드할 파일:

```text
gradle-9.7.1-bin.zip
```

공식 Distribution 직접 경로:

[gradle-9.7.1-bin.zip](https://services.gradle.org/distributions/gradle-9.7.1-bin.zip)

Release Note:

[Gradle 9.7.1 Release Notes](https://docs.gradle.org/9.7.1/release-notes.html)

### 4.2 `bin`과 `all`의 차이

Gradle Distribution은 대표적으로 다음 두 종류가 있다.

| Distribution | 내용 | 권장 용도 |
|---|---|---|
| `-bin.zip` | Gradle 실행에 필요한 Binary | 일반 개발환경 / CI |
| `-all.zip` | Binary + Source + Documentation | Gradle Source까지 로컬에서 확인할 경우 |

MicroServer 기본 개발환경에서는 다음 파일을 사용한다.

```text
gradle-9.7.1-bin.zip
```

`-bin`으로 일반적인 Build와 Wrapper 생성에 필요한 기능을 모두 사용할 수 있다.

---

## 5. Gradle 설치가 반드시 필요한가

Gradle 공식 문서는 **기존 프로젝트에 `gradlew` 또는 `gradlew.bat`가 있다면 Gradle을 별도로 설치하지 않아도 된다**고 설명한다.

즉, 일반적인 개발 프로젝트는 다음 구조가 가능하다.

```text
JDK 설치
   ↓
Git Clone
   ↓
./gradlew build
   ↓
Wrapper가 필요한 Gradle 자동 준비
```

그러나 MicroServer 프로젝트에서는 Gradle 학습과 초기 Build 환경 관리까지 직접 진행하므로 개발 PC에 Gradle을 설치한다.

```text
프로젝트 Build
→ Wrapper 사용             [프로젝트 표준]

개발 PC Gradle 설치
→ 학습 / 초기 구성 / 관리   [개발환경 권장]
```

!!! info "공식 설치 가이드"
    [Installing Gradle](https://docs.gradle.org/current/userguide/installation.html)

---

## 6. macOS Gradle 설치 및 환경 구성

### 6.1 macOS 설치 방법 선택

macOS에서는 크게 두 가지 방식이 있다.

```text
방법 A. 공식 Binary ZIP 직접 설치
방법 B. Homebrew 설치
```

MicroServer 문서에서는 Version 위치를 명확히 알 수 있는 **Binary ZIP 직접 설치 방식**을 기본 설명으로 사용한다.

Homebrew는 편의 설치 방식으로 함께 소개한다.

---

### 6.2 Gradle Directory 준비

Gradle은 다음 표준 Directory에 배치한다.

```text
~/local-microserver/tools/gradle
```

Directory가 없다면 생성한다.

```bash
mkdir -p ~/local-microserver/tools/gradle
```

---

### 6.3 Binary ZIP 압축 해제 및 배치

Gradle 공식 Releases 페이지에서 다음 파일을 다운로드한다.

```text
gradle-9.7.1-bin.zip
```

예를 들어 파일이 macOS 기본 Download Directory에 있다면 다음과 같이 압축을 해제할 수 있다.

```bash
unzip ~/Downloads/gradle-9.7.1-bin.zip \
  -d ~/local-microserver/tools/gradle
```

압축 해제 후 다음 구조인지 확인한다.

```text
~/local-microserver/tools/gradle/
└─ gradle-9.7.1/
   ├─ bin/
   │  ├─ gradle
   │  └─ gradle.bat
   ├─ init.d/
   ├─ lib/
   ├─ LICENSE
   └─ NOTICE
```

확인:

```bash
ls -la ~/local-microserver/tools/gradle/gradle-9.7.1
```

Gradle 실행파일 확인:

```bash
test -x ~/local-microserver/tools/gradle/gradle-9.7.1/bin/gradle \
  && echo "Gradle executable OK"
```

---

### 6.4 JDK와 Gradle 표준 경로 확인

앞 단계에서 구성한 macOS JDK의 실제 Home은 다음 경로이다.

```text
~/local-microserver/tools/jdk/temurin-25/Contents/Home
```

Gradle은 다음 경로를 사용한다.

```text
~/local-microserver/tools/gradle/gradle-9.7.1
```

즉 두 개발도구는 다음처럼 동일한 Root 아래에 배치된다.

```text
~/local-microserver
└─ tools
   ├─ jdk
   │  └─ temurin-25
   │     └─ Contents
   │        └─ Home
   └─ gradle
      └─ gradle-9.7.1
```

!!! important "JDK 보관 Directory와 JAVA_HOME은 다름"
    MicroServer에서는 Temurin JDK Bundle의 바깥 Directory 이름을 `temurin-25`로 정리하여 보관한다.

    ```text
    JDK 보관 Directory
    ~/local-microserver/tools/jdk/temurin-25
    ```

    하지만 macOS Temurin JDK의 실제 Java Home은 Bundle 내부의 `Contents/Home`이다.

    ```text
    JAVA_HOME
    ~/local-microserver/tools/jdk/temurin-25/Contents/Home
    ```

    따라서 `JAVA_HOME`을 `temurin-25`까지만 지정하면 `$JAVA_HOME/bin/java`가 존재하지 않는다.


---

### 6.5 현재 Terminal Session에서 직접 실행

먼저 현재 Terminal에서 MicroServer 표준 경로를 기준으로 환경을 설정해본다.

```bash
export LOCAL_MICROSERVER="$HOME/local-microserver"

export JAVA_HOME="$LOCAL_MICROSERVER/tools/jdk/temurin-25/Contents/Home"
export GRADLE_HOME="$LOCAL_MICROSERVER/tools/gradle/gradle-9.7.1"
export GRADLE_USER_HOME="$LOCAL_MICROSERVER/gradle-home"

export PATH="$JAVA_HOME/bin:$GRADLE_HOME/bin:$PATH"
```

`gradle-home` Directory가 없다면 생성한다.

```bash
mkdir -p "$GRADLE_USER_HOME"
```

확인:

```bash
echo "$LOCAL_MICROSERVER"
echo "$JAVA_HOME"
echo "$GRADLE_HOME"
echo "$GRADLE_USER_HOME"
```

Java 확인:

```bash
"$JAVA_HOME/bin/java" -version
"$JAVA_HOME/bin/javac" -version
```

이 확인이 먼저 성공해야 `JAVA_HOME`이 실제 JDK Home을 정확히 가리키고 있는 것이다.

이후 PATH를 통한 실행도 확인한다.

```bash
which java
java -version
javac -version
```

Gradle 확인:

```bash
gradle --version
```

!!! important "현재 Terminal Session 확인용"
    위 `export` 명령은 현재 Terminal Session에서 설치 상태를 확인하기 위한 것이다.

    MicroServer macOS 표준 환경에서는 이러한 값을 개발자 개인의 `.zshrc`에
    무조건 영구 등록하는 방식보다 `~/local-microserver/env`의 환경 Script에서 관리하는 방향을 사용한다.

---

### 6.6 `GRADLE_HOME`과 `GRADLE_USER_HOME`

두 환경변수는 역할이 다르다.

```text
GRADLE_HOME
~/local-microserver/tools/gradle/gradle-9.7.1
```

`GRADLE_HOME`은 **Gradle 프로그램 자체가 위치한 Directory**이다.

```text
GRADLE_USER_HOME
~/local-microserver/gradle-home
```

`GRADLE_USER_HOME`은 Gradle이 실행되면서 사용하는 **사용자 데이터 영역**이다.

대표적으로 다음 데이터가 저장된다.

```text
~/local-microserver/gradle-home
├─ caches
├─ daemon
├─ native
├─ notifications
└─ wrapper
```

Windows에서 `C:\local-microserver\gradle-home`으로 분리했던 것과 같은 원칙을 macOS에서도 적용한다.

!!! warning "gradle-home은 Source가 아님"
    `gradle-home`은 Dependency Cache와 Wrapper Distribution 등이 저장되는 실행 데이터 영역이다.

    프로젝트 Git Repository에 Commit하지 않는다.

---

### 6.7 환경 Script와의 연계

macOS 표준 개발환경의 `env` Directory는 다음 구조를 사용한다.

```text
~/local-microserver/env
├─ setup.command
├─ create-vscode-shortcut.command
├─ start-vscode.command
├─ local-env.example.sh
└─ local-env.sh
```

Gradle 설치 단계에서는 JDK와 Gradle의 실제 경로가 다음과 같이 확정된다.

```text
JAVA_HOME
~/local-microserver/tools/jdk/temurin-25/Contents/Home

GRADLE_HOME
~/local-microserver/tools/gradle/gradle-9.7.1

GRADLE_USER_HOME
~/local-microserver/gradle-home
```

이 값들은 이후 `local-env.sh`, `setup.command`, `start-vscode.command`를 구성할 때 동일하게 사용한다.

즉 Terminal, VS Code, Gradle이 서로 다른 JDK나 Gradle 경로를 바라보지 않도록
**하나의 표준 경로를 공유하는 것**이 목적이다.

---

### 6.8 Homebrew 설치는 보조 방법



개인 개발환경에서 Homebrew를 사용하는 경우 다음 명령으로 Gradle을 설치할 수도 있다.

```bash
brew install gradle
```

확인:

```bash
gradle --version
```

현재 실행되는 Gradle의 위치를 확인하려면:

```bash
which gradle
```

!!! warning "MicroServer 표준 설치 방식은 Binary ZIP"
    MicroServer macOS 표준 개발환경은 `~/local-microserver/tools/gradle/gradle-9.7.1`에
    Binary ZIP을 직접 배치하는 방식을 기준으로 한다.

    Homebrew 설치는 개인 편의를 위한 보조 방법이며 표준 개발환경 Package의 기준으로 사용하지 않는다.

!!! warning "프로젝트 Version과 Homebrew Version은 다를 수 있음"
    Homebrew가 Gradle을 Upgrade하면 `gradle` 명령의 Version이 변경될 수 있다.

    하지만 MicroServer 프로젝트의 실제 Build는 `./gradlew`가 지정한 Version을 사용하므로 프로젝트 Build 기준은 변경되지 않는다.

---

## 7. 실제 사용 중인 Gradle 실행파일 확인


macOS:

```bash
which gradle
```

이 명령은 **현재 PATH에서 어떤 Gradle 실행파일이 선택되는지** 확인하는 용도이다.

MicroServer 표준 환경이 적용되었다면 다음 경로가 선택되어야 한다.

```text
~/local-microserver/tools/gradle/gradle-9.7.1/bin/gradle
```

Homebrew 또는 시스템의 다른 Gradle이 표시된다면 현재 Terminal의 `PATH` 순서를 확인한다.

---

## 8. Gradle 실행 JVM 확인

다음 명령을 실행한다.

```bash
gradle --version
```

출력에서 JVM 정보를 확인한다.

Gradle 자체가 Java 25로 실행되어야 하는 경우 JVM 항목이 Java 25인지 확인한다.

예:

```text
Gradle 9.7.1
...
JVM: 25 (...)
```

Java Version이 예상과 다르면 먼저 현재 Terminal의 `JAVA_HOME`과 PATH를 확인한다.


macOS:

```bash
echo "$JAVA_HOME"
echo "$GRADLE_HOME"
echo "$GRADLE_USER_HOME"
which java
which gradle
java -version
```

---

## 9. 설치 완료 기준

다음 항목을 확인하면 macOS Gradle 기본 환경 구성이 완료된 것이다.

- [ ] Eclipse Temurin JDK 25 LTS가 준비되어 있다.
- [ ] JDK 보관 Directory가 `~/local-microserver/tools/jdk/temurin-25`이다.
- [ ] 실제 `JAVA_HOME`이 `~/local-microserver/tools/jdk/temurin-25/Contents/Home`이다.
- [ ] Gradle 9.7.1 Binary Distribution을 사용한다.
- [ ] Gradle이 `~/local-microserver/tools/gradle/gradle-9.7.1`에 배치되어 있다.
- [ ] `GRADLE_USER_HOME`을 `~/local-microserver/gradle-home`으로 사용할 수 있다.
- [ ] `java -version`과 `javac -version`이 Java 25를 표시한다.
- [ ] `gradle --version`이 Gradle 9.7.1을 표시한다.
- [ ] `gradle --version`의 JVM이 Java 25인지 확인했다.
- [ ] `which gradle`이 MicroServer 표준 Gradle 경로를 가리키는지 확인했다.
- [ ] `GRADLE_HOME`과 `GRADLE_USER_HOME`의 역할 차이를 이해했다.
- [ ] Local Gradle은 개발환경 도구이고 실제 프로젝트 Build는 Wrapper를 사용한다.
- [ ] 환경변수는 이후 `~/local-microserver/env`의 Script와 동일한 경로를 사용한다.

최종 구조:

```text
~/local-microserver
├─ tools
│  ├─ jdk
│  │  └─ temurin-25
│  └─ gradle
│     └─ gradle-9.7.1
├─ gradle-home
├─ workspace
└─ env
```

---

## 10. 다음 문서

다음 문서에서는 Gradle을 사용하는 데 가장 중요한 개념인 **Gradle Wrapper**를 자세히 설명한다.

→ [Gradle Wrapper 및 프로젝트 운영 원칙](gradle_wrapper.md)

---

## 11. 공식 참고 자료

- [Gradle Releases](https://gradle.org/releases/)
- [Gradle 9.7.1 Binary Distribution](https://services.gradle.org/distributions/gradle-9.7.1-bin.zip)
- [Installing Gradle](https://docs.gradle.org/current/userguide/installation.html)
- [Gradle Compatibility Matrix](https://docs.gradle.org/current/userguide/compatibility.html)
- [Gradle 9.7.1 Release Notes](https://docs.gradle.org/9.7.1/release-notes.html)
