# JDK 설치 및 설정 가이드

## 1. 문서 목적

본 문서는 MicroServer 프로젝트의 Java 개발환경을 구성하기 위해 **Eclipse Temurin JDK(Java Development Kit)** 를 준비하고, Windows 및 macOS에서 JDK가 정상적으로 동작하는지 확인하는 방법을 설명한다.

현재 단계에서는 아직 Maven, VS Code, Spring Boot 프로젝트를 구성하지 않는다.

따라서 본 문서에서는 다음 내용만 다룬다.

- 프로젝트에서 사용할 JDK 배포판과 버전 기준
- JDK와 JRE의 차이
- Eclipse Temurin JDK 다운로드
- Windows에서 JDK 압축 해제 및 보관
- macOS에서 JDK 압축 해제 및 보관
- `java` / `javac` 실행을 통한 JDK 정상 동작 확인
- 여러 JDK 버전을 개발 장비에 함께 보관하는 운영 방식

다음 내용은 이후 단계의 가이드에서 별도로 다룬다.

- Maven 설치 및 설정
- VS Code 설치 및 Extension 구성
- VS Code에서 프로젝트별 JDK 연결
- `.vscode/settings.json`
- `java.configuration.runtimes`
- Spring Boot 프로젝트 생성
- `pom.xml` 설정
- Maven Wrapper 설정
- 애플리케이션 실행 및 Build

---

## 2. 개발환경 구성에서 JDK의 위치

MicroServer 프로젝트의 개발환경은 다음 순서로 구성한다.

```mermaid
flowchart LR
    A[Git / GitHub 환경 구성] --> B[Eclipse Temurin JDK]
    B --> C[Apache Maven]
    C --> D[VS Code]
    D --> E[Spring Boot 프로젝트 생성]
    E --> F[프로젝트 개발환경 설정]
```

현재 문서는 다음 단계에 해당한다.

```text
Git / GitHub 환경 구성
        ↓
[ Eclipse Temurin JDK 준비 ]   ← 현재
        ↓
Apache Maven 설치
        ↓
VS Code 개발환경 구성
        ↓
Spring Boot 프로젝트 생성
```

JDK는 이후 Maven과 VS Code, Spring Boot 프로젝트가 공통으로 사용하는 Java 개발 기반이므로 가장 먼저 준비한다.

---

## 3. 프로젝트 JDK 운영 원칙

MicroServer 프로젝트의 JDK 운영 원칙은 다음과 같다.

### 3.1 Eclipse Temurin 사용

프로젝트에서 사용하는 OpenJDK 배포판은 **Eclipse Temurin**으로 통일한다.

Java는 여러 OpenJDK 배포판이 존재한다.

예:

- Eclipse Temurin
- Oracle JDK
- Amazon Corretto
- Microsoft Build of OpenJDK

기능적으로 호환되는 배포판이라도 개발자마다 서로 다른 Vendor의 JDK를 사용하면 설치 경로, 배포 방식, 업데이트 정책 등이 달라질 수 있다.

따라서 MicroServer 프로젝트에서는 개발환경의 일관성을 위해 Eclipse Temurin을 표준 JDK 배포판으로 사용한다.

### 3.2 JDK는 프로젝트 Git 저장소 외부에 보관

JDK Binary는 프로젝트 Source와 분리하여 관리한다.

#### Windows

```text
C:\dev\
 ├─ jdks\
 │   ├─ temurin-26\
 │   ├─ temurin-25\
 │   └─ temurin-17\
 │
 └─ workspace\
```

#### macOS

```text
~/dev/
 ├─ jdks/
 │   ├─ temurin-26.jdk/
 │   ├─ temurin-25.jdk/
 │   └─ temurin-17.jdk/
 │
 └─ workspace/
```

JDK는 용량이 크고 운영체제와 CPU Architecture에 따라 Binary가 다르므로 Git Repository에 포함하지 않는다.

### 3.3 여러 JDK 버전을 함께 보관 가능

개발 장비에서는 하나의 JDK만 설치할 필요가 없다.

```text
Temurin JDK 17
Temurin JDK 25
Temurin JDK 26
```

각 JDK를 별도의 디렉터리에 보관해 두면 이후 프로젝트 특성에 따라 필요한 JDK를 선택하여 사용할 수 있다.

