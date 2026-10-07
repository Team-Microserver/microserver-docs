# Gradle Wrapper 확인 및 Build 기준

## 1. 목적

이 문서는 MicroServer Project의 **Build 도구 기준을 Gradle Wrapper로 확정하고 실제 상태를 확인**하는 절차다.

Gradle Wrapper, Toolchain, Build Script의 상세 개념은 다음 문서를 참고한다.

→ [Gradle Wrapper / Build 기준 개념](gradle_wrapper_build_concepts.md)

---

## 2. Project 파일 확인

Project Root에서 다음 파일을 확인한다.

```text
microserver/
├─ gradle/
│  └─ wrapper/
│     ├─ gradle-wrapper.jar
│     └─ gradle-wrapper.properties
├─ gradlew
├─ gradlew.bat
├─ build.gradle
└─ settings.gradle
```

누락된 파일이 있으면 Build 진행 전에 Wrapper 구성을 복구한다.

---

## 3. Wrapper Version 확인

파일:

```text
gradle/wrapper/gradle-wrapper.properties
```

`distributionUrl`의 Gradle Version을 확인한다.

예:

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-9.7.1-bin.zip
```

현재 Project 표준과 일치하면 변경하지 않는다.

---

## 4. Wrapper 실행 확인

### Windows

```powershell
.\gradlew.bat --version
```

### macOS / Linux

최초 Clone 후 실행 권한이 없을 때만:

```bash
chmod +x gradlew
```

실행:

```bash
./gradlew --version
```

확인 항목:

```text
Gradle → Project 표준 Version
JVM    → Java 25
```

!!! important
    일상적인 Project Build는 `gradle` 명령이 아니라 `gradlew` / `gradlew.bat`을 사용한다.

---

## 5. `settings.gradle` 확인

최소한 Root Project 이름을 확인한다.

예:

```groovy
rootProject.name = 'microserver'
```

현재 단계에서는 Multi-Project 구성을 추가하지 않는다.

---

## 6. `build.gradle` 확인

다음 항목만 확인한다.

```text
Spring Boot Plugin
Dependency Management
Java Toolchain = 25
Repository
Dependencies
Test 설정
```

Java Toolchain:

```groovy
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(25)
    }
}
```

Project 표준과 다를 때만 수정한다.

---

## 7. Wrapper Version 변경이 필요한 경우

현재 Wrapper가 Project 표준과 다를 때만 실행한다.

### Windows

```powershell
.\gradlew.bat wrapper --gradle-version <표준버전>
```

### macOS / Linux

```bash
./gradlew wrapper --gradle-version <표준버전>
```

실행 후:

```bash
git status
git diff
```

Wrapper 관련 변경사항을 확인한다.

---

## 8. 현재 단계에서 하지 않는 작업

다음은 이후 단계에서 수행한다.

```text
clean / build / test 본격 검증
Spring Boot Run
Multi-Project 전환
공통 Framework 구현
DataSource / Security 구성
```

---

## 9. 완료 체크리스트

- [ ] `gradlew`, `gradlew.bat`이 존재한다.
- [ ] Wrapper Properties가 존재한다.
- [ ] Wrapper Gradle Version을 확인했다.
- [ ] Wrapper가 정상 실행된다.
- [ ] JVM이 Java 25다.
- [ ] `settings.gradle`의 Root Project 이름을 확인했다.
- [ ] `build.gradle` Toolchain이 Java 25다.
- [ ] 앞으로 Project Build는 Wrapper를 사용한다.

다음 단계의 Build / Run 검증 문서로 진행한다.
