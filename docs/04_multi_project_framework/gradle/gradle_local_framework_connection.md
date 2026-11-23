# Gradle 로컬 Framework 연결

이 문서는 Runtime의 `settings.gradle`에서 로컬 Framework를 연결하는 목적과 코드 문법을 설명한다.

Framework와 Runtime을 함께 개발할 때는 **Framework 코드를 수정할 때마다 공통 JAR을 저장소에 게시하고 Runtime에서 다시 내려받는 절차를 줄이기 위해** 로컬 소스를 연결한다. Composite Build를 사용하면 Runtime의 라이브러리 요청을 개발 PC의 Framework 프로젝트로 치환하고, Runtime 빌드·실행에 필요한 Framework 빌드 작업도 Gradle이 함께 처리한다.

Framework 코드를 수정한 뒤 Runtime을 다시 빌드·실행하여 변경 결과를 확인한다. 필요한 로컬 JAR은 빌드 과정에서 생성될 수 있지만, 변경 확인을 위한 별도 JAR 게시·다운로드 절차는 필요하지 않다. 외부 라이브러리는 필요한 경우 저장소에서 내려받는다.

!!! note "변경 반영 시점"
    이 연결은 실행 중인 서버의 자동 갱신 기능이 아니다. Gradle로 Runtime을 다시 빌드·실행하여 변경을 확인하고, VS Code 실행 시에도 Gradle 프로젝트 연결과 변경된 코드의 빌드가 반영됐는지 확인한다.

## 1. Runtime 프로젝트 이름 지정

```groovy
rootProject.name = 'microserver-runtime'
```

Runtime의 Gradle 루트 프로젝트 이름을 지정한다. Framework의 하위 프로젝트가 아니라 자체 `settings.gradle`과 `build.gradle`을 가진 독립 빌드다. 이 이름은 VS Code 실행 설정의 `projectName`과도 맞춘다.

## 2. 로컬 Framework 사용 여부 읽기

```groovy
def useLocalFramework = providers.gradleProperty('useLocalFramework')
        .map { it.toBoolean() }
        .getOrElse(false)
```

배포된 공통 라이브러리를 사용할지, 개발 PC의 Framework 소스를 사용할지 선택하는 사용자 정의 설정이다. `useLocalFramework`는 Gradle의 내장 옵션이 아니라 이 가이드에서 정한 이름이다.

| 코드 | 기능 | 값의 예 |
| --- | --- | --- |
| `def useLocalFramework` | 처리 결과를 저장할 Groovy 변수 선언 | 최종 Boolean 값 |
| `providers.gradleProperty('useLocalFramework')` | Gradle 프로젝트 속성을 Provider로 읽음 | 문자열 `true` 또는 `false` |
| `.map { it.toBoolean() }` | 속성이 있으면 문자열을 Boolean으로 변환 | `true` → 참, `false` → 거짓 |
| `.getOrElse(false)` | 속성이 없으면 기본값 사용 | 거짓 |

Provider는 외부에서 전달한 값을 읽고 변환할 수 있는 Gradle의 값 제공 객체다. `it`은 `map` 블록에 전달되는 속성 문자열을 가리킨다. 마지막에는 Boolean 값을 얻어 아래 `if` 조건에 사용한다.

설정값은 혼동을 피하도록 정확히 `true` 또는 `false`로 작성한다. `getOrElse(false)`는 속성이 없을 때의 기본값이다. 로컬 폴더가 없거나 빌드가 실패했을 때 배포 라이브러리로 자동 전환하는 예외 처리 기능이 아니다.

## 3. 사용 방식에 따라 로컬 연결 실행

```groovy
if (useLocalFramework) {
    // 로컬 Framework 위치 확인 및 빌드 연결
}
```

| 최종 값 | settings.gradle 동작 | Runtime이 사용하는 Framework |
| --- | --- | --- |
| `true` | 폴더를 검사하고 `includeBuild` 실행 | 개발 PC의 Framework 프로젝트 |
| `false` | 로컬 연결 블록을 건너뜀 | 설정된 저장소에서 해석한 라이브러리 |
| 값 미지정 | 기본값 `false` | 설정된 저장소에서 해석한 라이브러리 |

