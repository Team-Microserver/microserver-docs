# Gradle api 의존성 선언

이 문서는 `api`와 `implementation`의 차이와 선언 선택 기준을 설명한다. Framework Starter가 공통 모듈을 Runtime에 제공하는 예제를 통해 컴파일·실행 의존성의 전달 범위를 살펴본다.

!!! note "예제의 범위"
    Java 클래스 예제는 의존성 차이를 이해하기 위한 가상 코드다. 프로젝트 생성 과정에서 이 예제 클래스를 추가할 필요는 없다.

## 1. 의존성 선언이 하는 일

`api`와 `implementation`은 다른 모듈·라이브러리에 대한 의존성을 선언하는 방식이다. 둘 다 선언한 프로젝트에서는 해당 라이브러리를 컴파일과 실행에 사용할 수 있다. 차이는 **그 프로젝트를 사용하는 다른 프로젝트에도 의존성을 컴파일 시점에 전달하는가**이다.

컴파일 클래스패스는 소스에서 import한 클래스와 메서드의 존재·타입을 검사할 때 사용하는 라이브러리 목록이고, 실행 클래스패스는 애플리케이션을 실제 실행할 때 필요한 라이브러리 목록이다.

아래 표는 B 프로젝트가 C를 의존하고, A 프로젝트는 B만 의존하는 경우다. A가 C를 별도로 선언하거나 다른 의존성 경로로 받는 경우는 제외한다.

| B에서 C를 선언하는 방법 | B에서 C 사용 | A의 컴파일 클래스패스에 C 포함 | A의 실행 클래스패스에 C 포함 |
| --- | --- | --- | --- |
| `api(C)` | 컴파일·실행 가능 | 포함 | 포함 |
| `implementation(C)` | 컴파일·실행 가능 | 포함하지 않음 | 포함 |

`implementation`이라고 해서 C가 A의 실행에 전달되지 않는 것은 아니다. 또한 Java 클래스의 `public`·`private` 접근 제어를 바꾸거나 보안상 접근을 차단하는 기능도 아니다.

## 2. Starter에서 api를 사용하는 이유

이 가이드의 Starter는 Runtime에 공통 모듈을 묶어서 제공한다.

```groovy
// microserver-framework-starter/build.gradle
dependencies {
    api project(':microserver-framework-datasource')
    api project(':microserver-framework-mybatis')
}
```

Runtime은 Starter 하나를 선언한다.

```groovy
// microserver-runtime/build.gradle
dependencies {
    implementation 'io.github.microserverlab:microserver-framework-starter:0.0.1-SNAPSHOT'
}
```

그러면 Runtime의 컴파일·실행 클래스패스에 Starter뿐 아니라 DataSource·MyBatis 공통 모듈도 연결된다. Runtime 소스는 두 모듈에 공개된 클래스를 직접 import하여 사용할 수 있다. 단, 다음 예제 클래스가 실제로 구현되어 있다는 전제다.

```java
// Runtime에서 사용할 수 있는 공개 타입의 예시
// import io.github.microserverlab.microserver.framework.datasource.FrameworkDatabaseInfo;
```

Starter에서 두 의존성을 `implementation`으로 바꾸면 Runtime 실행에는 두 모듈이 전달되지만, Runtime 소스에서 해당 모듈의 클래스를 직접 import해 컴파일할 수는 없다. Runtime이 별도로 의존성을 선언했다면 그 별도 경로로는 사용할 수 있다.

Runtime이 Starter를 `implementation`으로 선언해도 Runtime 자신의 컴파일에는 Starter와 그 api 의존성이 포함된다. 이때의 `implementation`은 Runtime을 또 다른 프로젝트가 사용하는 경우의 전파 범위를 정하는 것으로, Runtime 자신에게 Starter의 공개 의존성이 전달되지 않는다는 의미가 아니다.

## 3. MyBatis 내부에서만 DataSource 타입을 사용하는 경우

다음은 의존성 차이를 설명하기 위한 가상 예제다. 실제 설정 클래스와 메서드를 이 예제대로 작성하라는 뜻은 아니다.

DataSource 모듈에 다음 클래스가 있다고 가정한다.

```java
public class FrameworkDatabaseInfo {
    public String name() {
        return "framework";
    }
}
```

MyBatis 모듈이 메서드 내부에서만 그 클래스를 사용하고, 외부에는 `String`을 반환한다면 다음과 같다. 각 예제는 별도 파일이며 import는 생략했다.

```java
public class MapperDatabaseService {
    public String databaseName() {
        FrameworkDatabaseInfo info = new FrameworkDatabaseInfo();
        return info.name();
    }
}
```

