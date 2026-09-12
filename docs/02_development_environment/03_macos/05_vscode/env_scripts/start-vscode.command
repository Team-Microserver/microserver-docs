#!/bin/zsh

# -----------------------------------------------------------------------------
# MicroServer Portable VS Code 실행 Script
#
# 목적:
#   setup.sh을 읽어 JDK / Gradle / 개인 환경변수를 적용한 뒤
#   MicroServer용 Portable VS Code를 Background Process로 실행한다.
#
# 최초 구성:
#   code-portable-data를 만든 뒤 이 Script로 최초 실행을 검증한다.
#
# 평상시:
#   MicroServer VS Code.app Launcher가 이 Script를 자동 호출하므로
#   개발자가 매번 Terminal에서 직접 실행할 필요는 없다.
# -----------------------------------------------------------------------------

# 중간 명령에서 오류가 발생하면 Script를 계속 진행하지 않고 종료한다.
set -e

# MicroServer Root Directory
export LOCAL_MICROSERVER="${LOCAL_MICROSERVER:-$HOME/local-microserver}"

# 공통 환경변수 설정 Script
SETUP_SCRIPT="$LOCAL_MICROSERVER/env/setup.sh"

# VS Code 관련 표준 경로
VSCODE_ROOT="$LOCAL_MICROSERVER/tools/vscode"
VSCODE_APP="$VSCODE_ROOT/Visual Studio Code.app"

# macOS Application Bundle 내부의 실제 VS Code 실행 파일
VSCODE_BIN="$VSCODE_APP/Contents/MacOS/Code"

# 이 Directory가 VS Code Application과 같은 위치에 있어야 Portable Mode가 활성화된다.
PORTABLE_DATA="$VSCODE_ROOT/code-portable-data"

# VS Code 시작 시 열 MicroServer Workspace Root
WORKSPACE="$LOCAL_MICROSERVER/workspace"

# setup.sh이 없으면 표준 환경을 만들 수 없으므로 실행 중단
if [[ ! -f "$SETUP_SCRIPT" ]]; then
  echo "ERROR: setup.sh not found:"
  echo "  $SETUP_SCRIPT"
  exit 1
fi

# setup.sh을 현재 Process에 적용한다.
# JAVA_HOME / GRADLE_HOME / PATH / local-env.sh 등이 적용된다.
source "$SETUP_SCRIPT"

# VS Code Application 존재 여부 확인
if [[ ! -d "$VSCODE_APP" ]]; then
  echo "ERROR: Visual Studio Code.app not found:"
  echo "  $VSCODE_APP"
  exit 1
fi

# 실제 VS Code 실행 파일 존재 및 실행 가능 여부 확인
if [[ ! -x "$VSCODE_BIN" ]]; then
  echo "ERROR: VS Code executable not found:"
  echo "  $VSCODE_BIN"
  exit 1
fi

# Portable Mode Directory가 없으면 일반 VS Code 환경으로 실행될 수 있으므로 중단
if [[ ! -d "$PORTABLE_DATA" ]]; then
  echo "ERROR: Portable Mode directory not found:"
  echo "  $PORTABLE_DATA"
  echo
  echo "Create code-portable-data before launching MicroServer VS Code."
  exit 1
fi

# Workspace Directory가 없으면 생성
mkdir -p "$WORKSPACE"

# VS Code를 Background Process로 실행한다.
# nohup을 사용하므로 이 Script를 실행한 Terminal이 종료되어도 VS Code가 계속 실행될 수 있다.
# 표준 출력/오류는 버려 Terminal을 점유하지 않도록 한다.
nohup "$VSCODE_BIN" --new-window "$WORKSPACE" \
  >/dev/null 2>&1 &

# Script 종료 후 Terminal Prompt를 즉시 반환한다.
exit 0
