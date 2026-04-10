#!/bin/bash

source ~/.config/hypr/hyprlock-colors.sh
primary="${ML_PRIMARY}"
faded="${ML_PRIMARY}90"
TOTAL=10

BUSY=$(awk '/MemTotal/{total=$2} /MemAvailable/{avail=$2} END{printf "%.0f", (total-avail)*100/total}' /proc/meminfo)
MEM_USED=$(awk '/MemTotal/{total=$2} /MemAvailable/{avail=$2} END{printf "%.1f", (total-avail)/1024/1024}' /proc/meminfo)
MEM_TOTAL=$(awk '/MemTotal/{printf "%.1f", $2/1024/1024}' /proc/meminfo)

FILLED=$(( BUSY * TOTAL / 100 ))

BAR="<span foreground='${primary}'>R </span>"
for ((i=0; i<TOTAL; i++)); do
    if (( i < FILLED )); then
        BAR+="<span foreground='${primary}'>█ </span>"
    else
        BAR+="<span foreground='${faded}'>░ </span>"
    fi
done

TOOLTIP="RAM: ${MEM_USED}GB / ${MEM_TOTAL}GB (${BUSY}%)"
echo "{\"text\": \"${BAR}\", \"tooltip\": \"${TOOLTIP}\"}"
