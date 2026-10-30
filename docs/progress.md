# Progress

Status: ⬜ not started · 🟡 in progress · ✅ done
Claude updates this file during every phase. If a phase stops partway, the note says exactly where to resume.

| Phase | Status | Notes |
|---|---|---|
| 0. Design (grilling) | ✅ | Finished 2026-10-30 |
| 1. Foundation | ✅ | Finished 2026-10-30. User visual check passed. |
| 2. Main monitor UI | ✅ | Finished 2026-10-30. Awaiting user visual check. |
| 3. Side monitor dashboard | ✅ | Finished 2026-10-30. Awaiting user visual check. |
| 4. Spotify + Discord widgets | ⬜ | |
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
