#!/usr/bin/env bash
# Compile quickshell/fx/*.frag to .qsb (Qt's shader bundle). Needs qt6-qtshadertools.
set -euo pipefail
cd "$(dirname "$0")/../quickshell/fx"
QSB=$(command -v qsb || echo /usr/lib64/qt6/bin/qsb)
for f in *.frag; do
    "$QSB" --qt6 -o "$f.qsb" "$f"
    echo "built fx/$f.qsb"
done
