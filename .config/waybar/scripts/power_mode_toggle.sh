#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/power_mode_state"
MODES=("performance" "balanced" "power-saver")

MONITOR="eDP-1"
POS="0x0"
SCALE="1.5"
DEFAULT_RES="2880x1800"

mkdir -p "$(dirname "$STATE_FILE")"

apply_refresh_rate() {
    local profile="$1"
    local refresh
    local current_res
    local current_scale

    case "$profile" in
        power-saver)
            refresh="48.00"
            ;;
        balanced|performance)
            refresh="120.00"
            ;;
        *)
            return
            ;;
    esac

    current_res="$(hyprctl monitors -j | jq -r ".[] | select(.name==\"$MONITOR\") | \"\(.width)x\(.height)\"")"
    current_scale="$(hyprctl monitors -j | jq -r ".[] | select(.name==\"$MONITOR\") | .scale")"

    [[ -z "$current_res" || "$current_res" == "null" ]] && current_res="$DEFAULT_RES"
    [[ -z "$current_scale" || "$current_scale" == "null" ]] && current_scale="1.5"

    hyprctl keyword monitor "$MONITOR,${current_res}@${refresh},$POS,$current_scale" >/dev/null
}
CURRENT_MODE=$(powerprofilesctl get 2>/dev/null)

if [[ -z "$CURRENT_MODE" && -f "$STATE_FILE" ]]; then
    CURRENT_MODE=$(<"$STATE_FILE")
fi

if [[ -z "$CURRENT_MODE" ]]; then
    CURRENT_MODE="${MODES[0]}"
    powerprofilesctl set "$CURRENT_MODE"
fi

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

    CURRENT_MODE="$(powerprofilesctl get)"
    apply_refresh_rate "$CURRENT_MODE"

    swayosd-client \
        --custom-message="Power Mode: $CURRENT_MODE" \
        --custom-icon=process-stop
else
    echo "$CURRENT_MODE" > "$STATE_FILE"
    apply_refresh_rate "$CURRENT_MODE"
fi

case "$CURRENT_MODE" in
    power-saver)
        ICON="<span color='#50fa7b'>󱤅</span>"
        COLOR="#50fa7b"
        CLASS="power-saver"
        ;;
    balanced)
        ICON="<span color='#DFDFDF'>󰚀</span>"
        COLOR="#f1c40f"
        CLASS="balanced"
        ;;
    performance)
        ICON="<span color='#ff5555'>󰠠</span>"
        COLOR="#ff5555"
        CLASS="performance"
        ;;
esac

echo "{\"text\": \"$ICON\", \"class\": \"$CLASS\", \"color\": \"$COLOR\"}"