이 값은 Gradle의 빌드·의존성 연결 설정이다. Spring의 `local`·`dev`·`prod` 실행 프로파일과는 별개다. `spring.profiles.active=local`만 전달해도 로컬 Framework 소스가 연결되는 것은 아니다.

## 4. Framework 소스 위치 지정

```groovy
def frameworkDir = file('../microserver-framework')
```

Runtime의 `settings.gradle`이 있는 디렉터리를 기준으로 Framework 경로를 해석한다. `..`는 상위 디렉터리이며, 그 아래 `microserver-framework` 폴더를 선택한다.

| 환경 | Runtime 빌드 루트 | 위 상대 경로의 결과 |
| --- | --- | --- |
| Windows | `C:\local-microserver\workspace\microserver-runtime` | `C:\local-microserver\workspace\microserver-framework` |
| macOS | `~/local-microserver/workspace/microserver-runtime` | `~/local-microserver/workspace/microserver-framework` |

두 프로젝트가 같은 작업 공간의 이웃 디렉터리에 있어야 이 경로를 그대로 사용할 수 있다. `file(...)`은 파일 경로를 나타내는 객체를 만들 뿐 폴더 생성·저장소 복제·파일 복사를 수행하지 않는다.

## 5. Framework 빌드 존재 확인과 오류 처리

```groovy
if (!new File(frameworkDir, 'settings.gradle').isFile()) {
    throw new GradleException("로컬 Framework 빌드를 찾을 수 없습니다: ${frameworkDir}")
}
```

| 표현 | 의미 |
| --- | --- |
| `new File(frameworkDir, 'settings.gradle')` | Framework 디렉터리 안의 설정 파일 경로 생성 |
| `.isFile()` | 해당 경로에 일반 파일이 존재하는지 확인 |
| `!` | 조건 반전. 파일이 없으면 참 |
| `throw new GradleException(...)` | 오류 메시지를 표시하고 빌드 설정 처리를 중단 |
| `${frameworkDir}` | 오류 메시지에 실제 검사한 경로 삽입 |

로컬 사용을 선택했는데 Framework를 준비하지 않은 경우, 원인을 초기에 알려주는 검사다. 로컬 빌드 파일의 존재만 확인하므로 소스의 정상 컴파일이나 의존성 다운로드 성공까지 보장하지는 않는다. 이 가이드는 Groovy DSL의 `settings.gradle`을 사용한다. Kotlin DSL의 `settings.gradle.kts`로 변경한다면 검사 대상도 조정해야 한다.

## 6. 독립 Framework 빌드 연결 — includeBuild

```groovy
includeBuild(frameworkDir) {
    // 의존성 치환 규칙
}
```

별도의 Framework 빌드를 Runtime과 함께 빌드할 수 있도록 연결한다. 독립된 빌드들을 함께 구성하는 방식을 Composite Build라고 한다.

| 구분 | 사용하는 설정 | 적용 위치 |
| --- | --- | --- |
| 하나의 Framework 빌드에 하위 프로젝트 포함 | `include 'microserver-framework-datasource'` | Framework의 `settings.gradle` |
| 같은 빌드 안의 하위 프로젝트 의존성 선언 | `implementation project(':microserver-framework-datasource')` 등 | Framework 하위 모듈의 `build.gradle` |
| 독립 Framework 빌드를 Runtime의 로컬 개발에 연결 | `includeBuild(frameworkDir)` | Runtime의 `settings.gradle` |

연결 후 Runtime을 빌드·실행하면 필요한 Framework 프로젝트의 빌드 작업도 의존성에 따라 수행된다. Framework 소스를 변경한 뒤 Runtime을 다시 빌드·실행할 때, 먼저 공통 JAR을 저장소에 게시하지 않고 변경 내용을 확인할 수 있다.

