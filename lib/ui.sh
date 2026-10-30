#!/usr/bin/env bash

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
  printf -v line '%*s' "$((width-4))" ''
  line="${line// /─}"
  printf '\033[1;36m  ├%s┤\033[0m\n' "$line"
}

ui_header() {
  local heading="$1" width line
  width="$(ui_width)"
  printf -v line '%*s' "$((width-4))" ''
  line="${line// /─}"
  printf '\033[1;36m  ╭%s╮\033[0m\n' "$line"
  printf '\033[1;36m  │\033[0m  \033[1;37m%-*s\033[0m\033[1;36m│\033[0m\n' "$((width-6))" "$heading"
  printf '\033[1;36m  │\033[0m  \033[2m%-*s\033[0m\033[1;36m│\033[0m\n' "$((width-6))" "$(date '+%H:%M:%S  %d-%m-%Y' 2>/dev/null)"
  ui_rule
}

ui_footer() {
  local hint="$1"
  ui_rule
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
