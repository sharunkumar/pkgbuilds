#!/usr/bin/env bash
set -euo pipefail

PID=$(kdotool getactivewindow getwindowpid 2>/dev/null)
GAME=$(cat "/proc/$PID/comm" 2>/dev/null)
[ -z "$GAME" ] && GAME=$(kdotool getactivewindow getwindowclassname 2>/dev/null)
[ -z "$GAME" ] && GAME=$(kdotool getactivewindow getwindowname 2>/dev/null)
[ -z "$GAME" ] && GAME="screenshot"
GAME=$(echo "$GAME" | tr ' /' '_-')
mkdir -p "$HOME/Pictures/Screenshots"
FILE="$HOME/Pictures/Screenshots/${GAME}_$(date +%Y%m%d_%H%M%S).png"
spectacle -b -a -n -o "$FILE"
wl-copy < "$FILE"
