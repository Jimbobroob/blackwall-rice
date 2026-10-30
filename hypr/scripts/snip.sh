#!/bin/sh
# Snip: drag for a region, or click a window to capture it. Opens the result in swappy.
boxes=$(hyprctl clients -j | jq -r --argjson ws "$(hyprctl monitors -j | jq '[.[].activeWorkspace.id]')" \
    '.[] | select(.mapped and (.workspace.id as $w | $ws | index($w))) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
region=$(printf '%s\n' "$boxes" | slurp -d -b '#00000066' -c '#FF0033ff' -s '#FF003322' -w 2) || exit 0
[ -n "$region" ] && grim -g "$region" - | swappy -f -
