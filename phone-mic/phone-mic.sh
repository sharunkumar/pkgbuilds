#!/usr/bin/env bash
set -euo pipefail

LATENCY=125
PIPE=/tmp/scrcpy_pipe

MODULE_ID=$(pactl load-module module-pipe-source \
    source_name="Scrcpy" channels=2 format=16 rate=48000 file="$PIPE")

# keep the pipe flowing so scrcpy never blocks on write
parec --fix-rate -d Scrcpy --raw > /dev/null &
PAREC_PID=$!

scrcpy --no-video --no-window --no-playback \
    --audio-source=mic --audio-codec=raw \
    --record-format=wav --record="$PIPE" \
    --audio-buffer=$LATENCY --audio-output-buffer=10

kill $PAREC_PID 2>/dev/null || true
pactl unload-module "$MODULE_ID"
