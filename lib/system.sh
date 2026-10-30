#!/usr/bin/env bash
show_cpu(){ echo "SoC: $(getprop ro.soc.model 2>/dev/null || getprop ro.hardware 2>/dev/null || uname -m)"; grep -m1 -E '^(Hardware|model name|Processor)' /proc/cpuinfo 2>/dev/null || true; echo "Cores: $(getconf _NPROCESSORS_ONLN 2>/dev/null || echo '?')"; for f in /sys/devices/system/cpu/cpu0/cpufreq/scaling_{cur_freq,max_freq}; do [[ -r "$f" ]] && echo "$(basename "$f"): $(cat "$f") kHz"; done; }
show_memory(){ awk '/MemTotal|MemAvailable|MemFree|SwapTotal|SwapFree/ {printf "%-14s %8.0f MB\n",$1,$2/1024}' /proc/meminfo 2>/dev/null; }
show_storage(){ df -h "$HOME" /storage/emulated/0 2>/dev/null | awk 'NR==1 || !seen[$1]++'; }
show_battery(){ local b=/sys/class/power_supply/battery; for f in capacity status health temperature voltage_now current_now; do [[ -r "$b/$f" ]] && printf '%-14s %s\n' "$f" "$(cat "$b/$f")"; done; }
show_display(){ wm size 2>/dev/null || true; wm density 2>/dev/null || true; }
show_system(){ echo "Android: $(getprop ro.build.version.release) (SDK $(getprop ro.build.version.sdk))"; echo "Device: $(getprop ro.product.manufacturer) $(getprop ro.product.model)"; echo "Kernel: $(uname -srmo)"; echo "Uptime: $(uptime -p 2>/dev/null || cat /proc/uptime)"; }
show_gpu(){ dumpsys SurfaceFlinger 2>/dev/null | grep -m2 -E 'GLES|GL_VENDOR|GL_RENDERER' || echo "GPU details restricted by Android."; }
show_sensors(){ local found=0; for d in /sys/bus/iio/devices/iio:device*; do [[ -d "$d" ]] || continue; found=1; echo "$(basename "$d"): $(cat "$d/name" 2>/dev/null)"; for f in "$d"/in*_input; do [[ -r "$f" ]] && echo "  $(basename "$f"): $(cat "$f")"; done; done; (( found )) || echo "No readable IIO sensors exposed."; }
show_network(){ ip -brief address 2>/dev/null || true; ip route 2>/dev/null | head -8 || true; echo "DNS: $(getprop net.dns1) $(getprop net.dns2)"; }
diagnostics(){ echo "Kernel: $(uname -r)"; for x in getprop df awk grep ip curl; do command -v "$x" || echo "$x unavailable"; done; for x in /sys/class/power_supply/battery /sys/devices/system/cpu /sys/bus/iio/devices; do [[ -r "$x" ]] && echo "OK $x" || echo "Restricted: $x"; done; }
