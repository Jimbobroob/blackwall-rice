#!/usr/bin/env bash
# Point GTK/GNOME's dconf settings at the rice (dark scheme, adw-gtk3, icons, font, cursor).
# Saves the previous values to ~/rice-old-backup/gsettings-before.txt first (once);
# `apply-gsettings.sh --restore` puts them back.
set -euo pipefail

RICE_DIR="$(cd "$(dirname "$(realpath "$0")")/.." && pwd)"
SAVE="$HOME/rice-old-backup/gsettings-before.txt"
S=org.gnome.desktop.interface
KEYS=(color-scheme gtk-theme icon-theme font-name cursor-theme cursor-size)

if [[ "${1:-}" == "--restore" ]]; then
    [[ -f "$SAVE" ]] || { echo "no saved values at $SAVE" >&2; exit 1; }
    while read -r key value; do gsettings set $S "$key" "$value"; done < "$SAVE"
    echo "restored from $SAVE"
    exit 0
fi

if [[ ! -f "$SAVE" ]]; then
    mkdir -p "$(dirname "$SAVE")"
    for k in "${KEYS[@]}"; do echo "$k $(gsettings get $S "$k")"; done > "$SAVE"
fi

read -r cursor size icons < <(python3 - "$RICE_DIR/settings.json" <<'PY'
import json, sys
look = json.load(open(sys.argv[1]))["look"]
print(look["cursor"]["theme"], look["cursor"]["size"], look["icon_theme"])
PY
)

gsettings set $S color-scheme prefer-dark
gsettings set $S gtk-theme adw-gtk3-dark
gsettings set $S icon-theme "$icons"
gsettings set $S font-name "JetBrainsMono Nerd Font 10"
gsettings set $S cursor-theme "$cursor"
gsettings set $S cursor-size "$size"
echo "applied (previous values saved in $SAVE)"
