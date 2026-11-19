# MyBatis 통합 테스트와 실행 검증

H2 테스트 데이터와 JUnit 테스트를 작성하고 DB별 SQL 실행과 등록 범위를 검증한다.

1. [MyBatis 구성 원칙과 공통 설정](mybatis_mapper_setup.md)
2. [MyBatis 세션·매퍼·서비스 구현](mybatis_session_mapper_setup.md)
3. [MyBatis 통합 테스트와 실행 검증](mybatis_integration_verification.md)

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

`src/test/java/io/github/microserverlab/microserver/mybatis/MyBatisMapperIntegrationTest.java`

```java
package io.github.microserverlab.microserver.mybatis;

import static org.assertj.core.api.Assertions.assertThat;

import java.sql.Connection;
import java.sql.SQLException;
import javax.sql.DataSource;

import io.github.microserverlab.microserver.framework.mybatis.mapper.FrameworkLabelMapper;
import io.github.microserverlab.microserver.framework.mybatis.service.FrameworkLabelService;
import io.github.microserverlab.microserver.business.mybatis.mapper.BusinessLabelMapper;
import io.github.microserverlab.microserver.business.mybatis.service.BusinessLabelService;
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

두 DB에 테스트 데이터를 넣고 서비스를 호출한다. 각 매퍼가 담당 DB의 값을 조회하는지, 각 Factory에 담당 SQL만 등록되는지 확인한다. 아래 순서로 파일을 준비한 뒤 VS Code에서 테스트를 실행한다.

1. **테스트 파일을 프로젝트에 작성한다.**

    위 SQL 예제 두 개와 Java 테스트 예제를 다음 위치에 저장한다. 경로는 프로젝트 루트 기준이다.

    | 파일 위치 | 역할 |
    | --- | --- |
    | `src/test/resources/sql/framework-mapper-fixture.sql` | Framework DB의 테스트 테이블과 데이터를 준비한다. |
    | `src/test/resources/sql/business-mapper-fixture.sql` | Business DB의 테스트 테이블과 데이터를 준비한다. |
    | `src/test/java/io/github/microserverlab/microserver/mybatis/MyBatisMapperIntegrationTest.java` | SQL 파일을 각 DB에 실행하고 서비스 조회와 SQL 등록 범위를 검증한다. |

2. **외부 Local 설정 파일을 준비한다.**

    [4절](mybatis_mapper_setup.md#4-profile-yaml)의 설정에 따라 외부 리소스 루트 아래에 두 파일을 둔다. DataSource YAML은 이전 장에서 작성한 파일을 사용한다.

    ```text
    <외부 리소스 루트>/
    └── config/application-context/local/
        ├── application-datasource.yml
        └── application-mybatis.yml
    ```

    DataSource YAML의 H2 DB 이름은 `frameworkdb`와 `businessdb`로 설정한다. 테스트 코드가 이 이름으로 접속 여부를 확인한다.

3. **VS Code의 테스트 실행 설정을 확인한다.**

    `microserver`와 `microserver_resource`가 함께 있는 `workspace` 폴더를 VS Code에서 연다. 이 폴더의 `.vscode/settings.json`에 테스트용 JVM 옵션을 설정한다. 이미 아래 항목이 있으면 현재 값을 확인한다. 다른 설정이 있으면 필요한 항목을 기존 JSON에 합친다.

    ```json
    {
        "java.test.config": [
            {
                "name": "microserver-local",
                "vmArgs": [
                    "-Dspring.profiles.active=local",
                    "-Dmicroserver.resource-dir=${workspaceFolder}/microserver_resource"
                ]
            }
        ],
        "java.test.defaultConfig": "microserver-local"
    }
    ```

    `${workspaceFolder}`는 VS Code에서 연 폴더다. 위 설정은 그 아래의 `microserver_resource`를 외부 리소스 루트로 사용한다. 실제 폴더 구조에 맞게 경로를 지정한다.

    **Run Test는 이 JVM 옵션으로 Profile과 리소스 경로를 전달한다.** 터미널에서 별도로 `export`할 필요가 없다. 애플리케이션 기동용 `launch.json`과 테스트용 `java.test.config`는 각각 설정한다.

4. **VS Code에서 MyBatis 통합 테스트를 실행한다.**

    `MyBatisMapperIntegrationTest.java`를 연다. 클래스 이름 위의 **Run Test** 또는 옆의 초록색 ▶ 버튼을 눌러 클래스의 테스트 두 건을 실행한다. Test Runner for Java 확장이 필요하다.

    테스트가 Spring 컨텍스트를 띄우고 각 DataSource에 SQL 파일을 실행한다. 준비한 데이터를 서비스와 매퍼를 통해 조회한다. 중단점에서 실행 흐름을 보려면 **Debug Test**를 선택한다.

5. **Testing 창에서 결과를 확인한다.**

    왼쪽 활동 표시줄의 시험관 아이콘으로 **Testing** 창을 연다. `MyBatisMapperIntegrationTest` 아래의 테스트 두 건이 모두 통과했는지 확인한다. 실패한 항목을 선택하면 오류 메시지와 실행 결과를 볼 수 있다. [VS Code Java 테스트 실행](https://code.visualstudio.com/docs/java/java-testing)

    | 테스트 메서드 | 확인하는 내용 |
    | --- | --- |
    | `queriesEachDatabaseThroughItsServiceAndMapper` | 서비스 → 매퍼 → JDBC 호출로 각 DB의 값을 조회한다. Framework DB는 `Framework DB`, Business DB는 `Business DB`를 반환해야 한다. |
    | `registersOnlyTheStatementsOwnedByEachFactory` | 각 Factory에 담당 매퍼의 SQL이 등록되어 있고, 상대 DB의 매퍼 SQL은 등록되어 있지 않은지 확인한다. |

!!! tip "참고 팁 — 터미널에서 테스트·기동·패키징 실행"
    macOS 또는 Linux 터미널에서는 아래 명령으로 같은 테스트를 실행할 수 있다. `cd`의 경로는 `build.gradle`과 `gradlew`가 있는 프로젝트 루트로 바꾼다. JSON의 `/opt/microserver-resource`는 외부 YAML을 저장한 리소스 루트의 실제 절대 경로로 바꾼다.

    ```bash
    cd /프로젝트/절대경로/microserver
    export SPRING_PROFILES_ACTIVE=local
    export SPRING_APPLICATION_JSON='{"microserver":{"resource-dir":"/opt/microserver-resource"}}'

    bash ./gradlew test \
      --tests 'io.github.microserverlab.microserver.mybatis.MyBatisMapperIntegrationTest' \
      --rerun-tasks
    ```

    필요한 Spring 환경변수가 현재 터미널에 이미 같은 값으로 지정되어 있으면 `export`는 생략한다. `java.test.config`의 JVM 옵션은 터미널의 Gradle 명령에 자동으로 전달되지 않는다.

    `--tests`는 테스트 클래스를 선택한다. `--rerun-tasks`는 이전 실행 결과가 있어도 테스트를 다시 수행한다. `BUILD SUCCESSFUL`을 확인하고, 프로젝트 루트의 `build/reports/tests/test/index.html`을 브라우저로 열어 결과를 확인한다.

    ### 애플리케이션 기동과 패키징

    통합 테스트를 마친 뒤에는 애플리케이션을 직접 기동하거나 배포용 실행 JAR을 만들 수 있다. **기동은 설정을 읽어 실행하는 작업이고, 패키징은 배포할 파일을 만드는 작업이다.** 아래 명령은 `build.gradle`과 `gradlew`가 있는 프로젝트 루트에서 실행한다.

    1. **애플리케이션 기동 — `bootRun`**

        외부 YAML과 MyBatis 설정을 읽어 실제 애플리케이션을 실행한다. DB별 세션 Bean을 만들고 매퍼 XML의 SQL을 등록하는지 확인할 때 사용한다.

        위 터미널 참고 팁처럼 `local` Profile과 외부 리소스 루트를 지정한 뒤 실행한다.

        ```bash
        bash ./gradlew bootRun
        ```

        기동 로그에서 애플리케이션 시작과 두 DB 연결을 확인한다. 실행을 종료하려면 터미널에서 `Ctrl+C`를 누른다.

        !!! note "H2 조회 데이터 준비"
            통합 테스트의 SQL 파일은 테스트가 실행되는 JVM의 DB에 데이터를 만든다. `bootRun`은 별도 JVM에서 실행하므로 자체 H2 메모리 DB를 사용한다. 이 애플리케이션에서 매퍼를 호출하려면 해당 DB에도 테이블과 데이터를 준비해야 한다.

    2. **배포용 실행 JAR 생성 — `bootJar`**

        컴파일한 코드, 리소스, 실행에 필요한 라이브러리를 하나의 Spring Boot 실행 JAR로 묶는다.

        ```bash
        bash ./gradlew bootJar
        ```

        - **결과물**은 프로젝트의 `build/libs/`에 생성된다.
        - **현재 단일 프로젝트의 MyBatis XML**은 JAR의 `BOOT-INF/classes/mybatis/` 아래에 포함된다.
        - **외부 YAML**은 배포 환경에서 별도로 준비한다. JAR을 실행할 때 Profile과 외부 리소스 루트를 지정하면 해당 파일을 읽는다.

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
