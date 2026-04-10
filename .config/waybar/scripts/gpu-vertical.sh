#!/bin/bash

IDLE_PATH="/sys/class/drm/card0/device/tile0/gt0/gtidle/idle_residency_ms"
FREQ_PATH="/sys/class/drm/card0/device/tile0/gt0/freq0/cur_freq"
INTERVAL=1

source ~/.config/hypr/hyprlock-colors.sh
primary="${ML_PRIMARY}"
faded="${ML_PRIMARY}"
TOTAL=10

IDLE1=$(cat "$IDLE_PATH")
sleep $INTERVAL
IDLE2=$(cat "$IDLE_PATH")

FREQ=$(cat "$FREQ_PATH")

BUSY=$(awk -v i1="$IDLE1" -v i2="$IDLE2" -v iv="$INTERVAL" 'BEGIN {
    delta = i2 - i1
    busy = 100 - (delta / (iv * 1000) * 100)
    if (busy < 0) busy = 0
    if (busy > 100) busy = 100
    printf "%.0f", busy
}')

FILLED=$(( BUSY * TOTAL / 100 ))

BAR=""
for ((i=TOTAL-1; i>=0; i--)); do
    if (( i < FILLED )); then
        BAR+="<span foreground='${primary}'>█</span>\n"
    else
        BAR+="<span foreground='${faded}'>░</span>\n"
    fi
done

TOOLTIP="GPU: ${BUSY}%\nFreq: ${FREQ} MHz"

echo "{\"text\": \"${BAR}\", \"tooltip\": \"${TOOLTIP}\"}"
