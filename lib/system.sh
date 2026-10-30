#!/usr/bin/env bash

show_cpu() {
  local model cores load i freq governor
  model="$(getprop ro.soc.model 2>/dev/null || getprop ro.hardware 2>/dev/null || uname -m)"
  cores="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo '?')"
  printf '%s: %s\n' "$MSG_SOC" "$model"
  grep -m1 -E '^(Hardware|model name|Processor)' /proc/cpuinfo 2>/dev/null || true
  printf '%s: %s\n' "$MSG_CORES" "$cores"
  if [[ -r /proc/loadavg ]]; then
    read -r load _ < /proc/loadavg
    printf '%s: %s (1 min)\n' "$MSG_LOAD" "$load"
  fi
  printf '\n%s\n' "$MSG_CPU_CORES_DETAIL"
  for d in /sys/devices/system/cpu/cpu[0-9]*; do
    [[ -d "$d" ]] || continue
    i="${d##*cpu}"
    freq="$d/cpufreq"
    if [[ -r "$freq/scaling_cur_freq" ]]; then
      printf '  CPU%-2s %s MHz' "$i" "$(awk '{printf "%.0f",$1/1000}' "$freq/scaling_cur_freq" 2>/dev/null)"
      [[ -r "$freq/scaling_max_freq" ]] && printf ' / max %s MHz' "$(awk '{printf "%.0f",$1/1000}' "$freq/scaling_max_freq" 2>/dev/null)"
      printf '\n'
    else
      printf '  CPU%-2s %s\n' "$i" "$MSG_DATA_UNAVAILABLE"
    fi
  done
  if [[ -r /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]]; then
    governor="$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)"
    printf '%s: %s\n' "$MSG_CPU_GOVERNOR" "$governor"
  fi
}

show_memory() {
  awk -v total="$MSG_MEM_TOTAL" -v available="$MSG_MEM_AVAILABLE" -v free="$MSG_MEM_FREE" -v swap_total="$MSG_SWAP_TOTAL" -v swap_free="$MSG_SWAP_FREE" '
    /MemTotal/ {printf "%-16s %8.0f MB\n",total,$2/1024}
    /MemAvailable/ {printf "%-16s %8.0f MB\n",available,$2/1024}
    /MemFree/ {printf "%-16s %8.0f MB\n",free,$2/1024}
    /SwapTotal/ {printf "%-16s %8.0f MB\n",swap_total,$2/1024}
    /SwapFree/ {printf "%-16s %8.0f MB\n",swap_free,$2/1024}
  ' /proc/meminfo 2>/dev/null
}

show_storage() {
  df -h "$HOME" /storage/emulated/0 2>/dev/null | awk 'NR==1 || !seen[$1]++'
}

battery_json_value() {
  local json="$1" key="$2"
  printf '%s\n' "$json" | awk -v key="$key" '
    {
      needle="\"" key "\""
      pos=index($0, needle)
      if (pos) {
        value=substr($0, pos+length(needle))
        sub(/^[[:space:]]*:[[:space:]]*"?/, "", value)
        sub(/".*$/, "", value)
        sub(/[,}].*$/, "", value)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
        print value
        exit
      }
    }
  '
}

battery_translate() {
  local field="$1" value="$2"
  case "$field:$value" in
    status:CHARGING) printf '%s' "$MSG_BATTERY_CHARGING" ;;
    status:DISCHARGING) printf '%s' "$MSG_BATTERY_DISCHARGING" ;;
    status:NOT_CHARGING) printf '%s' "$MSG_BATTERY_NOT_CHARGING" ;;
    status:FULL) printf '%s' "$MSG_BATTERY_FULL" ;;
    health:GOOD) printf '%s' "$MSG_BATTERY_HEALTH_GOOD" ;;
    health:OVERHEAT) printf '%s' "$MSG_BATTERY_OVERHEAT" ;;
    health:DEAD) printf '%s' "$MSG_BATTERY_HEALTH_DEAD" ;;
    health:OVER_VOLTAGE) printf '%s' "$MSG_BATTERY_OVER_VOLTAGE" ;;
    health:UNSPECIFIED_FAILURE) printf '%s' "$MSG_BATTERY_HEALTH_UNKNOWN" ;;
    plugged:PLUGGED_AC) printf '%s' "$MSG_BATTERY_AC" ;;
    plugged:PLUGGED_USB) printf '%s' "$MSG_BATTERY_USB" ;;
    plugged:PLUGGED_WIRELESS) printf '%s' "$MSG_BATTERY_WIRELESS" ;;
    plugged:PLUGGED_DOCK) printf '%s' "$MSG_BATTERY_DOCK" ;;
    plugged:UNPLUGGED) printf '%s' "$MSG_BATTERY_UNPLUGGED" ;;
    *) printf '%s' "$value" ;;
  esac
}

