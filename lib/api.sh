#!/usr/bin/env bash
# Optional Android integrations through the official Termux:API add-on.
# Every action is user-invoked; this module does not run background services.

api_command_ready() {
  command -v "$1" >/dev/null 2>&1
}

api_require() {
  if ! api_command_ready "$1"; then
    printf '  %s\n' "$MSG_API_NOT_READY"
    printf '  pkg install termux-api\n'
    return 1
  fi
  return 0
}

api_sensor_lab() {
  local choice
  while true; do
    title "$MSG_SENSOR_LAB"
    printf '  [1] %s\n  [2] %s\n  [3] %s\n  [4] %s\n  [0] %s\n' \
      "$MSG_SENSOR_LIST" "$MSG_SENSOR_SAMPLE" "$MSG_LOCATION_ONCE" "$MSG_CAMERA_INFO" "$MSG_BACK"
    read -r -p "  $MSG_PROMPT > " choice || return
    case "$choice" in
      1)
        if api_require termux-sensor; then
          termux-sensor -l 2>&1 || printf '%s\n' "$MSG_API_PERMISSION"
        fi
        pause ;;
      2)
        if api_require termux-sensor; then
          printf '%s\n' "$MSG_SENSOR_SAMPLE_HINT"
          termux-sensor -n 1 2>&1 || printf '%s\n' "$MSG_API_PERMISSION"
        fi
        pause ;;
      3)
        if api_require termux-location; then
          termux-location -p gps -r once 2>&1 || printf '%s\n' "$MSG_API_PERMISSION"
        fi
        pause ;;
      4)
        if api_require termux-camera-info; then
          termux-camera-info 2>&1 || printf '%s\n' "$MSG_API_PERMISSION"
        fi
        pause ;;
      0|q|Q|'') return ;;
      *) printf '%s\n' "$MSG_INVALID"; sleep 1 ;;
    esac
  done
}

api_network_info() {
  title "$MSG_NETWORK"
  if api_require termux-wifi-connectioninfo; then
    termux-wifi-connectioninfo 2>&1 || printf '%s\n' "$MSG_API_PERMISSION"
  fi
  printf '\n%s\n' "$MSG_NETWORK_INTERFACES"
  ip -brief address 2>/dev/null || ifconfig 2>/dev/null || printf '%s\n' "$MSG_NETWORK_RESTRICTED"
  pause
}

api_control_center() {
  local choice value
  while true; do
    title "$MSG_CONTROL_CENTER"
    printf '  [1] %s\n  [2] %s\n  [3] %s\n  [4] %s\n  [5] %s\n  [6] %s\n  [0] %s\n' \
      "$MSG_TORCH" "$MSG_VIBRATE" "$MSG_NOTIFICATION" "$MSG_SPEAK" "$MSG_BRIGHTNESS" "$MSG_VOLUME" "$MSG_BACK"
    read -r -p "  $MSG_PROMPT > " choice || return
    case "$choice" in
      1)
        if api_require termux-torch; then
          printf '  [1] ON  [0] OFF\n'
          read -r -p '  > ' value
          case "$value" in
            1) termux-torch on 2>&1 ;;
            0) termux-torch off 2>&1 ;;
            *) printf '%s\n' "$MSG_INVALID" ;;
          esac
        fi
        pause ;;
      2)
        if api_require termux-vibrate; then
          termux-vibrate -d 350 2>&1 || printf '%s\n' "$MSG_API_PERMISSION"
        fi
        pause ;;
      3)
        if api_require termux-notification; then
          termux-notification --title "Termux Dashboard" --content "$MSG_TEST_NOTIFICATION" 2>&1 || printf '%s\n' "$MSG_API_PERMISSION"
        fi
        pause ;;
      4)
        if api_require termux-tts-speak; then
          termux-tts-speak "$MSG_TEST_SPEECH" 2>&1 || printf '%s\n' "$MSG_API_PERMISSION"
        fi
        pause ;;
      5)
        if api_require termux-brightness; then
          printf '%s\n' "$MSG_BRIGHTNESS_HINT"
          read -r -p '  0-255 > ' value
          if [[ "$value" =~ ^[0-9]+$ ]] && (( value <= 255 )); then
            termux-brightness "$value" 2>&1 || printf '%s\n' "$MSG_API_PERMISSION"
          else
            printf '%s\n' "$MSG_INVALID"
          fi
        fi
        pause ;;
      6)
        if api_require termux-volume; then
          termux-volume 2>&1
          printf '%s\n' "$MSG_VOLUME_HINT"
        fi
        pause ;;
      0|q|Q|'') return ;;
      *) printf '%s\n' "$MSG_INVALID"; sleep 1 ;;
    esac
  done
}

api_automation_center() {
  local json level
  title "$MSG_AUTOMATION"
  printf '%s\n' "$MSG_AUTOMATION_ONESHOT"
  if ! api_require termux-battery-status; then pause; return; fi
  json="$(termux-battery-status 2>/dev/null || true)"
  level="$(battery_json_value "$json" percentage)"
  if [[ ! "$level" =~ ^[0-9]+$ ]]; then
    printf '%s\n' "$MSG_DATA_UNAVAILABLE"
  else
    printf '%s: %s%%\n' "$MSG_BATTERY_PERCENT" "$level"
    if (( level <= 20 )); then
      printf '%s\n' "$MSG_LOW_BATTERY"
      if api_command_ready termux-notification; then
        termux-notification --title "$MSG_LOW_BATTERY_TITLE" --content "$MSG_LOW_BATTERY" 2>/dev/null || true
      fi
    else
      printf '%s\n' "$MSG_BATTERY_OK"
    fi
  fi
  printf '\n%s\n' "$MSG_AUTOMATION_PRIVACY"
  pause
}

api_tools_menu() {
  local choice
  while true; do
    title "$MSG_API_CENTER"
    printf '  [1] %s\n  [2] %s\n  [3] %s\n  [4] %s\n  [0] %s\n' \
      "$MSG_SENSOR_LAB" "$MSG_NETWORK" "$MSG_CONTROL_CENTER" "$MSG_AUTOMATION" "$MSG_BACK"
    read -r -p "  $MSG_PROMPT > " choice || return
    case "$choice" in
      1) api_sensor_lab ;;
      2) api_network_info ;;
      3) api_control_center ;;
      4) api_automation_center ;;
      0|q|Q|'') return ;;
      *) printf '%s\n' "$MSG_INVALID"; sleep 1 ;;
    esac
  done
}
