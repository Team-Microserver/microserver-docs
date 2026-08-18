# 개발 지원 Extension 및 Profile 구성 가이드

## 1. 문서 목적

본 문서는 Java / Spring Boot 핵심 Extension 이외에 MicroServer 개발 과정에서 사용할 **YAML, XML, Container Tools** 등의 지원 Extension과 VS Code Profile 운영 방법을 설명한다.

핵심 Java / Spring Boot 기능과 보조 개발 기능을 분리하여 관리하는 것이 목적이다.

---

## 2. Extension 분류 기준

MicroServer의 VS Code Extension은 다음 세 수준으로 구분한다.

```text
필수
 ├─ Extension Pack for Java
 └─ Spring Boot Extension Pack

권장
 ├─ YAML
 ├─ XML
 └─ Container Tools

선택
 ├─ Git 보조 Extension
 ├─ Markdown 보조 Extension
 └─ 개인 생산성 Extension
```

핵심 원칙:

1. Java 기본 기능은 Java Extension Pack으로 통일한다.
2. Spring Boot 기능은 Spring Boot Extension Pack으로 통일한다.
3. 프로젝트에서 자주 사용하는 파일 형식은 공식 또는 신뢰 가능한 Extension을 사용한다.
4. 비슷한 기능을 제공하는 Extension을 불필요하게 중복 설치하지 않는다.
5. 개인 편의 Extension과 프로젝트 권장 Extension을 구분한다.

---

# 3. YAML Extension

Extension:

```text
YAML
```

Publisher:

```text
Red Hat
```

Extension ID:

```text
redhat.vscode-yaml
```

설치:

```bash
code --install-extension redhat.vscode-yaml
```

주요 역할:

- YAML Syntax Highlighting
- YAML 문법 오류 확인
- 자동완성
- Schema 기반 Validation
- YAML 구조 탐색

향후 다음 파일에서 사용할 수 있다.

```text
application.yml
docker-compose.yml
mkdocs.yml
GitHub Actions Workflow
기타 YAML 설정 파일
```

Spring Boot Tools도 `application.yml`에 Spring Boot 전용 기능을 제공하지만 YAML Extension은 일반 YAML 파일 전체를 지원한다.

따라서 두 Extension의 역할은 다음과 같이 구분할 수 있다.

```text
YAML Extension
→ YAML 파일 형식 자체 지원

Spring Boot Tools
→ application.yml 안의 Spring Boot Property 지원
```

---

# 4. XML Extension

Extension:

```text
XML
```

Publisher:

```text
Red Hat
```

Extension ID:

```text
redhat.vscode-xml
```

설치:

```bash
code --install-extension redhat.vscode-xml
```

주요 역할:

- XML Syntax Highlighting
- XML 자동완성
- XML Validation
- XML Formatting
- XML 구조 탐색
- XSD 기반 지원

향후 Maven 프로젝트가 생성되면 `pom.xml`과 기타 XML 파일 편집에 활용한다.

> 현재 단계에서는 `pom.xml`을 생성하거나 수정하지 않는다.

---

# 5. Container Tools

Extension:

```text
Container Tools
```

Publisher:

```text
Microsoft
```

Extension ID:

```text
ms-azuretools.vscode-containers
```

설치:

```bash
code --install-extension ms-azuretools.vscode-containers
```

주요 역할:

- Docker / Podman Container 확인
- Container Image 확인
- Container 관리
- Container Registry 관련 작업
- Container 기반 개발 지원

MicroServer 프로젝트에서는 이후 Oracle Local Database와 개발용 Container 환경을 사용할 수 있으므로 권장한다.

예전 VS Code 자료에서는 `Docker` Extension을 기준으로 설명하는 경우가 있지만 신규 환경에서는 현재 Microsoft의 Container 개발 도구 구성을 확인하여 적용한다.

---

# 6. 프로젝트 권장 Extension 요약

| 구분 | Extension | ID | 기준 | 역할 |
|---|---|---|---|---|
| Java | Extension Pack for Java | `vscjava.vscode-java-pack` | 필수 | Java 개발환경 |
| Spring | Spring Boot Extension Pack | `vmware.vscode-boot-dev-pack` | 필수 | Spring Boot 개발환경 |
| YAML | YAML | `redhat.vscode-yaml` | 권장 | YAML 편집 / Validation |
| XML | XML | `redhat.vscode-xml` | 권장 | XML 편집 / Validation |
| Container | Container Tools | `ms-azuretools.vscode-containers` | 권장 | Container 관리 |

Extension Pack 내부 Extension은 별도로 다시 설치할 필요가 없다.

---

# 7. CLI를 이용한 기본 Extension 일괄 설치

`code` 명령을 사용할 수 있다면 다음과 같이 설치할 수 있다.

```bash
code --install-extension vscjava.vscode-java-pack
code --install-extension vmware.vscode-boot-dev-pack
code --install-extension redhat.vscode-yaml
code --install-extension redhat.vscode-xml
code --install-extension ms-azuretools.vscode-containers
```

설치된 Extension 목록:

```bash
code --list-extensions
```

주요 Extension ID 확인:

```text
vscjava.vscode-java-pack
vmware.vscode-boot-dev-pack
redhat.vscode-yaml
redhat.vscode-xml
ms-azuretools.vscode-containers
```

Pack 설치 시 포함된 개별 Extension도 목록에 함께 표시될 수 있다.

---

# 8. GUI에서 설치 상태 확인

Extensions 화면:

```text
@installed
```

확인 대상:

### Java

```text
Extension Pack for Java
Language Support for Java by Red Hat
Debugger for Java
Test Runner for Java
Maven for Java
Project Manager for Java
Visual Studio IntelliCode
```

