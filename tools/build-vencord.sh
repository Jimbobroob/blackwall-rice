#!/bin/sh
# Rebuild Vencord with the RiceVoice plugin (source: ~/Source/rices/blackwall-rice/vencord/riceVoice).
# Vencord's path aliases only resolve inside its own tree, so the plugin is copied, not linked.
set -e
V=${VENCORD_SRC:-$HOME/.local/share/vencord-src}
export PATH=$HOME/.local/bin:$PATH
rm -rf "$V/src/userplugins/riceVoice"
mkdir -p "$V/src/userplugins"
cp -r "$(dirname "$0")/../vencord/riceVoice" "$V/src/userplugins/riceVoice"
cd "$V"
pnpm build
