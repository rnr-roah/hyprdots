#!/bin/bash

APPDIR="$HOME/.local/share/webapp"
DESKTOPDIR="$HOME/.local/share/applications"

rm -rf "$APPDIR"
mkdir -p "$DESKTOPDIR"

cp -r "../webapp" "$HOME/.local/share/"
chmod +x "$APPDIR/webapp-tool.sh"
cp "$APPDIR/webapps.desktop" "$DESKTOPDIR/webapps.desktop"

echo "All done!"

