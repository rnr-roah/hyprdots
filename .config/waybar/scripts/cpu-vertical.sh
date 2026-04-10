#!/bin/bash

INTERVAL=1
source ~/.config/hypr/hyprlock-colors.sh
primary="${ML_PRIMARY}"
faded="${ML_PRIMARY}90"
TOTAL=10

CPU1=$(awk '/^cpu / {print $2+$4, $2+$3+$4+$5}' /proc/stat)
sleep $INTERVAL
CPU2=$(awk '/^cpu / {print $2+$4, $2+$3+$4+$5}' /proc/stat)

BUSY=$(awk -v c1="$CPU1" -v c2="$CPU2" 'BEGIN {
    split(c1, a, " ")
    split(c2, b, " ")
    busy = (b[1]-a[1]) / (b[2]-a[2]) * 100
    if (busy < 0) busy = 0
    if (busy > 100) busy = 100
    printf "%.0f", busy
}')

FILLED=$(( BUSY * TOTAL / 100 ))

BAR="<span foreground='${primary}'></span>\n"
for ((i=0; i<TOTAL; i++)); do
    if (( i < FILLED )); then
        BAR+="<span foreground='${primary}'>█</span>\n"
    else
        BAR+="<span foreground='${faded}'>░</span>\n"
    fi
done

TOOLTIP="CPU: ${BUSY}%"
echo "{\"text\": \"${BAR}\", \"tooltip\": \"${TOOLTIP}\"}"
