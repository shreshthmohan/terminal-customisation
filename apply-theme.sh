#!/bin/zsh
# Apply a theme JSON (see themes/) to Terminal.
# Usage: ./apply-theme.sh <theme.json> <light|dark>
#   light -> updates "Basic Light", dark -> updates "Basic"
set -euo pipefail
cd "${0:A:h}"
json="${1:A}"; mode="$2"
[[ "$mode" == light ]] && name="Basic Light" || name="Basic"

swift apply-theme.swift "$json" "$mode"
# Remember the open windows, so we can close the one the import opens.
before=$(osascript -e 'tell application "Terminal" to get id of every window')
open "$name.terminal"          # Terminal imports it as "<name> 1" when <name> exists
/bin/sleep 2

osascript - "$name" "$before" <<'EOF'
on run argv
  set oldName to item 1 of argv
  set AppleScript's text item delimiters to ", "
  set beforeIds to text items of (item 2 of argv)
  tell application "Terminal"
    -- Terminal skips the import (but still opens a window) when the file
    -- matches the profile it already has.
    if exists settings set (oldName & " 1") then
      set newSet to settings set (oldName & " 1")
      if name of default settings is oldName then set default settings to newSet
      if name of startup settings is oldName then set startup settings to newSet
      delete settings set oldName
      set name of newSet to oldName
      -- Re-point tabs at the renamed profile.
      repeat with w in windows
        repeat with t in tabs of w
          set n to name of current settings of t
          if n is oldName or n is (oldName & " 1") then set current settings of t to newSet
        end repeat
      end repeat
    end if
    -- Close the window the import opened (any window that was not open before).
    repeat with w in (get every window)
      if (id of w as text) is not in beforeIds then close w
    end repeat
  end tell
end run
EOF
echo "Applied $mode theme to \"$name\"."
