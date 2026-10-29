# VS Code Java User Snippet 가이드

## 1. 목적 {#1-목적}

VS Code에서 반복적으로 작성하는 Java 코드 골격을 **User Snippet**으로
등록하여 짧은 키워드로 빠르게 생성하는 방법을 정리한다.

MicroServer 개발에서는 테스트 클래스, Framework 검증 코드 등 반복되는
코드 골격을 Snippet으로 만들어 개발 편의성을 높일 수 있다.

예를 들어 다음과 같이 입력한다.

``` text
mstest-ds
```

그리고 자동완성을 호출하면 DataSource 접속 테스트 클래스 골격을 한 번에
생성할 수 있다.

------------------------------------------------------------------------

## 2. User Snippet과 Java 코드 생성 {#2-user-snippet과-java-코드-생성}

Snippet은 미리 정의한 코드 템플릿을 VS Code 편집기에 삽입하는 기능이다.

``` text
Snippet Prefix 입력
        ↓
Ctrl + Space
        ↓
Snippet 선택
        ↓
Java 코드 골격 자동 생성
```

Eclipse의 코드 템플릿과 유사한 목적으로 사용할 수 있다.

------------------------------------------------------------------------

## 3. Java User Snippet 설정 열기 {#3-java-user-snippet-설정-열기}

VS Code에서 Command Palette를 연다.

``` text
⌘ + Shift + P
```

다음 명령을 검색한다.

``` text
Snippets: Configure Snippets
```

언어 목록에서 다음을 선택한다.

``` text
java
```

그러면 Java User Snippet 설정 파일인 `java.json`이 열린다.

------------------------------------------------------------------------

## 4. `java.json` 저장 위치 {#4-javajson-저장-위치}

`java.json`은 Java 프로젝트 소스 파일이 아니라 **VS Code 사용자 설정
영역의 Snippet 파일**이다.

일반적인 macOS VS Code에서는 사용자 설정 영역의 `snippets/java.json`에
저장된다.

MicroServer처럼 별도의 VS Code 실행환경 또는 Portable 구성을 사용하는
경우 실제 저장 위치가 달라질 수 있다.

현재 MicroServer 환경에서 정확한 파일 위치가 필요한 경우 다음과 같이
확인할 수 있다.

``` bash
find ~/local-microserver -name "java.json" 2>/dev/null
```

> User Snippet은 현재 프로젝트의 Git 소스와 자동으로 함께 관리되는
> 파일이 아니다.

------------------------------------------------------------------------

## 5. MicroServer DataSource 테스트 Snippet 등록 {#5-microserver-datasource-테스트-snippet-등록}

`java.json`의 최상위 `{ }` 안에 다음 Snippet을 추가한다.

``` json
{
    "MicroServer Framework DataSource Test": {
        "prefix": "mstest-ds",
        "body": [
            "package ${1:io.github.microserverlab.microserver};",
            "",
            "import static org.assertj.core.api.Assertions.assertThat;",
            "",
            "import java.sql.Connection;",
            "import javax.sql.DataSource;",
            "",
            "import org.junit.jupiter.api.Test;",
            "import org.springframework.beans.factory.annotation.Autowired;",
            "import org.springframework.beans.factory.annotation.Qualifier;",
            "import org.springframework.boot.test.context.SpringBootTest;",
            "",
            "@SpringBootTest",
            "class ${TM_FILENAME_BASE} {",
            "",
            "    @Autowired",
            "    @Qualifier(\"${2:frameworkDataSource}\")",
            "    private DataSource dataSource;",
            "",
            "    @Test",
            "    void ${3:connectionTest}() throws Exception {",
            "        try (Connection connection = dataSource.getConnection()) {",
            "            assertThat(connection.isClosed()).isFalse();",
            "            System.out.println(",
            "                    \"DB URL = \"",
            "                    + connection.getMetaData().getURL());",
            "        }",
            "    }",
            "}"
        ],
        "description": "MicroServer DataSource connection test"
    }
}
```

`java.json`에 이미 다른 Snippet이 있다면 기존 최상위 `{ }` 안에 쉼표로
구분하여 추가한다.

------------------------------------------------------------------------

## 6. Snippet 주요 항목 {#6-snippet-주요-항목}

### `prefix`

``` json
"prefix": "mstest-ds"
```

Java 편집기에서 Snippet을 호출할 때 사용하는 단축 키워드다.

``` text
mstest-ds
```

### `body`

실제로 생성할 Java 코드의 각 줄을 정의한다.

### `description`

자동완성 목록에 표시되는 Snippet 설명이다.

------------------------------------------------------------------------

## 7. `${TM_FILENAME_BASE}` {#7-tm_filename_base}

