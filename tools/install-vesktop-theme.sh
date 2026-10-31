#!/usr/bin/env bash
# Copy the generated Vencord theme into Vesktop's (Flatpak) themes folder and enable it.
# Copy, not symlink: the Flatpak sandbox can't see ~/Source/rices/blackwall-rice. Restart Vesktop afterwards.
set -euo pipefail
RICE_DIR="$(cd "$(dirname "$(realpath "$0")")/.." && pwd)"
DIR="$HOME/.var/app/dev.vencord.Vesktop/config/vesktop"
THEME=blackwall.theme.css

python3 "$RICE_DIR/tools/generate.py" >/dev/null
mkdir -p "$DIR/themes"
cp "$RICE_DIR/generated/vesktop/$THEME" "$DIR/themes/$THEME"

SETTINGS="$DIR/settings/settings.json"
if ! jq -e --arg t "$THEME" '.enabledThemes | index($t)' "$SETTINGS" >/dev/null; then
    cp "$SETTINGS" "$SETTINGS.pre-rice"
    jq --arg t "$THEME" '.enabledThemes += [$t]' "$SETTINGS.pre-rice" > "$SETTINGS"
    echo "enabled $THEME (previous settings kept at settings.json.pre-rice)"
else
    echo "$THEME already enabled; theme file refreshed"
fi
