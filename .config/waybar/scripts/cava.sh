#!/bin/bash
readonly CAVA_FIFO="/tmp/waybar-cava-pulse"
[ -p "$CAVA_FIFO" ] || mkfifo "$CAVA_FIFO"

cava -p ~/.config/cava/waybar > "$CAVA_FIFO" &

get_char() {
  local avg=$1
  if   [ "$avg" -ge 800 ]; then echo "◆"
  elif [ "$avg" -ge 500 ]; then echo "▪"
  elif [ "$avg" -ge 200 ]; then echo "▫"
  elif [ "$avg" -ge 50  ]; then echo "·"
  else echo " "
  fi
}

while IFS= read -r line; do
  IFS=';' read -ra values <<< "$line"
  clean=()
  for val in "${values[@]}"; do
    val="${val//[^0-9]/}"
    [ -n "$val" ] && clean+=("$val")
  done

  count=${#clean[@]}
  [ "$count" -eq 0 ] && echo "· · ·" && continue

  # Split into 3 groups and average each
  third=$((count / 3))
  [ "$third" -eq 0 ] && third=1

  t1=0; t2=0; t3=0; c1=0; c2=0; c3=0
  for ((i=0; i<count; i++)); do
    if   [ "$i" -lt "$third" ];         then t1=$((t1+clean[i])); c1=$((c1+1))
    elif [ "$i" -lt $((third*2)) ];     then t2=$((t2+clean[i])); c2=$((c2+1))
    else                                     t3=$((t3+clean[i])); c3=$((c3+1))
    fi
  done

  [ "$c1" -gt 0 ] && a1=$((t1/c1)) || a1=0
  [ "$c2" -gt 0 ] && a2=$((t2/c2)) || a2=0
  [ "$c3" -gt 0 ] && a3=$((t3/c3)) || a3=0

  echo "$(get_char $a1) $(get_char $a2) $(get_char $a3)"
done < "$CAVA_FIFO"
