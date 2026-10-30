#!/usr/bin/env bash
title(){ clear 2>/dev/null || true; printf '\033[1;36m%s\033[0m\n' "$1"; printf '%s\n' '────────────────────────────────────'; }
pause(){ echo; read -r -p "$MSG_CONTINUE" _; }
section(){ title "$1"; shift; "$@"; pause; }
