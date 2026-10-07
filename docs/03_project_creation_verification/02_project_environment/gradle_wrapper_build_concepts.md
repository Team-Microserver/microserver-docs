# Gradle Wrapper / Build 기준 개념

## 1. 목적

Gradle Wrapper가 왜 필요한지, `build.gradle`, `settings.gradle`, Java Toolchain이 각각 무엇을 담당하는지 설명한다.

## 2. Gradle Wrapper

개발자 PC의 Gradle Version은 서로 다를 수 있다.

```text
Developer A ─┐
Developer B ─┼→ gradlew → Project 지정 Gradle Version
CI Server   ─┘
```

Wrapper를 사용하면 Local과 CI/CD의 Gradle 실행 기준을 통일할 수 있다.

## 3. Wrapper 구성

```text
gradlew
gradlew.bat
gradle/wrapper/gradle-wrapper.jar
gradle/wrapper/gradle-wrapper.properties
```

`distributionUrl`이 Wrapper가 사용할 Gradle Distribution을 결정한다.

## 4. `settings.gradle`

주로 다음 정보를 담당한다.

```text
Root Project 이름
Subproject 포함
Plugin / Dependency Repository 관리의 일부
Multi-Project 구조
```

## 5. `build.gradle`

주로 다음 정보를 담당한다.

```text
Plugin
Java Toolchain
Repository
Dependency
Compile / Test / Packaging 관련 Build Logic
```

## 6. Java Toolchain과 Gradle JVM

둘은 개념적으로 구분된다.

```text
Gradle JVM
→ Gradle 자체를 실행하는 JVM

Java Toolchain
→ Compile / Test 등에 사용할 Java Tool 기준
```

MicroServer에서는 Launcher가 Java 실행환경을 제공하고 Project는 Toolchain으로 Java 25를 선언한다.

## 7. Wrapper 우선 원칙

Project Build 문서와 CI/CD Script는 특별한 이유가 없으면 `gradle`이 아니라 Wrapper 명령을 사용한다.

```text
Windows       .\gradlew.bat <task>
macOS/Linux   ./gradlew <task>
```
