# Java Runtime / Toolchain / Launcher 구조

## 1. 목적

MicroServer에서 JDK, `JAVA_HOME`, Java Toolchain, VS Code Java Runtime이 왜 분리되어 있는지 설명한다.

## 2. 네 가지 역할

```text
Folder 내부 JDK
→ 실제 Java 실행 파일

Launcher
→ JDK를 VS Code Process에 전달

build.gradle Toolchain
→ Project가 요구하는 Java Version 선언

VS Code Java Extension
→ Project 분석 및 개발 지원
```

Toolchain은 JDK 설치경로가 아니며 Launcher는 Project Java Version을 선언하는 파일이 아니다.

## 3. Process 환경변수

Launcher가 설정한 `JAVA_HOME`과 `PATH`는 Launcher에서 시작된 VS Code와 하위 Process에 전달된다.

```text
Launcher
  └─ VS Code
      ├─ Integrated Terminal
      ├─ Java Language Server
      └─ Gradle
```

따라서 OS 전체 Java 환경을 변경하지 않고 MicroServer만 독립된 JDK를 사용할 수 있다.

## 4. macOS JDK Bundle

macOS의 JDK는 일반적으로 다음 구조다.

```text
temurin-25/
└─ Contents/
   └─ Home/
      └─ bin/java
```

실제 `JAVA_HOME`은 `Contents/Home`이다.

## 5. Toolchain

```groovy
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(25)
    }
}
```

이 선언은 모든 개발자가 같은 Java Version을 Build 기준으로 사용하도록 만드는 Project 정책이다.

## 6. VS Code JDK 경로 설정

`java.configuration.runtimes`와 `java.jdt.ls.java.home`은 필요할 수 있지만 MicroServer 표준에서는 Launcher와 중복되므로 기본 설정하지 않는다.

OS별 절대경로를 Project Repository에 저장하지 않는 것이 핵심이다.
