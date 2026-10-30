#!/usr/bin/env bash

main_menu() {
  local choice
  while true; do
    render_dashboard
    read -r -p "  $MSG_PROMPT > " choice || break
    case "$choice" in
      1) section "$MSG_OVERVIEW" show_overview ;;
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
      *) printf '\n  \033[1;31m[!] %s\033[0m\n' "$MSG_INVALID"; sleep 1 ;;
    esac
  done
}

render_dashboard() {
  local width
  clear 2>/dev/null || true
  width="$(ui_width)"
  if (( width >= 68 )); then
    printf '\033[1;32m'
    printf '  ████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗\n'
    printf '  ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝\n'
    printf '     ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝ \n'
    printf '     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗ \n'
    printf '     ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗\n'
    printf '     ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝\n'
    printf '\033[0m'
  fi
  ui_header "HARDWARE CONTROL CENTER v$APP_VERSION"
  printf '\033[1;32m  [*]\033[0m %s\n' "$MSG_SUBTITLE"
  printf '\033[1;32m  [*]\033[0m %s: \033[1;37m%s\033[0m\n' "$MSG_DEVICE" "$(device_summary)"
  printf '\033[1;32m  [*]\033[0m %s\n' "$(system_summary)"
  ui_rule
  dashboard_metric "$MSG_CPU" "$(cpu_summary)" "$(cpu_percent)" 32
  dashboard_metric "$MSG_MEMORY" "$(memory_summary)" "$(memory_percent)" 36
  dashboard_metric "$MSG_BATTERY" "$(battery_summary)" "$(battery_percent)" 33
  dashboard_metric "$MSG_STORAGE" "$(storage_summary)" "$(storage_percent)" 35
  ui_rule
  printf '\033[1;32m  [ MODULES ]\033[0m\n'
  render_menu_items
  ui_footer "[0] $MSG_EXIT  [R] $MSG_REFRESH"
}

render_menu_items() {
  local width
  width="$(ui_width)"
  if (( width >= 64 )); then
    printf '  \033[1;32m01\033[0m %-16s  \033[1;32m02\033[0m %s\n' "$MSG_OVERVIEW" "$MSG_CPU"
    printf '  \033[1;32m03\033[0m %-16s  \033[1;32m04\033[0m %s\n' "$MSG_GPU" "$MSG_MEMORY"
    printf '  \033[1;32m05\033[0m %-16s  \033[1;32m06\033[0m %s\n' "$MSG_STORAGE" "$MSG_BATTERY"
    printf '  \033[1;32m07\033[0m %-16s  \033[1;32m08\033[0m %s\n' "$MSG_DISPLAY" "$MSG_SYSTEM"
    printf '  \033[1;32m09\033[0m %-16s  \033[1;32m10\033[0m %s\n' "$MSG_SENSORS" "$MSG_NETWORK"
    printf '  \033[1;32m11\033[0m %-16s  \033[1;32m12\033[0m %s\n' "$MSG_DIAG" "$MSG_SETTINGS"
  else
    printf '  \033[1;32m01\033[0m %s\n  \033[1;32m02\033[0m %s\n  \033[1;32m03\033[0m %s\n  \033[1;32m04\033[0m %s\n  \033[1;32m05\033[0m %s\n  \033[1;32m06\033[0m %s\n' "$MSG_OVERVIEW" "$MSG_CPU" "$MSG_GPU" "$MSG_MEMORY" "$MSG_STORAGE" "$MSG_BATTERY"
    printf '  \033[1;32m07\033[0m %s\n  \033[1;32m08\033[0m %s\n  \033[1;32m09\033[0m %s\n  \033[1;32m10\033[0m %s\n  \033[1;32m11\033[0m %s\n  \033[1;32m12\033[0m %s\n' "$MSG_DISPLAY" "$MSG_SYSTEM" "$MSG_SENSORS" "$MSG_NETWORK" "$MSG_DIAG" "$MSG_SETTINGS"
  fi
}

