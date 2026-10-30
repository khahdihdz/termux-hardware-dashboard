#!/usr/bin/env bash

# Terminal dashboard menu. Layout adapts to narrow Android terminals.
main_menu() {
  while true; do
    render_dashboard
    printf '\n'
    printf '  \033[1;36m┌────────────────────────────── MENU ──────────────────────────────┐\033[0m\n'
    printf '  \033[1;36m│\033[0m  \033[1;37m[1]\033[0m %-27s  \033[1;37m[2]\033[0m %-27s \033[1;36m│\033[0m\n' "$MSG_OVERVIEW" "$MSG_CPU"
    printf '  \033[1;36m│\033[0m  \033[1;37m[3]\033[0m %-27s  \033[1;37m[4]\033[0m %-27s \033[1;36m│\033[0m\n' "$MSG_GPU" "$MSG_MEMORY"
    printf '  \033[1;36m│\033[0m  \033[1;37m[5]\033[0m %-27s  \033[1;37m[6]\033[0m %-27s \033[1;36m│\033[0m\n' "$MSG_STORAGE" "$MSG_BATTERY"
    printf '  \033[1;36m│\033[0m  \033[1;37m[7]\033[0m %-27s  \033[1;37m[8]\033[0m %-27s \033[1;36m│\033[0m\n' "$MSG_DISPLAY" "$MSG_SYSTEM"
    printf '  \033[1;36m│\033[0m  \033[1;37m[9]\033[0m %-27s  \033[1;37m[10]\033[0m %-26s \033[1;36m│\033[0m\n' "$MSG_SENSORS" "$MSG_NETWORK"
    printf '  \033[1;36m│\033[0m  \033[1;37m[11]\033[0m %-26s  \033[1;37m[12]\033[0m %-26s \033[1;36m│\033[0m\n' "$MSG_DIAG" "$MSG_SETTINGS"
    printf '  \033[1;36m└──────────────────────────────────────────────────────────────────┘\033[0m\n'
    printf '  \033[2m[0] %s   •   [R] %s\033[0m\n' "$MSG_EXIT" "$MSG_REFRESH"
    read -r -p "  $MSG_CHOICE " c
    case "$c" in
      1) title "$MSG_OVERVIEW"; show_system; show_cpu; show_memory; show_storage; show_battery; pause ;;
      2) section "$MSG_CPU" show_cpu ;;
      3) section "$MSG_GPU" show_gpu ;;
      4) section "$MSG_MEMORY" show_memory ;;
      5) section "$MSG_STORAGE" show_storage ;;
      6) section "$MSG_BATTERY" show_battery ;;
      7) section "$MSG_DISPLAY" show_display ;;
      8) section "$MSG_SYSTEM" show_system ;;
      9) section "$MSG_SENSORS" show_sensors ;;
      10) section "$MSG_NETWORK" show_network ;;
      11) section "$MSG_DIAG" diagnostics ;;
      12) settings_menu ;;
      0|q|Q) break ;;
      r|R|'') continue ;;
      *) printf '\n  %s\n' "$MSG_INVALID"; sleep 1 ;;
    esac
  done
}

settings_menu() {
  title "$MSG_SETTINGS"
  printf '  [1] Tiếng Việt\n  [2] English\n  [0] Back\n'
  read -r -p "$MSG_CHOICE " c
  case "$c" in
    1) echo vi > "$HOME/.config/termux-hardware-dashboard/lang" ;;
    2) echo en > "$HOME/.config/termux-hardware-dashboard/lang" ;;
  esac
}

