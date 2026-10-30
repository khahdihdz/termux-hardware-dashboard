#!/usr/bin/env bash

show_cpu() {
  printf '%s: %s\n' "$MSG_SOC" "$(getprop ro.soc.model 2>/dev/null || getprop ro.hardware 2>/dev/null || uname -m)"
  grep -m1 -E '^(Hardware|model name|Processor)' /proc/cpuinfo 2>/dev/null || true
  printf '%s: %s\n' "$MSG_CORES" "$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo '?')"
  for f in /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq; do
    [[ -r "$f" ]] && printf '%s: %s kHz\n' "$(basename "$f")" "$(cat "$f")"
  done
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

show_storage() { df -h "$HOME" /storage/emulated/0 2>/dev/null | awk 'NR==1 || !seen[$1]++'; }

show_battery() {
  local b=/sys/class/power_supply/battery
  for f in capacity status health temperature voltage_now current_now; do
    [[ -r "$b/$f" ]] && printf '%-14s %s\n' "$f" "$(cat "$b/$f")"
  done
  [[ -r "$b/capacity" ]] || printf '%s\n' "$MSG_DATA_UNAVAILABLE"
}

show_display() { wm size 2>/dev/null || printf '%s\n' "$MSG_DATA_UNAVAILABLE"; wm density 2>/dev/null || true; }

show_system() {
  printf '%s: Android %s (SDK %s)\n' "$MSG_PLATFORM" "$(getprop ro.build.version.release)" "$(getprop ro.build.version.sdk)"
  printf '%s: %s %s\n' "$MSG_DEVICE" "$(getprop ro.product.manufacturer)" "$(getprop ro.product.model)"
  printf 'Kernel: %s\n' "$(uname -srmo)"
  printf '%s: %s\n' "$MSG_UPTIME" "$(uptime -p 2>/dev/null || cat /proc/uptime)"
}

show_gpu() { dumpsys SurfaceFlinger 2>/dev/null | grep -m2 -E 'GLES|GL_VENDOR|GL_RENDERER' || printf '%s\n' "$MSG_GPU_RESTRICTED"; }

show_sensors() {
  local found=0
  for d in /sys/bus/iio/devices/iio:device*; do
    [[ -d "$d" ]] || continue
    found=1
    printf '%s: %s\n' "$(basename "$d")" "$(cat "$d/name" 2>/dev/null)"
    for f in "$d"/in*_input; do
      [[ -r "$f" ]] && printf '  %s: %s\n' "$(basename "$f")" "$(cat "$f")"
    done
  done
  (( found )) || printf '%s\n' "$MSG_SENSOR_NONE"
}

show_network() {
  ip -brief address 2>/dev/null || printf '%s\n' "$MSG_NETWORK_RESTRICTED"
  ip route 2>/dev/null | head -8 || true
  printf 'DNS: %s %s\n' "$(getprop net.dns1)" "$(getprop net.dns2)"
}

diagnostics() {
  printf 'Kernel: %s\n' "$(uname -r)"
  for x in getprop df awk grep ip curl; do
    command -v "$x" >/dev/null 2>&1 && printf '[OK] %s\n' "$x" || printf '[--] %s %s\n' "$x" "$MSG_NOT_INSTALLED"
  done
  for x in /sys/class/power_supply/battery /sys/devices/system/cpu /sys/bus/iio/devices; do
    [[ -r "$x" ]] && printf '[OK] %s\n' "$x" || printf '[--] %s\n' "$x"
  done
}
