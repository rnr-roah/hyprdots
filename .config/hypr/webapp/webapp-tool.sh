#!/bin/bash

ICON_DIR="$HOME/.local/share/icons"
DESKTOP_DIR="$HOME/.local/share/applications"
PROFILE_DIR="$HOME/.local/share/webapps-profiles"

mkdir -p "$ICON_DIR" "$DESKTOP_DIR" "$PROFILE_DIR"

clear
echo "======================================="
echo "       WebApp CLI Tool (Chromium only)"
echo "======================================="
echo "1) Create a WebApp"
echo "2) Uninstall a WebApp"
echo "3) Exit"
echo "======================================="
read -p "Select an option (1‑3): " OPTION

###############################################################
# CREATE WEBAPP
###############################################################
if [ "$OPTION" = "1" ]; then
    echo "===== Create WebApp ====="

    read -p "Enter App Name (e.g., ChatGPT): " NAME
    APPID=$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

    read -p "Enter App URL (e.g., https://chat.openai.com): " URL

    echo "Icon options:"
    echo "1) Auto‑download favicon"
    echo "2) Use custom PNG file"
    read -p "Select (1‑2): " ICON_CHOICE

    ICON_PATH="$ICON_DIR/$APPID.png"

    if [ "$ICON_CHOICE" = "1" ]; then
        echo "Downloading favicon..."
        wget -q -O "$ICON_PATH" "$URL/favicon.ico" ||
        wget -q -O "$ICON_PATH" "$URL/favicon.png" ||
        wget -q -O "$ICON_PATH" "$URL/favicon-32x32.png" ||
        echo "Failed to fetch favicon. You may replace icon later."
    else
        read -p "Enter full path to PNG icon: " CUSTOM_ICON
        cp "$CUSTOM_ICON" "$ICON_PATH"
    fi

    echo ""
    echo "===== Confirm WebApp ====="
    echo "Name:     $NAME"
    echo "App ID:   $APPID"
    echo "URL:      $URL"
    echo "Icon:     $ICON_PATH"
    echo ""
    read -p "Create this WebApp? (y/n): " CONFIRM

    if [[ "$CONFIRM" != "y" ]]; then
        echo "Cancelled."
        exit 0
    fi

    APP_PROFILE="$PROFILE_DIR/$APPID"
    mkdir -p "$APP_PROFILE"

    # CREATE DESKTOP FILE
    DESKTOP_FILE="$DESKTOP_DIR/$APPID.desktop"

    # Set window size (you can adjust width,height as desired)
    WIDTH=900
    HEIGHT=700

    # Use Chromium in app mode: no tabs, minimal UI. :contentReference[oaicite:1]{index=1}
    CMD="chromium --app=$URL --user-data-dir=$APP_PROFILE --window-size=$WIDTH,$HEIGHT --class=$APPID"

    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=$NAME
Exec=$CMD
Icon=$ICON_PATH
Terminal=false
Categories=Network;
EOF

    chmod +x "$DESKTOP_FILE"

    echo ""
    echo "======================================="
    echo " WebApp '$NAME' created successfully!"
    echo "======================================="

    exit 0
fi

###############################################################
# UNINSTALL WEBAPP
###############################################################
if [ "$OPTION" = "2" ]; then
    echo "===== Uninstall WebApp ====="
    read -p "Enter App ID to remove (e.g., whatsapp, chatgpt): " APPID

    APP_PROFILE="$PROFILE_DIR/$APPID"
    DESKTOP_FILE="$DESKTOP_DIR/$APPID.desktop"
    ICON_PATH="$ICON_DIR/$APPID.png"

    echo ""
    echo "You are about to delete:"
    echo "- $APP_PROFILE"
    echo "- $DESKTOP_FILE"
    echo "- $ICON_PATH"
    echo ""
    read -p "Are you sure? (y/n): " OK

    if [[ "$OK" != "y" ]]; then
        echo "Cancelled."
        exit 0
    fi

    rm -rf "$APP_PROFILE"
    rm -f "$DESKTOP_FILE"
    rm -f "$ICON_PATH"

    echo ""
    echo "======================================="
    echo " WebApp '$APPID' uninstalled!"
    echo "======================================="

    exit 0
fi

###############################################################
# EXIT
###############################################################
if [ "$OPTION" = "3" ]; then
    echo "Exiting..."
    exit 0
fi

echo "Invalid option!"
exit 1

