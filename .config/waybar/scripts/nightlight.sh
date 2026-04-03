#!/bin/bash

if pgrep -x sunsetr >/dev/null; then
    pkill sunsetr
    notify-send "🌞 sunsetr" "The night has lifted. Colors breathe again."
    #swayosd-client --custom-message="The night has lifted. Colors breathe again." --custom-icon=process-stop
else
    sunsetr -b &
    notify-send "🌙 sunsetr" "Dusk has arrived. Blue light bows."
    #swayosd-client --custom-message="Dusk has arriveds. Blue light bows." --custom-icon=process-stop
fi

