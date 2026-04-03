#!/usr/bin/env bash
STATE_FILE="/tmp/battery_charge_state"

BAT="BAT0"
CHECK_INTERVAL=1
COOLDOWN=300

LOW=25
WARN=15
CRIT=8
HIBERNATE=5

LAST_ALERT="/tmp/battery_last_alert"

now() { date +%s; }

can_alert() {
  last=$(cat "$LAST_ALERT" 2>/dev/null || echo 0)
  (( $(now) - last > COOLDOWN ))
}

mark_alert() {
  echo "$(now)" > "$LAST_ALERT"
}

while true; do
  INFO=$(upower -i /org/freedesktop/UPower/devices/battery_$BAT)
  PERCENT=$(echo "$INFO" | awk '/percentage/ {print int($2)}')
  STATE=$(echo "$INFO" | awk '/state/ {print $2}')
  # ---- Plug / Unplug ----
# ---- Plug / Unplug (edge-triggered, once only) ----

LAST_STATE=$(cat "$STATE_FILE" 2>/dev/null)

if [[ "$STATE" != "$LAST_STATE" ]]; then
  if [[ "$STATE" == "charging" ]]; then
    notify-send "🔌 Power Connected" "Electrons return. Charging: $PERCENT %"
    #canberra-gtk-play -i power-plug
    paplay --volume=40000 /usr/share/sounds/freedesktop/stereo/power-plug.oga
  elif [[ "$STATE" == "discharging" ]]; then
    notify-send "🔋 Power Disconnected" "You walk alone  at $PERCENT% "
    #canberra-gtk-play -i power-unplug
    paplay --volume=40000 /usr/share/sounds/freedesktop/stereo/power-unplug.oga
  fi

  echo "$STATE" > "$STATE_FILE"
fi
 
  # ---- Battery levels ----
  if [[ "$STATE" == "discharging" ]] && can_alert; then
    if (( PERCENT <= HIBERNATE )); then
      notify-send -u critical "☠️ Battery Critical" "$PERCENT% — forced sleep."
      #canberra-gtk-play -i suspend-error
      paplay --volume=40000 /usr/share/sounds/freedesktop/stereo/suspend-error.oga
      systemctl hibernate

    elif (( PERCENT <= CRIT )); then
      notify-send -u critical "☠️ Battery Critical" "$PERCENT% — this is the end."
      #canberra-gtk-play -i suspend-error
      paplay --volume=40000 /usr/share/sounds/freedesktop/stereo/suspend-error.oga
      mark_alert

    elif (( PERCENT <= WARN )); then
      notify-send -u critical "⚠️ Battery Low" "$PERCENT% — plug in now."
      #canberra-gtk-play -i dialog-warning
      paplay --volume=40000 /usr/share/sounds/freedesktop/stereo/dialog-warning.oga
      mark_alert

    elif (( PERCENT <= LOW )); then
      notify-send "🔋 Battery" "$PERCENT% — still breathing."
      #canberra-gtk-play -i dialog-information
      paplay --volume=40000 /usr/share/sounds/freedesktop/stereo/dialog-information.oga
      mark_alert
    fi
  fi

  sleep "$CHECK_INTERVAL"
done