소스가 Runtime 폴더로 복사되거나 두 Git 저장소가 합쳐지는 것은 아니다. Framework와 Runtime의 루트 빌드 설정, 플러그인, 저장소 설정은 각각 관리한다. 실행 중인 애플리케이션에 소스 변경이 자동으로 반영되는 Hot Reload 기능도 아니므로 필요한 재빌드·재실행을 수행한다.

## 7. 라이브러리 의존성을 로컬 프로젝트로 치환

```groovy
dependencySubstitution {
    substitute module('io.github.microserverlab:microserver-framework-starter') using project(':microserver-framework-starter')
}
```

Runtime이 요청한 Starter 라이브러리를 로컬 Framework의 Starter 프로젝트로 바꿔 연결하는 규칙이다.

| 코드 | 의미 |
| --- | --- |
| `dependencySubstitution` | 의존성 대상을 다른 대상으로 치환하는 규칙 선언 |
| `module('io.github.microserverlab:microserver-framework-starter')` | 바꿀 대상인 외부 라이브러리의 그룹·이름 지정 |
| `using project(':microserver-framework-starter')` | 대체할 대상으로 포함된 Framework 빌드의 Starter 하위 프로젝트 지정 |

여기서 `project(...)`는 `includeBuild`의 치환 규칙 안에 있으므로 포함된 Framework 빌드의 프로젝트를 가리킨다. Runtime 안에 Starter 하위 프로젝트가 있다는 뜻이 아니다.

Runtime의 `build.gradle`은 두 사용 방식 모두 다음 선언을 유지한다.

```groovy
implementation 'io.github.microserverlab:microserver-framework-starter:0.0.1-SNAPSHOT'
```

| 사용 방식 | 위 선언의 실제 해석 |
| --- | --- |
| 로컬 연결 켬 | Framework 빌드의 `:microserver-framework-starter` 프로젝트로 치환 |
| 로컬 연결 끔 | 선언한 라이브러리 좌표와 버전을 설정된 저장소에서 해석 |

Starter가 의존하는 DataSource·MyBatis 공통 모듈도 Framework의 프로젝트 의존성으로 함께 연결된다. 외부 의존성 좌표를 유지하므로 로컬 소스 사용과 배포 라이브러리 사용을 전환할 때 Runtime의 의존성 선언을 바꿀 필요가 없다.

현재처럼 라이브러리 그룹·이름과 로컬 프로젝트 식별자가 일치하면 Gradle의 기본 치환 규칙으로도 연결할 수 있다. 본 가이드에서는 어떤 Starter를 어떤 프로젝트로 연결하는지 드러내기 위해 명시적인 치환 규칙을 작성했다.

위 `module(...)`에는 버전이 없으므로 같은 그룹·이름의 요청을 로컬 프로젝트로 치환한다. 따라서 로컬 연결을 켠 상태에서는 선언된 `0.0.1-SNAPSHOT` 배포물과 로컬 소스가 동일하다고 보장되지 않는다. 배포 버전 자체를 검증할 때는 로컬 연결을 끈다.

## 8. 개발 PC의 기본 선택 저장 — gradle.properties

`workspace/microserver-runtime/gradle.properties`:

```properties
useLocalFramework=true
```

Runtime 루트에 이 파일을 두면 매번 `-P` 옵션을 입력하지 않아도 로컬 연결을 사용한다. VS Code가 Runtime의 Gradle 프로젝트를 가져올 때도 이 설정을 읽을 수 있다.

이 가이드에서는 로컬 소스를 함께 내려받은 개발 PC의 선택으로 관리하므로 해당 파일을 `.gitignore`에서 제외한다. 파일이 Git에 포함되지 않기 때문에 신규 PC에서는 직접 만들거나 실행 명령에 속성을 전달해야 한다. CI도 다른 곳에서 이 속성을 주입하지 않는 한 기본값 `false`로 동작한다.

설정 파일을 Git에서 제외한다는 것은 개발 PC에 파일을 만들지 말라는 뜻이 아니다. 이 파일을 생성해 사용하되 저장소에는 올리지 않는다는 의미다. 공용 Gradle 설정까지 항상 모두 제외해야 한다는 일반 규칙도 아니다.

