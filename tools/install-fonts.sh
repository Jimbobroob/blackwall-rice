#!/usr/bin/env bash
# Install the Rajdhani display font (Google Fonts, OFL) into ~/.local/share/fonts. No sudo.
set -euo pipefail
dest="$HOME/.local/share/fonts/Rajdhani"
mkdir -p "$dest"
for w in Light Regular Medium SemiBold Bold; do
    [[ -f "$dest/Rajdhani-$w.ttf" ]] && continue
    curl -fsSL -o "$dest/Rajdhani-$w.ttf" \
        "https://raw.githubusercontent.com/google/fonts/main/ofl/rajdhani/Rajdhani-$w.ttf"
done
fc-cache -f "$dest"
fc-list | grep -i rajdhani
