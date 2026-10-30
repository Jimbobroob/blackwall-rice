# Progress

Status: ⬜ not started · 🟡 in progress · ✅ done
Claude updates this file during every phase. If a phase stops partway, the note says exactly where to resume.

| Phase | Status | Notes |
|---|---|---|
| 0. Design (grilling) | ✅ | Finished 2026-10-30 |
| 1. Foundation | ✅ | Finished 2026-10-30. User visual check passed. |
| 2. Main monitor UI | ✅ | Finished 2026-10-30. Awaiting user visual check. |
| 3. Side monitor dashboard | ✅ | Finished 2026-10-30. Awaiting user visual check. |
| 4. Spotify + Discord widgets | ✅ | Finished 2026-10-30. User confirmed working (voice panel, mute/deafen, Spotify, snip). Discord grid capped at 20. |
| 5. App theming + lock | ✅ | Finished 2026-10-30. Lock tested by user; Vesktop, Spotify (Spicetify) and Firefox confirmed. |
| 6. Polish | ✅ | Finished 2026-10-30. Awaiting user visual check of glitch effects. |

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
- [x] P4.5 Vencord built with the plugin via `tools/build-vencord.sh` (pnpm installed in ~/.local; plugin is copied into the Vencord tree because a symlink breaks its path aliases).
- [x] P4.6 Vesktop pointed at `~/.local/share/vencord-src/dist` (state.json `vencordDir`), RiceVoice enabled, flatpak overrides for that dir (ro) and `xdg-run/rice`, Vesktop restarted. Socket live; widget shows 'not in a call'. (Backups of the old Vesktop state/settings are in the session scratchpad.)
- [x] P4.7 Live test: user confirmed everything works (voice panel in a real call, Spotify, snip bind).
- [x] P4.8 (user request) `Super + Shift + S` snip bind (`hypr/scripts/snip.sh`: drag a region or click a window, then swappy). Registered, not yet fired interactively.
- [x] P4.9 Discord widget member grid (square-ish, cap 20, speakers first, +N more).
- [x] P4.10 Spotify widget volume knob (drag around it or scroll; Spotify's own volume over MPRIS).
- [x] P5.1 `tools/gen_apps.py` (called by generate.py): GTK css/settings.ini, qt5ct/qt6ct conf + colour scheme, btop, yazi, cava, fastfetch, hyprlock, hypridle, Firefox chrome + user.js, Spicetify theme, Vesktop theme, all from the palette
- [x] P5.2 install.sh run for the new links (backup `~/rice-old-backup/20261030-204452`); `tools/apply-gsettings.sh` (dark scheme, adw-gtk3-dark, Papirus-Dark, font, cursor; old values saved, `--restore` undoes)
- [x] P5.3 Checked live: btop, yazi, Nautilus (GTK4) and qt6ct render in the palette. Cursor theme is Adwaita for now (`settings.json` look.cursor)
- [x] P5.4 Vesktop: `tools/install-vesktop-theme.sh` copied + enabled blackwall.theme.css (needs a Vesktop restart to show)
- [x] P5.5 hyprlock.conf (Rajdhani clock/date, weather via `hypr/scripts/lock_weather.py`, input field; main + side monitors by desc) and hypridle.conf (lock after `lock.idle_minutes` = 60); Hyprland rule `idle_inhibit = fullscreen`; hypridle + cursor set in autostart. **Not yet tested: hypridle not installed, hyprlock not fired.**
- [x] P5.6a hypridle, hyprlock, fastfetch installed; fastfetch renders with the themed config; hypridle running. Lock tested by the user: works.
- [x] P5.7a Spicetify binary installed, Blackwall theme present (current_theme=Blackwall), cursor set to Bibata-Modern-Classic in settings.json.
- [x] P5.7b Spotify dir chmod done by user; Spicetify applied after copying jsHelper + css-map.json from the v2.46.4 release next to the binary; header tint pinned to red
- [x] P5.8 Firefox themed (seen); Vesktop theme overrides Discord's current brand variables (checked live: no blue left on Friends); user confirmed. `Super + B` opens Firefox.

- [x] P6.1 Glitch shaders (`quickshell/fx`: pop-in, scanlines, workspace tear), levels subtle/medium/heavy in settings.json; pop-in on widgets, launcher, power menu; scanlines on cards/launcher/power menu. Tear checked live; pop-in loads without errors, not caught mid-animation. Heavy/subtle not visually compared.
- [x] P6.2 Wallpapers (user chose different per monitor): hyprpaper from settings.json, autostart; widgets moved to Bottom layer. Checked on both screens.
- [x] P6.3 Review: no Hyprland config errors, both monitors/modes/positions right, qs/hypridle/hyprpaper running, links in place, fonts installed. Not re-tested this phase: lock, game mode, KVM unplug.
- [x] P6.4 README.md
- [x] P6.5 (user request) Liquid-glass bars: GlassPanel + blur layer rules; bar_opacity/bar_tint in settings.json.
- [x] P6.6 (user request) main bar back to solid (glass only on side bar); tray shows the Discord icon for Vesktop; widgets recoloured black + red.
- [x] P6.7 (user request) glitches re-roll seed, strength and length on every play (pop-in and workspace tear).
- [x] P6.8 (user request) main clock: no seconds; weather moved down (margin y 212) so the two no longer overlap.
- [x] P6.9 (user request) main bar auto-hide (bar.main_autohide). Tested: hidden by default, appears at the bottom edge, hides after leaving.