이 경우 MyBatis는 DataSource를 내부 구현 의존성으로 선언할 수 있다.

```groovy
// microserver-framework-mybatis/build.gradle
dependencies {
    implementation project(':microserver-framework-datasource')
}
```

MyBatis만 의존하는 사용자는 `MapperDatabaseService`와 `String` 타입만 알면 메서드를 호출할 수 있다. 내부에서 사용하는 `FrameworkDatabaseInfo` 타입을 자신의 소스에서 사용할 필요가 없다. 실행 시에는 내부 코드가 동작해야 하므로 DataSource 모듈도 실행 의존성으로 전달된다.

## 4. 공개 메서드에 다른 모듈의 타입이 나타나는 경우

MyBatis 모듈이 앞의 메서드를 다음처럼 변경했다고 가정한다.

```java
public class MapperDatabaseService {
    public FrameworkDatabaseInfo databaseInfo() {
        return new FrameworkDatabaseInfo();
    }
}
```

반환 타입이 DataSource 모듈의 `FrameworkDatabaseInfo`다. 사용자는 다음 코드를 컴파일할 때 해당 타입을 알아야 한다.

```java
FrameworkDatabaseInfo info = service.databaseInfo();
```

이 공개 기능을 제공하려면 MyBatis는 DataSource 의존성을 `api`로 선언하는 것이 적절하다.

```groovy
// microserver-framework-mybatis/build.gradle
dependencies {
    api project(':microserver-framework-datasource')
}
```

이것이 “공개 API에 다른 모듈의 타입이 노출되면 계약에 맞게 선언을 조정한다”는 의미다. 여기서 API는 HTTP API가 아니라 다른 Java 프로젝트가 호출·사용하는 공개 클래스와 메서드다. 메서드 반환 타입·매개변수, 공개 생성자 매개변수, 상속 클래스·구현 인터페이스 등에 다른 모듈의 타입이 사용되는지 확인한다.

이 예시에서 FrameworkDatabaseInfo는 직접 작성한 가상 타입이다. 실제 코드에서 쓰는 `javax.sql.DataSource`는 JDK 제공 타입이므로, 이름에 DataSource가 있다는 이유만으로 Framework DataSource 모듈을 `api`로 바꿀 필요는 없다. 타입이 어느 라이브러리에 소속되는지가 판단 기준이다.

현재 Starter는 DataSource 모듈을 직접 `api`로 공개한다. 따라서 Starter를 사용하는 Runtime에서는 MyBatis의 선언과 관계없이 그 직접 경로로 DataSource 모듈이 보일 수 있다. MyBatis 모듈의 의존성 계약을 확인할 때는 MyBatis만 사용하는 프로젝트에서도 공개 메서드를 컴파일할 수 있는지 검토한다.

## 5. 선언 선택 기준과 확인 방법

| 사용 상황 | 선언 기준 |
| --- | --- |
| 메서드 본문 등 해당 모듈 내부 구현에서만 사용 | `implementation` |
| 사용자가 호출할 공개 기능의 타입에 포함 | `api` 검토 |
| Starter처럼 다른 모듈을 사용자에게 묶어 제공 | `api` |
| Runtime이 별도 기능의 클래스를 직접 사용하지만 Starter가 공개하지 않음 | Runtime에 해당 라이브러리를 직접 선언 |

Java의 `import` 문이 있다는 사실만으로 결정하지 않는다. 가져온 타입이 내부 처리에만 쓰이는지, 다른 프로젝트도 컴파일할 때 알아야 하는 공개 계약에 포함되는지 확인한다. Gradle이 소스를 분석하여 `implementation`을 `api`로 자동 변경해주지는 않는다.

Runtime 루트에서 다음 두 결과를 비교하면 컴파일·실행 의존성 차이를 확인할 수 있다. macOS는 `./gradlew`, Windows PowerShell은 `.\gradlew.bat`을 사용한다.

```bash
./gradlew dependencies --configuration compileClasspath
./gradlew dependencies --configuration runtimeClasspath
```

`api`를 사용해도 대상 모듈의 클래스가 Starter JAR 안으로 합쳐지는 것은 아니다. 각 모듈 JAR은 별도로 존재하고, Gradle이 의존성 관계를 통해 필요한 클래스패스에 연결한다. 배포 시에도 이 관계가 전달되도록 JAR과 의존성 메타데이터를 함께 게시한다.

참고: [Gradle Java Library Plugin — API와 implementation 구분](https://docs.gradle.org/current/userguide/java_library_plugin.html#sec:java_library_separation)

[프로젝트 생성과 개발 환경 구성으로 돌아가기](../02_multi_project/multi_project_setup.md#45-starter-프로젝트)
