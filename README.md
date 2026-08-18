# Microserver MkDocs

Microserver 기술문서 사이트의 계층형 기본 구조입니다.

## 상단 메뉴

- Home
- 프로젝트 시작
- Framework 구축
- 업무 및 금융 연계
- 확장 아키텍처
- 참고자료

## Windows 실행

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
python -m mkdocs serve
```

PowerShell 실행 정책 오류가 발생하면 최초 1회:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## macOS 실행

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
python -m mkdocs serve
```

## 빌드 검증

```bash
python -m mkdocs build --strict
```