show_battery() {
  local b=/sys/class/power_supply/battery
  local found=0 f value api_json
  for f in capacity status health temperature voltage_now current_now charge_full charge_full_design; do
    [[ -r "$b/$f" ]] || continue
    found=1
    value="$(cat "$b/$f" 2>/dev/null)"
    case "$f" in
      temperature) [[ "$value" =~ ^[0-9]+$ ]] && value="$(awk -v v="$value" 'BEGIN {printf "%.1f °C",v/10}')" ;;
      voltage_now) [[ "$value" =~ ^[0-9]+$ ]] && value="$(awk -v v="$value" 'BEGIN {printf "%.3f V",v/1000000}')" ;;
      current_now) [[ "$value" =~ ^-?[0-9]+$ ]] && value="$(awk -v v="$value" 'BEGIN {printf "%.0f mA",v/1000}')" ;;
    esac
    printf '%-18s %s\n' "$f" "$value"
  done
  if (( ! found )) && command -v termux-battery-status >/dev/null 2>&1; then
    api_json="$(termux-battery-status 2>/dev/null || true)"
    if [[ -n "$api_json" && "$api_json" != "{}" ]]; then
      local key raw translated label
      for key in percentage status health plugged temperature voltage current technology; do
        raw="$(battery_json_value "$api_json" "$key")"
        [[ -n "$raw" ]] || continue
        case "$key" in
          percentage) label="$MSG_BATTERY_PERCENT"; translated="$raw%" ;;
          status) label="$MSG_BATTERY_STATUS"; translated="$(battery_translate status "$raw")" ;;
          health) label="$MSG_BATTERY_HEALTH"; translated="$(battery_translate health "$raw")" ;;
          plugged) label="$MSG_BATTERY_POWER_SOURCE"; translated="$(battery_translate plugged "$raw")" ;;
          temperature) label="$MSG_BATTERY_TEMPERATURE"; translated="$raw °C" ;;
          voltage) label="$MSG_BATTERY_VOLTAGE"; translated="$raw mV" ;;
          current) label="$MSG_BATTERY_CURRENT"; translated="$raw mA" ;;
          technology) label="$MSG_BATTERY_TECHNOLOGY"; translated="$raw" ;;
        esac
        printf '%-20s %s\n' "$label" "$translated"
      done
    else
      printf '%s\n' "$MSG_BATTERY_API_FAILED"
    fi
  elif (( ! found )); then
    printf '%s\n' "$MSG_DATA_UNAVAILABLE"
    printf '%s\n' "$MSG_BATTERY_API_HINT"
  fi
}

show_display() {
  wm size 2>/dev/null || printf '%s\n' "$MSG_DATA_UNAVAILABLE"
  wm density 2>/dev/null || true
}

show_system() {
  printf '%s: Android %s (SDK %s)\n' "$MSG_PLATFORM" "$(getprop ro.build.version.release)" "$(getprop ro.build.version.sdk)"
  printf '%s: %s %s\n' "$MSG_DEVICE" "$(getprop ro.product.manufacturer)" "$(getprop ro.product.model)"
  printf 'Build: %s\n' "$(getprop ro.build.display.id)"
  printf 'Architecture: %s\n' "$(uname -m)"
  printf 'Kernel: %s\n' "$(uname -srmo)"
  printf '%s: %s\n' "$MSG_UPTIME" "$(uptime -p 2>/dev/null || cat /proc/uptime)"
}

show_gpu() {
  local output
  output="$(dumpsys SurfaceFlinger 2>/dev/null | grep -m3 -E 'GLES|GL_VENDOR|GL_RENDERER' || true)"
  if [[ -n "$output" ]]; then printf '%s\n' "$output"; else printf '%s\n' "$MSG_GPU_RESTRICTED"; fi
}

show_sensors() {
  local found=0 d f
  for d in /sys/bus/iio/devices/iio:device*; do
    [[ -d "$d" ]] || continue
    found=1
    printf '%s: %s\n' "$(basename "$d")" "$(cat "$d/name" 2>/dev/null)"
    for f in "$d"/in*_input; do
      [[ -r "$f" ]] && printf '  %s: %s\n' "$(basename "$f")" "$(cat "$f")"
    done
  done
  if (( ! found )) && command -v termux-sensor >/dev/null 2>&1; then
    printf '%s\n' "$MSG_SENSOR_API_HINT"
    termux-sensor -l 2>/dev/null || printf '%s\n' "$MSG_SENSOR_NONE"
  elif (( ! found )); then
    printf '%s\n' "$MSG_SENSOR_NONE"
    printf '%s\n' "$MSG_SENSOR_API_HINT"
  fi
}

show_network() {
  local iface
  printf '%s\n' "$MSG_NETWORK_INTERFACES"
  ip -brief address 2>/dev/null || ifconfig 2>/dev/null || printf '%s\n' "$MSG_NETWORK_RESTRICTED"
  printf '\n'
  ip route 2>/dev/null | head -8 || true
  printf 'DNS: %s %s\n' "$(getprop net.dns1)" "$(getprop net.dns2)"
  iface="$(ip route 2>/dev/null | awk '/default/ {print $5; exit}')"
  if [[ -n "$iface" && -r "/sys/class/net/$iface/operstate" ]]; then
    printf 'Interface state: %s\n' "$(cat "/sys/class/net/$iface/operstate" 2>/dev/null)"
  fi
}

diagnostics() {
  printf 'Kernel: %s\n' "$(uname -r)"
  for x in getprop df awk grep ip curl; do
    command -v "$x" >/dev/null 2>&1 && printf '[OK] %s\n' "$x" || printf '[--] %s %s\n' "$x" "$MSG_NOT_INSTALLED"
  done
  for x in termux-battery-status termux-sensor; do
    command -v "$x" >/dev/null 2>&1 && printf '[OK] %s\n' "$x" || printf '[--] %s %s\n' "$x" "$MSG_OPTIONAL"
  done
  for x in /sys/class/power_supply/battery /sys/devices/system/cpu /sys/bus/iio/devices; do
    [[ -r "$x" ]] && printf '[OK] %s\n' "$x" || printf '[--] %s\n' "$x"
  done
}
