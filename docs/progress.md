# Progress

Status: ⬜ not started · 🟡 in progress · ✅ done
Claude updates this file during every phase. If a phase stops partway, the note says exactly where to resume.

| Phase | Status | Notes |
|---|---|---|
| 0. Design (grilling) | ✅ | Finished 2026-10-30 |
| 1. Foundation | 🟡 | Configs installed + verified. Waiting on user: starship (COPR), Spotify/Vesktop flatpaks, `chsh` to fish, then S/D toggle test + visual check. |
| 2. Main monitor UI | ⬜ | |
| 3. Side monitor dashboard | ⬜ | |
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
- [ ] P1.8 fish + starship (config installed; starship install + chsh pending)
- [x] P1.9 Rajdhani (tools/install-fonts.sh)
- [ ] P1.10 install + verify (hypr/kitty/fish/starship linked, no config errors; S/D toggle + user visual check pending)
