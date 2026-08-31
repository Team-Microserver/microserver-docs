# Windows Gradle 설치 및 기본 환경 구성

## 1. 문서 목적


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

Windows PowerShell:

```powershell
java -version
javac -version
```

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

## 5. Windows 환경 구성

### 5.1 Windows 설치 Directory 원칙

MicroServer 프로젝트의 Windows 개발환경은 개발도구와 프로젝트 관련 데이터를 다음 기준 경로 아래에서 관리한다.

```text
C:\local-microserver
```

Gradle은 다음 위치에 설치한다.

```text
C:\local-microserver\tools\gradle\gradle-9.7.1
```

JDK는 다음 위치에서 관리한다.

```text
C:\local-microserver\tools\jdk\temurin-25
```

Gradle 사용자 Cache와 Wrapper Distribution은 다음 위치에서 관리할 수 있도록 구성한다.

```text
C:\local-microserver\gradle-home
```

전체 구조는 다음과 같다.

```text
C:\local-microserver
│
├─ tools
│  ├─ jdk
│  │  └─ temurin-25
│  │
│  └─ gradle
│      └─ gradle-9.7.1
│
├─ gradle-home
├─ workspace
├─ repos
└─ env
```

Gradle 설치 Directory에 Version을 포함하면 향후 다른 Gradle Version이 필요해도 기존 설치를 제거하지 않고 병행하여 관리할 수 있다.

```text
tools\gradle
├─ gradle-9.7.1
└─ gradle-<other-version>
```

!!! tip "프로젝트 로컬 개발환경 기준"
    `C:\local-microserver` 전체 Directory 구조와 JDK, Gradle, VS Code Workspace,
    Git Repository를 한곳에서 관리하는 기준은 다음 가이드에서 자세히 설명한다.

    **[프로젝트 로컬 개발환경 구성](../../01_foundation/project_local_environment_setup.md)**

    현재 문서에서는 그 기준 구조 안에서 **Gradle을 실제로 설치하고 실행환경을 확인하는 방법**에 집중한다.

---

### 5.2 Windows Gradle 압축 해제

다운로드한 파일:

```text
gradle-9.7.1-bin.zip
```

압축을 다음 위치에 해제한다.

```text
C:\local-microserver\tools\gradle\gradle-9.7.1
```

정상적인 구조는 대략 다음과 같다.

```text
C:\local-microserver\tools\gradle\gradle-9.7.1\
├─ bin\
├─ init.d\
├─ lib\
├─ LICENSE
└─ NOTICE
```

다음 파일이 존재하는지 확인한다.

```text
C:\local-microserver\tools\gradle\gradle-9.7.1\bin\gradle.bat
```

---

### 5.3 Windows 현재 Terminal Session에서 실행

Windows PowerShell에서 직접 Gradle 명령을 실행하려면 현재 Terminal Session에
MicroServer 프로젝트에서 사용할 JDK와 Gradle 경로를 지정할 수 있다.

```powershell
$env:LOCAL_MICROSERVER="C:\local-microserver"

$env:JAVA_HOME="$env:LOCAL_MICROSERVER\tools\jdk\temurin-25"
$env:GRADLE_HOME="$env:LOCAL_MICROSERVER\tools\gradle\gradle-9.7.1"
$env:GRADLE_USER_HOME="$env:LOCAL_MICROSERVER\gradle-home"

$env:Path="$env:JAVA_HOME\bin;$env:GRADLE_HOME\bin;$env:Path"
```