현재 단계에서는 특정 프로젝트와 JDK를 연결하지 않는다.

실제 프로젝트별 JDK 연결은 **Spring Boot 프로젝트가 생성된 이후 프로젝트 개발환경 설정 단계**에서 진행한다.

### 3.4 시스템 전역 Java 설정을 기본 방식으로 사용하지 않음

MicroServer 프로젝트에서는 다음과 같은 운영체제 전역 설정을 기본 JDK 운영 방식으로 사용하지 않는다.

```text
JAVA_HOME
PATH에 JDK/bin 등록
운영체제 기본 Java 변경
```

JDK는 개발 도구 디렉터리에 독립적으로 보관하고 필요한 도구나 프로젝트에서 해당 JDK를 명시적으로 사용하는 방향으로 구성한다.

따라서 현재 단계에서는 시스템 `JAVA_HOME`이나 JDK `bin` PATH를 영구 설정하지 않는다.

---

## 4. 프로젝트 표준 JDK

MicroServer 프로젝트에서는 **Eclipse Temurin JDK 26**을 기준으로 개발환경을 구성한다.

```text
Vendor       : Eclipse Temurin
Java Version : 26
Package Type : JDK
JVM          : HotSpot
```

본 프로젝트에서는 최신 Java 버전을 적용한다는 기준으로 Java 26을 사용한다.

!!! info "Java 버전 운영"
    프로젝트 진행 중 JDK 기준 버전이 변경될 경우 문서, 개발환경, Build 설정, CI/CD 환경을 함께 변경해야 한다.

---

## 5. JDK와 JRE의 차이

Java 개발환경에서는 JRE가 아니라 반드시 **JDK**가 필요하다.

```text
JDK
 ├─ Java Runtime
 ├─ javac Compiler
 ├─ Debug / Diagnostic Tools
 ├─ javadoc
 └─ 기타 Java 개발 도구
```

JRE는 Java 애플리케이션 실행에 필요한 Runtime을 중심으로 제공하지만, JDK에는 Java Source를 컴파일하는 `javac`와 여러 개발 도구가 포함된다.

Temurin 다운로드 시 다음 항목을 확인한다.

```text
Package Type : JDK
```

JRE Package를 선택하지 않도록 주의한다.

---

## 6. JDK 설치 방식

MicroServer 프로젝트에서는 운영체제용 Installer를 이용하여 시스템 영역에 JDK를 설치하는 방식보다 **압축 배포본을 내려받아 개발 도구 디렉터리에 직접 보관하는 방식**을 권장한다.

| 운영체제 | 권장 형식 |
|---|---|
| Windows | ZIP |
| macOS | TAR.GZ |

압축 배포본을 사용하는 이유는 다음과 같다.

- 여러 JDK 버전을 동시에 보관하기 쉽다.
- 시스템 Java 환경을 변경하지 않아도 된다.
- JDK 설치 위치를 개발자가 명확하게 관리할 수 있다.
- 기존 Java 프로젝트의 환경에 미치는 영향을 줄일 수 있다.
- 필요하지 않은 JDK를 디렉터리 단위로 제거하기 쉽다.

---

# Windows 환경

## 7. Windows 개발 장비 Architecture 확인

PowerShell:

```powershell
$env:PROCESSOR_ARCHITECTURE
```

일반적인 x64 PC:

```text
AMD64
```

이 경우 Temurin 다운로드 기준은 다음과 같다.

```text
Operating System : Windows
Architecture     : x64
Package Type     : JDK
```

ARM 기반 Windows 장비라면 해당 Architecture에 맞는 Package를 사용한다.

---

## 8. Windows Temurin JDK 다운로드

Eclipse Adoptium 공식 사이트에서 Temurin JDK를 다운로드한다.

- Eclipse Adoptium: <https://adoptium.net/>
- Temurin Releases: <https://adoptium.net/temurin/releases/>

다운로드 기준:

```text
Version      : 26
Operating OS : Windows
Architecture : x64
Package Type : JDK
JVM          : HotSpot
Archive      : ZIP
```

본 프로젝트에서는 MSI Installer보다 **ZIP 압축 배포본**을 사용한다.

---

## 9. Windows JDK 디렉터리 준비

JDK를 보관할 개발 도구 디렉터리를 생성한다.

