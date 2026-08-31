# macOS Gradle 설치 및 기본 환경 구성

## 1. 문서 목적

본 문서는 Windows 및 macOS 개발 PC에서 **Gradle 9.7.1을 설치하고 기본 실행환경을 확인하는 방법**을 설명한다.

문서 구조는 하나의 최상위 제목 아래에서 Windows와 macOS 환경을 구분하여 구성한다.
이를 통해 MkDocs 오른쪽 목차(TOC)에서도 OS별 설치 절차와 세부 항목이 계층적으로 표시되도록 한다.

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

## 3. Gradle 공식 다운로드

Gradle은 반드시 **공식 Gradle 사이트**에서 다운로드한다.

### 3.1 공식 Releases 페이지

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

### 3.2 `bin`과 `all`의 차이

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

## 4. Gradle 설치가 반드시 필요한가

Gradle 공식 문서는 **기존 프로젝트에 `gradlew` 또는 `gradlew`가 있다면 Gradle을 별도로 설치하지 않아도 된다**고 설명한다.

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

## 6. macOS 환경 구성

### 6.1 macOS 설치 방법 선택

macOS에서는 크게 두 가지 방식이 있다.

```text
방법 A. 공식 Binary ZIP 직접 설치
방법 B. Homebrew 설치
```

MicroServer 문서에서는 Version 위치를 명확히 알 수 있는 **Binary ZIP 직접 설치 방식**을 기본 설명으로 사용한다.

Homebrew는 편의 설치 방식으로 함께 소개한다.

---

### 6.2 macOS Binary ZIP 직접 설치

Gradle 공식 Releases 페이지에서 다음 파일을 다운로드한다.

```text
gradle-9.7.1-bin.zip
```

권장 Directory 예:

```text
~/local-microserver/tools/gradle/gradle-9.7.1
```

예상 구조:

```text
~/local-microserver/tools/gradle/
└─ gradle-9.7.1/
   ├─ bin/
   ├─ init.d/
   ├─ lib/
   ├─ LICENSE
   └─ NOTICE
```

---

### 6.3 macOS 현재 Terminal Session에서 실행

예를 들어 JDK와 Gradle을 다음 경로에 두었다고 가정한다.

```text
JDK
~/local-microserver/jdks/temurin-25.jdk/Contents/Home

Gradle
~/local-microserver/tools/gradle/gradle-9.7.1
```

현재 Terminal Session에 설정한다.

```bash
export JAVA_HOME="$HOME/dev/jdks/temurin-25.jdk/Contents/Home"
export GRADLE_HOME="$HOME/dev/tools/gradle/gradle-9.7.1"
export PATH="$JAVA_HOME/bin:$GRADLE_HOME/bin:$PATH"
```

확인:

```bash
java -version
gradle --version
```

---

### 6.4 macOS Homebrew 설치

Homebrew를 사용하는 경우 다음 명령으로 설치할 수 있다.

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

!!! warning "프로젝트 Version과 Homebrew Version은 다를 수 있음"
    Homebrew가 Gradle을 Upgrade하면 `gradle` 명령의 Version이 변경될 수 있다.

    하지만 MicroServer 프로젝트의 실제 Build는 `./gradlew`가 지정한 Version을 사용하므로 프로젝트 Build 기준은 변경되지 않는다.

---

## 7. `gradle` 명령이 어떤 실행파일을 사용하는지 확인


macOS:

```bash
which gradle
```

이 명령은 **현재 PATH에서 어떤 Gradle 실행파일이 선택되는지** 확인하는 용도이다.

여러 Gradle Version이나 Package Manager를 함께 사용하는 경우 유용하다.

---

## 8. Gradle 실행 JVM 확인

다음 명령을 실행한다.

```bash
gradle --version
```

출력에서 JVM 정보를 확인한다.

Gradle 자체가 Java 25으로 실행되어야 하는 경우 JVM 항목이 Java 25인지 확인한다.

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
which java
java -version
```

---

## 9. 설치 완료 기준

다음 항목을 확인하면 개발 PC Gradle 기본 환경 구성이 완료된 것이다.

- [ ] JDK 25 LTS가 준비되어 있다.
- [ ] Gradle 공식 사이트에서 9.7.1 Binary Distribution을 확인했다.
- [ ] Gradle을 `~/local-microserver/tools/gradle/gradle-9.7.1`에 설치했다.
- [ ] `gradle --version`이 실행된다.
- [ ] Gradle 출력에서 사용 중인 JVM을 확인할 수 있다.
- [ ] `GRADLE_HOME`과 `GRADLE_USER_HOME`의 차이를 이해했다.
- [ ] 실제 프로젝트 Build는 설치본이 아니라 Wrapper를 사용할 것임을 이해했다.

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
