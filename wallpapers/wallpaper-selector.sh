# #!/bin/bash
# 
# WALLDIR="$HOME/Wallpapers"
# 
# # Choose with wofi
# chosen="$(ls "$WALLDIR" | rofi -dmenu -i -p 'Choose thy wallpaper:')"
# 
# if [ -n "$chosen" ]; then
#    swaybg -i "$WALLDIR/$chosen" -m fill
# fi
#!/bin/bash

#!/bin/bash

WALLDIR="$HOME/Wallpapers"

# Kill any old preview
pkill -f "imv.*preview-wall"

# Spawn an empty preview window
PREVIEW_IMG="$(ls "$WALLDIR"/* | head -n 1)"
imv --title preview-wall "$PREVIEW_IMG" &

sleep 0.2  # give the preview time to appear

# Move preview to the side (Hyprland magic)
hyprctl dispatch movewindowpixel 900 200, title:preview-wall
hyprctl dispatch resizewindowpixel 600 350, title:preview-wall

# Rofi selection
chosen="$(ls "$WALLDIR" | rofi -dmenu -i -p 'Choose thy wallpaper:')"

if [ -n "$chosen" ]; then
    # Show the chosen image in preview
    pkill -f "imv.*preview-wall"
    imv --title preview-wall "$WALLDIR/$chosen" &

    swaybg -i "$WALLDIR/$chosen" -m fill
fi

# Close preview after choosing
sleep 0.5
pkill -f "imv.*preview-wall"