render_dashboard() {
  clear 2>/dev/null || true
  local width
  width="$(tput cols 2>/dev/null || echo 80)"
  (( width > 76 )) && width=76
  (( width < 40 )) && width=40
  local line
  printf -v line '%*s' "$((width-4))" ''
  line="${line// /─}"
  printf '\033[1;36m  ╭%s╮\033[0m\n' "$line"
  printf '\033[1;36m  │\033[0m  \033[1;37m%-*s\033[0m\033[1;36m│\033[0m\n' "$((width-4))" "⌁  TERMUX HARDWARE DASHBOARD  v$APP_VERSION"
  printf '\033[1;36m  │\033[0m  \033[2m%-*s\033[0m\033[1;36m│\033[0m\n' "$((width-4))" "$MSG_SUBTITLE"
  printf '\033[1;36m  ├%s┤\033[0m\n' "$line"
  dashboard_metric "$MSG_CPU" "$(cpu_summary)" "$(cpu_percent)" "cyan"
  dashboard_metric "$MSG_MEMORY" "$(memory_summary)" "$(memory_percent)" "green"
  dashboard_metric "$MSG_BATTERY" "$(battery_summary)" "$(battery_percent)" "yellow"
  dashboard_metric "$MSG_STORAGE" "$(storage_summary)" "$(storage_percent)" "magenta"
  printf '\033[1;36m  ├%s┤\033[0m\n' "$line"
  printf '\033[1;36m  │\033[0m  \033[1;37m%s\033[0m: %s\033[1;36m│\033[0m\n' "$MSG_DEVICE" "$(device_summary)"
  printf '\033[1;36m  │\033[0m  \033[2m%s\033[0m\033[1;36m│\033[0m\n' "$(system_summary)"
  printf '\033[1;36m  ╰%s╯\033[0m\n' "$line"
}

dashboard_metric() {
  local label="$1" summary="$2" percent="$3" color="$4"
  local width bar filled empty color_code
  case "$color" in
    cyan) color_code=36 ;;
    green) color_code=32 ;;
    yellow) color_code=33 ;;
    magenta) color_code=35 ;;
    *) color_code=37 ;;
  esac
  width="$(tput cols 2>/dev/null || echo 80)"
  (( width > 76 )) && width=76
  (( width < 40 )) && width=40
  bar=$((width-34))
  (( bar < 6 )) && bar=6
  (( bar > 32 )) && bar=32
  [[ "$percent" =~ ^[0-9]+$ ]] || percent=0
  (( percent > 100 )) && percent=100
  filled=$((percent*bar/100)); empty=$((bar-filled))
  printf -v _fill '%*s' "$filled" ''; _fill="${_fill// /█}"
  printf -v _empty '%*s' "$empty" ''; _empty="${_empty// /░}"
  printf '\033[1;36m  │\033[0m  \033[1;37m%-9s\033[0m %-*s \033[1;%sm%s%s\033[0m %3s%% \033[1;36m│\033[0m\n' "$label" 15 "$summary" "$color_code" "$_fill" "$_empty" "$percent"
}

cpu_summary() {
  local cores model
  cores="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo '?')"
  model="$(getprop ro.soc.model 2>/dev/null || getprop ro.hardware 2>/dev/null || uname -m)"
  printf '%s · %s cores' "${model:0:18}" "$cores"
}
cpu_percent() {
  local load cores
  cores="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
  load="$(awk -v cores="$cores" 'BEGIN { if (cores < 1) cores=1 } { print int(($1/cores)*100) }' /proc/loadavg 2>/dev/null || echo 0)"
  (( load > 100 )) && load=100
  echo "$load"
}
memory_summary() {
  awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {if(t) printf "%.0f / %.0f MB", (t-a)/1024,t/1024; else print "N/A"}' /proc/meminfo 2>/dev/null
}
memory_percent() {
  awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {if(t) printf "%d",((t-a)*100/t); else print 0}' /proc/meminfo 2>/dev/null
}
battery_summary() {
  local b=/sys/class/power_supply/battery
  if [[ -r "$b/capacity" ]]; then printf '%s%% · %s' "$(cat "$b/capacity")" "$(cat "$b/status" 2>/dev/null || echo unknown)"
  else echo "N/A"; fi
}
battery_percent() { cat /sys/class/power_supply/battery/capacity 2>/dev/null || echo 0; }
storage_summary() {
  df -h "$HOME" 2>/dev/null | awk 'NR==2 {printf "%s / %s", $3,$2}'
}
storage_percent() {
  df "$HOME" 2>/dev/null | awk 'NR==2 {gsub(/%/,"",$5); print $5+0}'
}
device_summary() {
  local maker model
  maker="$(getprop ro.product.manufacturer 2>/dev/null)"
  model="$(getprop ro.product.model 2>/dev/null)"
  printf '%s %s' "${maker:-Android}" "${model:-device}"
}
system_summary() {
  printf 'Android %s  •  Kernel %s  •  %s' "$(getprop ro.build.version.release 2>/dev/null || echo '?')" "$(uname -r)" "$(date '+%H:%M:%S %d-%m-%Y' 2>/dev/null)"
}
