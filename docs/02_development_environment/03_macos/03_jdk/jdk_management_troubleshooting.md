# macOS JDK 운영 및 문제 해결

## 1. 문서 목적

본 문서는 Eclipse Temurin JDK를 설치한 이후 개발 장비에서 여러 JDK Version을 관리하고,
업데이트 또는 실행 과정에서 발생할 수 있는 대표적인 문제를 확인하는 방법을 설명한다.

OS별 최초 설치는 다음 문서를 먼저 진행한다.

- [macOS JDK 설치 및 검증](windows_jdk_setup.md)
- [macOS JDK 설치 및 검증](macos_jdk_setup.md)

---

## 2. 여러 JDK Version 관리

개발 장비에서는 프로젝트 특성에 따라 여러 JDK를 함께 보관할 수 있다.

### 2.2 macOS

```text
~/local-microserver/tools/jdk/
├─ temurin-17.jdk
├─ temurin-21.jdk
└─ temurin-25.jdk
```

새 Version을 추가할 때 기존 JDK를 덮어쓰지 않고 별도 Directory에 보관한다.

현재 MicroServer 프로젝트의 기준 JDK는 **Temurin 25 LTS**이다.

!!! tip "여러 JDK를 보관하는 이유"
    시스템 전체 Java를 하나의 Version으로 고정하지 않고 프로젝트별로 필요한 JDK를 선택할 수 있다.

    예:

    ```text
    Legacy Project   → JDK 8
    Existing Project → JDK 17
    MicroServer      → JDK 25 LTS
    ```

---

## 3. JDK 업데이트 시 주의사항

같은 Major Version이라도 보안 Patch 등에 따라 세부 Version이 변경될 수 있다.

예:

```text
Temurin 25.x.x
```

업데이트 시 다음 항목을 확인한다.

- 프로젝트 표준 JDK Major Version이 변경되는지
- 기존 JDK Directory를 즉시 삭제할 필요가 있는지
- Gradle이 참조하는 JDK 경로가 있는지
- VS Code Java Runtime이 참조하는 경로가 있는지
- CI/CD 환경의 Java Version이 일치하는지
- 팀 전체에 동일한 Version 적용이 필요한지

기존 JDK를 바로 덮어쓰기보다 새로운 Directory에 준비하고 검증 후 전환하는 방식을 권장한다.

---

## 4. `java -version`이 실행되지 않음

MicroServer 프로젝트에서는 JDK `bin`을 시스템 PATH에 영구 등록하지 않으므로
새 Terminal에서 다음 명령이 실패할 수 있다.

```text
java -version
```

이 현상만으로 JDK 설치 실패라고 판단하지 않는다.

### 4.2 macOS

```bash
~/local-microserver/tools/jdk/temurin-25.jdk/Contents/Home/bin/java -version
```

파일 존재 확인:

```bash
test -f ~/local-microserver/tools/jdk/temurin-25.jdk/Contents/Home/bin/java && echo "OK"
```

!!! info "이후 개발환경에서는"
    일반 Terminal에서는 `setup.command` / `setup.cmd` 등을 통해 현재 Session의 `JAVA_HOME`과 PATH를 구성할 수 있고,
    VS Code에서는 Java Runtime 설정을 통해 프로젝트 JDK를 자동 적용할 수 있다.

    현재 문서는 JDK Binary 자체의 정상 여부를 확인하는 단계이다.

---

## 5. `javac`가 없음

JDK에는 Java Compiler인 `javac`가 포함되어 있어야 한다.

### 5.2 macOS

정상 경로:

```text
~/local-microserver/tools/jdk/temurin-25.jdk/Contents/Home/bin/javac
```

파일이 없다면 Temurin 다운로드 시 JRE가 아닌 **JDK Package**를 선택했는지 확인한다.

---

## 6. Architecture가 맞지 않음

CPU Architecture와 다운로드한 JDK Package의 Architecture가 일치해야 한다.

### 6.2 macOS

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

장비 Architecture에 맞는 Temurin Package를 사용한다.

