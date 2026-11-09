# MyBatis 매퍼 설정 및 SQL 실행

[DataSource Framework 구성 및 접속 검증](datasource_framework_setup.md)에서 만든 두 DataSource에 MyBatis를 연결한다. Local H2에서 Framework와 Business Mapper를 각각 호출해 XML의 SQL이 실행되고, 각 Mapper가 지정된 DataSource를 사용하는지 확인한다.

## 1. 레거시 설정에서 이어받을 부분

| 확인한 파일 | 실제 역할 |
| --- | --- |
| `application-local(1).yml` | `mybatis.config-location`, `config-name`, `mapper-location` 값을 제공한다. 설정 XML은 `${resource-dir}/config/mybatis` 아래에 있고, Mapper 경로는 `classpath:/mybatis/mapper/${PROJECT_NAME}/*/*.xml`이다. |
| `CommonMyBatisConfig(1).java` | `MyBatisProperties`에서 설정 XML의 디렉터리와 파일명을 읽어 `setConfigLocation()`에 전달한다. 실제 Mapper 등록에는 `classpath:/mybatis/mapper/module-common/*/*.xml`을 직접 사용한다. YAML의 Mapper 경로도 조회하지만 해당 코드는 디버그 출력에 쓰인다. Common DataSource로 Factory, Template, TransactionManager를 만든다. |
| `AdminMyBatisConfig.java` | `@Value`로 YAML의 세 값을 읽는다. `setConfigLocation()`으로 설정 XML을 지정하고, `setMapperLocations()`로 YAML 패턴에 매칭된 Mapper XML을 지정한다. Admin DataSource로 별도 Factory, Template, TransactionManager를 만든다. |
| `mybatis-config(1).xml` | `<configuration>`에서 캐시, 생성 키, `REUSE` 실행기, 지연 로딩 동작, Admin 모델 별칭, 클래스패스의 `biz.properties` 등을 지정한다. 첨부 XML에는 SQL 문이나 `<mappers>` 목록이 없다. |

두 Java 설정 모두 `SqlSessionFactoryBean.getObject()`를 호출할 때 설정 XML과 지정된 Mapper XML을 읽어 Factory를 만든다. YAML은 경로를 제공한다. 이 가이드에서도 Spring ApplicationContext가 Java 설정으로 Bean을 구성하고, 외부 application-context YAML은 환경별 값을 공급한다.

## 2. Bean 연결과 파일 소유권

| 구분 | Framework DB | Business DB |
| --- | --- | --- |
| 기존 DataSource | `frameworkDataSource` | `businessDataSource` (`@Primary`) |
| 기존 TransactionManager | `frameworkTransactionManager` | `businessTransactionManager` (`@Primary`) |
| 신규 SqlSessionFactory | `frameworkSqlSessionFactory` | `businessSqlSessionFactory` |
| 신규 SqlSessionTemplate | `frameworkSqlSessionTemplate` | `businessSqlSessionTemplate` |
| 스캔할 패키지 | `io.github.microserverlab.microserver.framework.mybatis.mapper` | `io.github.microserverlab.microserver.runtime.mapper` |
| Mapper XML | `mybatis/mapper/framework/` | `mybatis/mapper/business/` |
| Mapper와 SQL의 소유자 | Framework 자체 기능 | Runtime 도메인 |

- `SqlSessionFactory`는 DataSource, MyBatis 설정, 등록된 SQL 문을 보유하고 세션을 만든다.
- `SqlSessionTemplate`은 Factory 하나에 연결되고 Spring 트랜잭션에 맞춰 세션을 관리한다. Service는 Mapper 인터페이스를 주입받아 메서드를 호출한다.
- `@MapperScan`은 지정된 패키지의 인터페이스를 Spring Mapper Bean으로 등록한다. `sqlSessionTemplateRef`가 그 Mapper가 사용할 Template을 결정한다. XML 검색 패턴은 Factory에 어떤 SQL 문을 등록할지 결정한다.

현재 `settings.gradle`에는 단일 프로젝트만 있다. 이번 단계에서는 Framework와 Runtime을 패키지와 리소스 경로로 나눈다. 멀티프로젝트 전환 시 Factory·Template 구성과 Framework 전용 Mapper는 Framework 모듈에, Business Mapper·XML·Service는 Runtime 모듈에 둔다. 업무 패키지에 대한 `@MapperScan` 선언은 Runtime의 설정 클래스에서 Framework가 공개한 Template 이름을 참조하도록 옮긴다. 이렇게 하면 Framework에서 Runtime 모듈로 향하는 의존성이 생기지 않는다.

