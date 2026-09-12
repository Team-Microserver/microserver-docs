# macOS VS Code 가이드 보완 내역

## 주요 변경사항

- Windows 최신 가이드와 동일하게 `VS Code 설치`와 `VS Code 개발환경 설정` NAV 분리
- `vscode_portable_setup.md` 신규 분리
- `vscode_basic_setup.md`를 `vscode_basic_settings.md`로 정리
- macOS Portable Mode를 `Visual Studio Code.app` + 형제 `code-portable-data` 구조로 통일
- 실제 `JAVA_HOME`을 `~/local-microserver/tools/jdk/temurin-25/Contents/Home`으로 통일
- 오래된 `~/dev/jdks`, `temurin-25.jdk` 경로 정리
- macOS Portable Mode의 자동 Update 동작을 최신 공식 기준에 맞게 수정
- Portable Mode에서 `--user-data-dir`, `--extensions-dir`보다 Portable Data Directory가 우선함을 명시
- Apple Silicon / Arm64 확인 절차 추가
- 설치와 Portable 설정의 역할 중복 축소
