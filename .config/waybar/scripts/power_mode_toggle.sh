#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/power_mode_state"
MODES=("performance" "balanced" "power-saver")

mkdir -p "$(dirname "$STATE_FILE")"

# Detect actual current system mode
CURRENT_MODE=$(powerprofilesctl get 2>/dev/null)

# If detection failed (shouldn’t happen), fall back to file
if [[ -z "$CURRENT_MODE" && -f "$STATE_FILE" ]]; then
    CURRENT_MODE=$(<"$STATE_FILE")
fi

# Initialize if nothing set
if [[ -z "$CURRENT_MODE" ]]; then
    CURRENT_MODE="${MODES[0]}"
    powerprofilesctl set "$CURRENT_MODE"
fi

# Toggle mode
if [[ "$1" == "toggle" ]]; then
    CURRENT_INDEX=-1
    for i in "${!MODES[@]}"; do
        if [[ "${MODES[$i]}" == "$CURRENT_MODE" ]]; then
            CURRENT_INDEX=$i
            break
        fi
    done
    (( CURRENT_INDEX == -1 )) && CURRENT_INDEX=0

    NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#MODES[@]} ))
    NEXT_MODE="${MODES[$NEXT_INDEX]}"
    echo "$NEXT_MODE" > "$STATE_FILE"
    powerprofilesctl set "$NEXT_MODE"
    #notify-send "⚙️ Power Mode" "$(powerprofilesctl get)"
    swayosd-client --custom-message="Power Mode: $(powerprofilesctl get)" --custom-icon=process-stop
    CURRENT_MODE="$NEXT_MODE"
else
    echo "$CURRENT_MODE" > "$STATE_FILE"
fi

# Output JSON for Waybar with your custom Nerd Font icons
case "$CURRENT_MODE" in
    power-saver)
        ICON="<span color='#50fa7b'>󱤅</span>"      # eco / powersaver
        COLOR="#50fa7b"    # green
	class="power-saver"
        ;;
    balanced)
        #ICON="<span color='#f1c40f'>󰚀</span>"      # balanced
        ICON="<span color='#DFDFDF'>󰚀</span>"      # balanced
        COLOR="#f1c40f"    # yellowish-orange
	class="balanced"
        ;;
    performance)
        ICON="<span color='#ff5555'>󰠠</span>"      # performance
        COLOR="#ff5555"    # red
	class="performance"
        ;;
esac

echo "{\"text\": \"$ICON\", \"class\": \"$CURRENT_MODE\", \"color\": \"$COLOR\"}"



# Output JSON for Waybar