!!! tip "PowerShell의 `$env:`는 무엇인가?"
    PowerShell에서 `$env:`는 **Windows 환경변수(Environment Variable)를 읽거나 설정할 때 사용하는 문법**이다.

    예를 들어 다음 명령은 현재 PowerShell Session의 `JAVA_HOME` 환경변수를 설정한다.

    ```powershell
    $env:JAVA_HOME="C:\local-microserver\tools\jdk\temurin-25"
    ```

    현재 설정된 값을 확인할 때는 다음과 같이 사용한다.

    ```powershell
    $env:JAVA_HOME
    ```

    Command Prompt의 다음 명령과 같은 역할이다.

    ```cmd
    set JAVA_HOME=C:\local-microserver\tools\jdk\temurin-25
    ```

    즉 PowerShell과 Command Prompt의 환경변수 설정 문법은 다음과 같이 구분된다.

    | 구분 | 환경변수 설정 | 환경변수 확인 |
    |---|---|---|
    | PowerShell | `$env:JAVA_HOME="..."` | `$env:JAVA_HOME` |
    | Command Prompt | `set JAVA_HOME=...` | `echo %JAVA_HOME%` |

    또한 `$env:LOCAL_MICROSERVER`처럼 먼저 기준 경로를 환경변수로 정의하면,
    이후 JDK와 Gradle 경로를 반복해서 전체 경로로 작성하지 않고 기준 경로를 조합하여 사용할 수 있다.

    ```powershell
    $env:LOCAL_MICROSERVER="C:\local-microserver"
    $env:JAVA_HOME="$env:LOCAL_MICROSERVER\tools\jdk\temurin-25"
    ```

    위 설정에서 실제 `JAVA_HOME` 값은 다음과 같다.

    ```text
    C:\local-microserver\tools\jdk\temurin-25
    ```

    `$env:`로 설정한 값은 기본적으로 **현재 PowerShell Session에만 적용**되며,
    PowerShell을 종료하면 해당 Session에서 설정한 값도 사라진다.

확인:

```powershell
$env:JAVA_HOME
$env:GRADLE_HOME
$env:GRADLE_USER_HOME

java -version
gradle --version
```

Gradle 출력에서 다음 항목을 확인한다.

```text
Gradle 9.7.1
JVM 25
Windows
```

실제 출력 형식은 Gradle과 JDK Build에 따라 조금 다를 수 있다.

!!! tip "매번 환경변수를 직접 입력할 필요는 없다"
    위 명령은 **현재 PowerShell Session에서 Gradle 설치 상태를 직접 확인하기 위한 예시**이다.

    MicroServer 프로젝트에서는 이후 `setup.ps1` / `setup.cmd`를 통해 일반 Terminal의 프로젝트 환경을 초기화하고,
    VS Code 개발환경에서는 Workspace / Java / Gradle 설정을 통해 필요한 환경을 자동 적용하는 방향으로 구성한다.

    따라서 평소 VS Code 개발 시 매번 위 환경변수를 수동으로 입력하는 구조로 운영하지 않는다.

!!! note "현재 Session에만 적용"
    `$env:JAVA_HOME`, `$env:GRADLE_HOME`, `$env:GRADLE_USER_HOME` 설정은
    현재 PowerShell Session에 적용된다.

    PowerShell을 종료하면 해당 Session 설정은 사라지며,
    Windows 시스템 환경변수를 영구적으로 변경하지 않는다.

---

### 5.4 `GRADLE_HOME`은 무엇인가

`GRADLE_HOME`은 **개발 PC에 직접 설치한 Gradle Distribution의 위치**를 가리키는 환경변수이다.

예:

```text
GRADLE_HOME
=
C:\local-microserver\tools\gradle\gradle-9.7.1
```

그리고 실제 실행 Script는 다음에 있다.

```text
%GRADLE_HOME%\bin\gradle.bat
```

그래서 PATH에 다음 경로를 추가하면 `gradle` 명령을 실행할 수 있다.

```text
%GRADLE_HOME%\bin
```

#### `GRADLE_HOME`과 `GRADLE_USER_HOME` 구분

`GRADLE_HOME`과 `GRADLE_USER_HOME`은 완전히 다른 개념이다.

```text
GRADLE_HOME
→ Gradle 프로그램을 설치한 위치

GRADLE_USER_HOME
→ Gradle이 사용자별 Cache와 설정을 저장하는 위치
```

예:

```text
GRADLE_HOME
C:\local-microserver\tools\gradle\gradle-9.7.1

GRADLE_USER_HOME
C:\local-microserver\gradle-home
```

둘을 같은 Directory로 설정하지 않는다.

