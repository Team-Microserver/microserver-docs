#!/bin/zsh

# -----------------------------------------------------------------------------
# MicroServer 공통 개발환경 설정 Script
#
# 목적:
#   - MicroServer의 표준 Root Directory를 정의한다.
#   - JDK / Gradle / Gradle User Home을 설정한다.
#   - PATH에 Java와 Gradle 실행 경로를 추가한다.
#   - 개발자 개인 설정 파일(local-env.sh)이 있으면 추가로 읽는다.
#
# 사용:
#   1) 일반적인 VS Code 실행 시 직접 실행하지 않는다.
#      start-vscode.command가 이 파일을 source한다.
#   2) 일반 Terminal에 같은 환경을 적용할 때만 다음처럼 사용한다.
#      source "$HOME/local-microserver/env/setup.sh"
# -----------------------------------------------------------------------------

# MicroServer 개발환경의 기준 Root Directory
export LOCAL_MICROSERVER="${LOCAL_MICROSERVER:-$HOME/local-microserver}"

# JDK의 실제 JAVA_HOME.
# macOS .jdk Bundle은 Contents/Home이 Java Home이다.
export JAVA_HOME="$LOCAL_MICROSERVER/tools/jdk/temurin-25/Contents/Home"

# 설치해 둔 Gradle의 Home Directory
export GRADLE_HOME="$LOCAL_MICROSERVER/tools/gradle/gradle-9.7.1"

# Gradle Cache, Wrapper, Daemon 등의 User Data 저장 위치
export GRADLE_USER_HOME="$LOCAL_MICROSERVER/gradle-home"

# 현재 Shell에서 java와 gradle 명령을 바로 사용할 수 있도록 PATH 앞쪽에 추가
export PATH="$JAVA_HOME/bin:$GRADLE_HOME/bin:$PATH"

# 개발자별 Password, Token, Local DB 정보 등을 둘 수 있는 개인 설정 파일
LOCAL_ENV_FILE="$LOCAL_MICROSERVER/env/local-env.sh"

# 개인 설정 파일이 존재할 때만 현재 Shell에 적용한다.
# 파일이 없어도 공통 개발환경은 정상 동작한다.
if [[ -f "$LOCAL_ENV_FILE" ]]; then
  source "$LOCAL_ENV_FILE"
fi
