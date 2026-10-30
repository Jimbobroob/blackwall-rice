#!/usr/bin/env bash
# Install the rice: back up whatever is at each target, then symlink ~/rice into place.
#
#   ./install.sh            install everything in links.txt
#   ./install.sh hypr kitty install only these sources (first column of links.txt)
#
# Nothing is deleted: existing targets are MOVED to ~/rice-old-backup/<timestamp>/files/,
# and every action is recorded in that folder's manifest so rollback.sh can undo it.
set -euo pipefail

RICE_DIR="${RICE_DIR:-$(cd "$(dirname "$(realpath "$0")")" && pwd)}"
TARGET_HOME="${RICE_HOME:-$HOME}"
BACKUP_ROOT="${RICE_BACKUP_ROOT:-$HOME/rice-old-backup}"
LINKS="${RICE_LINKS:-$RICE_DIR/links.txt}"

# Regenerate palette/settings outputs so links never point at stale files.
if [[ -z "${RICE_SKIP_GEN:-}" ]]; then
    python3 "$RICE_DIR/tools/generate.py"
fi

wanted=("$@")
is_wanted() {
    [[ ${#wanted[@]} -eq 0 ]] && return 0
    local w
    for w in "${wanted[@]}"; do [[ "$w" == "$1" ]] && return 0; done
    return 1
}

stamp="$(date +%Y%m%d-%H%M%S)"
backup="$BACKUP_ROOT/$stamp"
done_any=0

while read -r src dst _; do
    [[ -z "$src" || "$src" == \#* ]] && continue
    is_wanted "$src" || continue

    src_abs="$RICE_DIR/$src"
    dst_abs="$TARGET_HOME/$dst"

    if [[ ! -e "$src_abs" ]]; then
        echo "!! missing source: $src_abs (skipped)" >&2
        continue
    fi
    if [[ -L "$dst_abs" && "$(readlink "$dst_abs")" == "$src_abs" ]]; then
        echo "ok  $dst (already linked)"
        continue
    fi

    mkdir -p "$backup/files"
    backed_up=no
    if [[ -e "$dst_abs" || -L "$dst_abs" ]]; then
        mkdir -p "$backup/files/$(dirname "$dst")"
        mv "$dst_abs" "$backup/files/$dst"
        backed_up=yes
    fi
    mkdir -p "$(dirname "$dst_abs")"
    ln -s "$src_abs" "$dst_abs"
    printf '%s\t%s\t%s\n' "$dst" "$src_abs" "$backed_up" >> "$backup/manifest"
    done_any=1
    echo "->  $dst  =>  $src_abs   (backup: $backed_up)"
done < "$LINKS"

if [[ $done_any -eq 1 ]]; then
    echo "Backup + manifest: $backup"
else
    echo "Nothing to do."
fi