!!! tip "MicroServer의 GRADLE_USER_HOME"
    Gradle의 기본 `GRADLE_USER_HOME`은 일반적으로 다음 위치이다.

    ```text
    C:\Users\<사용자>\.gradle
    ```

    하지만 MicroServer 프로젝트에서는 Gradle 관련 Cache와 Wrapper Distribution을
    프로젝트 기준 Directory 아래에서 관리할 수 있도록 다음 경로 사용을 권장한다.

    ```text
    C:\local-microserver\gradle-home
    ```

    이를 통해 개발자별 사용자 Home Directory에 대한 의존성을 줄이고
    프로젝트 개발환경을 `C:\local-microserver` 아래에 최대한 모아서 관리할 수 있다.

---

### 5.5 Windows PATH 영구 등록 여부

Gradle을 개발 PC에서 자주 직접 사용할 경우 Windows 환경변수에 다음을 등록할 수 있다.

```text
GRADLE_HOME=C:\local-microserver\tools\gradle\gradle-9.7.1
```

PATH:

```text
%GRADLE_HOME%\bin
```

하지만 MicroServer 프로젝트는 실제 Build에서 Wrapper를 사용하므로 **전역 Gradle PATH에 의존하는 구조로 만들지 않는다.**

권장 우선순위:

```text
1. 프로젝트 gradlew.bat
2. 필요한 관리 작업에서만 PC gradle.bat
```

따라서 전역 PATH 등록은 편의 기능이지 프로젝트 Build의 필수 조건이 아니다.

!!! tip "MicroServer 권장 방식"
    Windows 시스템 환경변수에 `JAVA_HOME`, `GRADLE_HOME`, `GRADLE_USER_HOME`을
    프로젝트용으로 영구 등록하는 방식은 기본 운영 방식으로 사용하지 않는다.

    일반 Terminal에서는 `setup.ps1` / `setup.cmd`로 현재 Session을 초기화하고,
    VS Code에서는 Workspace와 Java / Gradle 설정을 통해 프로젝트 환경을 자동 적용하는 방식을 사용한다.

---

### 5.6 Windows Gradle 경로 정리

MicroServer Windows 개발환경에서 Gradle 관련 경로는 다음과 같이 정리한다.

| 구분 | 경로 |
|---|---|
| 프로젝트 로컬 개발환경 Root | `C:\local-microserver` |
| JDK | `C:\local-microserver\tools\jdk\temurin-25` |
| Gradle 설치본 | `C:\local-microserver\tools\gradle\gradle-9.7.1` |
| `GRADLE_HOME` | `C:\local-microserver\tools\gradle\gradle-9.7.1` |
| `GRADLE_USER_HOME` | `C:\local-microserver\gradle-home` |
| 환경 초기화 Script | `C:\local-microserver\env` |
| 프로젝트 Repository | `C:\local-microserver\repos` |
| VS Code Workspace | `C:\local-microserver\workspace` |

구조상 중요한 차이는 다음과 같다.

```text
GRADLE_HOME
└─ Gradle 프로그램 자체의 설치 위치

GRADLE_USER_HOME
└─ Gradle Cache / Wrapper Distribution / 사용자 설정 위치
```

두 Directory는 역할이 다르므로 동일한 위치로 설정하지 않는다.

!!! note "macOS 경로"
    이번에 정한 `C:\local-microserver` 표준은 Windows 개발환경 기준이다.

    따라서 아래 macOS 환경 구성은 기존 macOS 경로 체계를 유지한다.
    macOS 로컬 개발환경 Root를 별도로 표준화할 경우 해당 기준에 맞춰 추후 조정한다.

---

## 7. `gradle` 명령이 어떤 실행파일을 사용하는지 확인

Windows PowerShell:

```powershell
Get-Command gradle
```

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

Windows:

```powershell
$env:JAVA_HOME
Get-Command java
java -version
```

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
- [ ] Gradle을 `C:\local-microserver\tools\gradle\gradle-9.7.1`에 설치했다.
- [ ] `gradle --version`이 실행된다.
- [ ] Gradle 출력에서 사용 중인 JVM을 확인할 수 있다.
- [ ] `GRADLE_HOME`과 `GRADLE_USER_HOME`의 차이를 이해했다.
- [ ] Windows에서는 `GRADLE_USER_HOME`을 `C:\local-microserver\gradle-home`으로 관리하는 목적을 이해했다.
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
