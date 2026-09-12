# macOS 개발 지원 Extension 구성

## 1. 문서 목적

본 문서는 Java / Spring Boot 핵심 Extension 구성이 완료된 이후,
MicroServer 개발 과정에서 사용할 **지원 Extension**을 설치하고 운영 기준을 정리한다.

Java / Spring Boot Extension의 설치와 역할은 앞 문서에서 이미 다루었으므로 여기서는 반복하지 않는다.

현재 단계의 목표:

- YAML Extension 설치
- XML Extension 설치
- Container Tools 설치
- 필수 / 권장 / 개인 Extension의 구분
- Portable VS Code에서 지원 Extension 설치 상태 확인

---

## 2. Extension 운영 기준

MicroServer에서는 Extension을 다음과 같이 구분한다.

| 구분 | Extension | 기준 |
|---|---|---|
| 필수 | Extension Pack for Java | Java 개발 기반 |
| 필수 | Spring Boot Extension Pack | Spring Boot 개발 기반 |
| 권장 | YAML | YAML 편집 / Validation |
| 권장 | XML | XML 편집 / Validation |
| 권장 | Container Tools | Container 확인 / 관리 |
| 선택 | Git / Markdown / 개인 생산성 도구 | 개발자 필요에 따라 사용 |

운영 원칙:

- 같은 기능의 Extension을 불필요하게 중복 설치하지 않는다.
- 프로젝트 표준 Extension과 개인 편의 Extension을 구분한다.
- Publisher와 Extension ID를 확인한 뒤 설치한다.
- 개인 인증정보나 Secret을 공통 설정에 포함하지 않는다.

지원 Extension도 다음 Portable Directory에서 관리된다.

```text
~/local-microserver/tools/vscode/code-portable-data/extensions
```

---

## 3. YAML

Publisher:

```text
Red Hat
```

Extension ID:

```text
redhat.vscode-yaml
```

주요 기능:

- YAML Syntax Highlighting
- 문법 오류 확인
- 자동완성
- Schema 기반 Validation
- YAML 구조 탐색

MicroServer에서는 다음과 같은 파일을 편집할 때 사용한다.

```text
application.yml
docker-compose.yml
mkdocs.yml
GitHub Actions Workflow
```

Spring Boot Tools와의 역할은 다음처럼 구분한다.

```text
YAML
→ YAML 형식 자체 지원

Spring Boot Tools
→ application.yml의 Spring Boot Property 지원
```

---

## 4. XML

Publisher:

```text
Red Hat
```

Extension ID:

```text
redhat.vscode-xml
```

주요 기능:

- XML Syntax Highlighting
- 자동완성
- Validation
- Formatting
- XML 구조 탐색
- XSD 기반 지원

MicroServer의 Build Tool은 Gradle이므로 Build Script를 위해 XML이 필요한 것은 아니다.
XML 설정 파일이나 Java 생태계의 XML 문서를 다룰 때 사용한다.

---

## 5. Container Tools

Publisher:

```text
Microsoft
```

Extension ID:

```text
ms-azuretools.vscode-containers
```

주요 기능:

- Docker / Podman Container 확인
- Container Image 확인
- Container 관리
- Container Registry 관련 작업
- Container 기반 개발 지원

MicroServer에서는 이후 Local Database와 Container 기반 개발환경을 다룰 수 있으므로 권장 Extension으로 사용한다.

---

## 6. Extension 설치

기본 설치 방법은 MicroServer Portable VS Code의 Extensions 화면을 이용하는 것이다.

```text
Command + Shift + X
```

각 Extension ID로 검색하여 설치한다.

```text
redhat.vscode-yaml
redhat.vscode-xml
ms-azuretools.vscode-containers
```

CLI 설치가 필요한 경우 MicroServer VS Code의 CLI를 명시적으로 사용한다.

```bash
CODE="$HOME/local-microserver/tools/vscode/Visual Studio Code.app/Contents/Resources/app/bin/code"

"$CODE" --install-extension redhat.vscode-yaml
"$CODE" --install-extension redhat.vscode-xml
"$CODE" --install-extension ms-azuretools.vscode-containers
```

