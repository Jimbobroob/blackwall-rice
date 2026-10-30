# Progress

Status: ⬜ not started · 🟡 in progress · ✅ done
Claude updates this file during every phase. If a phase stops partway, the note says exactly where to resume.

| Phase | Status | Notes |
|---|---|---|
| 0. Design (grilling) | ✅ | Finished 2026-10-30 |
| 1. Foundation | ✅ | Finished 2026-10-30. User visual check passed. |
| 2. Main monitor UI | ✅ | Finished 2026-10-30. Awaiting user visual check. |
| 3. Side monitor dashboard | ✅ | Finished 2026-10-30. Awaiting user visual check. |
| 4. Spotify + Discord widgets | 🟡 | P4.1–P4.4 done. **Resume at P4.5**: build Vencord with the RiceVoice plugin (blocked on user running the build commands), point Vesktop at it, test live. |
| 5. App theming + lock | ⬜ | |
| 6. Polish | ⬜ | |

## Step log
_(Claude ticks steps here as they are done, e.g. `- [x] P1.2 install.sh + rollback.sh`)_
- [x] P1.1 git init + .gitignore
- [x] P1.2 install.sh + rollback.sh (rollback tested on dummy targets: home restored byte-identical; multi-install + --last tested)
- [x] P1.3 theme/palette.json + tools/generate.py -> generated/ (lua, kitty, css, qml, fish, starship)
- [x] P1.4 settings.json
- [x] P1.5 Hyprland Lua config (monitors by desc, ws 1-5/6-10, look, binds, Spotify/Discord specials, autostart)
- [x] P1.6 game mode (hypr/modules/gamemode.lua): tested, main-only, writes $XDG_RUNTIME_DIR/rice/gamemode
- [x] P1.7 kitty
- [x] P1.8 fish + starship (starship installed via COPR, login shell is fish)
- [x] P1.9 Rajdhani (tools/install-fonts.sh)
- [x] P1.10 install + verify (hypr/kitty/fish/starship linked, no config errors; S/D toggles tested via rice.toggle_app: open/close on DP-2, windows in special workspaces). User visual check passed.
- [x] P2.1 Quickshell skeleton (quickshell/, Theme + Settings singletons, per-monitor scopes keyed by role, KVM-safe)
- [x] P2.2 bottom bar (workspaces, title, now-playing, volume, network, 24h clock); hides in game mode (tested)
- [x] P2.3 launcher (Super+Space via qs ipc)
- [x] P2.4 volume OSD
- [x] P2.5 notification server (side top-right, history in Notifs.history for the phase 3 bell)
- [x] P2.6 main widgets: digital clock + weather (Open-Meteo), placed from settings.json
- [x] P2.7 autostart: `qs` added, rumda bar no longer runs; no waybar/dunst/rofi autostarts exist (rofi only for clipboard picker)
- [x] P3.1 side bar (launcher | ws 6-10 | GPU temp | updates | tray | mic | volume | network | bell | power)
- [x] P3.2 power menu (lock, log out, suspend, reboot, shut down; checked visually, actions not fired)
- [x] P3.3 notification history panel (bell)
- [x] P3.4 widgets: analog clock + date, calendar, weather, system stats, network speed (checked live)
- [x] P3.4b cava visualiser (Fedora's cava has no pipewire input, so it uses `pulse`; tested with sounds)
- [x] P3.5 layout driven by settings.json widgets.side (spotify/discord entries kept for phase 4)
- [x] P4.1 Spotify widget (MPRIS: art, title, artist, progress, prev/play-pause/next); WidgetHost masks only non-interactive widgets (Card.interactive). Rendered on DP-2; no track was playing, so live art/progress still to confirm.
- [x] P4.2 Discord feasibility check: local RPC ruled out (Vesktop's arRPC has no voice events, rpc.voice.read needs approval). User chose **option B: Vencord plugin** (recorded in design.md).
- [x] P4.3 Plugin source `vencord/riceVoice/` (index.ts renderer: voice members, speaking, mute/deaf, 250ms publish; native.ts: Unix socket `$XDG_RUNTIME_DIR/rice/discord.sock`, commands mute/deafen). **Not built or run yet.**
- [x] P4.4 Quickshell `services/DiscordVoice.qml` + `widgets/DiscordWidget.qml`; layout slot `discord` live. Tested against a fake socket server (members, speaking ring, mute icon, offline state, reconnect). Mute/deafen button clicks not tested.
- [ ] P4.5 Build Vencord with the plugin: `~/.local/share/vencord-src` is cloned (no deps installed). Needs: pnpm, `pnpm install`, symlink `vencord/riceVoice` into `src/userplugins/`, `pnpm build`.
- [ ] P4.6 Vesktop: set its Vencord location to the build's `dist`, `flatpak override --user --filesystem=xdg-run/rice dev.vencord.Vesktop`, enable RiceVoice, restart Vesktop.
- [ ] P4.7 Live test in a real voice channel: members, speaking, mute/deafen; Spotify art/progress with a track playing. Ask user to confirm visually, then mark phase done and commit.
