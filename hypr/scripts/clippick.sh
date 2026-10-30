#!/usr/bin/env bash
# Clipboard history picker (Super+Shift+V): search, Enter copies the entry, Esc cancels.
theme="$HOME/.config/hypr/generated/rofi/blackwall.rasi"
sel=$(cliphist list | rofi -dmenu -i -p "clipboard" -display-columns 2 -theme "$theme") || exit 0
[ -n "$sel" ] && printf '%s' "$sel" | cliphist decode | wl-copy