!!! tip "일반 VS Code와 구분"
    일반 VS Code가 함께 설치되어 있다면 단순히 `code` 명령을 사용하는 것보다
    MicroServer VS Code의 CLI 경로를 직접 지정하는 것이 명확하다.

---

## 7. 설치 상태 확인

Extensions 화면에서 다음 조건으로 검색한다.

```text
@installed
```

지원 Extension을 확인한다.

```text
YAML
XML
Container Tools
```

Terminal에서는 다음과 같이 확인할 수 있다.

```bash
"$HOME/local-microserver/tools/vscode/Visual Studio Code.app/Contents/Resources/app/bin/code" \
  --list-extensions
```

확인할 Extension ID:

```text
redhat.vscode-yaml
redhat.vscode-xml
ms-azuretools.vscode-containers
```

---

## 8. VS Code Profile 사용 여부

VS Code Profile은 하나의 VS Code에서 개발 목적별 Settings와 Extension 구성을 분리할 때 유용하다.

그러나 MicroServer는 이미 **전용 Portable VS Code Instance**를 사용한다.

```text
MicroServer Portable VS Code
→ 전용 User Data
→ 전용 Settings
→ 전용 Extension
```

따라서 현재 표준 구성에서는 **MicroServer 전용 Profile을 별도로 만들지 않는다.**

Profile을 추가하면 Portable Instance 안에서 다시 Profile별 Settings / Extension을 관리해야 하므로
현재 구성에서는 관리 지점만 늘어날 수 있다.

!!! note "Profile이 필요한 경우"
    하나의 VS Code Instance에서 Java, Python, AI 등 서로 다른 개발환경을 명확하게 분리해야 하는 경우에는
    Profile을 선택적으로 사용할 수 있다.

    이는 MicroServer 표준 개발환경 구성 범위에는 포함하지 않는다.

---

## 9. Extension 업데이트 운영

Extension은 지속적으로 업데이트되므로 개발자별 Version이 시간이 지나면서 달라질 수 있다.

초기에는 모든 Extension Version을 과도하게 고정하기보다 다음 원칙을 사용한다.

```text
기본
→ 최신 안정 Version 사용

문제 발생
→ 해당 Extension Version 확인

팀 공통 문제
→ 검증된 Version으로 통일
```

Java / Spring Boot 핵심 Extension Update 이후 문제가 발생하면
해당 Extension Version과 Output Log를 우선 확인한다.

---

## 10. 프로젝트 생성 이후 Extension 권장

Project가 생성된 이후에는 `.vscode/extensions.json`을 사용하여
Project를 연 개발자에게 권장 Extension을 안내할 수 있다.

```text
microserver/
└─ .vscode/
   └─ extensions.json
```

현재는 아직 Project 생성 전이므로 이 파일을 만들지 않는다.

Portable Package 자체의 구성과 배포 방법은 **VS Code Portable 설정 가이드**에서 관리하며,
이 문서에서는 반복하지 않는다.

---

## 11. 체크리스트

- [ ] YAML이 설치되어 있다.
- [ ] XML이 설치되어 있다.
- [ ] Container Tools가 설치되어 있다.
- [ ] Extension이 `code-portable-data/extensions`에서 관리된다.
- [ ] 필수 / 권장 / 개인 Extension의 차이를 이해했다.
- [ ] MicroServer 표준에서는 별도 VS Code Profile을 만들지 않는다.
- [ ] 아직 Project용 `.vscode/extensions.json`을 만들지 않았다.

---

## 12. 다음 단계

지원 Extension 구성이 완료되면 MicroServer Portable VS Code의
JDK / Gradle 실행환경이 정상적으로 적용되는지 최종 확인한다.

```text
Extension Pack for Java
   ↓
Spring Boot Extension Pack
   ↓
지원 Extension                  ← 현재 완료
   ↓
JDK / Gradle 개발환경 운영 확인
   ↓
Spring Boot Project 생성
```

## 참고

- [VS Code Profiles](https://code.visualstudio.com/docs/configure/profiles)
- [YAML](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml)
- [XML](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-xml)
- [Container Tools](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-containers)
