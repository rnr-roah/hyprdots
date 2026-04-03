#!/bin/bash
# ~/.config/hypr/scripts/media_watchdog.sh
# Notifies when apps start/stop using mic or camera

PREV_MIC=""
PREV_CAM=""

get_mic_apps() {
    pw-dump 2>/dev/null \
        | jq -r '.[] | select(.info.props["media.class"] == "Stream/Input/Audio")
                      | .info.props["application.name"] // .info.props["node.name"] // "Unknown"' \
        | sort -u \
        | tr '\n' ',' \
        | sed 's/,$//'
}

get_cam_state() {
    pw-dump 2>/dev/null \
        | jq -r '.[] | select(.info.props["media.class"] == "Video/Source" and .info.state == "running")
                      | .info.props["node.nick"] // .info.props["node.name"] // "Camera"' \
        | sort -u \
        | tr '\n' ',' \
        | sed 's/,$//'
}

while true; do
    MIC=$(get_mic_apps)
    CAM=$(get_cam_state)

    # Mic started
    if [[ -z "$PREV_MIC" && -n "$MIC" ]]; then
        notify-send -u critical -i audio-input-microphone "🎤 Mic active" "$MIC is using your microphone"
    fi
    # Mic stopped
    if [[ -n "$PREV_MIC" && -z "$MIC" ]]; then
        notify-send -u normal -i audio-input-microphone "Mic stopped" "$PREV_MIC stopped using your microphone"
    fi
    # Mic changed (different app)
    if [[ -n "$PREV_MIC" && -n "$MIC" && "$PREV_MIC" != "$MIC" ]]; then
        notify-send -u critical -i audio-input-microphone "🎤 Mic active" "$MIC is using your microphone"
    fi

    # Camera started
    if [[ -z "$PREV_CAM" && -n "$CAM" ]]; then
        notify-send -u critical -i camera-web "🔴 Camera active" "$CAM is using your camera"
    fi
    # Camera stopped
    if [[ -n "$PREV_CAM" && -z "$CAM" ]]; then
        notify-send -u normal -i camera-web "Camera stopped" "$PREV_CAM stopped using your camera"
    fi
    # Camera changed
    if [[ -n "$PREV_CAM" && -n "$CAM" && "$PREV_CAM" != "$CAM" ]]; then
        notify-send -u critical -i camera-web "🔴 Camera active" "$CAM is using your camera"
    fi

    PREV_MIC="$MIC"
    PREV_CAM="$CAM"

    sleep 0.5
done
