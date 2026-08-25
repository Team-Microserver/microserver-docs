# macOS JDK 설치 및 검증

## 1. 문서 목적

본 문서는 macOS 개발 장비에 **Eclipse Temurin JDK 25 LTS**을 준비하고 정상 동작을 확인하는 방법을 설명한다.

MicroServer 프로젝트에서는 macOS 시스템 Java를 프로젝트용으로 변경하지 않고,
압축 배포본을 별도 Directory에 보관하는 방식을 사용한다.

!!! tip "전체 JDK 운영 원칙"
    JDK Vendor, Version, 시스템 전역 Java 설정을 최소화하는 이유는 다음 문서에서 설명한다.

    **[JDK 개발환경 구성 및 운영 기준](../jdk_setup.md)**

!!! note "macOS 경로 기준"
    현재 `C:\local-microserver` 표준은 Windows 개발환경 기준으로 정의되어 있다.

    macOS에서는 기존 개발도구 보관 경로인 `~/dev/jdks` 체계를 사용한다.
    macOS의 프로젝트 로컬 개발환경 Root가 별도로 표준화되면 이 경로도 함께 조정한다.

---

## 2. Mac Architecture 확인

Terminal에서 다음 명령을 실행한다.

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

Architecture에 따라 Temurin Package를 다음과 같이 선택한다.

| 장비 | Temurin Architecture |
|---|---|
| Apple Silicon | AArch64 |
| Intel Mac | x64 |

---

## 3. Eclipse Temurin JDK 다운로드

Eclipse Adoptium 공식 사이트에서 Temurin JDK를 다운로드한다.

- Eclipse Adoptium: <https://adoptium.net/>
- Temurin Releases: <https://adoptium.net/temurin/releases/>

Apple Silicon 기준:

```text
Version      : 25 (LTS)
Operating OS : macOS
Architecture : AArch64
Package Type : JDK
JVM          : HotSpot
Archive      : TAR.GZ
```

!!! info "Java 25 LTS"
    MicroServer 프로젝트는 장기적인 개발환경 안정성을 위해
    **Java 25 LTS**를 프로젝트 표준 JDK로 사용한다.

    Temurin 25의 Patch Version은 보안 Update에 따라 변경될 수 있으므로
    다운로드 시점의 최신 Java 25 LTS Release를 사용한다.

Intel Mac은 Architecture를 `x64`로 선택한다.

MicroServer 프로젝트에서는 `.pkg` Installer보다 **TAR.GZ 압축 배포본**을 사용한다.

---

## 4. JDK Directory 준비

다음 Directory를 사용한다.

```text
~/dev/jdks
```

생성:

```bash
mkdir -p ~/dev/jdks
```

여러 JDK Version은 다음과 같이 보관할 수 있다.

```text
~/dev/jdks/
├─ temurin-17.jdk/
├─ temurin-21.jdk/
└─ temurin-25.jdk/
```

---

## 5. JDK 압축 해제

다운로드한 TAR.GZ 파일을 `~/dev/jdks`에 압축 해제한다.

```bash
tar -xzf OpenJDK25U-jdk_*.tar.gz -C ~/dev/jdks
```

압축 해제 후 실제 Directory 이름은 Release에 따라 다를 수 있다.

필요하면 관리하기 쉬운 이름으로 정리한다.

```text
~/dev/jdks/temurin-25.jdk
```

---

## 6. macOS JDK 구조

macOS용 JDK는 일반적으로 `.jdk` Bundle 구조를 사용한다.

```text
temurin-25.jdk
└─ Contents
   └─ Home
      ├─ bin
      ├─ conf
      ├─ include
      ├─ legal
      ├─ lib
      └─ release
```

!!! note "JDK 25의 `jmods` Directory"
    Temurin JDK 25부터는 `jmods` Directory가 기본 배포본에 포함되지 않을 수 있다.

    따라서 `Contents/Home` 아래에 `jmods`가 없어도 정상적인 JDK 25 배포본일 수 있다.

    JDK 설치 검증에서는 다음 실행파일을 우선 확인한다.

    ```text
    Contents/Home/bin/java
    Contents/Home/bin/javac
    ```

JDK Bundle과 실제 JDK Home을 구분한다.

```text
JDK Bundle
~/dev/jdks/temurin-25.jdk

JDK Home
~/dev/jdks/temurin-25.jdk/Contents/Home
```

Gradle이나 VS Code에서 JDK Home을 지정해야 할 때는 `Contents/Home`까지 포함한 경로를 사용한다.

---

## 7. JDK 정상 동작 확인

시스템 `JAVA_HOME`을 설정하지 않고 실행파일을 직접 호출한다.

### 7.1 Java Runtime

```bash
~/dev/jdks/temurin-25.jdk/Contents/Home/bin/java -version
```

### 7.2 Java Compiler

```bash
~/dev/jdks/temurin-25.jdk/Contents/Home/bin/javac -version
```

정상적인 경우 Java 25 계열 정보가 표시된다.

```text
openjdk version "25..."
OpenJDK Runtime Environment Temurin-25...
OpenJDK 64-Bit Server VM Temurin-25...
```

Compiler:

```text
javac 25...
```

---

## 8. 전역 JAVA_HOME을 기본 방식으로 사용하지 않음

현재 단계에서는 다음 설정을 기본 구성으로 사용하지 않는다.

```bash
export JAVA_HOME=...
export PATH="$JAVA_HOME/bin:$PATH"
```

따라서 `~/.zshrc`에 MicroServer 프로젝트용 JDK를 전역 기본값으로 등록하지 않는다.

JDK 자체가 정상적으로 준비되었는지는 앞에서 설명한 절대 경로 실행 방식으로 확인한다.

향후 Gradle, VS Code, 프로젝트 Runtime 구성 단계에서 필요한 JDK를 명시적으로 연결한다.

---

## 9. 최종 확인

JDK Home:

```text
~/dev/jdks/temurin-25.jdk/Contents/Home
```

확인:

```bash
~/dev/jdks/temurin-25.jdk/Contents/Home/bin/java -version
~/dev/jdks/temurin-25.jdk/Contents/Home/bin/javac -version
```

두 명령이 Java 25 계열로 정상 실행되면 macOS JDK 준비가 완료된 것이다.

---

## 10. 체크리스트

- [ ] Apple Silicon / Intel Architecture를 확인했다.
- [ ] Eclipse Temurin JDK 25 LTS을 선택했다.
- [ ] JRE가 아닌 JDK Package를 선택했다.
- [ ] macOS용 TAR.GZ 배포본을 사용했다.
- [ ] JDK를 `~/dev/jdks` 계열 경로에 압축 해제했다.
- [ ] 실제 JDK Home이 `Contents/Home`임을 이해했다.
- [ ] `java -version`이 정상 실행된다.
- [ ] `javac -version`이 정상 실행된다.
- [ ] `~/.zshrc`에 MicroServer 프로젝트용 `JAVA_HOME`을 영구 등록하지 않았다.

---

## 11. 다음 단계

JDK 준비가 완료되면 Gradle 기본 환경 구성으로 진행한다.

프로젝트별 JDK Runtime 연결은 이후 VS Code / 프로젝트 개발환경 설정 단계에서 진행한다.
