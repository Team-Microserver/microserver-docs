# VS Code Workspace Settings

## 1. 목적

이 문서는 Repository에 저장하여 **팀이 함께 사용할 VS Code Project 설정 파일을 작성하는 절차**를 다룬다.

Workspace Settings의 개념과 User Settings와의 차이는 다음 문서를 참고한다.

→ [VS Code Workspace / User Settings 구조](vscode_workspace_concepts.md)

---

## 2. `.vscode` Directory 확인

Project Root에 다음 구조를 사용한다.

```text
microserver/
└─ .vscode/
   ├─ settings.json
   └─ extensions.json
```

없으면 `.vscode` Directory와 필요한 파일을 생성한다.

---

## 3. `settings.json` 작성

파일:

```text
.vscode/settings.json
```

권장 기준:

```json
{
  "files.encoding": "utf8",
  "files.autoGuessEncoding": false,
  "files.autoSave": "off",
  "editor.formatOnSave": false,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "java.configuration.updateBuildConfiguration": "automatic",
  "java.compile.nullAnalysis.mode": "automatic"
}
```

이 파일에는 **OS와 개발자에 관계없이 팀 전체가 동일하게 사용할 설정만** 둔다.

JDK 절대경로는 넣지 않는다.

---

## 4. `extensions.json` 작성

파일:

```text
.vscode/extensions.json
```

```json
{
  "recommendations": [
    "vscjava.vscode-java-pack",
    "vscjava.vscode-gradle",
    "vmware.vscode-boot-dev-pack",
    "redhat.vscode-yaml",
    "redhat.vscode-xml",
    "ms-azuretools.vscode-containers"
  ]
}
```

`recommendations`는 Extension을 강제 설치하거나 Version을 고정하는 기능이 아니다. Project 권장 목록을 공유하는 설정이다.

---

## 5. `.gitignore` 확인

`.vscode` 전체를 제외하고 있다면 공통 설정 파일이 Git에서 누락되지 않도록 확인한다.

권장 예:

```gitignore
.vscode/*
!.vscode/settings.json
!.vscode/extensions.json
!.vscode/tasks.json
!.vscode/launch.json
```

Spring Initializr가 일시적으로 만드는 Marker 등은 공유하지 않는다.

---

## 6. VS Code에서 적용 확인

VS Code를 다시 열거나 Reload한 뒤 다음을 확인한다.

```text
.vscode/settings.json 존재
.vscode/extensions.json 존재
Recommended Extensions 확인 가능
JDK 절대경로 없음
Restricted Mode 아님
```

Java / Gradle / Spring Boot의 실제 인식 여부는 여기서 중복 확인하지 않는다.

→ [Java / Gradle / Spring Boot 인식 확인](project_jdk_vscode_verify.md)

---

## 7. Git 확인

```bash
git status
```

정상적으로 공유할 파일:

```text
.vscode/settings.json
.vscode/extensions.json
```

필요한 경우 Commit한다.

```bash
git add .vscode/settings.json .vscode/extensions.json .gitignore
git commit -m "chore: configure VS Code workspace"
```

---

## 8. 완료 체크리스트

- [ ] `.vscode/settings.json`을 작성했다.
- [ ] `.vscode/extensions.json`을 작성했다.
- [ ] JDK 절대경로를 Workspace Settings에 넣지 않았다.
- [ ] `.gitignore`가 공통 `.vscode` 파일을 허용한다.
- [ ] Git 변경사항을 확인했다.

다음 단계:

→ [Java / Gradle / Spring Boot 인식 확인](project_jdk_vscode_verify.md)
