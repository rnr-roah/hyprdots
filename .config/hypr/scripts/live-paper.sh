#!/usr/bin/env bash

LIVE_DIR="${1:-$HOME/Wallpapers/live}"
DEFAULT_DIR="$HOME/Wallpapers/default"
DEFAULT_WALL="$DEFAULT_DIR/background.png"

THUMB_CACHE_DIR="$HOME/.cache/wallpaper-thumbs"
PINGPONG_CACHE_DIR="$HOME/.cache/wallpaper-pingpong"

STATE_DIR="$HOME/.local/state/wallpapers"
CACHE_FILE="$STATE_DIR/current_live_wallpaper"

THUMB_SIZE="240x135"

MONITOR="${MONITOR:-eDP-1}"
MPV_OPTS="no-audio loop --hwdec=auto --panscan=1.0 --vf-add=fps=30"

mkdir -p "$THUMB_CACHE_DIR" "$PINGPONG_CACHE_DIR" "$STATE_DIR" "$DEFAULT_DIR"

mapfile -t WALLS < <(
  find -L "$LIVE_DIR" -maxdepth 1 -type f \
    \( -iname "*.mp4" -o -iname "*.mkv" \
       -o -iname "*.webm" -o -iname "*.mov" \
       -o -iname "*.gif" \) \
  | sort
)

[[ ${#WALLS[@]} -eq 0 ]] && {
  notify-send "Live Wallpaper" "No live wallpapers found in $LIVE_DIR" 2>/dev/null
  exit 1
}

for vid in "${WALLS[@]}"; do
  thumb="$THUMB_CACHE_DIR/$(md5sum <<< "$vid" | cut -d' ' -f1).png"

  [[ ! -f "$thumb" ]] && {
    ffmpeg -y -ss 00:00:03 -i "$vid" -vframes 1 "$thumb" >/dev/null 2>&1 &
  }
done

wait

ROFI_INPUT=""
for vid in "${WALLS[@]}"; do
  thumb="$THUMB_CACHE_DIR/$(md5sum <<< "$vid" | cut -d' ' -f1).png"
  ROFI_INPUT+=" \0icon\x1f${thumb}\n"
done

CHOICE=$(printf "%b" "$ROFI_INPUT" | rofi \
  -dmenu \
  -i \
  -p "" \
  -show-icons \
  -theme-str '
    window       { width: 100%; location: south; anchor: south; y-offset: 0; }
    mainbox      { padding: 4px; spacing: 0px; }
    inputbar     { enabled: false; }
    listview     { lines: 3; columns: 6; scrollbar: false; }
    element      { orientation: vertical; padding: 0px; spacing: 0px; }
    element-icon { size: 240px; border-radius: 4px; }
    element-text { enabled: false; }
  ' \
  -no-custom \
  -format i)

[[ -z "$CHOICE" ]] && exit 0

SELECTED="${WALLS[$CHOICE]}"
HASH="$(md5sum <<< "$SELECTED" | cut -d' ' -f1)"
PINGPONG_VIDEO="$PINGPONG_CACHE_DIR/$HASH.mp4"

# Extract frame into default wallpaper path
ffmpeg -y -ss 00:00:03 -i "$SELECTED" -vframes 1 "$DEFAULT_WALL" >/dev/null 2>&1

# Set extracted frame with swaybg first, so no ugly gap
pkill -x swaybg 2>/dev/null
swaybg -i "$DEFAULT_WALL" -m fill &
disown

# Generate Matugen colors
matugen image "$DEFAULT_WALL" --source-color-index 0

# Create ping-pong version only if it does not already exist
if [[ ! -f "$PINGPONG_VIDEO" ]]; then
  notify-send "Live Wallpaper" "Creating ping-pong version..." 2>/dev/null

  ffmpeg -y -i "$SELECTED" \
    -filter_complex "[0:v]reverse[r];[0:v][r]concat=n=2:v=1:a=0" \
    -an \
    -movflags +faststart \
    "$PINGPONG_VIDEO" >/dev/null 2>&1
fi

# Kill old live wallpaper
pkill -x mpvpaper 2>/dev/null

# Start ping-pong live wallpaper
mpvpaper -o "$MPV_OPTS" "$MONITOR" "$PINGPONG_VIDEO" &
disown

# Save original selected wallpaper persistently
echo "$SELECTED" > "$CACHE_FILE"

notify-send "Live wallpaper set" "$(basename "$SELECTED")" 2>/dev/null
