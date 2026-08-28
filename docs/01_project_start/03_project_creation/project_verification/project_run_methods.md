# Spring Boot 실행 방법 가이드

## 1. 문서 목적

본 문서는 초기 Build / Test 검증이 완료된 Spring Boot Project를
**여러 방식으로 실행하고 각 실행 방법의 차이를 이해하는 것**을 목적으로 한다.

현재 확인하는 실행 방법은 다음과 같다.

```text
1. Gradle bootRun
2. Executable JAR 직접 실행
3. VS Code Run
4. VS Code Debug
5. Spring Boot Dashboard
```

먼저 Build / Test가 완료되어 있어야 한다.

→ [Spring Boot 초기 Build 및 Test 검증](project_initial_build_verification.md)

## 2. Gradle `bootRun`으로 실행

Spring Boot Gradle Plugin이 제공하는 `bootRun` Task를 이용하면
Build된 JAR를 직접 실행하지 않고도 Application을 실행할 수 있다.

### Windows

```powershell
.\gradlew.bat bootRun
```

### macOS / Linux

```bash
./gradlew bootRun
```

Application Log를 확인한다.

`bootRun`은 Spring Boot Application을 실행한 뒤 바로 종료되는 Task가 아니다.

```text
.\gradlew.bat bootRun
        ↓
Spring Boot Application 시작
        ↓
Embedded Tomcat 기동
        ↓
8080 Port Listen
        ↓
계속 실행 상태 유지
        ↓
Ctrl + C
        ↓
종료
```

따라서 Terminal에 `EXECUTING` 상태가 계속 표시되어도
Application이 정상 기동된 상태라면 문제가 아니다.

---

## 3. 정상 기동 Log 확인

Log에서 다음 정보를 확인한다.

```text
Spring Boot Version
Java Version
Embedded Servlet Container
HTTP Port
Started ...Application
```

현재 MicroServer의 초기 Web MVC 구성에서는
기본 설정 기준으로 Embedded Servlet Container가 기동된다.

Port를 별도로 변경하지 않았다면 기본 HTTP Port는 `8080`이다.

!!! important "기동 성공의 핵심 기준"

    Browser 화면보다 먼저 Application Log에서
    다음과 같은 **정상 Start 완료 메시지**가 출력되는지를 확인한다.

    ```text
    Started ...Application
    ```

    실제 로그 문구와 부가 정보는 Spring Boot Version 및 설정에 따라 달라질 수 있다.

---

## 4. `localhost:8080` 확인

Browser:

```text
http://localhost:8080
```

현재 Controller / Static Page를 아직 만들지 않았다면
`/` 요청에 404 Response가 나타날 수 있다.

!!! info "404가 실패를 의미하지 않음"

    현재 검증 목적은 Business 화면을 확인하는 것이 아니라
    Application과 Web Server가 정상 기동되었는지 확인하는 것이다.

    따라서 다음 조건이라면 `/`의 404는 정상일 수 있다.

    ```text
    Application 정상 Start
    + 8080 Port 정상 Listen
    + "/"에 매핑된 Controller / Static Resource 없음
    → 404 가능
    ```

    단, Connection Refused처럼 Server 자체에 연결할 수 없는 상태는
    정상 기동으로 보지 않는다.

!!! tip "Whitelabel Error Page / 404"

    현재 `/` 경로에 연결된 Controller 또는 Static Resource가 없다면
    Browser에서 다음과 같은 화면이 표시될 수 있다.

    ```text
    Whitelabel Error Page
    status=404
    ```

    이것은 Server가 기동되지 않았다는 뜻이 아니다.

    ```text
    Application 정상 기동
    + Tomcat 8080 정상 Listen
    + "/" Mapping 없음
    → 404 가능
    ```

    반면 `ERR_CONNECTION_REFUSED`처럼 Server 자체에 연결할 수 없다면
    정상 기동 상태로 보지 않는다.

---

## 5. Application 종료

Terminal:

```text
Ctrl + C
```

정상 종료되는지 확인한다.

---

## 6. Executable JAR 직접 실행

Build 결과로 생성된 Spring Boot Executable JAR를 직접 실행한다.

먼저 JAR 목록 확인:

Windows PowerShell:

```powershell
Get-ChildItem .\build\libs\*.jar
```

macOS / Linux:

```bash
ls -la build/libs/*.jar
```

현재 기본 Artifact 이름 기준 실행 예:

Windows PowerShell:

```powershell
java -jar .\build\libs\microserver-0.0.1-SNAPSHOT.jar
```

macOS / Linux:

```bash
java -jar build/libs/microserver-0.0.1-SNAPSHOT.jar
```