```text
C:\dev\jdks
```

PowerShell:

```powershell
New-Item -ItemType Directory -Force C:\dev\jdks
```

여러 버전은 다음과 같이 보관할 수 있다.

```text
C:\dev\jdks
 ├─ temurin-26
 ├─ temurin-25
 └─ temurin-17
```

---

## 10. Windows JDK 압축 해제

다운로드한 Temurin ZIP 파일을 `C:\dev\jdks` 아래에 압축 해제한다.

압축 해제 후 실제 디렉터리 이름은 Release에 따라 다음처럼 생성될 수 있다.

```text
jdk-26.0.2+10
```

관리 편의를 위해 다음과 같이 정리할 수 있다.

```text
C:\dev\jdks\temurin-26
```

구조 예:

```text
C:\dev\jdks\temurin-26
 ├─ bin\
 ├─ conf\
 ├─ include\
 ├─ jmods\
 ├─ legal\
 ├─ lib\
 └─ release
```

---

## 11. Windows JDK Home 확인

JDK Home은 JDK의 최상위 디렉터리를 의미한다.

```text
C:\dev\jdks\temurin-26
```

다음과 혼동하지 않는다.

```text
O  C:\dev\jdks\temurin-26
X  C:\dev\jdks\temurin-26\bin
X  C:\dev\jdks\temurin-26\bin\java.exe
```

이 JDK Home 경로는 이후 Maven 및 VS Code 개발환경 구성에서 다시 사용한다.

---

## 12. Windows JDK 정상 동작 확인

MicroServer 프로젝트에서는 JDK를 시스템 PATH에 등록하지 않으므로 다음 명령이 바로 실행되지 않아도 된다.

```powershell
java -version
```

현재 단계에서는 JDK 실행파일을 직접 호출하여 확인한다.

### Java Runtime

```powershell
& "C:\dev\jdks\temurin-26\bin\java.exe" -version
```

### Java Compiler

```powershell
& "C:\dev\jdks\temurin-26\bin\javac.exe" -version
```

정상적인 경우 Java 26 계열 정보가 표시된다.

```text
openjdk version "26..."
OpenJDK Runtime Environment Temurin-26...
OpenJDK 64-Bit Server VM Temurin-26...
```

Compiler:

```text
javac 26...
```

---

## 13. Windows 확인 항목

다음 파일이 존재하는지 확인한다.

```text
C:\dev\jdks\temurin-26
        │
        ├─ bin\java.exe
        ├─ bin\javac.exe
        └─ release
```

특히 `javac.exe`가 없다면 JDK가 아닌 다른 Runtime Package를 내려받은 것은 아닌지 확인한다.

---

# macOS 환경

## 14. Mac Architecture 확인

Terminal:

```bash
uname -m
```

Apple Silicon:

```text
arm64
```

Intel Mac:

```text
x86_64
```

Apple Silicon 환경에서는 Temurin의 **macOS / AArch64** Package를 사용하고, Intel Mac은 x64 Package를 사용한다.

---

## 15. macOS Temurin JDK 다운로드

Eclipse Adoptium 공식 사이트에서 Temurin JDK를 다운로드한다.

Apple Silicon 기준:

```text
Version      : 26
Operating OS : macOS
Architecture : AArch64
Package Type : JDK
JVM          : HotSpot
Archive      : TAR.GZ
```

Intel Mac은 Architecture를 x64로 선택한다.

본 프로젝트에서는 `.pkg` Installer보다 **TAR.GZ 압축 배포본**을 사용한다.

---

## 16. macOS JDK 디렉터리 준비

```bash
mkdir -p ~/dev/jdks
```

여러 버전은 다음과 같이 보관할 수 있다.

```text
~/dev/jdks/
 ├─ temurin-26.jdk/
 ├─ temurin-25.jdk/
 └─ temurin-17.jdk/
```

---

## 17. macOS JDK 압축 해제

다운로드한 TAR.GZ 파일을 `~/dev/jdks`에 압축 해제한다.

```bash
tar -xzf OpenJDK26U-jdk_*.tar.gz -C ~/dev/jdks
```

압축 해제 후 실제 디렉터리 이름은 Release에 따라 다를 수 있다.

필요하면 다음처럼 관리하기 쉬운 이름으로 변경한다.

