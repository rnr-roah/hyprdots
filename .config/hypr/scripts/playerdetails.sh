#!/bin/bash

player=$(playerctl -l 2>/dev/null | head -1)

if [ -z "$player" ]; then
    echo "No media playing"
    exit 0
fi

status=$(playerctl --player="$player" status 2>/dev/null)

if [ "$status" != "Playing" ] && [ "$status" != "Paused" ]; then
    echo "No media playing"
    exit 0
fi

artist=$(playerctl --player="$player" metadata artist 2>/dev/null)
title=$(playerctl --player="$player" metadata title 2>/dev/null)

if [ -n "$artist" ] && [ -n "$title" ]; then
    echo " $artist — $title"
elif [ -n "$title" ]; then
    echo " $title"
else
    echo "No media playing"
fi
