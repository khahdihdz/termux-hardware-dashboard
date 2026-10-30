#!/usr/bin/env bash

# Adaptive terminal UI. Respect narrow phones and wide desktop terminals.
ui_width() {
  local cols
  cols="$(tput cols 2>/dev/null || printf '%s' "${COLUMNS:-80}")"
  [[ "$cols" =~ ^[0-9]+$ ]] || cols=80
  (( cols < 20 )) && cols=20
  (( cols > 76 )) && cols=76
  printf '%s' "$cols"
}

ui_rule() {
  local width line
  width="$(ui_width)"
  printf -v line '%*s' "$((width-4))" ''
  line="${line// /━}"
  printf '\033[1;32m  ┣%s┫\033[0m\n' "$line"
}

ui_header() {
  local heading="$1" width inner stamp prefix
  width="$(ui_width)"
  inner=$((width-4))
  stamp="$(date '+%H:%M:%S  %d-%m-%Y' 2>/dev/null)"
  if (( width < 38 )); then
    printf '\033[1;32m  [ SYS ]\033[0m \033[1;37m%.*s\033[0m\n' "$((width-10))" "$heading"
    printf '\033[2m  %.*s\033[0m\n' "$((width-4))" "$stamp"
  else
    printf '\033[1;32m  ┏%*s┓\033[0m\n' "$((width-4))" '' | sed 's/ /━/g'
    prefix='[ SYSTEM ONLINE ]'
    printf '\033[1;32m  ┃\033[0m \033[1;32m%s\033[0m  \033[1;37m%.*s\033[0m\n' "$prefix" "$((inner-23))" "$heading"
    printf '\033[1;32m  ┃\033[0m \033[2m%.*s\033[0m\n' "$((inner-2))" "$stamp"
  fi
  ui_rule
}

ui_footer() {
  local hint="$1" width line
  width="$(ui_width)"
  ui_rule
  if (( width < 38 )); then
    printf '\033[2m  %.*s\033[0m\n' "$((width-4))" "$hint"
  else
    printf -v line '%*s' "$((width-4))" ''
    line="${line// /━}"
    printf '\033[1;32m  ┗%s┛\033[0m\n' "$line"
    printf '\033[2m  %.*s\033[0m\n' "$((width-4))" "$hint"
  fi
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
