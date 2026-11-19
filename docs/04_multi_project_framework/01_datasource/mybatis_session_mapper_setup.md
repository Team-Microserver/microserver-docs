# MyBatis 세션·매퍼·서비스 구현

DB별 세션 Bean을 등록하고 Java 매퍼, SQL XML, 서비스를 연결한다.

1. [MyBatis 구성 원칙과 공통 설정](mybatis_mapper_setup.md)
2. [MyBatis 세션·매퍼·서비스 구현](mybatis_session_mapper_setup.md)
3. [MyBatis 통합 테스트와 실행 검증](mybatis_integration_verification.md)

## 6. DB별 세션 Bean과 매퍼 스캔 등록

이 단계에서는 **Framework 매퍼와 업무 매퍼가 각각 담당 DB에서 SQL을 실행하도록 연결한다.** DB마다 `SqlSessionFactory`와 `SqlSessionTemplate`을 만들고, 각 매퍼 패키지를 사용할 Template에 연결한다.

### 두 설정 클래스의 역할

Framework에서 두 DB의 세션 Bean을 제공한다. 업무 쪽에서는 이 중 Business DB용 Template을 골라 업무 매퍼를 연결한다. 이 역할 차이 때문에 두 클래스의 코드 분량이 다르다.

| 설정 클래스 | 세션 Bean 구성 | 매퍼 연결 |
| --- | --- | --- |
| `MicroServerMyBatisConfig` | 두 DB의 `SqlSessionFactory`와 `SqlSessionTemplate`을 만든다. 각 Factory에 담당 DataSource와 매퍼 XML을 설정한다. | Framework 매퍼를 `frameworkSqlSessionTemplate`에 연결한다. |
| `BusinessMapperConfig` | 앞에서 만든 `businessSqlSessionTemplate`을 참조한다. | 업무 매퍼를 스캔하고 해당 Template에 연결한다. |

아래 두 파일의 경로는 `src/main/java/io/github/microserverlab/microserver/` 기준이다.

### DB별 세션 등록과 Framework 매퍼 연결

**파일** `framework/mybatis/MicroServerMyBatisConfig.java`

- **`SqlSessionFactory`**는 담당 `DataSource`에 연결된다. 공통 MyBatis 설정과 해당 DB의 매퍼 XML을 읽어 SQL을 등록한다.
- **`SqlSessionTemplate`**은 DB별 Factory를 사용해 Spring 트랜잭션 안에서 매퍼가 사용할 세션을 관리한다.
- **`@MapperScan`**은 Framework 매퍼 인터페이스를 Spring Bean으로 등록하고 `frameworkSqlSessionTemplate`에 연결한다.

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

### 업무 매퍼 연결

**파일** `business/mybatis/BusinessMapperConfig.java`

- **스캔 범위**는 `business.mybatis.mapper`다. 이 패키지의 매퍼 인터페이스를 Spring Bean으로 등록한다.
- **세션 연결**에는 앞 파일에서 만든 `businessSqlSessionTemplate`을 사용한다. 업무 매퍼를 호출하면 이 Template을 통해 Business DB에서 SQL을 실행한다.