dashboard_metric() {
  local label="$1" summary="$2" percent="$3" color="$4"
  local width bar filled empty fill emptybar
  width="$(ui_width)"
  [[ "$percent" =~ ^[0-9]+$ ]] || percent=0
  (( percent > 100 )) && percent=100
  if (( width < 48 )); then
    printf '\033[1;32m  ▸ %-8.8s\033[0m %3s%%\n' "$label" "$percent"
    printf '    \033[1;37m%s\033[0m\n' "$summary"
    return
  fi
  bar=$((width-48))
  (( bar < 3 )) && bar=3
  (( bar > 18 )) && bar=18
  filled=$((percent*bar/100))
  empty=$((bar-filled))
  printf -v fill '%*s' "$filled" ''
  fill="${fill// /█}"
  printf -v emptybar '%*s' "$empty" ''
  emptybar="${emptybar// /░}"
  printf '\033[1;32m  ▸\033[0m %-9.9s \033[1;37m%-17.17s\033[0m \033[1;%sm%s%s\033[0m %3s%%\n' "$label" "$summary" "$color" "$fill" "$emptybar" "$percent"
}

settings_menu() {
  local choice
  while true; do
    title "$MSG_SETTINGS"
    printf '  \033[1;32m[1]\033[0m Tiếng Việt\n  \033[1;32m[2]\033[0m English\n  \033[1;32m[0]\033[0m %s\n' "$MSG_BACK"
    read -r -p "  $MSG_PROMPT > " choice || return
    case "$choice" in
      1) printf 'vi\n' > "$CONFIG/lang"; source "$ROOT/locales/vi.sh"; break ;;
      2) printf 'en\n' > "$CONFIG/lang"; source "$ROOT/locales/en.sh"; break ;;
      0|q|Q|'') break ;;
      *) printf '  %s\n' "$MSG_INVALID"; sleep 1 ;;
    esac
  done
}

show_overview() {
  show_system
  printf '\n'
  show_cpu
  printf '\n'
  show_memory
  printf '\n'
  show_storage
  printf '\n'
  show_battery
}

cpu_summary() {
  local cores model
  cores="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo '?')"
  model="$(getprop ro.soc.model 2>/dev/null || getprop ro.hardware 2>/dev/null || uname -m)"
  printf '%s · %s cores' "${model:0:16}" "$cores"
}

cpu_percent() {
  local load cores
  cores="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
  load="$(awk -v cores="$cores" 'BEGIN { if (cores < 1) cores=1 } { print int(($1/cores)*100) }' /proc/loadavg 2>/dev/null || echo 0)"
  (( load > 100 )) && load=100
  printf '%s' "$load"
}

memory_summary() {
  awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {if(t) printf "%.0f/%.0f MB", (t-a)/1024,t/1024; else print "N/A"}' /proc/meminfo 2>/dev/null
}

memory_percent() {
  awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {if(t) printf "%d",((t-a)*100/t); else print 0}' /proc/meminfo 2>/dev/null
}

battery_summary() {
  local b=/sys/class/power_supply/battery json percentage status
  if [[ -r "$b/capacity" ]]; then
    printf '%s%% · %s' "$(cat "$b/capacity")" "$(cat "$b/status" 2>/dev/null || echo unknown)"
    return
  fi
  if command -v termux-battery-status >/dev/null 2>&1; then
    json="$(termux-battery-status 2>/dev/null || true)"
    percentage="$(battery_json_value "$json" percentage)"
    status="$(battery_json_value "$json" status)"
    if [[ "$percentage" =~ ^[0-9]+$ ]]; then
      printf '%s%% · %s' "$percentage" "${status:-unknown}"
      return
    fi
  fi
  printf '%s' "N/A"
}

battery_percent() {
  local value
  if [[ -r /sys/class/power_supply/battery/capacity ]]; then
    cat /sys/class/power_supply/battery/capacity
  elif command -v termux-battery-status >/dev/null 2>&1; then
    value="$(battery_json_value "$(termux-battery-status 2>/dev/null || true)" percentage)"
    [[ "$value" =~ ^[0-9]+$ ]] && printf '%s\n' "$value" || printf '0\n'
  else
    printf '0\n'
  fi
}
storage_summary() { df -h "$HOME" 2>/dev/null | awk 'NR==2 {printf "%s/%s", $3,$2}'; }
storage_percent() { df "$HOME" 2>/dev/null | awk 'NR==2 {gsub(/%/,"",$5); print $5+0}'; }

device_summary() {
  local maker model
  maker="$(getprop ro.product.manufacturer 2>/dev/null)"
  model="$(getprop ro.product.model 2>/dev/null)"
  printf '%s %s' "${maker:-Android}" "${model:-device}"
}

system_summary() {
  printf 'Android %s · %s' "$(getprop ro.build.version.release 2>/dev/null || echo '?')" "$(uname -r)"
}