!!! warning "Windows ARM64 + Temurin 25"
    2026년 8월 기준 Eclipse Temurin 25의 Windows AArch64 Binary는 제공되지 않는다.

    Windows ARM64 장비에서는 단순히 Architecture만 맞춰 다운로드하는 방식으로 해결되지 않을 수 있으므로
    Adoptium의 최신 지원 Platform을 확인해야 한다.

---

## 7. 압축 해제 후 Directory 이름이 다름

Temurin Archive를 압축 해제하면 Release에 따라 다음처럼 상세 Version이 포함된 Directory가 생성될 수 있다.

```text
jdk-25.0.4+7
```

Directory 이름이 예상과 다르다고 해서 문제가 있는 것은 아니다.

MicroServer에서는 관리 편의를 위해 다음처럼 정리할 수 있다.


macOS:

```text
~/local-microserver/tools/jdk/temurin-25.jdk/Contents/Home.jdk
```

중요한 것은 Directory 이름보다 다음 파일이 정상적으로 존재하는지 여부이다.

```text
bin/java
bin/javac
```


---

## 8. JDK Home을 잘못 지정함

JDK Home은 `bin` Directory나 `java` 실행파일 자체가 아니라 **JDK 최상위 Home Directory**이다.

### 8.2 macOS

```text
O  ~/local-microserver/tools/jdk/temurin-25.jdk/Contents/Home
X  ~/local-microserver/tools/jdk/temurin-25.jdk/Contents/Home.jdk
X  ~/local-microserver/tools/jdk/temurin-25.jdk/Contents/Home/bin
```

macOS는 `.jdk` Bundle과 실제 `Contents/Home`을 구분해야 한다.

---

## 9. 어떤 Java가 실행되는지 확인

이후 `JAVA_HOME`이나 PATH를 사용하는 단계에서 예상과 다른 Java가 실행된다면 현재 명령이 어느 실행파일을 선택하는지 확인한다.

### 9.2 macOS

```bash
echo "$JAVA_HOME"
which java
java -version
```

!!! warning "시스템 Java와 프로젝트 Java 혼동"
    `java -version` 결과만 보고 MicroServer 프로젝트 JDK가 실행되고 있다고 판단하지 않는다.

    반드시 필요한 경우 `JAVA_HOME`, 실행파일 위치, VS Code Runtime, Gradle JVM 설정을 함께 확인한다.

---

## 10. 최종 확인

### 10.2 macOS

JDK Home:

```text
~/local-microserver/tools/jdk/temurin-25.jdk/Contents/Home
```

확인:

```bash
~/local-microserver/tools/jdk/temurin-25.jdk/Contents/Home/bin/java -version
~/local-microserver/tools/jdk/temurin-25.jdk/Contents/Home/bin/javac -version
```

두 환경 모두 Java Runtime과 Compiler가 Java 25 계열로 정상 실행되면 JDK 준비는 완료된 것이다.

---

## 11. 최종 체크리스트

### 공통

- [ ] Eclipse Temurin을 프로젝트 표준 JDK 배포판으로 사용한다.
- [ ] Java 25 LTS JDK를 준비했다.
- [ ] JRE가 아닌 JDK Package를 사용한다.
- [ ] JDK Binary를 프로젝트 Git Repository에 포함하지 않는다.
- [ ] 여러 JDK를 Version별 Directory로 관리할 수 있다.
- [ ] 시스템 전역 `JAVA_HOME`을 MicroServer 기본 구성으로 사용하지 않는다.

### macOS

- [ ] JDK Home은 `~/local-microserver/tools/jdk/temurin-25.jdk/Contents/Home`이다.
- [ ] `bin/java`가 정상 실행된다.
- [ ] `bin/javac`가 정상 실행된다.
- [ ] Apple Silicon / Intel Architecture에 맞는 Package를 사용한다.

---

## 12. 다음 단계

JDK 자체의 설치와 검증이 완료되면 Gradle 기본 환경 구성으로 진행한다.

그 이후 VS Code 환경에서 프로젝트 JDK를 연결하고,
Spring Boot 프로젝트를 생성한 후 프로젝트별 JDK / Gradle / Workspace 설정을 진행한다.