!!! warning "`-plain.jar`를 실행 대상으로 선택하지 않음"

    다음과 같은 Plain JAR가 함께 생성된 경우:

    ```text
    microserver-0.0.1-SNAPSHOT-plain.jar
    ```

    Spring Boot Executable JAR 검증에는
    classifier가 없는 Executable JAR를 사용한다.

실제 JAR 이름이 다르면 `build/libs`의 결과를 확인하여 해당 파일명을 사용한다.

정상 기동을 확인한 후 `Ctrl + C`로 종료한다.

---

## 7. `bootRun`과 `java -jar` 실행 차이

```text
./gradlew bootRun
→ Source / Runtime Classpath를 이용하여
  Spring Boot Gradle Plugin을 통해 실행

java -jar build/...jar
→ 이미 Package된 Spring Boot Executable JAR를 직접 실행
```

두 방식이 모두 정상이라면
개발 단계 실행과 Package Artifact 실행을 각각 확인한 것이다.

### Maven 명령과 비교

| 검증 목적 | Gradle | Maven |
|---|---|---|
| Wrapper 버전 | `./gradlew --version` | `./mvnw -version` |
| Test | `./gradlew clean test` | `./mvnw clean test` |
| Build / Packaging | `./gradlew build` | `./mvnw package` |
| Spring Boot 실행 | `./gradlew bootRun` | `./mvnw spring-boot:run` |
| Artifact 위치 | `build/libs/` | `target/` |
| Dependency Cache | `GRADLE_USER_HOME/caches` | `~/.m2/repository` 기본값 |

이번 프로젝트의 실제 검증 명령은 Gradle Wrapper를 사용하고,
Maven 명령은 대응 개념 학습용으로 본다.

---

## 8. VS Code `Run`으로 실행

생성된 다음 Main Class를 연다.

```text
*Application.java
```

Main Method 위에 표시되는 `Run | Debug` 링크에서 `Run`을 선택하거나
Editor의 Run 기능으로 실행한다.

```text
Run | Debug
public static void main(...)
```

여기서 `Run | Debug`는 **CodeLens**로 표시되는 실행 기능이다.

CodeLens 자체는 VS Code의 기본 UI 기능이며,
Java Extension이 Java Source를 분석한 뒤 실행 가능한 `main()` Method 위에
`Run | Debug` 같은 Action을 표시한다.

```text
VS Code CodeLens
        +
Java Extension
        ↓
main() Method 인식
        ↓
Run | Debug 표시
```

Java Extension과 Spring Boot Extension이 Project를 정상 인식하면
VS Code에서도 Application 실행이 가능하다.

!!! note "CLI 검증 후 수행"

    VS Code 실행 확인은 Gradle Wrapper 기반 CLI Baseline이 성공한 뒤 수행한다.

    ```text
    CLI Build / Run 정상
    + VS Code Run 정상
    → Project와 IDE 연계 모두 정상
    ```

    CLI는 정상인데 VS Code Run만 실패한다면
    Project Build 문제와 IDE 설정 문제를 분리해서 확인할 수 있다.

!!! note "Run / Debug JDK"

    VS Code의 Java Language Server JDK,
    Gradle Build Toolchain JDK,
    Run / Debug 시 사용하는 Java Runtime은 개념적으로 구분할 수 있다.

    현재 MicroServer 초기 단계에서는 모두 Java 25 기준으로 맞추고 있으며,
    별도의 `launch.json`에서 Run / Debug용 Java 실행경로를 강제로 지정하지 않는다.

    OS 종속적인 절대경로는 Project 설정에 가능한 한 넣지 않고,
    Project에는 Java Version 기준을 중심으로 유지한다.

---

## 9. VS Code `Debug`로 실행

Main Class의 `Run | Debug` CodeLens에서 `Debug`를 선택한다.

```text
Run | Debug
```

`Debug`는 VS Code Java Debugger를 이용하여 Application을 실행한다.

현재 Breakpoint를 별도로 만들 필요는 없다.

목적:

```text
VS Code Java Debugger
        ↓
Project JDK
        ↓
Spring Boot Application
```

연계가 가능한지 확인한다.

Application 기동 후 종료한다.

---

## 10. Spring Boot Dashboard에서 실행

Spring Boot Dashboard의 `Apps` 영역에서는
현재 Workspace에서 인식된 Spring Boot Application을 확인하고
실행 상태에 따라 `Run`, `Debug`, `Stop` 등의 기능을 사용할 수 있다.

예:

```text
Apps
└─ microserver
```

### Application이 실행되지 않은 상태

`microserver`가 아직 실행되지 않은 상태에서는
Application 항목 오른쪽에 다음과 같은 실행 Action이 표시된다.

```text
microserver    Run    Debug
```

