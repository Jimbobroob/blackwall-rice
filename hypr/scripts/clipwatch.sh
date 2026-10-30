#!/usr/bin/env bash
# Keeps clipboard history recording: one watcher for text, one for images, each restarted
# if it ever exits. Safe to run again (replaces any running copy). Started at login by autostart.lua.
# anchored (^) so these patterns can never match this script or the shell that launched it
pkill -f '^rice-clipwatch' 2>/dev/null
pkill -f '^wl-paste --type (text|image) --watch cliphist store$' 2>/dev/null

watch() {  # watch <mime-prefix>
    while true; do
        wl-paste --type "$1" --watch cliphist store
        sleep 1
    done
}

# the argv0 marker lets a re-run find and replace the old supervisors
( exec -a rice-clipwatch-text  bash -c "$(declare -f watch); watch text" ) &
( exec -a rice-clipwatch-image bash -c "$(declare -f watch); watch image" ) &
wait
