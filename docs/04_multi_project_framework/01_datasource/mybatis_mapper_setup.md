# MyBatis 매퍼 설정 및 SQL 실행

MicroServer는 Framework 내부 기능용 DB와 Runtime 업무용 DB에 각각 MyBatis를 연결한다. 이 가이드에서는 두 DB에 같은 이름의 테이블을 만들고, 각 서비스가 자기 DB의 행을 조회하는지 H2 통합 테스트로 검증한다.

준비 사항은 JDK 25, 프로젝트의 Gradle Wrapper, 그리고 `MicroServerDataSourceConfig`가 등록하는 두 DataSource와 두 트랜잭션 관리자다. DataSource Bean과 접속 정보의 구성은 [DataSource Framework 구성 및 접속 검증](datasource_framework_setup.md)을 따른다.

## 1. MyBatis와 Spring의 역할

MyBatis는 Java 메서드를 SQL 문에 연결하는 데이터 접근 라이브러리다. 개발자가 매퍼 XML에 SQL과 결과 매핑을 작성하면 MyBatis가 JDBC 파라미터를 바인딩하고 조회 결과를 Java 값이나 객체로 변환한다. 서비스는 매퍼 인터페이스를 호출한다. MyBatis-Spring은 그 인터페이스의 프록시를 Spring Bean으로 등록하고, SQL 실행에 사용할 세션을 Spring 트랜잭션과 연동한다. [MyBatis 매퍼 XML](https://mybatis.org/mybatis-3/sqlmap-xml.html) · [MyBatis-Spring 세션 관리](https://mybatis.org/spring/sqlsession.html)

| 구성 요소 | 담당하는 일 |
| --- | --- |
| `application.yml` | 활성 Profile에 해당하는 외부 YAML을 가져온다. |
| 외부 `application-context/<profile>/application-*.yml` | DB 접속 정보와 MyBatis 리소스 경로를 Spring 환경의 프로퍼티로 제공한다. |
| Java `@Configuration` | 프로퍼티와 DataSource Bean으로 DB별 `SqlSessionFactory`, `SqlSessionTemplate`을 생성한다. `@MapperScan`으로 각 인터페이스를 해당 Template에 연결한다. |
| `mybatis-config.xml` | 각 Factory에 적용할 MyBatis 엔진 옵션을 정의한다. |
| 매퍼 XML | `select`, `insert`, `update`, `delete`의 SQL, 입력 바인딩, 결과 매핑을 정의한다. |
| 서비스 | 매퍼를 호출하고 `@Transactional`로 작업 단위와 트랜잭션 관리자를 지정한다. |

**기동 시** Spring Boot가 외부 YAML을 Spring `Environment`에 로딩한다. Spring ApplicationContext가 Java 설정을 실행하면 각 Factory가 설정 XML과 담당 매퍼 XML을 읽어 SQL 문을 등록한다. 매퍼 스캔은 인터페이스별 프록시 Bean을 만들고 연결할 Template을 지정한다. 외부 디렉터리 이름인 `application-context`는 설정값을 모아 두는 경로다. Bean 등록은 실행 중인 Spring ApplicationContext가 Java 설정을 바탕으로 수행한다. [Spring Boot 외부 설정](https://docs.spring.io/spring-boot/reference/features/external-config.html) · [MyBatis-Spring 매퍼 등록](https://mybatis.org/spring/mappers.html)

**호출 시** 서비스의 트랜잭션 경계 안에서 매퍼 프록시가 `namespace.id`로 SQL을 찾는다. `SqlSessionTemplate`은 해당 Factory에서 현재 Spring 트랜잭션에 연결된 세션을 사용하고, MyBatis는 JDBC로 SQL을 실행한다. 트랜잭션이 끝나면 Spring이 커밋 또는 롤백을 처리하고 세션과 커넥션을 정리한다. Template은 여러 서비스에서 공유할 수 있다. [MyBatis-Spring 트랜잭션](https://mybatis.org/spring/transactions.html)

## 2. DB별 Bean과 파일 소유권

| 구분 | Framework DB | Business DB |
| --- | --- | --- |
| DataSource | `frameworkDataSource` | `businessDataSource` (`@Primary`) |
| 트랜잭션 관리자 | `frameworkTransactionManager` | `businessTransactionManager` (`@Primary`) |
| 세션 Factory | `frameworkSqlSessionFactory` | `businessSqlSessionFactory` |
| 세션 Template | `frameworkSqlSessionTemplate` | `businessSqlSessionTemplate` |
| 매퍼 패키지 접미사 | `framework.mybatis.mapper` | `runtime.mapper` |
| 매퍼 XML 디렉터리 | `mybatis/mapper/framework/` | `mybatis/mapper/business/` |
| 매퍼와 SQL 소유자 | Framework 내부 기능 | Runtime 업무 도메인 |

Framework는 두 DB의 DataSource·트랜잭션 관리자·세션 Bean과 공통 엔진 설정을 제공한다. Framework 내부 기능의 매퍼와 서비스도 Framework에 둔다. Runtime은 업무 매퍼의 스캔, 인터페이스, XML, 서비스를 관리한다. 매퍼 패키지는 해당 DB의 인터페이스 전용으로 둔다.

아래 예제는 `io.github.microserverlab.microserver` 아래에서 Framework와 Runtime의 패키지 및 매퍼 리소스를 구분한다. Runtime의 `BusinessMapperConfig`는 Framework가 제공하는 `businessSqlSessionTemplate`을 이름으로 참조한다.

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
    │   │   └── runtime/
    │   │       ├── mybatis/BusinessMapperConfig.java
    │   │       ├── mapper/BusinessLabelMapper.java
    │   │       └── service/BusinessLabelService.java
    │   └── resources/
    │       ├── application.yml
    │       └── mybatis/
    │           ├── mybatis-config.xml
    │           └── mapper/
    │               ├── framework/FrameworkLabelMapper.xml
    │               └── business/BusinessLabelMapper.xml
    └── test/
        ├── java/io/github/microserverlab/microserver/
        │   └── MyBatisMapperIntegrationTest.java
        └── resources/sql/
            ├── framework-mapper-fixture.sql
            └── business-mapper-fixture.sql
```

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

루트 `build.gradle`의 `dependencies`에 MyBatis Starter를 추가한다. 이 가이드의 Spring Boot 4.1.1에서는 4.1.0을 사용한다. Starter는 MyBatis Core와 MyBatis-Spring을 함께 가져온다. [MyBatis Starter 4.1.0 릴리스 POM](https://github.com/mybatis/spring-boot-starter/blob/mybatis-spring-boot-4.1.0/pom.xml)

```groovy
implementation 'org.mybatis.spring.boot:mybatis-spring-boot-starter:4.1.0'
```

[DataSource Framework 구성 및 접속 검증](datasource_framework_setup.md)에서 설정한 JDBC Starter, H2 런타임 의존성, 테스트 의존성을 사용한다. 다음 단계에서는 Profile별 YAML을 연결하고 MyBatis 자동 구성을 제외해 Framework가 두 DB의 세션을 각각 등록하도록 한다.

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

MyBatis 자동 구성은 단일 후보 DataSource를 기준으로 동작하며, DataSource가 여러 개여도 `@Primary` 후보가 있으면 그 조건을 충족할 수 있다. 이 예제의 세션 Bean과 매퍼는 Java 설정이 전담하도록 해당 자동 구성을 제외한다. `spring.sql.init.mode=never`는 Spring Boot의 SQL 스크립트 자동 초기화를 끈다. 아래 H2 픽스처는 테스트가 각 DataSource에 직접 실행한다. [MyBatis 4.1.0 자동 구성 코드](https://github.com/mybatis/spring-boot-starter/blob/mybatis-spring-boot-4.1.0/mybatis-spring-boot-autoconfigure/src/main/java/org/mybatis/spring/boot/autoconfigure/MybatisAutoConfiguration.java)

!!! warning "환경 Profile은 하나만 지정"
    이 경로는 `spring.profiles.active` 값을 디렉터리명으로 사용한다. `local`, `dev`, `prod` 중 하나를 실행 시 전달한다. 두 import는 필수이므로 설정 경로가 잘못되거나 파일이 누락되면 기동이 실패한다. Gradle 테스트와 IDE 실행에도 각각 Profile과 리소스 루트를 전달한다.

`config/application-context/local/application-datasource.yml`을 작성한다. 메모리 DB 이름이 서로 달라 두 개의 독립된 DB가 생성된다.

```yaml
microserver:
  datasource:
    framework:
      driver-class-name: org.h2.Driver
      jdbc-url: 'jdbc:h2:mem:frameworkdb;DB_CLOSE_DELAY=-1'
      username: sa
      password: ''
      maximum-pool-size: 5
      minimum-idle: 1
    business:
      driver-class-name: org.h2.Driver
      jdbc-url: 'jdbc:h2:mem:businessdb;DB_CLOSE_DELAY=-1'
      username: sa
      password: ''
      maximum-pool-size: 10
      minimum-idle: 1
```

`config/application-context/local/application-mybatis.yml`을 작성한다. 이 예제의 프로퍼티는 Java 설정이 직접 읽는다.

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
    `file:`은 실행 환경의 파일시스템에 있는 YAML을 읽는다. `classpath:`은 배포물에 포함된 설정 XML 한 개를 찾는다. `classpath*:`와 와일드카드는 여러 클래스패스 위치에서 패턴에 맞는 매퍼 XML을 찾는다. Framework JAR과 Runtime JAR로 나누더라도 두 매퍼 경로의 범위를 분리한다. 실제 DB의 계정과 암호는 외부 YAML에서 환경변수나 배포 환경의 Secret으로 주입한다.

## 5. `mybatis-config.xml` 관리

`src/main/resources/mybatis/mybatis-config.xml`을 작성한다. 두 Factory가 같은 파일을 각자 읽으므로 공통 옵션이 적용되면서도 SQL 등록과 실행 환경은 Factory마다 독립적이다.

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

`mapUnderscoreToCamelCase`는 객체 자동 매핑에서 `display_name` 같은 컬럼을 `displayName` 속성에 연결한다. 아래 조회 예제는 단일 문자열 컬럼을 반환한다. 여러 컬럼의 매핑을 명시하려면 해당 매퍼 XML에서 `<resultMap>`을 선언한다. 공통 엔진 정책이 바뀔 때 이 설정 파일과 양쪽 DB의 매퍼 테스트를 함께 검토한다. [MyBatis 설정 옵션](https://mybatis.org/mybatis-3/configuration.html)

!!! note "설정 XML과 SQL 등록 위치"
    `mybatis-config.xml`은 엔진 옵션을 담는다. DB 연결과 트랜잭션 관리자는 Spring 설정에서 선택하고, SQL XML 목록은 Factory별 `setMapperLocations()`로 관리한다. 이 구성에서는 설정 XML에 `<environments>`나 `<mappers>`를 추가하지 않는다. 동일 SQL 파일이 중복 등록되면 statement ID 충돌이 발생할 수 있다. [SqlSessionFactoryBean 설정](https://mybatis.org/spring/factorybean.html)

## 6. DB별 세션 Bean과 매퍼 스캔 등록

`framework/mybatis/MicroServerMyBatisConfig.java`에 두 Factory와 두 Template을 등록한다. Java 파일의 경로는 2절의 `src/main/java/io/github/microserverlab/microserver/` 기준이다.

```java
package io.github.microserverlab.microserver.framework.mybatis;

import javax.sql.DataSource;

import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.SqlSessionTemplate;
import org.mybatis.spring.annotation.MapperScan;
import org.mybatis.spring.boot.autoconfigure.SpringBootVFS;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.ResourcePatternResolver;

@Configuration(proxyBeanMethods = false)
@MapperScan(
        basePackages = "io.github.microserverlab.microserver.framework.mybatis.mapper",
        sqlSessionTemplateRef = "frameworkSqlSessionTemplate")
public class MicroServerMyBatisConfig {

    @Bean
    SqlSessionFactory frameworkSqlSessionFactory(
            @Qualifier("frameworkDataSource") DataSource dataSource,
            ResourcePatternResolver resources,
            @Value("${microserver.mybatis.config-location}") String configLocation,
            @Value("${microserver.mybatis.framework.mapper-locations}") String mapperPattern)
            throws Exception {
        return createFactory(dataSource, resources, configLocation, mapperPattern);
    }

    @Bean
    SqlSessionFactory businessSqlSessionFactory(
            @Qualifier("businessDataSource") DataSource dataSource,
            ResourcePatternResolver resources,
            @Value("${microserver.mybatis.config-location}") String configLocation,
            @Value("${microserver.mybatis.business.mapper-locations}") String mapperPattern)
            throws Exception {
        return createFactory(dataSource, resources, configLocation, mapperPattern);
    }

    @Bean
    SqlSessionTemplate frameworkSqlSessionTemplate(
            @Qualifier("frameworkSqlSessionFactory") SqlSessionFactory factory) {
        return new SqlSessionTemplate(factory);
    }

    @Bean
    SqlSessionTemplate businessSqlSessionTemplate(
            @Qualifier("businessSqlSessionFactory") SqlSessionFactory factory) {
        return new SqlSessionTemplate(factory);
    }

    private SqlSessionFactory createFactory(
            DataSource dataSource,
            ResourcePatternResolver resources,
            String configLocation,
            String mapperPattern) throws Exception {
        Resource config = resources.getResource(configLocation);
        if (!config.exists()) {
            throw new IllegalStateException("MyBatis 설정 XML을 찾을 수 없습니다. " + configLocation);
        }

        Resource[] mappers = resources.getResources(mapperPattern);
        if (mappers.length == 0) {
            throw new IllegalStateException("매퍼 XML을 찾을 수 없습니다. " + mapperPattern);
        }

        SqlSessionFactoryBean factory = new SqlSessionFactoryBean();
        factory.setDataSource(dataSource);
        factory.setVfs(SpringBootVFS.class);
        factory.setConfigLocation(config);
        factory.setMapperLocations(mappers);
        return factory.getObject();
    }
}
```

`runtime/mybatis/BusinessMapperConfig.java`에서 업무 매퍼의 스캔 범위와 Template을 지정한다.

```java
package io.github.microserverlab.microserver.runtime.mybatis;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Configuration;

@Configuration(proxyBeanMethods = false)
@MapperScan(
        basePackages = "io.github.microserverlab.microserver.runtime.mapper",
        sqlSessionTemplateRef = "businessSqlSessionTemplate")
public class BusinessMapperConfig {
}
```

루트 패키지의 `MicroserverApplication`에 선언된 `@SpringBootApplication`이 두 설정 클래스를 찾는다. `setMapperLocations()`는 해당 Factory에 XML의 SQL을 등록하고, `@MapperScan`은 Java 인터페이스를 프록시 Bean으로 등록한다. 각 Factory의 DataSource는 서비스가 지정하는 트랜잭션 관리자의 DataSource와 일치해야 한다. 트랜잭션 관리자 Bean은 DataSource 구성 단계에서 등록한 이름으로 참조한다. [MyBatis-Spring 매퍼 스캔](https://mybatis.org/spring/mappers.html) · [트랜잭션과 DataSource](https://mybatis.org/spring/transactions.html)

!!! warning "매퍼 하나에는 스캔 경로 하나"
    예제는 두 `@MapperScan`으로 모든 매퍼를 등록한다. 루트 패키지 전체를 대상으로 하는 매퍼 스캔이나 별도 `MapperFactoryBean`을 추가하면 등록 범위가 겹칠 수 있다. 두 스캔은 각각 `sqlSessionTemplateRef`를 명시한다. Business DataSource의 `@Primary`는 매퍼의 라우팅을 결정하지 않는다.

## 7. Framework와 Business 매퍼 작성

### Framework 인터페이스와 XML

`framework/mybatis/mapper/FrameworkLabelMapper.java`를 작성한다.

```java
package io.github.microserverlab.microserver.framework.mybatis.mapper;

import org.apache.ibatis.annotations.Param;

public interface FrameworkLabelMapper {

    String findDisplayName(@Param("code") String code);
}
```

`src/main/resources/mybatis/mapper/framework/FrameworkLabelMapper.xml`을 작성한다.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper
    PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
    "https://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="io.github.microserverlab.microserver.framework.mybatis.mapper.FrameworkLabelMapper">
    <select id="findDisplayName" resultType="string">
        SELECT display_name
        FROM mapper_label
        WHERE code = #{code, jdbcType=VARCHAR}
    </select>
</mapper>
```

### Business 인터페이스와 XML

`runtime/mapper/BusinessLabelMapper.java`를 작성한다.

```java
package io.github.microserverlab.microserver.runtime.mapper;

import org.apache.ibatis.annotations.Param;

public interface BusinessLabelMapper {

    String findDisplayName(@Param("code") String code);
}
```

`src/main/resources/mybatis/mapper/business/BusinessLabelMapper.xml`을 작성한다.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper
    PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
    "https://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="io.github.microserverlab.microserver.runtime.mapper.BusinessLabelMapper">
    <select id="findDisplayName" resultType="string">
        SELECT display_name
        FROM mapper_label
        WHERE code = #{code, jdbcType=VARCHAR}
    </select>
</mapper>
```

`namespace`는 인터페이스의 전체 이름이고, `id`는 메서드 이름이다. `@Param("code")`는 `#{code, jdbcType=VARCHAR}`에 연결된다. 조회 결과가 한 행이면 `display_name`을 문자열로 반환하고, 일치하는 행이 없으면 `null`을 반환한다. 예제 테이블의 기본 키는 조회 결과를 최대 한 행으로 제한한다.

!!! tip "SQL과 Java 코드를 함께 관리"
    인터페이스와 XML의 파일명을 맞추고 같은 변경에서 함께 검토한다. 업무 매퍼를 추가할 때는 Runtime의 매퍼 패키지와 `mybatis/mapper/business/` 아래를 사용한다. XML에서 부등호 `<`는 `&lt;`로 쓰거나 필요한 SQL 조각을 CDATA로 감싼다.

!!! warning "입력값은 JDBC 파라미터로 바인딩"
    사용자 입력값에는 `#{...}`를 사용한다. `${...}`는 입력을 SQL 문자열에 그대로 삽입하므로 SQL 주입으로 이어질 수 있다. 컬럼명이나 정렬 방향처럼 바인딩할 수 없는 식별자는 허용 목록에서 고른다. [MyBatis 파라미터 매핑](https://mybatis.org/mybatis-3/sqlmap-xml.html#Parameters)

## 8. 서비스에서 매퍼 호출

`framework/mybatis/service/FrameworkLabelService.java`를 작성한다.

```java
package io.github.microserverlab.microserver.framework.mybatis.service;

import io.github.microserverlab.microserver.framework.mybatis.mapper.FrameworkLabelMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class FrameworkLabelService {

    private final FrameworkLabelMapper mapper;

    public FrameworkLabelService(FrameworkLabelMapper mapper) {
        this.mapper = mapper;
    }

    @Transactional(transactionManager = "frameworkTransactionManager", readOnly = true)
    public String findDisplayName(String code) {
        return mapper.findDisplayName(code);
    }
}
```

`runtime/service/BusinessLabelService.java`를 작성한다.

```java
package io.github.microserverlab.microserver.runtime.service;

import io.github.microserverlab.microserver.runtime.mapper.BusinessLabelMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class BusinessLabelService {

    private final BusinessLabelMapper mapper;

    public BusinessLabelService(BusinessLabelMapper mapper) {
        this.mapper = mapper;
    }

    @Transactional(transactionManager = "businessTransactionManager", readOnly = true)
    public String findDisplayName(String code) {
        return mapper.findDisplayName(code);
    }
}
```

호출자는 Spring이 주입한 서비스 Bean을 통해 public 메서드를 호출한다. 같은 클래스 내부에서 `this`로 호출하면 기본 프록시 방식에서는 해당 메서드의 `@Transactional`이 적용되지 않는다. 조회 메서드의 `readOnly = true`는 트랜잭션 최적화를 위한 힌트다. 쓰기 메서드는 같은 DB의 트랜잭션 관리자를 지정하고 기본 읽기·쓰기 트랜잭션으로 실행한다. [Spring 선언적 트랜잭션](https://docs.spring.io/spring-framework/reference/data-access/transaction/declarative/annotations.html)

!!! warning "두 DB의 트랜잭션 범위"
    각 트랜잭션 관리자는 연결된 DB 하나를 관리한다. 하나의 업무 흐름에서 두 DB를 모두 변경하더라도 두 커밋이나 롤백을 하나의 원자적 작업으로 묶으려면 별도 설계가 필요하다.

## 9. H2에서 매퍼 SQL 실행 검증

두 DB에서 동일한 키 `sample`을 조회하되, DB마다 다른 값을 저장한다. 테스트용 스크립트는 `src/test/resources`에 두고 각 DataSource에 개별 실행한다.

`src/test/resources/sql/framework-mapper-fixture.sql`

```sql
CREATE TABLE IF NOT EXISTS mapper_label (
    code VARCHAR(32) PRIMARY KEY,
    display_name VARCHAR(80) NOT NULL
);

MERGE INTO mapper_label (code, display_name) KEY (code)
VALUES ('sample', 'Framework DB');
```

`src/test/resources/sql/business-mapper-fixture.sql`

```sql
CREATE TABLE IF NOT EXISTS mapper_label (
    code VARCHAR(32) PRIMARY KEY,
    display_name VARCHAR(80) NOT NULL
);

MERGE INTO mapper_label (code, display_name) KEY (code)
VALUES ('sample', 'Business DB');
```

`src/test/java/io/github/microserverlab/microserver/MyBatisMapperIntegrationTest.java`

```java
package io.github.microserverlab.microserver;

import static org.assertj.core.api.Assertions.assertThat;

import java.sql.Connection;
import java.sql.SQLException;
import javax.sql.DataSource;

import io.github.microserverlab.microserver.framework.mybatis.mapper.FrameworkLabelMapper;
import io.github.microserverlab.microserver.framework.mybatis.service.FrameworkLabelService;
import io.github.microserverlab.microserver.runtime.mapper.BusinessLabelMapper;
import io.github.microserverlab.microserver.runtime.service.BusinessLabelService;
import org.apache.ibatis.session.SqlSessionFactory;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.NONE)
class MyBatisMapperIntegrationTest {

    @Autowired
    FrameworkLabelService frameworkService;

    @Autowired
    BusinessLabelService businessService;

    @Autowired
    @Qualifier("frameworkDataSource")
    DataSource frameworkDataSource;

    @Autowired
    @Qualifier("businessDataSource")
    DataSource businessDataSource;

    @Autowired
    @Qualifier("frameworkSqlSessionFactory")
    SqlSessionFactory frameworkFactory;

    @Autowired
    @Qualifier("businessSqlSessionFactory")
    SqlSessionFactory businessFactory;

    @Test
    void queriesEachDatabaseThroughItsServiceAndMapper() throws SQLException {
        assertDatabaseUrl(frameworkDataSource, "jdbc:h2:mem:frameworkdb");
        assertDatabaseUrl(businessDataSource, "jdbc:h2:mem:businessdb");
        loadFixture(frameworkDataSource, "sql/framework-mapper-fixture.sql");
        loadFixture(businessDataSource, "sql/business-mapper-fixture.sql");

        assertThat(frameworkService.findDisplayName("sample")).isEqualTo("Framework DB");
        assertThat(businessService.findDisplayName("sample")).isEqualTo("Business DB");
        assertThat(businessService.findDisplayName("missing")).isNull();
    }

    @Test
    void registersOnlyTheStatementsOwnedByEachFactory() {
        String frameworkStatement = FrameworkLabelMapper.class.getName() + ".findDisplayName";
        String businessStatement = BusinessLabelMapper.class.getName() + ".findDisplayName";

        assertThat(frameworkFactory.getConfiguration().hasStatement(frameworkStatement)).isTrue();
        assertThat(frameworkFactory.getConfiguration().hasStatement(businessStatement)).isFalse();
        assertThat(businessFactory.getConfiguration().hasStatement(businessStatement)).isTrue();
        assertThat(businessFactory.getConfiguration().hasStatement(frameworkStatement)).isFalse();
    }

    private void assertDatabaseUrl(DataSource dataSource, String expected) throws SQLException {
        try (Connection connection = dataSource.getConnection()) {
            assertThat(connection.getMetaData().getURL()).isEqualTo(expected);
        }
    }

    private void loadFixture(DataSource dataSource, String path) {
        new ResourceDatabasePopulator(new ClassPathResource(path)).execute(dataSource);
    }
}
```

### 테스트 실행

Gradle Wrapper가 있는 프로젝트 루트에서 실행한다. 예시의 `/opt/microserver-resource`를 4절의 Local H2 YAML 두 파일을 저장한 리소스 루트의 실제 절대 경로로 바꾼다.

```bash
export SPRING_PROFILES_ACTIVE=local
export SPRING_APPLICATION_JSON='{"microserver":{"resource-dir":"/opt/microserver-resource"}}'

bash ./gradlew test \
  --tests 'io.github.microserverlab.microserver.MyBatisMapperIntegrationTest' \
  --rerun-tasks
```

`BUILD SUCCESSFUL`과 `build/reports/tests/test/index.html`의 테스트 두 건을 확인한다. 첫 테스트는 실제 서비스 → 매퍼 → JDBC 경로를 실행하고 두 DB의 값이 구분되는지 검증한다. 두 번째 테스트는 상대 DB의 SQL이 각 Factory에 등록되지 않았는지 확인한다.

### 애플리케이션 기동과 패키징

같은 환경변수로 `bash ./gradlew bootRun`을 실행하면 외부 설정, 세션 Bean, 매퍼 XML을 읽어 기동한다. 조회용 테이블과 데이터는 통합 테스트가 테스트 JVM에서 준비한다. `bootRun` 프로세스에서 매퍼를 직접 호출하려면 그 프로세스가 접속하는 DB에도 스키마와 데이터가 있어야 한다. H2 메모리 DB는 프로세스 간에 공유되지 않는다.

`bash ./gradlew bootJar`로 패키징하면 설정 XML과 두 매퍼 XML이 실행 JAR의 `BOOT-INF/classes/mybatis/` 아래에 들어간다. 외부 YAML은 실행 시 별도로 읽는다.

## 10. 오류 확인

| 증상 | 확인할 항목 |
| --- | --- |
| 외부 설정 import 실패 | 단일 활성 Profile, `microserver.resource-dir`이 가리키는 루트, 해당 Profile의 두 YAML 파일 |
| 설정 XML 또는 매퍼 XML을 찾지 못함 | `src/main/resources` 아래 경로, `classpath:`와 `classpath*:`의 용도, JAR에 포함된 파일 |
| 매퍼 XML 파싱 오류 | 예외에 표시된 파일, DTD, XML 특수 문자, 결과 타입 또는 `resultMap` |
| 매퍼 Bean 주입 실패 | `@MapperScan` 패키지, 설정 클래스의 컴포넌트 스캔 범위, Template Bean 이름 |
| `Invalid bound statement (not found)` | XML의 `namespace`와 `id`, 매퍼의 Template과 해당 Factory의 XML 패턴 |
| 중복 statement 또는 Bean 이름 충돌 | 겹치는 XML 패턴, 설정 XML의 `<mappers>`, 중복 매퍼 스캔 또는 같은 이름의 매퍼 |
| 다른 DB의 행이 반환됨 | Factory의 DataSource `@Qualifier`, 매퍼의 `sqlSessionTemplateRef`, 외부 YAML의 JDBC URL |
| SQL이 트랜잭션에 참여하지 않음 | 서비스가 Spring Bean으로 호출되는지, 지정한 관리자가 Factory와 같은 DataSource를 사용하는지 |
| `mapper_label` 테이블이 없음 | 테스트용 SQL이 매퍼 호출과 같은 JVM에서 같은 DataSource로 실행되었는지 |
