#!/usr/bin/env bash
# Add this to the top of your update_check.sh
echo "$(date): Script triggered" >> /tmp/update_check.log #this is to check how many times the script has been triggered use this to check: tail -f /tmp/update_check.log
#Sync AUR metadata silently

#yay -Sy --aur --noconfirm --color=never >/dev/null  2>&1
#PACMAN_COUNT=$(pacman -Qu 2>/dev/null | wc -l || echo 0)
#sudo pacman -S pacman-contrib to install checkupdates

PACMAN_COUNT=$(checkupdates 2>/dev/null | wc -l || echo 0)
AUR_COUNT=$(yay -Qua --noconfirm --color=never 2>/dev/null | wc -l || echo 0)
TOTAL=$((PACMAN_COUNT + AUR_COUNT))

if [ "$TOTAL" -eq 0 ]; then
    ICON="󰏗"   # check / calm icon
    TEXT=""
    TOOLTIP="Available Updates: 0\n✔ System is up to date\n󰣇 Pacman: 0\n󰏗 AUR (yay): 0"
else
    ICON="󰏗"   # update icon
    #TEXT="$ICON $TOTAL"
    TEXT="$ICON"
    TOOLTIP="Available Updates: $TOTAL\n󰣇 Pacman: $PACMAN_COUNT\n󰏗 AUR: $AUR_COUNT"
fi

echo "{\"text\":\"$TEXT\",\"tooltip\":\"$TOOLTIP\"}"