역할:

```text
Run
→ Application 일반 실행

Debug
→ Application Debug 실행
```

VS Code에서는 아이콘으로 표시되므로
실제 화면에서는 `Run` / `Debug` 글자 대신 실행 아이콘과 Debug 아이콘으로 보일 수 있다.

```text
실행 전

Apps
└─ microserver    ▶ Run    Debug
```

### Application이 실행된 상태

`Run` 또는 `Debug`로 Application을 실행하면
Dashboard가 Application의 실행 상태를 인식하고
해당 Application 오른쪽의 Action이 변경된다.

예:

```text
실행 후

Apps
└─ microserver    [실행 상태용 Action]    ■ Stop
```

실행 중에는 더 이상 `Run` Action을 표시할 필요가 없으므로
`Stop`과 현재 실행 중인 Application에 사용할 수 있는 Action이 표시된다.

현재 화면에서는 `microserver` 항목 오른쪽에
브라우저와 관련된 아이콘과 `Stop` 아이콘이 표시되는 것을 확인할 수 있다.

```text
실행 전
→ Run / Debug

실행 후
→ 실행 중 App Action / Stop
```

즉 **Application 상태에 따라 같은 위치의 Action이 동적으로 바뀐다.**

### `Apps` 상위 영역의 Action

`microserver` 개별 Application 행뿐 아니라
그 위의 `Apps` 제목 영역에도 별도의 Action이 표시된다.

개념적으로 다음과 같이 구분한다.

```text
Spring Boot Dashboard

Apps                         ← Apps 전체 대상 Action
│
└─ microserver               ← 개별 Application 대상 Action
```

`Apps` 상위 영역의 Action은
여러 Spring Boot Application을 대상으로 실행 / 중지하거나
Dashboard 상태를 Refresh하는 등의 공통 기능에 사용된다.

반면 `microserver` 옆의 Action은
**해당 Application 하나의 현재 실행 상태에 따라 변경되는 기능**이다.

!!! important "상위 Apps Action과 개별 Application Action 구분"

    ```text
    Apps 제목 영역
    → 여러 Application 대상 공통 Run / Stop / Refresh

    microserver 항목
    → 해당 Application의 Run / Debug / Stop 등
    ```

    따라서 `Stop` 아이콘이 상위 `Apps` 영역에도 보일 수 있고,
    실행 중인 `microserver` 항목에도 개별 `Stop` Action이 표시될 수 있다.

!!! note "Application 상태에 따라 Action이 달라짐"

    Spring Boot Dashboard는 Application 상태에 따라
    표시되는 Action을 변경한다.

    ```text
    Application 미실행
    → Run / Debug

    Application 실행 중
    → Stop / 실행 상태용 Action
    ```

    Extension Version이나 현재 Application 상태에 따라
    실제 아이콘의 위치와 표시되는 부가 Action은 조금 달라질 수 있다.

Dashboard를 이용해 `microserver`를 실행하고,
실행 후 Action이 `Stop` 중심으로 변경되는 것까지 확인하면
Spring Boot Dashboard가 Application 상태를 정상적으로 인식하고 있는 것이다.

!!! tip "Dashboard가 Application을 인식하지 못하는 경우"

    CLI의 `build`와 `bootRun`은 정상인데
    Spring Boot Dashboard에서 Application을 인식하지 못한다면
    Project 자체보다 VS Code / Spring Boot Extension 연계 문제일 가능성이 있다.

    자세한 확인 방법은 다음 문서를 참고한다.

    → [초기 Project 검증 및 Troubleshooting](project_initial_verification_summary.md)
---

---

## 11. 실행 방법 한눈에 비교

| 실행 방법 | 목적 | 특징 |
|---|---|---|
| `./gradlew bootRun` | 개발 단계 실행 | Gradle + Spring Boot Plugin을 통해 실행 |
| `java -jar ...jar` | Package 결과 검증 / 배포 형태 확인 | 생성된 Executable JAR 직접 실행 |
| VS Code `Run` | IDE에서 빠른 실행 | Java Extension 기반 실행 |
| VS Code `Debug` | Breakpoint / Debugging | Java Debugger 기반 실행 |
| Spring Boot Dashboard | Spring Boot App 관리 | 상태에 따라 Run / Debug / Stop 등의 Action 제공 |

```text
개발 중 빠른 실행
→ bootRun / VS Code Run

실행 Artifact 검증
→ java -jar

문제 분석
→ VS Code Debug

IDE에서 Spring Boot App 관리
→ Spring Boot Dashboard
```

다음 문서에서는 오류 상황과 최종 Baseline을 확인한다.

→ [초기 Project 검증 및 Troubleshooting](project_initial_verification_summary.md)
