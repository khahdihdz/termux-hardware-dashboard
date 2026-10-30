#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail
REPO="https://github.com/khahdihdz/termux-hardware-dashboard"; DEST="$HOME/.local/share/termux-hardware-dashboard"
tmp="$(mktemp -d)"; backup="$DEST.backup.$(date +%Y%m%d%H%M%S)"; trap 'rm -rf "$tmp"' EXIT
curl -fL "$REPO/archive/refs/heads/main.tar.gz" -o "$tmp/source.tgz"; tar -xzf "$tmp/source.tgz" -C "$tmp"
src="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -n1)"
[[ -d "$DEST" ]] && cp -a "$DEST" "$backup"; mkdir -p "$DEST"
if ! cp -R "$src/." "$DEST/"; then [[ -d "$backup" ]] && { rm -rf "$DEST"; mv "$backup" "$DEST"; }; exit 1; fi
chmod +x "$DEST/hwinfo" "$DEST"/*.sh; echo "Updated. Backup: $backup"