### Spring Boot

```text
Spring Boot Extension Pack
Spring Boot Tools
Spring Initializr Java Support
Spring Boot Dashboard
```

### 지원 도구

```text
YAML
XML
Container Tools
```

---

# 9. VS Code Profile

VS Code의 Profile 기능을 사용하면 개발 목적별로 Extension과 Settings 구성을 분리할 수 있다.

예:

```text
Default
Python
AI Development
MicroServer Java
```

Profile은 다음과 같은 경우 유용하다.

- Python / Java 개발환경을 분리하고 싶은 경우
- 프로젝트와 무관한 Extension을 Java 개발환경에서 제외하고 싶은 경우
- Java 개발용 Extension Set을 별도로 유지하고 싶은 경우

---

# 10. Profile 생성

VS Code 메뉴:

```text
File
→ Preferences
→ Profiles
```

Command Palette:

```text
Profiles: Create Profile
```

예를 들어 다음 이름으로 생성할 수 있다.

```text
MicroServer Java
```

Profile 사용은 필수가 아니다.

개발자가 이미 다른 VS Code 개발환경을 많이 사용하고 있다면 MicroServer 전용 Profile을 만들어 Extension 구성을 분리하는 것을 권장할 수 있다.

---

# 11. Java Spring Profile Template

VS Code는 Java와 Spring 개발에 사용할 수 있는 Profile Template을 제공한다.

대표적으로 다음 Profile Template이 있다.

```text
Java General
Java Spring
```

Java Spring Profile은 Java 개발 Extension과 Spring Boot 관련 Extension을 포함하는 초기 구성을 빠르게 준비할 때 사용할 수 있다.

다만 MicroServer 프로젝트에서는 Extension의 역할을 이해하고 표준 구성을 명확히 하기 위해 본 가이드에서 각 Extension을 직접 확인한 후 Profile에 포함시키는 방식을 권장한다.

---

# 12. Profile과 Workspace의 차이

Profile과 Workspace는 목적이 다르다.

```mermaid
flowchart LR
    PROFILE[VS Code Profile] --> ENV[개발 도구 환경]
    WORKSPACE[Workspace] --> PROJECT[특정 프로젝트 설정]
```

### Profile

개발 도구 환경을 구분한다.

예:

- Extension 목록
- Theme
- User Settings
- 개발 목적별 VS Code 구성

### Workspace

특정 프로젝트 설정을 관리한다.

예:

- 프로젝트 JDK
- Formatter
- Workspace Extension 추천
- 프로젝트별 Java 설정

따라서 Profile은 **개발자의 VS Code 환경**, Workspace는 **프로젝트 환경**이라고 구분하면 이해하기 쉽다.

---

# 13. Extension 자동 업데이트

VS Code Extension은 지속적으로 업데이트된다.

Extensions 화면에서 다음 상태를 확인할 수 있다.

```text
Installed
Enabled
Update
```

기본적으로 최신 Extension을 사용하는 것을 권장하지만 프로젝트 진행 중 특정 버전에서 문제가 발생하는 경우 팀에서 버전을 통일할 수 있다.

특히 다음 Extension은 Java / Spring 개발환경의 핵심이므로 Update 이후 문제가 발생했을 때 우선 확인한다.

```text
Language Support for Java
Debugger for Java
Maven for Java
Spring Boot Tools
Spring Boot Dashboard
```

---

# 14. Extension 운영 원칙

프로젝트에서는 Extension을 무조건 많이 설치하지 않는다.

권장 원칙:

- 프로젝트에 필요한 기능인지 확인한다.
- Publisher를 확인한다.
- 유사 기능 중복 설치를 피한다.
- 필수 / 권장 / 개인용 Extension을 구분한다.
- 프로젝트 진행 중 문제가 있는 Extension은 팀에서 공유한다.
- 개인 인증정보를 Extension 설정에 저장소 형태로 공유하지 않는다.

---

# 15. 향후 `.vscode/extensions.json`

프로젝트 생성 이후에는 권장 Extension을 Workspace 차원에서 제안할 수 있다.

예상 구조:

```text
microserver/
 └─ .vscode/
     └─ extensions.json
```

이 파일을 사용하면 프로젝트를 연 개발자에게 권장 Extension을 안내할 수 있다.

> 아직 프로젝트 생성 전이므로 현재 단계에서는 실제 `extensions.json` 파일을 생성하지 않는다.

---

# 16. 체크리스트

- [ ] YAML Extension이 설치되어 있다.
- [ ] XML Extension이 설치되어 있다.
- [ ] Container Tools가 설치되어 있다.
- [ ] 필수 Extension과 권장 Extension의 차이를 이해했다.
- [ ] `code --list-extensions`로 설치 상태를 확인할 수 있다.
- [ ] VS Code Profile의 역할을 이해했다.
- [ ] Java Spring Profile Template이 있다는 것을 확인했다.
- [ ] Profile과 Workspace의 차이를 이해했다.
- [ ] 아직 프로젝트용 `.vscode/extensions.json`을 만들지 않았다.

---

# 17. 다음 단계

다음 문서에서는 앞 단계에서 준비한 Eclipse Temurin JDK와 VS Code의 관계 및 프로젝트별 JDK 운영 방향을 정리한다.

```text
지원 Extension / Profile
        ↓
JDK 연계 / 개발환경 운영
        ↓
Maven 환경 구성
```

## 참고

- VS Code Profiles  
  <https://code.visualstudio.com/docs/configure/profiles>

- YAML  
  <https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml>

- XML  
  <https://marketplace.visualstudio.com/items?itemName=redhat.vscode-xml>

- Container Tools  
  <https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-containers>