```text
~/dev/jdks/temurin-26.jdk
```

---

## 18. macOS JDK 구조

macOS용 JDK는 일반적으로 `.jdk` Bundle 구조를 사용한다.

```text
temurin-26.jdk
 └─ Contents
     └─ Home
         ├─ bin
         ├─ conf
         ├─ include
         ├─ jmods
         ├─ legal
         ├─ lib
         └─ release
```

실제 JDK Home:

```text
~/dev/jdks/temurin-26.jdk/Contents/Home
```

구분:

```text
JDK Bundle
~/dev/jdks/temurin-26.jdk

JDK Home
~/dev/jdks/temurin-26.jdk/Contents/Home
```

이 JDK Home 경로는 이후 Maven 및 VS Code 개발환경 구성에서 다시 사용한다.

---

## 19. macOS JDK 정상 동작 확인

시스템 `JAVA_HOME`을 설정하지 않고 실행파일을 직접 호출한다.

### Java Runtime

```bash
~/dev/jdks/temurin-26.jdk/Contents/Home/bin/java -version
```

### Java Compiler

```bash
~/dev/jdks/temurin-26.jdk/Contents/Home/bin/javac -version
```

정상적인 경우 Java 26 계열 정보가 표시된다.

```text
openjdk version "26..."
OpenJDK Runtime Environment Temurin-26...
OpenJDK 64-Bit Server VM Temurin-26...
```

Compiler:

```text
javac 26...
```

---

## 20. macOS에서 전역 JAVA_HOME을 설정하지 않음

현재 단계에서는 다음 설정을 기본 구성으로 사용하지 않는다.

```bash
export JAVA_HOME=...
export PATH="$JAVA_HOME/bin:$PATH"
```

따라서 `~/.zshrc`에도 JDK 관련 설정을 추가하지 않는다.

JDK 자체가 정상적으로 준비되었는지는 앞에서 설명한 절대 경로 실행 방식으로 확인한다.

---

## 21. 여러 JDK 버전 관리

향후 다른 프로젝트 때문에 추가 JDK가 필요할 수 있다.

### Windows

```text
C:\dev\jdks\
 ├─ temurin-17
 ├─ temurin-21
 ├─ temurin-25
 └─ temurin-26
```

### macOS

```text
~/dev/jdks/
 ├─ temurin-17.jdk
 ├─ temurin-21.jdk
 ├─ temurin-25.jdk
 └─ temurin-26.jdk
```

새 버전을 추가할 때 기존 JDK를 덮어쓰지 않고 별도 디렉터리에 보관한다.

현재 단계에서는 어떤 프로젝트가 어떤 JDK를 사용하는지 설정하지 않는다.

---

## 22. JDK 업데이트 시 주의사항

같은 Major Version의 JDK라도 보안 Patch 등에 따라 세부 버전이 변경될 수 있다.

예:

```text
Temurin 26.x.x
```

업데이트 시 다음 항목을 확인한다.

- 프로젝트 표준 JDK Major Version이 변경되는지
- 기존 JDK 디렉터리를 바로 삭제할 필요가 있는지
- 이후 Maven / VS Code / CI/CD가 참조하는 경로가 있는지
- 팀 전체에 동일한 버전 적용이 필요한지

기존 JDK를 즉시 덮어쓰기보다 새로운 디렉터리에 준비하고 검증 후 전환하는 방식을 권장한다.

---

## 23. 자주 발생하는 문제

### 23.1 `java -version`이 실행되지 않음

현재 프로젝트에서는 JDK `bin`을 시스템 PATH에 등록하지 않으므로 다음 명령이 실패할 수 있다.

```bash
java -version
```

이는 반드시 설치 오류를 의미하지 않는다.

절대 경로로 확인한다.

#### Windows

```powershell
& "C:\dev\jdks\temurin-26\bin\java.exe" -version
```

#### macOS

```bash
~/dev/jdks/temurin-26.jdk/Contents/Home/bin/java -version
```

### 23.2 `javac`가 없음

#### Windows

```text
C:\dev\jdks\temurin-26\bin\javac.exe
```

#### macOS

```text
~/dev/jdks/temurin-26.jdk/Contents/Home/bin/javac
```

