# MyBatis 구성 원칙과 공통 설정

MyBatis의 역할과 파일 소유권을 정하고 외부 YAML 및 공통 설정 XML을 준비한다.

1. [MyBatis 구성 원칙과 공통 설정](mybatis_mapper_setup.md)
2. [MyBatis 세션·매퍼·서비스 구현](mybatis_session_mapper_setup.md)
3. [MyBatis 통합 테스트와 실행 검증](mybatis_integration_verification.md)

MicroServer는 Framework 내부 기능용 DB와 Runtime 업무용 DB에 각각 MyBatis를 연결한다. 이 가이드에서는 두 DB에 같은 이름의 테이블을 만들고, 각 서비스가 자기 DB의 행을 조회하는지 H2 통합 테스트로 검증한다.

준비 사항은 JDK 25, 프로젝트의 Gradle Wrapper, 그리고 `MicroServerDataSourceConfig`가 등록하는 두 DataSource와 두 트랜잭션 관리자다. DataSource Bean과 접속 정보의 구성은 [DataSource 구성 원칙과 외부 설정](datasource_framework_setup.md)과 [DataSource Bean 구현과 등록](datasource_bean_setup.md)을 따른다.

## 1. MyBatis와 Spring의 역할

MyBatis는 Java 메서드를 SQL 문에 연결하는 데이터 접근 라이브러리다. 개발자가 매퍼 XML에 SQL과 결과 매핑을 작성하면 MyBatis가 JDBC 파라미터를 바인딩하고 조회 결과를 Java 값이나 객체로 변환한다. 서비스는 매퍼 인터페이스를 호출한다. MyBatis-Spring은 그 인터페이스의 프록시를 Spring Bean으로 등록하고, SQL 실행에 사용할 세션을 Spring 트랜잭션과 연동한다.

