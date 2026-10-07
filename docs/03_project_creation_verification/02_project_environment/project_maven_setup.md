# Maven Wrapper 및 프로젝트 설정 - 비교 / 참고

!!! info
    MicroServer의 주 Build Tool은 **Gradle + Groovy DSL**이다.  
    이 문서는 수행 필수 단계가 아니라 Maven Project와 비교하거나 기존 Maven Project를 이해하기 위한 참고 문서다.

## 1. Gradle과 Maven 대응

| Gradle | Maven |
|---|---|
| `build.gradle` | `pom.xml` |
| `settings.gradle` | `pom.xml`의 Project/Module 구성 |
| `gradlew`, `gradlew.bat` | `mvnw`, `mvnw.cmd` |
| `gradle/wrapper/` | `.mvn/wrapper/` |
| `implementation` | compile Dependency |
| `testImplementation` | test scope |

## 2. Maven Wrapper

Maven Project에서는 다음 파일을 통해 Project Maven Version을 통일할 수 있다.

```text
.mvn/
mvnw
mvnw.cmd
pom.xml
```

Windows:

```powershell
.\mvnw.cmd -version
```

macOS / Linux:

```bash
./mvnw -version
```

## 3. 개인 Maven 설정

다음 파일은 개발자 개인 환경이다.

```text
~/.m2/settings.xml
```

주요 용도:

```text
Nexus / Artifactory Mirror
Proxy
Repository 인증
개인 Maven 설정
```

Credential이 포함될 수 있으므로 Project Repository에 Commit하지 않는다.

## 4. MicroServer에서의 사용 기준

새 MicroServer Project에서는 Maven 절차를 수행하지 않는다.

```text
실제 Build 기준 → Gradle Wrapper
Maven 문서       → 비교 / 참고
```

→ [Gradle Wrapper 확인 및 Build 기준](project_gradle_setup.md)
→ [Gradle Wrapper / Build 기준 개념](gradle_wrapper_build_concepts.md)
