#!/usr/bin/env bash
# waybar-switch.sh — Switch Waybar config via Rofi
# Symlinks config & style.css from ~/.config/waybar/bars/<choice>/
# into ~/.config/waybar/

WAYBAR_DIR="$HOME/.config/waybar"
BARS_DIR="$WAYBAR_DIR/bars"

# ── Collect bar names (folder names inside bars/) ────────────────────────────
mapfile -t bars < <(find "$BARS_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)

if [[ ${#bars[@]} -eq 0 ]]; then
    notify-send "Waybar Switcher" "No bars found in $BARS_DIR"
    exit 1
fi

# ── Show Rofi menu ────────────────────────────────────────────────────────────
chosen=$(printf '%s\n' "${bars[@]}" | rofi -dmenu \
    -p "Waybar" \
    -mesg "Choose a bar layout" \
    -theme-str 'window {width: 400px;}')

[[ -z "$chosen" ]] && exit 0   # user cancelled

BAR_PATH="$BARS_DIR/$chosen"

# ── Validate required files exist ─────────────────────────────────────────────
missing=()
[[ -f "$BAR_PATH/config" ]]    || missing+=("config")
[[ -f "$BAR_PATH/style.css" ]] || missing+=("style.css")

if [[ ${#missing[@]} -gt 0 ]]; then
    notify-send "Waybar Switcher" \
        "Bar '$chosen' is missing: ${missing[*]}"
    exit 1
fi

# ── Remove old symlinks / files and create new ones ───────────────────────────
for f in config style.css; do
    target="$WAYBAR_DIR/$f"
    # Remove only if it's a symlink; refuse to clobber real files
    if [[ -L "$target" ]]; then
        rm "$target"
    elif [[ -e "$target" ]]; then
        notify-send "Waybar Switcher" \
            "$f exists and is not a symlink — refusing to overwrite. Move or delete it first."
        exit 1
    fi
    ln -s "$BAR_PATH/$f" "$target"
done

# ── Restart Waybar ────────────────────────────────────────────────────────────
pkill -x waybar
sleep 0.3
waybar &
disown

notify-send "Waybar Switcher" "Switched to '$chosen' ✓"
