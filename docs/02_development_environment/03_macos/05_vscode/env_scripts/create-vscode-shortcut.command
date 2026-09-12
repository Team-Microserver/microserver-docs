#!/bin/zsh

# -----------------------------------------------------------------------------
# MicroServer VS Code Launcher / Desktop Alias 생성 Script
#
# 목적:
#   - 설치된 VS Code의 Icon을 MicroServer Launcher용으로 복사한다.
#   - ~/local-microserver/MicroServer VS Code.app 을 생성한다.
#   - Desktop에 Finder Alias를 생성한다.
#
# 실행 시점:
#   start-vscode.command로 Portable VS Code가 정상 실행되는 것을 확인한 뒤
#   개발자별 Mac에서 최초 1회 실행한다.
# -----------------------------------------------------------------------------

# 오류 발생 시 즉시 종료
set -e

# MicroServer Root Directory
export LOCAL_MICROSERVER="${LOCAL_MICROSERVER:-$HOME/local-microserver}"

# 원본 VS Code Application
SOURCE_APP="$LOCAL_MICROSERVER/tools/vscode/Visual Studio Code.app"

# 실제 Portable VS Code를 실행하는 Script
START_SCRIPT="$LOCAL_MICROSERVER/env/start-vscode.command"

# Launcher Icon 저장 Directory / 파일
ICONS_DIR="$LOCAL_MICROSERVER/icons"
ICON_FILE="$ICONS_DIR/microserver-vscode.icns"

# 생성할 MicroServer 전용 Launcher Application
LAUNCHER_APP="$LOCAL_MICROSERVER/MicroServer VS Code.app"

# Desktop에 생성할 Finder Alias 이름
DESKTOP_ALIAS="$HOME/Desktop/MicroServer VS Code"

# VS Code가 표준 위치에 설치되어 있는지 확인
if [[ ! -d "$SOURCE_APP" ]]; then
  echo "ERROR: Visual Studio Code.app not found:"
  echo "  $SOURCE_APP"
  exit 1
fi

# start-vscode.command가 실행 가능한지 확인
if [[ ! -x "$START_SCRIPT" ]]; then
  echo "ERROR: start-vscode.command is not executable:"
  echo "  $START_SCRIPT"
  echo "Run:"
  echo "  chmod +x \"$START_SCRIPT\""
  exit 1
fi

# Icon 저장 Directory 생성
mkdir -p "$ICONS_DIR"

# 일반적인 VS Code Icon 위치를 먼저 확인한다.
SOURCE_ICON=""
if [[ -f "$SOURCE_APP/Contents/Resources/Code.icns" ]]; then
  SOURCE_ICON="$SOURCE_APP/Contents/Resources/Code.icns"
else
  # Version에 따라 파일명이 다를 경우 첫 번째 .icns 파일을 찾는다.
  SOURCE_ICON="$(find "$SOURCE_APP/Contents/Resources" -maxdepth 1 -name '*.icns' -print -quit 2>/dev/null || true)"
fi

# Icon을 찾았으면 MicroServer 표준 위치로 복사
if [[ -n "$SOURCE_ICON" ]]; then
  cp "$SOURCE_ICON" "$ICON_FILE"
fi

# 기존 Launcher가 있으면 새로 만들기 위해 제거
rm -rf "$LAUNCHER_APP"

# macOS .app Bundle 기본 Directory 생성
mkdir -p "$LAUNCHER_APP/Contents/MacOS"
mkdir -p "$LAUNCHER_APP/Contents/Resources"

# Launcher가 실행할 작은 Shell Script 생성.
# 사용자가 Launcher를 더블클릭하면 start-vscode.command가 실행된다.
cat > "$LAUNCHER_APP/Contents/MacOS/microserver-vscode" <<'EOF'
#!/bin/zsh
exec "$HOME/local-microserver/env/start-vscode.command"
EOF

# Launcher 내부 실행 파일에 실행 권한 부여
chmod +x "$LAUNCHER_APP/Contents/MacOS/microserver-vscode"

# 복사한 Icon이 있으면 Launcher Resources에 포함
if [[ -f "$ICON_FILE" ]]; then
  cp "$ICON_FILE" "$LAUNCHER_APP/Contents/Resources/microserver-vscode.icns"
fi

# macOS가 Application으로 인식할 수 있도록 Info.plist 생성
cat > "$LAUNCHER_APP/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>MicroServer VS Code</string>
  <key>CFBundleDisplayName</key>
  <string>MicroServer VS Code</string>
  <key>CFBundleIdentifier</key>
  <string>com.team-microserver.vscode-launcher</string>
  <key>CFBundleVersion</key>
  <string>1.0</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleExecutable</key>
  <string>microserver-vscode</string>
  <key>CFBundleIconFile</key>
  <string>microserver-vscode</string>
</dict>
</plist>
EOF

# 같은 이름의 이전 Desktop Alias가 있으면 제거
rm -f "$DESKTOP_ALIAS" 2>/dev/null || true

# Finder에게 MicroServer VS Code.app을 가리키는 Desktop Alias 생성을 요청
osascript <<EOF
tell application "Finder"
  set launcherApp to POSIX file "$LAUNCHER_APP" as alias
  set desktopFolder to desktop
  make new alias file at desktopFolder to launcherApp with properties {name:"MicroServer VS Code"}
end tell
EOF

echo
echo "MicroServer VS Code launcher created:"
echo "  $LAUNCHER_APP"
echo
echo "Desktop alias created:"
echo "  $DESKTOP_ALIAS"
echo
echo "You can also drag 'MicroServer VS Code.app' to the Dock."
