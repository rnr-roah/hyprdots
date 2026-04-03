#!/usr/bin/env bash
# ~/.config/waybar/scripts/scrolling-indicator.sh

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr/ 2>/dev/null | head -1)
fi

SOCK="/run/user/1000/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"

get_state() {
    local active_ws_json active_ws active_addr clients total index pills i

    active_ws_json=$(hyprctl -j activeworkspace 2>/dev/null)
    [ -z "$active_ws_json" ] && echo '{"text":"","tooltip":"","class":""}' && return

    active_ws=$(echo "$active_ws_json" | jq '.id')
    active_addr=$(hyprctl -j activewindow 2>/dev/null | jq -r '.address // ""')

    clients=$(hyprctl -j clients 2>/dev/null | jq --argjson ws "$active_ws" '
        [.[] | select(
            .workspace.id == $ws and
            .hidden == false and
            .floating == false and
            .mapped == true
        )] | sort_by(.at[0])
    ')

    total=$(echo "$clients" | jq 'length')
    [ "$total" -le 1 ] && echo '{"text":"","tooltip":"","class":""}' && return

    index=$(echo "$clients" | jq --arg addr "$active_addr" '
        to_entries | map(select(.value.address == $addr)) | .[0].key // 0
    ')

    pills=""
    for ((i = 0; i < total; i++)); do
        if [ "$i" -eq "$index" ]; then
            pills+="● "
        else
            pills+="○ "
        fi
    done
    pills="${pills% }"

    jq -cn \
        --arg text "$pills" \
        --arg tooltip "Window $((index + 1)) of $total" \
        --arg class "scrolling-indicator" \
        '{"text":$text,"tooltip":$tooltip,"class":$class}' 2>/dev/null
}

get_state

[ ! -S "$SOCK" ] && exit 0

socat -u "UNIX-CONNECT:${SOCK}" - 2>/dev/null | \
while IFS= read -r line; do
    event="${line%%>>*}"
    case "$event" in
        activewindow|openwindow|closewindow|movewindow|workspace|moveworkspace)
            get_state
            ;;
    esac
done