## 3. Gradle 의존성과 버전

현재 `build.gradle`의 Spring Boot는 **4.1.1**, Java Toolchain은 **25**다. 기존 MyBatis 의존성 선언은 없으므로 루트 `build.gradle`의 `dependencies`에 다음 한 줄을 추가한다.

```groovy
implementation 'org.mybatis.spring.boot:mybatis-spring-boot-starter:4.1.0'
```

Starter 4.1.0은 Spring Boot 4.1 계열용이다. 릴리스 POM의 기준 버전은 Spring Boot 4.1.0, MyBatis-Spring 4.1.0, MyBatis Core 3.5.19이며 최소 Java는 17이다. 현재 Boot 4.1.1과 JDK 25는 같은 지원 계열에 해당한다. 실제 해석 버전은 프로젝트의 Boot 의존성 관리와 Gradle 해석 결과에서 확인한다. [MyBatis Starter 호환성 표](https://github.com/mybatis/spring-boot-starter#requirements) · [4.1.0 릴리스 POM](https://github.com/mybatis/spring-boot-starter/blob/mybatis-spring-boot-4.1.0/pom.xml)

기존 JDBC Starter, H2 런타임 의존성, 테스트 의존성을 사용한다. Starter는 통합 라이브러리와 `SpringBootVFS`를 제공하며, 아래 YAML에서 MyBatis 자동 구성만 제외한다. 자동 구성은 단일 후보 DataSource 기준이고, 지금 구조에서는 Business가 `@Primary`이므로 자동 구성 조건을 충족할 수 있다. 명시 구성은 두 Factory의 연결과 스캔 범위를 각각 고정한다. [MyBatis 4.1.0 자동 구성 코드](https://github.com/mybatis/spring-boot-starter/blob/mybatis-spring-boot-4.1.0/mybatis-spring-boot-autoconfigure/src/main/java/org/mybatis/spring/boot/autoconfigure/MybatisAutoConfiguration.java)

```bash
bash ./gradlew dependencyInsight --configuration runtimeClasspath --dependency org.mybatis
```

## 4. 외부 application-context YAML

현재 Mac의 외부 저장소 폴더명은 `microserver_resource`다. 실행 환경에서 실제 폴더를 `microserver.resource-dir`으로 전달한다. 기존 DataSource import 아래에 MyBatis import를 추가하고, 같은 `spring:` 블록에 자동 구성 제외를 넣는다.

```yaml
# microserver/src/main/resources/application.yml
spring:
  application:
    name: microserver
  autoconfigure:
    exclude:
      - org.mybatis.spring.boot.autoconfigure.MybatisAutoConfiguration
  config:
    import:
      - file:${microserver.resource-dir}/config/application-context/${spring.profiles.active}/application-datasource.yml
      - file:${microserver.resource-dir}/config/application-context/${spring.profiles.active}/application-mybatis.yml
```

```yaml
# microserver_resource/config/application-context/local/application-mybatis.yml
microserver:
  mybatis:
    framework:
      mapper-locations: 'classpath*:mybatis/mapper/framework/**/*.xml'
    business:
      mapper-locations: 'classpath*:mybatis/mapper/business/**/*.xml'
```

두 YAML은 필수 import다. Local에서는 `spring.profiles.active=local`을 전달하고, Dev와 Prod를 추가할 때도 각각의 디렉터리에 같은 이름의 파일을 배치한다. 이 경로 규칙은 한 번에 단일 환경 Profile을 받는다. `local,extra` 같은 복수 Profile 문자열을 쓰려면 환경 디렉터리 선택 값을 별도로 설계한다. VS Code 실행·테스트에 설정한 값은 터미널의 Gradle 실행과 별도로 전달한다.

`classpath*:`는 클래스패스의 여러 위치를 검색하므로, 향후 Framework JAR과 Runtime 리소스를 분리해도 각 전용 경로를 사용할 수 있다. Framework와 Business 패턴을 서로 겹치지 않게 관리한다. 외부 YAML에 경로를 두더라도 Mapper XML은 `src/main/resources`에 저장하고 애플리케이션과 함께 배포한다.

### MyBatis 설정 XML이 필요한 경우

기본 구성은 Java에서 MyBatis 공통 옵션을 지정한다. 환경별로 공통 동작을 바꿀 필요가 생기면 해당 Factory에 `config-location`을 지정한다. 이 값은 `<configuration>` 루트의 **단일 파일**을 가리키고, `mapper-locations`는 `<mapper>` 루트의 **SQL 파일 검색 패턴**을 가리킨다.

예를 들어 외부 Local YAML의 `microserver.mybatis.business` 아래에 다음 값을 추가할 수 있다.

```yaml
config-location: 'file:${microserver.resource-dir}/config/mybatis/local/business-mybatis-config.xml'
```

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
    PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
    "https://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <settings>
        <setting name="mapUnderscoreToCamelCase" value="true"/>
    </settings>
</configuration>
```

아래 Java는 설정 XML이 지정된 경우 그 파일에서 옵션을 읽는다. `setConfiguration()`과 `setConfigLocation()`은 한 Factory에서 하나만 적용한다. DataSource와 트랜잭션은 Spring Bean에 두고, Mapper 등록은 `setMapperLocations()`로 통일한다. 레거시 XML의 Admin 별칭과 `biz.properties`는 기존 모델 및 리소스에 연결되어 있으므로 새 프로젝트에서 필요한 설정만 옮긴다. [MyBatis-Spring Factory 설정](https://mybatis.org/spring/factorybean.html)

## 5. Framework의 Factory와 Template 구성

`src/main/java/io/github/microserverlab/microserver/framework/mybatis/MicroServerMyBatisConfig.java`를 만든다. 현재 메인 클래스 `MicroserverApplication`의 하위 패키지이므로 컴포넌트 스캔으로 설정을 읽는다.

```java
package io.github.microserverlab.microserver.framework.mybatis;

import java.io.IOException;

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
@MapperScan(
        basePackages = "io.github.microserverlab.microserver.runtime.mapper",
        sqlSessionTemplateRef = "businessSqlSessionTemplate")
public class MicroServerMyBatisConfig {

    @Bean
    SqlSessionFactory frameworkSqlSessionFactory(
            @Qualifier("frameworkDataSource") DataSource dataSource,
            ResourcePatternResolver resources,
            @Value("${microserver.mybatis.framework.mapper-locations}") String mapperLocations,
            @Value("${microserver.mybatis.framework.config-location:}") String configLocation)
            throws Exception {
        return createFactory(dataSource, resources, mapperLocations, configLocation);
    }

    @Bean
    SqlSessionFactory businessSqlSessionFactory(
            @Qualifier("businessDataSource") DataSource dataSource,
            ResourcePatternResolver resources,
            @Value("${microserver.mybatis.business.mapper-locations}") String mapperLocations,
            @Value("${microserver.mybatis.business.config-location:}") String configLocation)
            throws Exception {
        return createFactory(dataSource, resources, mapperLocations, configLocation);
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
            DataSource dataSource, ResourcePatternResolver resources,
            String mapperLocations, String configLocation) throws Exception {
        Resource[] mappers = resources.getResources(mapperLocations);
        if (mappers.length == 0) {
            throw new IOException("Mapper XML을 찾을 수 없습니다: " + mapperLocations);
        }

        SqlSessionFactoryBean factory = new SqlSessionFactoryBean();
        factory.setDataSource(dataSource);
        factory.setVfs(SpringBootVFS.class);
        factory.setMapperLocations(mappers);

        if (configLocation.isBlank()) {
            var configuration = new org.apache.ibatis.session.Configuration();
            configuration.setMapUnderscoreToCamelCase(true);
            factory.setConfiguration(configuration);
        } else {
            factory.setConfigLocation(resources.getResource(configLocation));
        }

        return factory.getObject();
    }
}
```

Spring의 ApplicationContext는 `ResourcePatternResolver`를 제공한다. Factory마다 XML을 적어도 하나씩 요구하므로 다음 절의 Mapper 네 파일까지 작성한 후 기동한다. `@MapperScan`이 패키지 내 인터페이스를 등록하므로 그 패키지에는 Mapper 인터페이스만 둔다. Template과 Factory는 이름으로 선택하고, 별도의 TransactionManager는 생성하지 않는다. [Mapper 스캔](https://mybatis.org/spring/mappers.html) · [SqlSessionTemplate](https://mybatis.org/spring/sqlsession.html)

## 6. Mapper 인터페이스와 XML 작성

검증 SQL은 Local H2에서 테이블을 만들지 않고 정수 파라미터를 조회한다. DBMS가 달라지면 검증 SQL도 해당 DBMS 문법에 맞춘다.

### Framework Mapper

`src/main/java/io/github/microserverlab/microserver/framework/mybatis/mapper/FrameworkProbeMapper.java`

```java
package io.github.microserverlab.microserver.framework.mybatis.mapper;

import org.apache.ibatis.annotations.Param;

public interface FrameworkProbeMapper {
    int probe(@Param("value") int value);
}
```

`src/main/resources/mybatis/mapper/framework/FrameworkProbeMapper.xml`

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
    PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
    "https://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="io.github.microserverlab.microserver.framework.mybatis.mapper.FrameworkProbeMapper">
    <select id="probe" resultType="int">
        SELECT CAST(#{value, jdbcType=INTEGER} AS INTEGER)
    </select>
</mapper>
```

### Business Mapper

`src/main/java/io/github/microserverlab/microserver/runtime/mapper/BusinessProbeMapper.java`

```java
package io.github.microserverlab.microserver.runtime.mapper;

import org.apache.ibatis.annotations.Param;

public interface BusinessProbeMapper {
    int probe(@Param("value") int value);
}
```

`src/main/resources/mybatis/mapper/business/BusinessProbeMapper.xml`

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
    PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
    "https://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="io.github.microserverlab.microserver.runtime.mapper.BusinessProbeMapper">
    <select id="probe" resultType="int">
        SELECT CAST(#{value, jdbcType=INTEGER} AS INTEGER)
    </select>
</mapper>
```

Mapper 메서드를 호출하면 MyBatis는 `namespace + "." + id`로 SQL을 찾는다. `namespace`는 인터페이스의 전체 이름, `id`는 메서드 이름, `#{value}`는 `@Param("value")`에 대응한다. `#{...}`는 JDBC 바인딩을 사용하고, `${...}`는 SQL 문자열 치환이므로 사용자 입력값은 `#{...}`로 전달한다. [MyBatis Mapper XML](https://mybatis.org/mybatis-3/sqlmap-xml.html)

## 7. 테스트와 기동 검증

`src/test/java/io/github/microserverlab/microserver/MyBatisMapperIntegrationTest.java`를 작성한다. SQL 결과와 Factory의 statement 등록 범위를 확인한다. JDBC 연결 URL을 비교해 Local H2의 두 DB가 서로 구분되는지도 확인한다.

```java
package io.github.microserverlab.microserver;

import static org.assertj.core.api.Assertions.assertThat;

import java.sql.Connection;
import javax.sql.DataSource;

import io.github.microserverlab.microserver.framework.mybatis.mapper.FrameworkProbeMapper;
import io.github.microserverlab.microserver.runtime.mapper.BusinessProbeMapper;
import org.apache.ibatis.session.SqlSessionFactory;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class MyBatisMapperIntegrationTest {

    @Autowired
    FrameworkProbeMapper frameworkMapper;

    @Autowired
    BusinessProbeMapper businessMapper;

    @Autowired
    @Qualifier("frameworkSqlSessionFactory")
    SqlSessionFactory frameworkFactory;

    @Autowired
    @Qualifier("businessSqlSessionFactory")
    SqlSessionFactory businessFactory;

    @Test
    void runsBothXmlStatementsWithSeparateDataSources() throws Exception {
        String frameworkStatement = FrameworkProbeMapper.class.getName() + ".probe";
        String businessStatement = BusinessProbeMapper.class.getName() + ".probe";

        assertThat(frameworkFactory.getConfiguration().hasStatement(frameworkStatement)).isTrue();
        assertThat(frameworkFactory.getConfiguration().hasStatement(businessStatement)).isFalse();
        assertThat(businessFactory.getConfiguration().hasStatement(businessStatement)).isTrue();
        assertThat(businessFactory.getConfiguration().hasStatement(frameworkStatement)).isFalse();

        assertThat(frameworkMapper.probe(11)).isEqualTo(11);
        assertThat(businessMapper.probe(22)).isEqualTo(22);

        DataSource framework = frameworkFactory.getConfiguration().getEnvironment().getDataSource();
        DataSource business = businessFactory.getConfiguration().getEnvironment().getDataSource();
        try (Connection frameworkConnection = framework.getConnection();
                Connection businessConnection = business.getConnection()) {
            assertThat(frameworkConnection.getMetaData().getURL())
                    .startsWith("jdbc:h2:mem:frameworkdb");
            assertThat(businessConnection.getMetaData().getURL())
                    .startsWith("jdbc:h2:mem:businessdb");
        }
    }
}
```

`gradlew`가 있는 MicroServer 프로젝트 루트에서 실행한다. 저장소 위치가 다르면 외부 Resource 경로를 맞춘다.

```bash
export SPRING_PROFILES_ACTIVE=local
export SPRING_APPLICATION_JSON='{"microserver":{"resource-dir":"/Users/jangkwankim/local-microserver/workspace/microserver_resource"}}'

bash ./gradlew test \
  --tests 'io.github.microserverlab.microserver.MyBatisMapperIntegrationTest' \
  --rerun-tasks
bash ./gradlew bootRun
```

- 테스트 보고서 `build/reports/tests/test/index.html`에서 두 Mapper를 호출한 테스트의 성공을 확인한다. 두 Factory 모두 SQL을 실행하며, 반대쪽 XML이 등록되지 않아 잘못된 Template을 연결하면 해당 Mapper 호출이 실패한다.
- `bootRun` 로그에서 활성 Profile `local`과 `Started MicroserverApplication`을 확인한다. 이 단계에서 외부 YAML 로딩, 두 Factory 초기화, XML 파싱, Mapper Bean 등록이 이뤄진다. SQL 실행은 위 통합 테스트에서 검증한다.
- 패키징 검증이 필요하면 `bash ./gradlew bootJar` 후 실행 JAR의 `BOOT-INF/classes/mybatis/mapper/`에 두 XML이 포함되는지 확인하고, 같은 환경변수로 `java -jar`를 실행한다.

### 업무 Service에서 사용

업무 Service 생성자에서 `BusinessProbeMapper`와 같은 업무 Mapper를 주입한다. 업무 단위의 읽기·쓰기는 `@Transactional(transactionManager = "businessTransactionManager")`로, Framework DB 작업은 `frameworkTransactionManager`로 지정한다. 같은 작업에서 Mapper와 TransactionManager가 같은 DataSource를 바라봐야 Spring 트랜잭션에 참여한다. 두 로컬 TransactionManager는 각 DB의 트랜잭션을 별도로 관리한다. 쓰기 기능을 추가할 때는 테스트 테이블에서 같은 트랜잭션 내의 여러 쓰기가 예외 발생 후 함께 롤백되는지 검증한다. [MyBatis-Spring 트랜잭션](https://mybatis.org/spring/transactions.html)

## 8. 오류 확인

| 증상 | 확인할 내용 |
| --- | --- |
| 외부 YAML을 찾지 못함 | 실행에 전달된 `microserver.resource-dir`, 단일 활성 Profile, 해당 디렉터리의 필수 YAML 두 파일 |
| `Mapper XML을 찾을 수 없습니다` | `src/main/resources` 아래 실제 경로, YAML의 검색 패턴, 빌드 결과에 포함된 리소스 |
| `Failed to parse mapping resource` | 오류에 나온 XML의 루트 태그, DTD, SQL 안의 XML 특수 문자, 별칭 또는 결과 타입 |
| Mapper Bean 주입 실패 | `@MapperScan` 패키지, 애플리케이션의 설정 클래스 스캔 범위, Template Bean 이름 |
| `Invalid bound statement (not found)` | XML `namespace`, `id`, 해당 Mapper가 사용하는 Template 및 Factory의 XML 검색 패턴 |
| `Parameter 'value' not found` | `@Param` 이름과 `#{...}` 이름 |
| 중복 statement 또는 중복 Mapper Bean | Factory별 XML 패턴 중복, 설정 XML의 `<mappers>`, Mapper 스캔 범위와 Bean 이름 충돌 |
| SQL은 실행되지만 다른 DB가 사용됨 | Factory의 DataSource `@Qualifier`, Mapper의 `sqlSessionTemplateRef`, Service의 TransactionManager, 외부 YAML의 JDBC URL |
