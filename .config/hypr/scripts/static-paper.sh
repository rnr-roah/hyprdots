#!/usr/bin/env bash

WALLPAPER_DIR="${1:-$HOME/Wallpapers}"
DEFAULT_DIR="$HOME/Wallpapers/default"
DEFAULT_WALL="$DEFAULT_DIR/background.png"

THUMB_CACHE_DIR="$HOME/.cache/wallpaper-thumbs"
STATE_DIR="$HOME/.local/state/wallpapers"
CACHE_FILE="$STATE_DIR/current_wallpaper"

THUMB_SIZE="240x135"

mkdir -p "$THUMB_CACHE_DIR" "$STATE_DIR" "$DEFAULT_DIR"

mapfile -t WALLS < <(
  find -L "$WALLPAPER_DIR" -maxdepth 1 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" \
       -o -iname "*.png" -o -iname "*.webp" \) \
  | sort
)

[[ ${#WALLS[@]} -eq 0 ]] && {
  notify-send "Wallpaper" "No wallpapers found" 2>/dev/null
  exit 1
}

for img in "${WALLS[@]}"; do
  thumb="$THUMB_CACHE_DIR/$(md5sum <<< "$img" | cut -d' ' -f1).png"

  [[ ! -f "$thumb" ]] && {
    magick "$img[0]" -thumbnail "$THUMB_SIZE^" \
      -gravity center -extent "$THUMB_SIZE" \
      "$thumb" 2>/dev/null &
  }
done

wait

ROFI_INPUT=""
for img in "${WALLS[@]}"; do
  thumb="$THUMB_CACHE_DIR/$(md5sum <<< "$img" | cut -d' ' -f1).png"
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

# Stop live wallpaper
pkill -x mpvpaper 2>/dev/null

# Clear live wallpaper state
rm -f "$HOME/.local/state/wallpapers/current_live_wallpaper"

# Copy selected image to universal wallpaper path
cp "$SELECTED" "$DEFAULT_WALL"

# Restart swaybg
pkill -x swaybg 2>/dev/null
swaybg -i "$DEFAULT_WALL" -m fill &
disown

# Generate colors
matugen image "$DEFAULT_WALL" --source-color-index 0

# Save state
echo "$SELECTED" > "$CACHE_FILE"

notify-send "Wallpaper set" "$(basename "$SELECTED")" 2>/dev/null
