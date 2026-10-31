# Build Phases

The rice is built in 6 phases. Each phase leaves the desktop **working**. Never start a phase before the previous one is marked done in `progress.md`.

## Rules for every phase (Claude must follow these)

1. **Read first**: `design.md`, `keybinds.md`, `progress.md`, and this phase's section below. `design.md` wins over anything else, including Claude's own preferences.
2. **Check prerequisites**: the previous phase must be ✅ in `progress.md`. If it isn't, stop and tell the user which phase to run.
3. **Resume, don't restart**: if this phase is 🟡 in-progress, continue from the last ticked step in `progress.md`.
4. **Ask before deviating**: if something in the design is impossible or needs a new decision, stop and ask. Record the answer in `design.md`.
5. **Colours only from the palette file** (`~/Source/rices/blackwall-rice/theme/palette.*`). No hardcoded hex anywhere else.
6. **Configurable over hardcoded**: things the user may change (clock style, 12/24h, widget placement, glitch level) go in one settings file.
7. **sudo**: Claude can't type the user's password. List the exact `sudo dnf install ...` commands and ask the user to run them with `! <command>` in Claude Code.
8. **Keybinds**: every bind added or changed is written to `keybinds.md` (table + changelog).
9. **Never delete** the user's existing configs. Install only via `~/Source/rices/blackwall-rice/install.sh` (backs up to `~/rice-old-backup/`, then symlinks).
10. **Test before finishing**: reload Hyprland/Quickshell, check `hyprctl` and logs for errors, and ask the user to confirm it looks right.
11. **Finish**: tick steps in `progress.md`, mark the phase ✅, `git commit` in `~/Source/rices/blackwall-rice` with a clear message, then tell the user which phase is next.
12. **Running low on context or limits**: stop at a clean step, commit, mark the phase 🟡 in `progress.md` with a note on exactly where it stopped. Re-running the same phase command resumes it.

---

## Phase 1: Foundation
**Goal:** safe base. Hyprland configured, terminal and shell done.
1. `git init` `~/Source/rices/blackwall-rice`, add `.gitignore`.
2. Write **`install.sh`** (back up targets to `~/rice-old-backup/<timestamp>/`, then symlink) and **`rollback.sh`** (remove symlinks, restore the latest backup). Test rollback on a dummy target first.
3. Palette file(s): `theme/palette.json` as the source, plus generated formats as needed (hyprland conf, kitty conf, QML, CSS).
4. Settings file: `settings.json` (glitch level, clock style, 12/24h, widget placement).
5. Hyprland from scratch: monitors (positions from design.md, KVM-safe), workspaces 1–5 main / 6–10 side, borders/gaps/sharp corners, quick animations, all keybinds in keybinds.md, special workspaces for Spotify/Discord with toggle scripts that always show them on the side monitor, autostart of Spotify + Vesktop hidden.
6. Game mode script: fullscreen on HDMI-A-1 → blur, animations, borders off. Side monitor untouched.
7. kitty themed, JetBrainsMono, no greeting.
8. fish as default shell (`chsh`, needs the user) + starship themed.
9. Install Rajdhani font.
10. Run `install.sh` for the phase-1 configs, reload, verify.

**Done when:** login works, both monitors right, keybinds work, Super+S/D toggles on the side monitor, kitty+fish+starship themed, rollback tested.

## Phase 2: Main monitor UI (Quickshell)
**Goal:** the main monitor is fully usable.
1. Quickshell project skeleton: shared palette/settings loaders, one window per monitor, survives KVM unplug/replug.
2. Slim bottom bar (main): workspaces 1–5 | window title | mini now-playing | volume | network | 24h clock. Hides in game mode.
3. Launcher on Super+Space (centre of main).
4. Volume OSD: thin, above the bar, fast in and out, shows in game mode.
5. Notification server (replaces dunst): side monitor top-right, always on, no sound, history kept for the bell.
6. Main desktop widgets: digital 24h time + weather (London, °C/mph), styled differently from the side.
7. Disable or remove waybar/dunst/rofi autostarts.

**Done when:** bar, launcher, OSD and notifications work, and game mode hides the bar.

## Phase 3: Side monitor dashboard
1. Vertical left bar: launcher | ws 6–10 | space | GPU temp | updates | tray | mic | volume | network | bell | power.
2. Compact power menu: lock, log out, suspend, reboot, shut down.
3. Notification history panel (bell).
4. Widgets: analog clock + date, system stats (CPU/GPU usage + temps, RAM), calendar, weather, network speed, cava visualiser.
5. Widget layout driven by `settings.json`.

**Done when:** the side monitor is a full dashboard, and everything updates live.

## Phase 4: Spotify + Discord widgets
1. Spotify widget (MPRIS): art, title, artist, progress, play/pause/skip.
2. **Discord voice feasibility check first.** Research options (Discord local RPC with the user's own app and `rpc.voice.read`, or a Vencord/Vesktop plugin exposing voice state). Report to the user and get a choice before building.
3. Discord voice panel: who's in the call, who's speaking, mute/deafen.

**Done when:** both widgets work with the apps hidden.

## Phase 5: App theming + lock
1. GTK3/4 + Qt (qt5ct/qt6ct) dark red theme, cursor theme.
2. Firefox (userChrome or a theme), Spicetify for Spotify, Vencord theme for Vesktop.
3. btop, yazi, cava, fastfetch themes.
4. hyprlock: big Rajdhani clock + weather. hypridle: lock after 1 hour, inhibited by games or video.

**Done when:** everything matches, and lock/idle behave.

## Phase 6: Polish
1. Glitch effects (shaders): workspace switches, widget pop-ins, scanlines, at **medium**, switchable subtle/medium/heavy from `settings.json`.
2. The user's wallpaper on both monitors.
3. Full review against design.md: every item checked, gaps fixed, final commit.
4. Write `~/Source/rices/blackwall-rice/README.md` (what's where, how to change palette/settings, install/rollback).
