# Lombok 설치 및 설정 가이드

## 1. 목적 {#1-목적}

MicroServer Java 개발에서 Getter / Setter와 같은 반복 코드를 직접
작성하지 않고 Lombok Annotation을 사용하기 위한 개발환경 설정 방법을
정리한다.

Lombok은 `@Getter`, `@Setter` 등의 Annotation을 Java 컴파일 과정에서
처리하여 필요한 코드를 생성한다.

> Lombok은 Runtime에서 Getter / Setter를 동적으로 생성하는 라이브러리가
> 아니다.\
> Annotation Processor가 컴파일 과정에서 코드를 생성한다.

------------------------------------------------------------------------

## 2. 구성 범위 {#2-구성-범위}

MicroServer에서 Lombok을 사용하려면 다음 두 부분을 구성한다.

``` text
Gradle Lombok Dependency
        +
VS Code Lombok 지원 Extension
        ↓
Java 소스 작성 / IDE 인식 / Gradle 컴파일
```

-   **Gradle 설정**: 실제 프로젝트 컴파일에서 Lombok을 사용한다.
-   **VS Code Extension**: VS Code Java 편집기에서 Lombok Annotation과
    생성 코드를 올바르게 인식하도록 지원한다.

------------------------------------------------------------------------

## 3. VS Code Lombok Extension 설치 {#3-vs-code-lombok-extension-설치}

VS Code의 **Extensions** 화면을 열고 다음을 검색한다.

``` text
Lombok
```

검색 결과에서 다음 Extension을 설치한다.

  항목        내용
  ----------- ----------------------------------------------
  Extension   Lombok Annotations Support for VS Code
  Publisher   Microsoft
  용도        VS Code Java 환경에서 Lombok Annotation 지원

Microsoft에서 제공하는 **Lombok Annotations Support for VS Code**를
사용한다.

유사한 이름의 다른 Lombok Extension을 추가로 설치할 필요는 없다.

------------------------------------------------------------------------

## 4. Gradle Dependency 추가 {#4-gradle-dependency-추가}

MicroServer 프로젝트의 `build.gradle`에서 `dependencies`에 다음 설정을
추가한다.

``` groovy
dependencies {

    // Lombok Annotation을 Java 소스 컴파일 시 사용할 수 있게 한다.
    // @Getter, @Setter 등의 Annotation을 코드에서 사용할 수 있게 하며,
    // Lombok은 컴파일 과정에서 코드를 생성하므로 Runtime 의존성에는 포함하지 않는다.
    compileOnly 'org.projectlombok:lombok'

    // Java 컴파일 시 Lombok Annotation Processor를 실행한다.
    // @Getter, @Setter 등의 Annotation을 분석하여 실제 Getter / Setter 코드를 생성한다.
    annotationProcessor 'org.projectlombok:lombok'

    // 테스트 소스(src/test/java)에서도 Lombok Annotation을 사용할 수 있게 한다.
    // 테스트용 클래스에서 @Getter, @Setter 등을 사용할 때 필요하다.
    testCompileOnly 'org.projectlombok:lombok'

    // 테스트 Java 소스를 컴파일할 때도 Lombok Annotation Processor를 실행한다.
    // 테스트 코드에 선언된 Lombok Annotation을 실제 코드로 생성한다.
    testAnnotationProcessor 'org.projectlombok:lombok'
}
```

### Dependency 역할

  설정                        역할
  --------------------------- -------------------------------------------
  `compileOnly`               Main Java 소스에서 Lombok Annotation 사용
  `annotationProcessor`       Main Java 컴파일 시 Lombok 코드 생성
  `testCompileOnly`           Test Java 소스에서 Lombok Annotation 사용
  `testAnnotationProcessor`   Test Java 컴파일 시 Lombok 코드 생성

`compileOnly`와 `annotationProcessor`는 역할이 다르므로 함께 설정한다.

------------------------------------------------------------------------

## 5. Gradle 동기화 {#5-gradle-동기화}

`build.gradle`을 변경하면 VS Code가 Java Classpath / Configuration
동기화를 요청할 수 있다.

``` text
A build file was modified.
Do you want to synchronize the Java classpath/configuration?
```

이 경우 **Yes**를 선택하여 변경된 Gradle Dependency를 Java 프로젝트에
반영한다.

동기화가 완료되기 전에는 Lombok Annotation의 Import나 자동완성이
일시적으로 인식되지 않을 수 있다.

------------------------------------------------------------------------

## 6. Lombok 사용 예 {#6-lombok-사용-예}

기존 Java 코드에서 Getter / Setter를 직접 작성하는 대신 다음과 같이
사용할 수 있다.

``` java
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DataSourceProperty {

    private String driverClassName;
    private String jdbcUrl;
    private String username;
    private String password;
}
```

컴파일 과정에서 각 필드에 필요한 Getter / Setter가 생성된다.

MicroServer의 설정 Property 클래스처럼 단순 데이터 접근 메서드가 많이
필요한 클래스에 특히 유용하다.

------------------------------------------------------------------------

## 7. `@Getter` / `@Setter`와 `@Data` {#7-getter--setter와-data}

Lombok의 `@Data`는 Getter / Setter 외에도 `equals()`, `hashCode()`,
`toString()` 등을 함께 생성한다.

MicroServer Framework 설정 클래스에서는 필요한 기능을 명확하게 표현하기
위해 우선 다음 방식을 사용한다.

``` java
@Getter
@Setter
public class DataSourceProperty {
    // ...
}
```

즉, 단순히 코드를 더 짧게 만드는 것보다 **클래스에 필요한 Lombok 기능만
명시적으로 적용**하는 것을 기본 방향으로 한다.

------------------------------------------------------------------------

## 8. 정상 동작 확인 {#8-정상-동작-확인}

Java 클래스에서 다음 Import가 정상적으로 인식되는지 확인한다.

``` java
import lombok.Getter;
import lombok.Setter;
```

그리고 다음 Annotation에 오류가 없는지 확인한다.

``` java
@Getter
@Setter
```

Gradle Build도 함께 확인한다.

``` bash
./gradlew build
```

Build가 정상 완료되고 VS Code에서도 Lombok Annotation 오류가 없다면
설정이 완료된 것이다.

------------------------------------------------------------------------

## 9. 문제 발생 시 확인 {#9-문제-발생-시-확인}

Lombok Import 또는 생성된 Getter / Setter가 VS Code에서 인식되지 않는
경우 다음 순서로 확인한다.

1.  `build.gradle`의 Lombok Dependency가 저장되었는지 확인한다.
2.  Gradle 동기화가 완료되었는지 확인한다.
3.  Microsoft의 `Lombok Annotations Support for VS Code`가 설치되어
    있는지 확인한다.
4.  Java Language Server의 프로젝트 로딩이 완료되었는지 확인한다.

필요한 경우 VS Code Command Palette에서 다음 명령으로 Java Language
Server 상태를 초기화할 수 있다.

``` text
Java: Clean Java Language Server Workspace
```

이 명령은 일반적인 설정 절차가 아니라 Java Classpath / 인덱싱이
정상적으로 갱신되지 않을 때 사용하는 문제 해결 방법이다.
