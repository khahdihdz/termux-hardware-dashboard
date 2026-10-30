#!/usr/bin/env bash

# Shared terminal UI: compact cyber/HUD style, safe on narrow Termux screens.
ui_width() {
  local cols
  cols="$(tput cols 2>/dev/null || printf '80')"
  [[ "$cols" =~ ^[0-9]+$ ]] || cols=80
  (( cols > 76 )) && cols=76
  (( cols < 36 )) && cols=36
  printf '%s' "$cols"
}

ui_rule() {
  local width line
  width="$(ui_width)"
  printf -v line '%*s' "$((width-6))" ''
  line="${line// /━}"
  printf '\033[1;32m  ┣%s┫\033[0m\n' "$line"
}

ui_header() {
  local heading="$1" width inner stamp
  width="$(ui_width)"
  inner=$((width-6))
  stamp="$(date '+%H:%M:%S  %d-%m-%Y' 2>/dev/null)"
  printf '\033[1;32m  ┏%*s┓\033[0m\n' "$((width-6))" '' | sed 's/ /━/g'
  printf '\033[1;32m  ┃\033[0m \033[1;32m[ SYSTEM ONLINE ]\033[0m  \033[1;37m%-*.*s\033[0m\n' "$((inner-20))" "$((inner-20))" "$heading"
  printf '\033[1;32m  ┃\033[0m \033[2m%-*.*s\033[0m\n' "$((inner-2))" "$((inner-2))" "$stamp"
  ui_rule
}

ui_footer() {
  local hint="$1"
  ui_rule
  printf '\033[1;32m  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\033[0m\n' | cut -c1-"$(($(ui_width)+2))"
  printf '\033[2m  %s\033[0m\n' "$hint"
}

title() {
  clear 2>/dev/null || true
  ui_header "$1"
}

pause() {
  printf '\n'
  read -r -p "  $MSG_CONTINUE" _ || true
}

section() {
  title "$1"
  shift
  "$@"
  ui_footer "$MSG_BACK_HINT"
  pause
}
