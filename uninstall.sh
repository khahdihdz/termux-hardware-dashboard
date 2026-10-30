#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail
DEST="$HOME/.local/share/termux-hardware-dashboard"
if [[ "${1:-}" != "--yes" ]]; then read -r -p "Remove dashboard? [y/N] " a; [[ "$a" =~ ^[Yy]$ ]] || exit 0; fi
rm -f "$PREFIX/bin/hwinfo"; rm -rf "$DEST"
echo "Removed application. User configuration preserved."