!!! tip "참고 팁"
    - [MyBatis 매퍼 XML](https://mybatis.org/mybatis-3/sqlmap-xml.html)
    - [MyBatis-Spring 세션 관리](https://mybatis.org/spring/sqlsession.html)

| 구성 요소 | 담당하는 일 |
| --- | --- |
| `application.yml` | 활성 Profile에 해당하는 외부 YAML을 가져온다. |
| 외부 `application-context/<profile>/application-*.yml` | DB 접속 정보와 MyBatis 리소스 경로를 Spring 환경의 프로퍼티로 제공한다. |
| Java `@Configuration` | 프로퍼티와 DataSource Bean으로 DB별 `SqlSessionFactory`, `SqlSessionTemplate`을 생성한다. `@MapperScan`으로 각 인터페이스를 해당 Template에 연결한다. |
| `mybatis-config.xml` | 각 Factory에 적용할 MyBatis 엔진 옵션을 정의한다. |
| 매퍼 XML | `select`, `insert`, `update`, `delete`의 SQL, 입력 바인딩, 결과 매핑을 정의한다. |
| 서비스 | 매퍼를 호출하고 `@Transactional`로 작업 단위와 트랜잭션 관리자를 지정한다. |

**기동 시** Spring Boot가 외부 YAML을 Spring `Environment`에 로딩한다. Spring ApplicationContext가 Java 설정을 실행하면 각 Factory가 설정 XML과 담당 매퍼 XML을 읽어 SQL 문을 등록한다. 매퍼 스캔은 인터페이스별 프록시 Bean을 만들고 연결할 Template을 지정한다. 외부 디렉터리 이름인 `application-context`는 설정값을 모아 두는 경로다. Bean 등록은 실행 중인 Spring ApplicationContext가 Java 설정을 바탕으로 수행한다.

!!! tip "참고 팁"
    - [Spring Boot 외부 설정](https://docs.spring.io/spring-boot/reference/features/external-config.html)
    - [MyBatis-Spring 매퍼 등록](https://mybatis.org/spring/mappers.html)

**호출 시** 서비스의 트랜잭션 경계 안에서 매퍼 프록시가 `namespace.id`로 SQL을 찾는다. `SqlSessionTemplate`은 해당 Factory에서 현재 Spring 트랜잭션에 연결된 세션을 사용하고, MyBatis는 JDBC로 SQL을 실행한다. 트랜잭션이 끝나면 Spring이 커밋 또는 롤백을 처리하고 세션과 커넥션을 정리한다. Template은 여러 서비스에서 공유할 수 있다.

!!! tip "참고 팁"
    - [MyBatis-Spring 트랜잭션](https://mybatis.org/spring/transactions.html)

## 2. DB별 Bean과 파일 소유권

| 구분 | Framework DB | Business DB |
| --- | --- | --- |
| DataSource | `frameworkDataSource` | `businessDataSource` (`@Primary`) |
| 트랜잭션 관리자 | `frameworkTransactionManager` | `businessTransactionManager` (`@Primary`) |
| 세션 Factory | `frameworkSqlSessionFactory` | `businessSqlSessionFactory` |
| 세션 Template | `frameworkSqlSessionTemplate` | `businessSqlSessionTemplate` |
| 매퍼 패키지 접미사 | `framework.mybatis.mapper` | `business.mybatis.mapper` |
| 매퍼 XML 디렉터리 | `mybatis/mapper/framework/` | `mybatis/mapper/business/` |
| 매퍼와 SQL 소유자 | Framework 내부 기능 | Runtime 업무 도메인 |

- **Framework**는 두 DB의 DataSource, 트랜잭션 관리자, 세션 Bean과 공통 MyBatis 설정을 제공한다. 내부 기능의 매퍼와 서비스는 `framework.mybatis` 아래에 둔다.
- **Runtime**은 업무 매퍼의 스캔 설정, 인터페이스, XML, 서비스를 관리한다. 업무용 Java 코드는 `business.mybatis` 아래에 둔다.

두 패키지는 `io.github.microserverlab.microserver` 아래에 있으며, 각 `mapper` 패키지에는 담당 DB의 매퍼 인터페이스만 둔다. `BusinessMapperConfig`는 Framework가 제공하는 `businessSqlSessionTemplate`을 이름으로 참조해 업무 매퍼를 연결한다.

```text
microserver/
├── build.gradle
├── gradlew
└── src/
    ├── main/
    │   ├── java/io/github/microserverlab/microserver/
    │   │   ├── MicroserverApplication.java
    │   │   ├── framework/
    │   │   │   ├── datasource/
    │   │   │   │   ├── MicroServerDataSourceConfig.java
    │   │   │   │   └── MicroServerDataSourceProperties.java
    │   │   │   └── mybatis/
    │   │   │       ├── MicroServerMyBatisConfig.java
    │   │   │       ├── mapper/FrameworkLabelMapper.java
    │   │   │       └── service/FrameworkLabelService.java
    │   │   └── business/
    │   │       └── mybatis/
    │   │           ├── BusinessMapperConfig.java
    │   │           ├── mapper/BusinessLabelMapper.java
    │   │           └── service/BusinessLabelService.java
    │   └── resources/
    │       ├── application.yml
    │       └── mybatis/
    │           ├── mybatis-config.xml
    │           └── mapper/
    │               ├── framework/FrameworkLabelMapper.xml
    │               └── business/BusinessLabelMapper.xml
    └── test/
        ├── java/io/github/microserverlab/microserver/
        │   └── mybatis/MyBatisMapperIntegrationTest.java
        └── resources/sql/
            ├── framework-mapper-fixture.sql
            └── business-mapper-fixture.sql
```

!!! note "참고 사항 — 멀티프로젝트에서 매퍼 XML 배치"
    위 파일 트리는 단일 모듈 예제다. 두 매퍼 XML은 조회 SQL을 담으며, `namespace`로 대응하는 Java 매퍼 인터페이스에 연결된다. 프로젝트를 분리할 때는 각 인터페이스를 소유한 프로젝트의 `src/main/resources`에 XML을 둔다.

    - **Framework 모듈**의 내부 기능 SQL은 `src/main/resources/mybatis/mapper/framework/FrameworkLabelMapper.xml`에 둔다.
    - **해당 업무 프로젝트**의 업무 SQL은 `src/main/resources/mybatis/mapper/business/BusinessLabelMapper.xml`에 둔다.
    - **공통 MyBatis 엔진 설정**인 `mybatis-config.xml`은 Framework 모듈의 `src/main/resources/mybatis/`에 둔다.

    인터페이스, SQL, 테스트를 같은 프로젝트에서 변경하고 배포할 수 있다. 각 DB의 `SqlSessionFactory`는 `mapperLocations`에 지정된 경로에서 담당 XML을 읽는다. [MyBatis-Spring 매퍼 리소스 설정](https://mybatis.org/spring/factorybean.html)

외부 리소스는 실행 환경에서 별도로 제공한다. `local`은 아래 H2 예제를 위한 디렉터리다. `dev`, `prod`를 사용하는 환경도 같은 두 파일을 준비한다.

```text
microserver-resource/
└── config/
    └── application-context/
        ├── local/
        │   ├── application-datasource.yml
        │   └── application-mybatis.yml
        ├── dev/
        │   ├── application-datasource.yml
        │   └── application-mybatis.yml
        └── prod/
            ├── application-datasource.yml
            └── application-mybatis.yml
```

## 3. MyBatis 의존성 추가

프로젝트 루트의 `build.gradle`을 열고, 이미 있는 `dependencies { ... }` 블록에서 JDBC Starter 바로 아래에 MyBatis Starter 선언 한 줄을 추가한다. 이 가이드의 Spring Boot 4.1.1에서는 4.1.0을 사용한다. Starter는 MyBatis Core와 MyBatis-Spring을 함께 가져온다. [MyBatis Starter 4.1.0 릴리스 POM](https://github.com/mybatis/spring-boot-starter/blob/mybatis-spring-boot-4.1.0/pom.xml)

```groovy
dependencies {
    // 기존 JDBC Starter
    implementation 'org.springframework.boot:spring-boot-starter-jdbc'

    // 추가할 MyBatis Starter
    implementation 'org.mybatis.spring.boot:mybatis-spring-boot-starter:4.1.0'
    // 나머지 의존성
}
```

[DataSource Bean 구현과 등록](datasource_bean_setup.md#6-datasource)에서 설정한 JDBC Starter, H2 런타임 의존성, 테스트 의존성을 사용한다. 다음 단계에서는 Profile별 YAML을 연결하고 MyBatis 자동 구성을 제외해 Framework가 두 DB의 세션을 각각 등록하도록 한다.

## 4. Profile별 외부 YAML 연결

`src/main/resources/application.yml`에 두 파일의 import를 등록한다. 애플리케이션 이름과 import는 이 파일에서 관리한다. 실행 명령에서 `spring.profiles.active=local`과 `microserver.resource-dir`을 제공하면 Spring Boot가 `config/application-context/local/` 아래의 두 YAML을 읽는다.

```yaml
spring:
  application:
    name: microserver
  config:
    import:
      - 'file:${microserver.resource-dir}/config/application-context/${spring.profiles.active}/application-datasource.yml'
      - 'file:${microserver.resource-dir}/config/application-context/${spring.profiles.active}/application-mybatis.yml'
  autoconfigure:
    exclude:
      - org.mybatis.spring.boot.autoconfigure.MybatisAutoConfiguration
  sql:
    init:
      mode: never
```

- **MyBatis 자동 구성** (`spring.autoconfigure.exclude`)
    - **사용 시** DataSource가 하나면 그 DB를 선택한다. 여러 개면 `@Primary`로 지정한 DB를 선택할 수 있다. Starter가 필요한 세션 Bean과 매퍼를 자동으로 등록한다. [MyBatis 4.1.0 자동 구성 코드](https://github.com/mybatis/spring-boot-starter/blob/mybatis-spring-boot-4.1.0/mybatis-spring-boot-autoconfigure/src/main/java/org/mybatis/spring/boot/autoconfigure/MybatisAutoConfiguration.java)
    - **제외 시 (현재 예제)** Java 설정에서 Framework DB와 Business DB의 세션 Bean을 각각 만든다. `@MapperScan`으로 각 매퍼를 담당 세션에 연결한다.
- **SQL 스크립트 초기화** (`spring.sql.init.mode`)
    - **`embedded` (기본값)** H2 인메모리 DB 같은 내장 인메모리 DB에서만 스크립트를 실행한다.
    - **`always`** 외부 DB에서도 스크립트를 실행한다.
    - **`never` (현재 예제)** `schema.sql`과 `data.sql`을 자동 실행하지 않는다. H2 통합 테스트에서 각 DataSource에 테스트용 SQL을 직접 실행한다.

!!! warning "환경 Profile은 하나만 지정"
    이 경로는 `spring.profiles.active` 값을 디렉터리명으로 사용한다. `local`, `dev`, `prod` 중 하나를 실행 시 전달한다. 두 import는 필수이므로 설정 경로가 잘못되거나 파일이 누락되면 기동이 실패한다. Gradle 테스트와 IDE 실행에도 각각 Profile과 리소스 루트를 전달한다.

!!! tip "참고 팁 — 이전 장의 DataSource 설정"
    `config/application-context/local/application-datasource.yml`은 이전 장에서 작성한 파일을 그대로 사용한다. [외부 DataSource 설정파일 작성](datasource_framework_setup.md#4-datasource)

### MyBatis 설정 파일 작성

외부 리소스 루트의 `config/application-context/local/application-mybatis.yml`을 작성한다. **공통 설정 XML과 DB별 매퍼 XML 경로**를 지정하면 Java 설정이 이 값을 읽는다.

```yaml
microserver:
  mybatis:
    config-location: 'classpath:/mybatis/mybatis-config.xml'
    framework:
      mapper-locations: 'classpath*:mybatis/mapper/framework/**/*.xml'
    business:
      mapper-locations: 'classpath*:mybatis/mapper/business/**/*.xml'
```

!!! tip "실행 환경과 배포 리소스의 경로"
    - **`file:` — 파일시스템에서 읽기.** 실행하는 PC나 서버의 파일 경로를 지정한다. 이 예제에서는 외부 리소스 루트와 활성 Profile을 경로에 넣어 `application-datasource.yml`과 `application-mybatis.yml`을 읽는다. 같은 JAR을 배포해도 환경마다 다른 YAML을 사용할 수 있다.
    - **`classpath:` — 클래스패스에서 파일 한 개 찾기.** 클래스패스에는 빌드된 리소스 디렉터리와 실행에 포함된 JAR 등이 들어간다. 이 예제의 `classpath:/mybatis/mybatis-config.xml`은 클래스패스 루트 기준으로 공통 설정 XML 한 개를 찾는다. 소스에서는 `src/main/resources/mybatis/mybatis-config.xml`에 둔다.
    - **`classpath*:` — 여러 클래스패스 위치에서 일치하는 파일 모으기.** `classpath*:mybatis/mapper/business/**/*.xml`은 클래스패스에 포함된 디렉터리와 JAR에서 업무 매퍼 XML을 찾는다. `**/`는 현재 디렉터리와 하위 디렉터리를 포함하고, `*.xml`은 XML 파일 이름을 고른다. Framework와 Runtime을 별도 JAR로 패키징해도 DB별 매퍼 검색 경로는 각각 지정한다.

    실제 DB의 계정과 암호는 외부 YAML에서 환경변수나 배포 환경의 Secret으로 주입한다. [Spring 리소스 경로](https://docs.spring.io/spring-framework/reference/core/resources.html) · [Spring Boot 외부 설정](https://docs.spring.io/spring-boot/reference/features/external-config.html)

!!! tip "클래스패스는 빌드 결과와 JAR에서 어떻게 구성되나"
    클래스패스는 실행할 때 클래스와 리소스를 찾는 위치의 목록이다. 디렉터리와 JAR가 각각 검색 위치가 될 수 있다.

    - **개발 중 Gradle로 실행할 때** 각 모듈의 `src/main/resources/`는 리소스 원본을 두는 곳이다. Gradle은 `processResources`에서 파일을 `build/resources/main/`으로 복사한다. 실행 클래스패스에는 이 리소스 출력 디렉터리와 컴파일된 클래스 디렉터리, 실행에 필요한 의존성이 들어간다. [Gradle Java 플러그인](https://docs.gradle.org/current/userguide/java_plugin.html)
    - **JAR로 패키징할 때** 일반 라이브러리 JAR에는 리소스가 JAR 루트 기준으로 들어간다. 예를 들어 Framework 모듈의 `src/main/resources/mybatis/mybatis-config.xml`은 `framework.jar` 안의 `mybatis/mybatis-config.xml`이 된다. Spring Boot 실행 JAR에서는 애플리케이션의 클래스와 리소스가 `BOOT-INF/classes/`에 들어가고, 의존 JAR는 `BOOT-INF/lib/`에 들어간다. 실행 시 Boot Loader가 이 위치들을 클래스패스에 올린다. [Spring Boot 실행 JAR 구조](https://docs.spring.io/spring-boot/specification/executable-jar/nested-jars.html)
    - **여러 JAR에서 매퍼를 찾을 때** 예를 들어 `orders.jar`와 `billing.jar`가 둘 다 실행 클래스패스에 있다고 하자. 각 JAR의 `mybatis/mapper/business/` 아래에 매퍼 XML이 있으면 `classpath*:mybatis/mapper/business/**/*.xml`로 두 JAR의 매퍼를 함께 찾을 수 있다. **`classpath*:`는 여러 검색 위치를 대상으로 하고, `**/*.xml`은 각 위치에서 일치하는 파일을 고른다.** [Spring 클래스패스 리소스 검색](https://docs.spring.io/spring-framework/reference/core/resources.html#resources-classpath-wildcards)

## 5. `mybatis-config.xml` 관리

이 예제에서는 Framework DB와 Business DB에 같은 MyBatis 동작 규칙을 적용한다. 그래서 **공통 설정 XML을 Framework 코드와 함께 버전 관리하고 배포한다.** 환경별 리소스 경로는 외부 YAML에서 지정한다.

| 파일 | 역할 | 위치 |
| --- | --- | --- |
| `application-mybatis.yml` | 공통 설정 XML과 DB별 매퍼 XML을 **어디서 읽을지** 지정한다. | 환경별 외부 설정 디렉터리 |
| `mybatis-config.xml` | `mapUnderscoreToCamelCase` 같은 **MyBatis 동작 규칙**을 정의한다. | Framework 리소스 |

현재 단일 프로젝트에서는 루트 프로젝트의 `src/main/resources/mybatis/mybatis-config.xml`을 작성한다. 모듈을 분리하면 Framework 모듈의 같은 리소스 경로에 둔다. Framework JAR가 실행 클래스패스에 있으면 `classpath:/mybatis/mybatis-config.xml`로 읽을 수 있다.

### 공통 XML과 Spring 설정의 역할

두 `SqlSessionFactory`는 같은 XML에서 공통 옵션을 읽는다. 접속할 DB와 등록할 매퍼는 Factory별로 지정한다.

- **공통 동작 옵션**은 `mybatis-config.xml`의 `<settings>`에 둔다. 아래 예제에서는 컬럼 이름을 Java 속성에 매핑하는 옵션을 설정한다.
- **DB 연결과 트랜잭션**은 Spring이 맡는다. [6절](mybatis_session_mapper_setup.md#6-db-bean)에서 각 Factory에 담당 `DataSource`를 연결한다. [8절](mybatis_session_mapper_setup.md#8)에서는 서비스의 `@Transactional`에 같은 DB의 트랜잭션 관리자를 지정한다. 이 구성에서는 XML의 `<environments>`를 생략한다.
- **매퍼 SQL 등록**은 [4절](mybatis_mapper_setup.md#4-profile-yaml)의 `mapper-locations`에서 시작한다. [6절](mybatis_session_mapper_setup.md#6-db-bean)의 Java 설정이 이 경로에서 매퍼 XML을 찾아 Factory의 `setMapperLocations()`에 전달한다. 매퍼 목록은 이 경로로 관리하므로 공통 XML의 `<mappers>`는 생략한다. 같은 Factory에 같은 `namespace.id`가 중복 등록되면 충돌할 수 있다. [SqlSessionFactoryBean 설정](https://mybatis.org/spring/factorybean.html)

!!! tip "환경별로 설정 XML을 관리하는 경우"
    환경마다 XML의 동작 규칙을 바꿔야 한다면 파일을 외부 설정 디렉터리에 둘 수 있다. 외부 `application-mybatis.yml`의 `microserver.mybatis.config-location`에 `file:/opt/microserver-resource/config/mybatis/mybatis-config.xml`처럼 실제 파일 경로를 지정한다.

### 공통 설정 XML의 최소 예제

이 단계에서는 공통 설정 XML을 읽는 흐름을 확인할 수 있도록 옵션 하나만 예로 넣는다. 실제 프로젝트에 적용할 옵션은 매핑과 실행 요구사항이 정해지면 추가한다.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE configuration
    PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
    "https://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <settings>
        <setting name="mapUnderscoreToCamelCase" value="true"/>
    </settings>
</configuration>
```

!!! tip "참고 팁 — `mapUnderscoreToCamelCase`"
    `true`로 설정하면 객체 자동 매핑 시 `display_name` 컬럼을 `displayName` 속성에 연결한다. 이 가이드의 조회 예제는 문자열 하나를 반환하므로 이 옵션에 의존하지 않는다. [MyBatis 설정 옵션](https://mybatis.org/mybatis-3/configuration.html)