다음 변수는 현재 Java 파일의 확장자를 제외한 파일명을 사용한다.

``` text
${TM_FILENAME_BASE}
```

예를 들어 파일명이 다음과 같다면:

``` text
FrameworkDataSourceConnectionTest.java
```

Snippet의:

``` java
class ${TM_FILENAME_BASE} {
```

부분은 자동으로 다음과 같이 생성된다.

``` java
class FrameworkDataSourceConnectionTest {
```

따라서 테스트 클래스 이름을 다시 입력할 필요가 없다.

------------------------------------------------------------------------

## 8. Tab Stop {#8-tab-stop}

Snippet의 `${1}`, `${2}`, `${3}`은 코드 생성 후 사용자가 수정할 위치를
지정하는 **Tab Stop**이다.

예:

``` text
${1:io.github.microserverlab.microserver}
${2:frameworkDataSource}
${3:connectionTest}
```

Snippet을 생성한 뒤 `Tab`을 누르면 다음 순서로 이동한다.

``` text
package
   ↓ Tab
frameworkDataSource
   ↓ Tab
connectionTest
```

기본값을 그대로 사용하거나 필요한 값만 빠르게 수정할 수 있다.

------------------------------------------------------------------------

## 9. Snippet 사용 방법 {#9-snippet-사용-방법}

먼저 Java 파일을 생성한다.

예:

``` text
src/test/java/io/github/microserverlab/microserver/
└── FrameworkDataSourceConnectionTest.java
```

빈 Java 파일에서 다음을 입력한다.

``` text
mstest-ds
```

그 다음:

``` text
Ctrl + Space
```

를 눌러 VS Code 자동완성을 호출한다.

목록에서:

``` text
MicroServer Framework DataSource Test
```

를 선택하면 전체 테스트 코드가 생성된다.

> `mstest-ds`를 입력했는데 바로 목록이 나타나지 않더라도 Snippet이
> 등록되지 않은 것은 아닐 수 있다.\
> `Ctrl + Space`로 자동완성 목록을 직접 호출한다.

------------------------------------------------------------------------

## 10. 생성되는 테스트 코드 {#10-생성되는-테스트-코드}

예를 들어 `FrameworkDataSourceConnectionTest.java`에서 Snippet을
실행하면 다음 형태의 테스트 골격을 만들 수 있다.

``` java
package io.github.microserverlab.microserver;

import static org.assertj.core.api.Assertions.assertThat;

import java.sql.Connection;
import javax.sql.DataSource;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class FrameworkDataSourceConnectionTest {

    @Autowired
    @Qualifier("frameworkDataSource")
    private DataSource dataSource;

    @Test
    void connectionTest() throws Exception {
        try (Connection connection = dataSource.getConnection()) {
            assertThat(connection.isClosed()).isFalse();
            System.out.println(
                    "DB URL = "
                    + connection.getMetaData().getURL());
        }
    }
}
```

------------------------------------------------------------------------

## 11. User Snippet과 Workspace 공용 Snippet {#11-user-snippet과-workspace-공용-snippet}

현재 설명한 `java.json`은 **개인 VS Code User Snippet**이다.

향후 MicroServer에서 공통 코드 템플릿을 표준화할 경우 Workspace 공용
Snippet으로 관리할 수 있다.

예:

``` text
workspace/
├── .vscode/
│   ├── launch.json
│   └── microserver.code-snippets
├── microserver/
└── microserver_resource/
```

이 경우 MicroServer 개발환경에서 사용하는 표준 Snippet을
프로젝트/Workspace 설정과 함께 관리할 수 있다.

예를 들어 향후 다음과 같은 Snippet을 추가할 수 있다.

``` text
mstest-ds       DataSource 접속 테스트
mstest-spring   Spring Boot 테스트
mscontroller    Controller 기본 골격
msservice       Service 기본 골격
```

다만 공용 Snippet의 범위와 표준은 실제 Framework / Runtime 개발 패턴이
정리된 이후 확정한다.

------------------------------------------------------------------------

## 12. 문제 발생 시 확인 {#12-문제-발생-시-확인}

Snippet이 자동완성 목록에 나타나지 않으면 다음을 확인한다.

1.  `java.json`을 저장했는지 확인한다.
2.  현재 편집 중인 파일의 Language Mode가 `Java`인지 확인한다.
3.  `prefix` 값이 입력한 문자열과 동일한지 확인한다.
4.  `Ctrl + Space`로 자동완성을 직접 호출한다.
5.  `java.json`의 JSON 문법 오류가 없는지 확인한다.

Snippet은 Java 컴파일 기능이 아니라 VS Code 편집 기능이므로 Gradle
Build와는 독립적으로 동작한다.