클래스 본문이 비어 있어도 Spring이 설정 클래스를 읽을 때 `@MapperScan`이 매퍼 Bean을 등록한다. `sqlSessionTemplateRef`에는 사용할 Template의 Bean 이름을 지정한다. [MyBatis-Spring 매퍼 스캔](https://mybatis.org/spring/mappers.html)

**업무 매퍼 호출 흐름**

업무 매퍼 → `businessSqlSessionTemplate` → `businessSqlSessionFactory` → Business DB

```java
package io.github.microserverlab.microserver.business.mybatis;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Configuration;

@Configuration(proxyBeanMethods = false)
@MapperScan(
        basePackages = "io.github.microserverlab.microserver.business.mybatis.mapper",
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

`business/mybatis/mapper/BusinessLabelMapper.java`를 작성한다.

```java
package io.github.microserverlab.microserver.business.mybatis.mapper;

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
<mapper namespace="io.github.microserverlab.microserver.business.mybatis.mapper.BusinessLabelMapper">
    <select id="findDisplayName" resultType="string">
        SELECT display_name
        FROM mapper_label
        WHERE code = #{code, jdbcType=VARCHAR}
    </select>
</mapper>
```

`namespace`는 인터페이스의 전체 이름이고, `id`는 메서드 이름이다. `@Param("code")`는 `#{code, jdbcType=VARCHAR}`에 연결된다. 조회 결과가 한 행이면 `display_name`을 문자열로 반환하고, 일치하는 행이 없으면 `null`을 반환한다. 예제 테이블의 기본 키는 조회 결과를 최대 한 행으로 제한한다.

!!! tip "SQL과 Java 코드를 함께 관리"
    인터페이스와 XML의 파일명을 맞추고 같은 변경에서 함께 검토한다. 업무 매퍼를 추가할 때는 `business.mybatis.mapper` 패키지와 `mybatis/mapper/business/` 아래를 사용한다. XML에서 부등호 `<`는 `&lt;`로 쓰거나 필요한 SQL 조각을 CDATA로 감싼다.

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

`business/mybatis/service/BusinessLabelService.java`를 작성한다.

```java
package io.github.microserverlab.microserver.business.mybatis.service;

import io.github.microserverlab.microserver.business.mybatis.mapper.BusinessLabelMapper;
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

### 서비스 메서드에 트랜잭션 적용하기

`@Transactional`은 서비스 메서드에서 실행하는 SQL을 트랜잭션으로 묶는다. `transactionManager`에는 매퍼가 사용하는 DB의 관리자를 지정한다.

| 호출 방식 | 트랜잭션 동작 |
| --- | --- |
| 서비스 클래스 밖에서 Spring이 주입한 서비스의 `findDisplayName(code)`를 호출 | Spring 프록시를 거친다. 메서드에 선언한 `@Transactional` 설정이 적용된다. |
| 같은 클래스에서 `this.findDisplayName(code)`를 호출 | 기본 프록시 방식에서는 호출이 프록시를 우회한다. 호출된 메서드의 `@Transactional` 설정은 적용되지 않는다. 이미 시작된 트랜잭션이 있다면 그대로 이어진다. |

#### 우리가 만든 호출 방식

[9절](mybatis_integration_verification.md#9-h2-sql)의 통합 테스트는 Spring이 주입한 `FrameworkLabelService`를 테스트 클래스에서 호출한다. 이 호출은 Spring 프록시를 거쳐 `findDisplayName()`에 선언한 트랜잭션 설정을 적용한다.

```java
// MyBatisMapperIntegrationTest의 필드
@Autowired
FrameworkLabelService frameworkService;

// 테스트 메서드 안에서 호출
assertThat(frameworkService.findDisplayName("sample")).isEqualTo("Framework DB");
```

#### 같은 클래스에서 호출하는 예시

`this`는 지금 메서드를 실행 중인 객체를 가리킨다. 아래는 `FrameworkLabelService` 안에 다른 메서드가 있다고 가정한 예시다.

```java
// FrameworkLabelService 안에 메서드를 추가한다고 가정한 예시
public String findLabel(String code) {
    return this.findDisplayName(code);
}
```

!!! tip "같은 SQL인데 트랜잭션 설정이 달라지는 이유"
    두 호출 모두 `findDisplayName()` 본문의 `return mapper.findDisplayName(code);`까지 실행한다. **Spring은 SQL 실행 전에 프록시로 들어온 서비스 메서드의 `@Transactional` 설정을 확인한다.**

    - **`frameworkService.findDisplayName(code)`** 호출은 Spring 프록시를 거친다. 새 트랜잭션이 필요하면 `frameworkTransactionManager`가 `readOnly = true` 설정으로 트랜잭션을 시작한다. 그 안에서 매퍼가 SQL을 실행한다.
    - **`frameworkService.findLabel(code)`** 호출에서 프록시가 받는 메서드는 `findLabel()`이다. 예제의 `findLabel()`에는 트랜잭션 선언이 없다. 내부의 `this.findDisplayName(code)`는 같은 객체의 메서드를 직접 호출하므로 `findDisplayName()`의 트랜잭션 설정은 새로 적용되지 않는다.

    매퍼는 두 경우 모두 SQL을 실행한다. 해당 DB에 이미 참여할 수 있는 Spring 트랜잭션이 있다면 MyBatis는 그 트랜잭션을 사용한다. [Spring 선언적 트랜잭션](https://docs.spring.io/spring-framework/reference/data-access/transaction/declarative/annotations.html) · [MyBatis-Spring 세션 관리](https://mybatis.org/spring/sqlsession.html)

#### 조회와 쓰기의 트랜잭션 설정

- **조회 메서드**에는 `readOnly = true`를 지정한다. 조회 작업이라는 힌트를 주며, 트랜잭션 관리자나 DB가 지원하면 이를 최적화에 활용한다. 쓰기 SQL 차단 여부는 실행 환경에 따라 달라진다. [Spring `readOnly` 설명](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/transaction/annotation/Transactional.html#readOnly())
- **쓰기 메서드**에는 같은 DB의 트랜잭션 관리자를 지정한다. `readOnly`를 생략하면 기본값 `false`로 읽기·쓰기 트랜잭션을 사용한다.

!!! warning "두 DB의 트랜잭션 범위"
    - 각 트랜잭션 관리자는 담당 DB의 커밋과 롤백을 처리한다.
    - 두 DB를 모두 변경하는 업무에서 두 변경을 함께 커밋하거나 함께 롤백하려면 별도 설계가 필요하다.
