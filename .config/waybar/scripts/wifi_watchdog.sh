#!/bin/bash
# this is just for university wifi cause it keeps on disconnecting...kind of
IFACE=$(nmcli -t -f DEVICE,TYPE device | grep wifi | cut -d: -f1 | head -1)

while true; do
  if ! ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
    nmcli device disconnect "$IFACE"
    nmcli device connect "$IFACE"
  fi
  sleep 15
done
