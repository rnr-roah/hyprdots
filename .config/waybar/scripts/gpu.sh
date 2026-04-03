#!/bin/bash

IDLE_PATH="/sys/class/drm/card0/device/tile0/gt0/gtidle/idle_residency_ms"
FREQ_PATH="/sys/class/drm/card0/device/tile0/gt0/freq0/cur_freq"
INTERVAL=3

IDLE1=$(cat "$IDLE_PATH")
sleep $INTERVAL
IDLE2=$(cat "$IDLE_PATH")

FREQ=$(cat "$FREQ_PATH")

BUSY=$(awk -v i1="$IDLE1" -v i2="$IDLE2" -v iv="$INTERVAL" 'BEGIN {
    delta = i2 - i1
    busy = 100 - (delta / (iv * 1000) * 100)
    if (busy < 0) busy = 0
    if (busy > 100) busy = 100
    printf "%.1f", busy
}')

TOOLTIP="GPU: ${BUSY}%\nFreq: ${FREQ} MHz"

echo "{\"text\": \"${BUSY}%\", \"tooltip\": \"$TOOLTIP\"}"