또한 Gradle 사용자 홈의 `gradle.properties` 등에 같은 속성이 있다면 값 선택에 영향을 줄 수 있다. 본 가이드에서는 Runtime별 파일로 관리하고, 의도와 다른 동작이 나오면 사용자 홈의 동명 속성도 확인한다.

## 9. 명령행에서 일시적으로 전환 — -P

`-P`는 Gradle 프로젝트 속성을 전달하는 옵션이다. 명령행 값이 파일의 같은 속성보다 우선한다.

Windows PowerShell — Runtime 루트:

```powershell
# 이번 명령에서는 로컬 Framework 사용
.\gradlew.bat classes -PuseLocalFramework=true

# 이번 명령에서는 배포 라이브러리 사용
.\gradlew.bat classes -PuseLocalFramework=false
```

macOS — Runtime 루트:

```bash
# 이번 명령에서는 로컬 Framework 사용
./gradlew classes -PuseLocalFramework=true

# 이번 명령에서는 배포 라이브러리 사용
./gradlew classes -PuseLocalFramework=false
```

위 명령은 `gradle.properties` 파일을 수정하지 않는다. 파일이 `true`인 상태에서 명령행에 `false`를 지정하면 해당 실행만 배포 라이브러리를 사용하고, 다음 명령에서 옵션을 생략하면 다시 파일의 `true`를 사용한다.

`useLocalFramework`는 빌드 구성을 선택하는 값이므로 `bootRun --args`의 애플리케이션 인수로 전달하지 않는다. 예를 들어 `bootRun -PuseLocalFramework=true`는 Gradle 설정이고, `bootRun --args='--spring.profiles.active=local'`은 Spring 애플리케이션 설정이다.

## 10. 사용 방식 확인과 최초 구성 시 주의점

| 확인 상황 | 확인할 내용 |
| --- | --- |
| Framework 소스도 함께 개발 | 속성 `true`, 이웃 Framework 폴더 존재, 의존성이 로컬 프로젝트로 치환되는지 확인 |
| 배포된 버전만 사용 | 속성 `false`, Framework가 게시된 저장소 설정과 대상 버전 존재 확인 |
| 로컬 연결은 켰지만 폴더가 없음 | 설정 파일 검사에서 즉시 실패. 배포 라이브러리로 자동 전환하지 않음 |
| 속성 없이 신규 PC에서 실행 | 기본값 `false`. 아직 배포하지 않았다면 Starter 의존성 해석 실패 가능 |

현재 가이드의 Runtime은 `mavenCentral()`만 선언한다. 회사 공통 Framework가 그곳에 게시되어 있지 않다면 로컬 연결을 끈 상태에서 사용할 수 없다. 배포 단계에서 실제 라이브러리 저장소를 추가하고 필요한 버전을 게시해야 한다. 이 설정에 `mavenLocal()`이 없으므로 로컬 Maven 저장소에 게시하는 것만으로 해석되지도 않는다.

최초 구성에서는 반드시 `gradle.properties`를 만들거나 `-PuseLocalFramework=true`를 전달한다. 이후 배포 라이브러리 사용 검증은 실제 게시와 저장소 설정을 마친 다음 진행한다.

예를 들어 macOS에서는 다음으로 Starter 연결 결과를 확인한다. Windows에서는 `./gradlew` 대신 `.\gradlew.bat`을 사용한다.

```bash
./gradlew dependencyInsight --dependency microserver-framework-starter --configuration runtimeClasspath -PuseLocalFramework=true
```

결과에서 Starter의 라이브러리 요청이 포함된 Framework 빌드의 프로젝트로 선택되는지 확인한다. `useLocalFramework=false` 검증에서는 같은 명령의 속성을 `false`로 바꾸어 저장소의 배포 버전이 선택되는지 확인한다.

참고: [Gradle Composite Builds](https://docs.gradle.org/current/userguide/composite_builds.html) · [Gradle 프로젝트 속성](https://docs.gradle.org/current/userguide/build_environment.html#sec:project_properties)

[프로젝트 생성과 개발 환경 구성으로 돌아가기](../02_multi_project/multi_project_setup.md#51-runtime-settingsgradle)
