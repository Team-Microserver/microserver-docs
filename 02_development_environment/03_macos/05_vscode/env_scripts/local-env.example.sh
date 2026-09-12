#!/bin/zsh

# -----------------------------------------------------------------------------
# MicroServer 개발자 개인 환경변수 Sample
#
# 목적:
#   공통 Package에 포함하면 안 되는 개발자별 Password, Token,
#   Local DB 접속정보 등의 작성 형식을 제공한다.
#
# 사용 방법:
#   아래 명령으로 개인 파일을 만든 뒤 필요한 항목만 수정한다.
#
#   cp "$HOME/local-microserver/env/local-env.example.sh" \
#      "$HOME/local-microserver/env/local-env.sh"
#
# 주의:
#   local-env.example.sh : 배포 가능
#   local-env.sh         : 개인 파일이므로 배포 제외
# -----------------------------------------------------------------------------

# 필요한 항목의 주석을 해제하고 개발자 자신의 값으로 설정한다.

# export ORACLE_PWD="<strong-local-password>"
# export DB_HOST="127.0.0.1"
# export DB_PORT="1521"
