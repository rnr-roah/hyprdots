#!/bin/bash

# Get selected wallpaper
WALL=$(hellpaper ~/Wallpapers/anime/)

# Copy it to your default location
mkdir -p ~/Wallpapers/default
cp "$WALL" ~/Wallpapers/default/background.png

# Set wallpaper
swaybg -i ~/Wallpapers/default/background.png -m fill & disown
matugen image ~/Wallpapers/default/background.png --source-color-index 0