파일이 없다면 Temurin 다운로드 시 JRE가 아닌 **JDK Package**를 선택했는지 확인한다.

### 23.3 Architecture가 맞지 않음

Windows:

```powershell
$env:PROCESSOR_ARCHITECTURE
```

macOS:

```bash
uname -m
```

장비 Architecture에 맞는 Temurin Package를 사용한다.

### 23.4 압축 해제 후 경로가 다름

Release에 따라 다음처럼 이름이 생성될 수 있다.

```text
jdk-26.0.2+10
```

관리 편의를 위해 `temurin-26` 형태로 정리할 수 있다.

중요한 것은 디렉터리 이름보다 다음 파일이 정상적으로 존재하는지 여부이다.

```text
bin/java
bin/javac
```

---

## 24. 최종 확인

### Windows

JDK Home:

```text
C:\dev\jdks\temurin-26
```

확인:

```powershell
& "C:\dev\jdks\temurin-26\bin\java.exe" -version
& "C:\dev\jdks\temurin-26\bin\javac.exe" -version
```

### macOS

JDK Home:

```text
~/dev/jdks/temurin-26.jdk/Contents/Home
```

확인:

```bash
~/dev/jdks/temurin-26.jdk/Contents/Home/bin/java -version
~/dev/jdks/temurin-26.jdk/Contents/Home/bin/javac -version
```

두 환경 모두 Java Runtime과 Compiler가 Java 26으로 정상 실행되면 JDK 준비는 완료된 것이다.

---

## 25. 체크리스트

### 공통

- [ ] Eclipse Temurin을 프로젝트 표준 JDK 배포판으로 사용한다.
- [ ] Java 26 JDK를 준비했다.
- [ ] JRE가 아닌 JDK Package를 다운로드했다.
- [ ] JDK를 프로젝트 Git Repository 외부에 보관했다.
- [ ] 여러 JDK를 버전별 디렉터리로 관리할 수 있다.
- [ ] 시스템 전역 `JAVA_HOME`을 프로젝트 기본 구성으로 사용하지 않는다.
- [ ] JDK `bin`을 시스템 전역 PATH에 추가하지 않았다.

### Windows

- [ ] 개발 장비 Architecture를 확인했다.
- [ ] Windows용 ZIP 배포본을 사용했다.
- [ ] JDK를 `C:\dev\jdks` 계열 경로에 압축 해제했다.
- [ ] `java.exe -version`이 정상 실행된다.
- [ ] `javac.exe -version`이 정상 실행된다.

### macOS

- [ ] Apple Silicon / Intel Architecture를 확인했다.
- [ ] macOS용 TAR.GZ 배포본을 사용했다.
- [ ] JDK를 `~/dev/jdks` 계열 경로에 압축 해제했다.
- [ ] `Contents/Home/bin/java -version`이 정상 실행된다.
- [ ] `Contents/Home/bin/javac -version`이 정상 실행된다.
- [ ] `~/.zshrc`에 프로젝트용 `JAVA_HOME`을 등록하지 않았다.

### 단계 확인

- [ ] VS Code 관련 설정을 아직 진행하지 않았다.
- [ ] 프로젝트별 JDK Runtime 설정을 아직 만들지 않았다.
- [ ] Maven 프로젝트 설정을 아직 진행하지 않았다.
- [ ] Spring Boot 프로젝트를 아직 생성하지 않았다.
- [ ] `pom.xml`을 아직 작성하거나 수정하지 않았다.

---

## 26. 다음 단계

JDK 준비가 완료되면 다음 가이드로 진행한다.

```text
JDK 설치 및 설정                ← 현재 완료
        ↓
Maven 설치 및 기본 환경 구성
        ↓
VS Code 개발환경 구성
        ↓
Spring Boot 프로젝트 생성
        ↓
프로젝트 JDK / Maven / VS Code 설정
```

다음 단계에서는 Apache Maven을 개발 PC에 준비하고, 앞에서 설치한 Temurin JDK를 이용하여 Maven이 정상 실행되는지 확인한다.

---

## 27. 공식 참고 자료

- Eclipse Adoptium  
  <https://adoptium.net/>

- Eclipse Temurin Releases  
  <https://adoptium.net/temurin/releases/>

- Eclipse Temurin Support / Release Roadmap  
  <https://adoptium.net/support/>
