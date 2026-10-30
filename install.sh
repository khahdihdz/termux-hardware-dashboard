#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail
REPO="https://github.com/khahdihdz/termux-hardware-dashboard"; DEST="$HOME/.local/share/termux-hardware-dashboard"
command -v pkg >/dev/null || { echo "Run inside Termux."; exit 1; }
pkg install -y curl tar
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
curl -fL "$REPO/archive/refs/heads/main.tar.gz" -o "$tmp/source.tgz"
tar -xzf "$tmp/source.tgz" -C "$tmp"
src="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -n1)"
mkdir -p "$DEST" "$HOME/.config/termux-hardware-dashboard" "$PREFIX/bin"
cp -R "$src/." "$DEST/"
chmod +x "$DEST/hwinfo" "$DEST"/*.sh
ln -sf "$DEST/hwinfo" "$PREFIX/bin/hwinfo"
echo "Installed. Run: hwinfo"
