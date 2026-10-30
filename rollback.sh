#!/usr/bin/env bash
# Undo install.sh: remove the rice symlinks and move the backed-up originals back.
#
#   ./rollback.sh          undo every install, newest first (back to the pre-rice state)
#   ./rollback.sh --last   undo only the most recent install
#
# A target is only removed if it is still the exact symlink install.sh made,
# so anything changed by hand since then is left alone (and reported).
set -euo pipefail

TARGET_HOME="${RICE_HOME:-$HOME}"
BACKUP_ROOT="${RICE_BACKUP_ROOT:-$HOME/rice-old-backup}"

only_last=0
[[ "${1:-}" == "--last" ]] && only_last=1

if [[ ! -d "$BACKUP_ROOT" ]]; then
    echo "No backups in $BACKUP_ROOT, nothing to roll back."
    exit 0
fi

mapfile -t backups < <(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d | sort -r)
undone=0

for backup in "${backups[@]}"; do
    [[ -f "$backup/manifest" && ! -e "$backup/.restored" ]] || continue
    echo "== rolling back $(basename "$backup")"

    # Undo in reverse order of installation.
    while IFS=$'\t' read -r dst src_abs backed_up; do
        dst_abs="$TARGET_HOME/$dst"
        if [[ -L "$dst_abs" && "$(readlink "$dst_abs")" == "$src_abs" ]]; then
            rm "$dst_abs"
        elif [[ -e "$dst_abs" || -L "$dst_abs" ]]; then
            echo "!! $dst is no longer the rice symlink, leaving it alone" >&2
            continue
        fi
        if [[ "$backed_up" == yes ]]; then
            mkdir -p "$(dirname "$dst_abs")"
            mv "$backup/files/$dst" "$dst_abs"
            echo "<-  $dst restored"
        else
            echo "x   $dst removed (nothing was there before)"
        fi
    done < <(tac "$backup/manifest")

    date > "$backup/.restored"
    undone=$((undone + 1))
    [[ $only_last -eq 1 ]] && break
done

if [[ $undone -eq 0 ]]; then
    echo "Nothing to roll back (all backups already restored)."
else
    echo "Rolled back $undone install(s). Reload Hyprland with: hyprctl reload"
fi
