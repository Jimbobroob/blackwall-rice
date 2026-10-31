#!/usr/bin/env bash
# Clipboard history picker (Super+Shift+V): search, Enter copies the entry and pastes it, Esc cancels.
theme="$HOME/.config/hypr/generated/rofi/blackwall.rasi"
sel=$(cliphist list | rofi -dmenu -i -p "clipboard" -display-columns 2 -theme "$theme") || exit 0
[ -n "$sel" ] || exit 0
printf '%s' "$sel" | cliphist decode | wl-copy
sleep 0.15
# Terminals paste with Ctrl+Shift+V, everything else with Ctrl+V.
class=$(hyprctl activewindow -j | grep -oP '"class":\s*"\K[^"]*')
case "${class,,}" in
    *kitty*|*alacritty*|*foot*|*wezterm*|*ghostty*|*konsole*|*terminal*) mods="CTRL SHIFT" ;;
    *) mods="CTRL" ;;
esac
hyprctl dispatch "hl.dsp.send_shortcut({ mods = \"$mods\", key = \"V\" })" >/dev/null
