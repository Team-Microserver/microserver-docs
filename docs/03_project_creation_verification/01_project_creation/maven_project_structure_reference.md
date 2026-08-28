# Maven 기본 구조 - 비교 / 참고

!!! info "프로젝트 표준 변경"
    Team-Microserver의 주 Build Tool은 **Gradle + Groovy DSL**이다.

    Maven 구조는 기존 Java / 금융 SI 프로젝트를 이해하기 위한 비교 대상으로 유지한다.

## 핵심 대응 관계

| Gradle | Maven |
|---|---|
| `settings.gradle` | Parent `pom.xml`의 `<modules>` |
| `build.gradle` | `pom.xml` |
| `gradlew` | `mvnw` |
| Task | Lifecycle / Goal |
| `build/` | `target/` |

실제 프로젝트 구성은 다음 가이드를 따른다.

→ [Gradle Wrapper 및 프로젝트 Gradle 설정](../02_project_environment/project_gradle_setup.md)

→ [Gradle Multi-Project 기본 구성](../../04_multi_project_transition/02_build_tool/gradle_multi_project_setup.md)

Maven 상세 비교가 필요한 경우 다음 참고 문서를 사용한다.

→ [Maven Wrapper 및 프로젝트 Maven 설정 - 비교 / 참고](../02_project_environment/project_maven_setup.md)

→ [Maven 멀티모듈 기본 구성 - 비교 / 참고](../../04_multi_project_transition/02_build_tool/maven_multi_module_setup.md)
