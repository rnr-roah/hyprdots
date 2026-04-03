#!/bin/bash

INPUT="$HOME/.config/hypr/modules/keybinds.conf"
TEMPFILE="/tmp/hyprkeys_preview.txt"

# Extract bind lines
BINDS=$(grep -E '^\s*bind' "$INPUT" | sed -E 's/^\s*bind\s*=\s*//')

# Rofi category menu
CHOICE=$(printf "Applications\nWorkspaces\nWindow Control\nPyprland\nMedia Keys\nFunction Keys\nAll\n" | rofi -dmenu -p "Hyprland Keybinds")

format_output () {
    echo "HYPRLAND KEYBINDS - $1" > "$TEMPFILE"
    echo "Generated: $(date)" >> "$TEMPFILE"
    echo "==============================================================" >> "$TEMPFILE"
    printf "%-20s %-10s %-40s\n" "MODIFIERS" "KEY" "ACTION" >> "$TEMPFILE"
    echo "--------------------------------------------------------------" >> "$TEMPFILE"

    echo "$2" | while IFS=',' read -r mods key action
    do
        mods=$(echo "$mods" | xargs)
        key=$(echo "$key" | xargs)
        action=$(echo "$action" | xargs)
        mods=${mods//\$mainMod/SUPER}
        printf "%-20s %-10s %-40s\n" "$mods" "$key" "$action"
    done >> "$TEMPFILE"
}

case "$CHOICE" in
    "Applications")
        format_output "Applications" "$(echo "$BINDS" | grep -E ',[[:space:]]*exec')"
        ;;
    "Workspaces")
        format_output "Workspaces" "$(echo "$BINDS" | grep -E 'workspace|movetoworkspace|,[[:space:]]*[0-9]+')"
        ;;
    "Window Control")
        format_output "Window Control" "$(echo "$BINDS" | grep -E 'killactive|fullscreen|togglefloating|pin|resize|move')"
        ;;
    "Pyprland")
        format_output "Pyprland" "$(echo "$BINDS" | grep -E 'pypr')"
        ;;
    "Media Keys")
        format_output "Media Keys" "$(echo "$BINDS" | grep -E 'XF86')"
        ;;
    "Function Keys")
        format_output "Function Keys" "$(echo "$BINDS" | grep -E ',[[:space:]]*F[0-9]+')"
        ;;
    "All")
        format_output "All Keybinds" "$BINDS"
        ;;
    *)
        exit 0
        ;;
esac

# Open in Alacritty
alacritty --title hyprkeys -e sh -c "less $TEMPFILE; exit"
