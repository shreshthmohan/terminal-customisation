#!/bin/zsh
# Builds the watcher and installs it as a LaunchAgent (starts at login).
set -euo pipefail
cd "${0:A:h}"

LABEL=com.user.terminal-appearance-watcher
PLIST=~/Library/LaunchAgents/$LABEL.plist
BIN="$PWD/appearance-watcher"

swiftc -O appearance-watcher.swift -o "$BIN"

cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key><array><string>$BIN</string></array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>StandardErrorPath</key><string>/tmp/$LABEL.log</string>
</dict>
</plist>
EOF

launchctl bootout gui/$UID "$PLIST" 2>/dev/null || true
launchctl bootstrap gui/$UID "$PLIST"
echo "Installed. Logs: /tmp/$LABEL.log"
echo "Uninstall: launchctl bootout gui/\$UID $PLIST && rm $PLIST"
