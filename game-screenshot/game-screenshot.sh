#!/usr/bin/env bash
set -euo pipefail

GAME=$(kdotool getactivewindow getwindowname 2>/dev/null)
[ -z "$GAME" ] && GAME=$(kdotool getactivewindow getwindowclassname 2>/dev/null)
[ -z "$GAME" ] && GAME="screenshot"
GAME=$(echo "$GAME" | tr ' /' '_-')
mkdir -p "$HOME/Pictures/Screenshots"
spectacle -b -a -n -o "$HOME/Pictures/Screenshots/${GAME}_$(date +%Y%m%d_%H%M%S).png"
