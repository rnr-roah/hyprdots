#!/usr/bin/env bash
# ──────────────────────────────────────────────
#  wallpaper.sh — rofi wallpaper selector with previews
#  Dependencies: rofi (≥1.7), imagemagick (magick)
# ──────────────────────────────────────────────

WALLPAPER_DIR="${1:-/home/roah/Wallpapers}"
CACHE_DIR="$HOME/.cache/wallpaper-thumbs"
CACHE_FILE="$HOME/.cache/current_wallpaper"
THUMB_SIZE="240x135"   # matches rofi icon size exactly — no runtime scaling

mkdir -p "$CACHE_DIR"

# ── Sanity check ──────────────────────────────
if [[ ! -d "$WALLPAPER_DIR" ]]; then
  notify-send "wallpaper.sh" "Directory not found: $WALLPAPER_DIR" 2>/dev/null
  echo "Error: directory '$WALLPAPER_DIR' not found." >&2
  exit 1
fi

# ── Collect wallpapers ────────────────────────
mapfile -t WALLS < <(
  find -L "$WALLPAPER_DIR" -maxdepth 2 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" \
       -o -iname "*.png" -o -iname "*.webp" \
       -o -iname "*.gif" \) \
  | sort
)

if [[ ${#WALLS[@]} -eq 0 ]]; then
  notify-send "wallpaper.sh" "No images found in $WALLPAPER_DIR" 2>/dev/null
  echo "No images found in '$WALLPAPER_DIR'." >&2
  exit 1
fi

# ── Generate thumbnails in parallel (skip if already cached) ──
needs_gen=0
for img in "${WALLS[@]}"; do
  thumb="$CACHE_DIR/$(md5sum <<< "$img" | cut -d' ' -f1).png"
  [[ ! -f "$thumb" ]] && { needs_gen=1; break; }
done

[[ $needs_gen -eq 1 ]] && notify-send "Wallpaper selector" "Generating thumbnails, one moment..." 2>/dev/null

for img in "${WALLS[@]}"; do
  thumb="$CACHE_DIR/$(md5sum <<< "$img" | cut -d' ' -f1).png"
  if [[ ! -f "$thumb" ]]; then
    magick "$img" -thumbnail "$THUMB_SIZE^" \
      -gravity center -extent "$THUMB_SIZE" \
      "$thumb" 2>/dev/null &
  fi
done
wait   # wait for all background magick jobs to finish

# ── Build rofi input (no display name, just icon) ──
ROFI_INPUT=""
for img in "${WALLS[@]}"; do
  thumb="$CACHE_DIR/$(md5sum <<< "$img" | cut -d' ' -f1).png"
  ROFI_INPUT+=" \0icon\x1f${thumb}\n"
done

# ── Launch rofi ───────────────────────────────
CHOICE=$(printf "%b" "$ROFI_INPUT" | rofi \
  -dmenu \
  -i \
  -p "" \
  -show-icons \
  -theme-str '
    window    { width: 100%; location: south; anchor: south; y-offset: 0; }
    mainbox      { padding: 4px; spacing: 0px; }
    inputbar     { enabled: false; }
    listview  { lines: 3; columns: 6; scrollbar: false; }
    element   { orientation: vertical; padding: 0px; spacing: 0px; }
    element-icon { size: 240px; border-radius: 4px; }
    element-text { enabled: false; }
  ' \
  -no-custom \
  -format i)

[[ -z "$CHOICE" ]] && exit 0

SELECTED="${WALLS[$CHOICE]}"

# ── Copy to default location ─────────────────
mkdir -p /home/roah/Wallpapers/default
cp "$SELECTED" /home/roah/Wallpapers/default/background.png

# ── Set the wallpaper ─────────────────────────
pkill -x swaybg 2>/dev/null
swaybg -i /home/roah/Wallpapers/default/background.png -m fill &
disown

# ── Generate colorscheme with matugen ─────────
matugen image /home/roah/Wallpapers/default/background.png --source-color-index 0

# ── Cache the selection ───────────────────────
echo "$SELECTED" > "$CACHE_FILE"
notify-send "Wallpaper set" "$(basename "$SELECTED")" 2>/dev/null
