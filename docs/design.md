# Rice Design Doc

The single source of truth for this rice. Everything built in `~/rice/` follows these decisions.
Built in `~/rice/`, symlinked into `~/.config` later.

_Started: 2026-10-30_

---

## 1. System facts (detected, not decided)

| Item | Value |
|---|---|
| OS | Fedora 44 |
| Compositor | Hyprland (Wayland) |
| CPU | Intel i5-12600K |
| GPU | AMD Radeon RX 9060 XT (Navi 44) |
| Hyprland | 0.57.0 (Lua config) |
| Keyboard | UK (`gb`) |
| RAM | 32 GB |
| Font available | JetBrainsMono Nerd Font |

### Monitors
| Output | Panel | Mode | Connection | Role |
|---|---|---|---|---|
| HDMI-A-1 | 1920×1080 | 144 Hz | PC → DP → KVM → HDMI → monitor | **MAIN**: gaming + everything active |
| DP-2 | iiyama PL3270Q 32" 2560×1440 | 60 Hz | HDMI through the KVM | **SIDE**: Discord / Spotify "watcher" screen |

Both monitors go through a KVM switch. The rice must handle monitors disappearing/reappearing when the KVM switches.

---

## 2. Who this is for / usage

- **Avid gamer** (primary use).
- **C#** at work.
- Learning **Rust** and **C++** in free time.
- Side monitor is a passive watcher dashboard: Discord + Spotify run hidden, widgets show them.

## 3. Decisions

### Approach
- **Fresh start.** Configs are written from scratch. Existing configs (`rumda`, the `*.backup.*` dirs from 2026-10-29) are reference only.

### Monitor layout
- Physical layout matches Hyprland: **1440p (DP-2) on the LEFT**, **1080p 144 Hz (HDMI-A-1) on the RIGHT**, offset 360px down.

### Aesthetic
- **Darker cyberpunk.** Reference: Cyberpunk: Edgerunners riot scene, but **darker**.
- **Red, Blackwall-style**: near-black base, aggressive red as the signature colour.
- **Secondary accent: magenta/pink**, for small details.

### Palette (approved v1, tweakable)
All components read colours from ONE palette file. Never hardcode hex values elsewhere.

| Role | Hex | Use |
|---|---|---|
| base | `#07070A` | background, almost black with a hint of blue |
| surface | `#111116` | panels, widgets |
| overlay | `#1C1C24` | hover states, borders at rest |
| text | `#E6E1E3` | main text |
| muted | `#6E6A75` | labels, inactive |
| **red** | `#FF0033` | **signature (Blackwall)**: active borders, focus, highlights |
| red_dim | `#7A0019` | glows, inactive accents |
| **magenta** | `#FF2AA0` | small details: now-playing, clock, links |
| warning | `#FFB000` | rare warnings |
- **Glitch/HUD intensity: MEDIUM** (sharp/angled corners, thin red borders, techy monospace labels, quick glitch effects on workspace switches and widget pop-ins, scanlines on some panels).
  - Must be **switchable later** (one setting: subtle / medium / heavy). Try medium first.

### Wallpaper
- **Static, the same on both monitors**, very minimal. The user will supply it at the end.
- Because the wallpaper is minimal, **desktop widgets do the visual work**, especially on the side monitor.

### Shell framework
- **Quickshell** runs the bar, all desktop widgets, notifications and the launcher (one tool, one style, GPU shaders for glitch effects, live monitor hotplug for the KVM).

### Bars
- **Main monitor (HDMI-A-1): horizontal bar at the BOTTOM**, **sleeker/slimmer** than the side bar. (Changed from "no bar" in round 3.)
  - Contents (left → right): **workspaces 1–5 | focused window title (centred) | mini now-playing | volume | network | 24h clock**
  - **Hidden completely in game mode.**
- **Side monitor (DP-2): vertical bar on the LEFT edge.**
  - Contents (top → bottom): **launcher button | workspaces 6–10 | [space] | tray | volume | network | notifications bell | power menu**
  - Volume + network intentionally **duplicated** from the main bar.
  - **Extras:** **mic mute toggle** (lights red when muted), **dnf updates count** (click to update in the terminal), **GPU temp** mini readout.
  - Final order (top → bottom): launcher | workspaces 6–10 | [space] | GPU temp | updates | tray | mic | volume | network | bell | power
- **No workspace-switch popup.** The bars are enough.

### Workspaces
- **Main (HDMI-A-1): workspaces 1–5** (Super+1…5), locked to that monitor.
- **Side (DP-2): workspaces 6–10** (Super+6…9, **Super+0 = 10**), locked to that monitor.

### Volume OSD
- A **thin** volume bar on the **main monitor, just above the bottom bar**.
- **Very quick** to appear and disappear.
- **Shows in game mode too** (allowed to cover the game).

### Notifications
- Shown on the **side monitor, TOP-RIGHT** corner (next to the main monitor).
- **Always shown**, including in game mode (no do-not-disturb).
- **No sound.**

### Launcher
- **Super+Space** opens a search launcher **in the middle of the main monitor**, styled like the rest (glitch-in).

### Windows
- **Sharp corners (0px rounding).**
- **2px borders**: red (`#FF0033`) when focused, dark grey when not.
- **6px gaps** between windows.
- **Super+Tab** throws the focused window to the other monitor (onto that monitor's current workspace).

### Keybinds
- Full list lives in **`docs/keybinds.md`**. It must be updated whenever a bind is added or changed.

### Startup
- On login, auto-launch **Spotify** and **Vesktop (Discord)** **hidden** (special workspaces), ready to toggle instantly. Nothing else.

### Login screen
- **Leave GDM as-is.** Theming it is a possible later bonus.

### Install / safety
- Everything is built in **`~/rice/`**, a **local git repo** (no GitHub for now).
- Install = back up the current `~/.config` entries to **`~/rice-old-backup/`**, then **symlink** `~/rice/*` into `~/.config`.
- **Rollback = one command: `~/rice/rollback.sh`.** It removes the symlinks and restores everything from `~/rice-old-backup/`.

### App theming (all use the palette)
- GTK + Qt apps
- Spotify via **Spicetify**
- Vesktop via a **Vencord theme**
- **Firefox** (the user's browser)
- Cursor theme
- btop, yazi, cava, fastfetch

### Lock screen (hyprlock)
- Shows a **big clock (Rajdhani) + weather**.
- **Super+L** locks manually.
- **Auto-lock after 1 hour idle**, EXCEPT while a game or video is playing (idle inhibit).

### Power menu
- Opened from the side-bar button: **lock, log out, suspend, reboot, shut down**.
- Glitch-style overlay but **compact, not too big** (not full-screen).

### Fonts
- **JetBrainsMono Nerd Font**: terminal, code, small UI text.
- **Rajdhani**: display font for clocks, headings and big HUD text.

### Weather
- Location: **London, England**. Units: **°C, mph**.

### Desktop widgets
- **Side monitor (DP-2)**, the dashboard:
  - Spotify (now playing + controls)
  - Discord voice panel
  - **Analog clock** ("an actual clock") + date
  - System stats: CPU/GPU usage + temps, RAM
  - Audio visualiser (cava)
  - Weather
  - Calendar
  - Network speed
- **Side monitor = pure dashboard.** The **Spotify and Discord windows stay HIDDEN** (Hyprland special workspaces). They are launched at login so they are already running and open **instantly** when toggled. The Spotify widget and the Discord voice widget are the main way to see them.
  - **Super+S** shows/hides the Spotify window. **Super+D** shows/hides the Discord window.
  - Toggled windows **always appear on the SIDE monitor** (over the widgets), never on main, even if main is focused. The same key hides them again.
  - ⚠️ **The Discord voice widget is critical** now that Discord is hidden. Check feasibility first at build time (Discord local RPC with the user's own registered app, or a Vencord plugin exposing voice state).
- **Main monitor (HDMI-A-1)**: **only time + weather**, styled **differently** from the side monitor.
  - Time is **digital, 24h**.
- **Everything configurable**: clock style (analog/digital), 12h/24h, which widgets appear on which monitor, and their positions must be settings, not hardcoded. The user expects to change these later.

### Game mode
- **Automatic** when a game is fullscreen on the **main monitor (HDMI-A-1) only**: blur, animations and borders off. **Notifications are NOT muted** (they show on the side monitor).
- The **side monitor (DP-2) stays unchanged** during game mode (widgets keep running).

### Apps
- **Spotify desktop app** (widget reads now-playing info).
- **Discord via Vesktop/Vencord** (themed to match).
- **Discord widget = voice-channel panel**: who's in the call, who's speaking, mute/deafen buttons. Feasibility to be checked before building.
- **Editor: Neovim** (the user is learning it), themed, set up for **Rust + C++** (and C# is a bonus).
  - Config **from totally blank** (no kickstart, no LazyVim).
  - **Deferred**: not part of this rice build. It will be done later as a separate, step-by-step learning session.

### Terminal & shell
- **Terminal: kitty** (chosen for its image protocol, maturity and r/unixporn examples).
- **Shell: fish** (replacing bash as the default).
- **Prompt: starship**, themed with the palette, in a **"bubbles" layout** (after oh-my-posh's bubblesextra, the user's old prompt): dark rounded pills with coloured Nerd Font icons; everything left-aligned: path, git, languages and time on line 1; duration, exit status and `user ❯` on line 2. `ls` uses eza with icons. (Changed 2026-10-30: the plain version was too barren.)
- **Terminal greeting: NONE for now.** Terminal opens straight to the prompt. (A fastfetch image like Johnny's gun can be added later. kitty supports real images.)

### Motion
- **Smooth and quick.** Snappy animations, never floaty or slow.

### Phase 1 build decisions (2026-10-30)
- **Hyprland 0.57 reads Lua only** (`hyprland.lua`), so the Hyprland config is written in Lua.
- **Keyboard: UK layout only (`gb`).** The old `us,ara` + Super+Space toggle is dropped (Super+Space = launcher).
- **Game mode affects the main monitor only**: blur/animations/borders are switched off per-window (window rules) for windows on HDMI-A-1, because Hyprland's global blur/animation switches would also hit the side monitor.
- **starship installed via COPR** (`atim/starship`). Spotify and Vesktop installed as Flatpaks.
- **Monitors are matched by description** (`desc:`), not port name, so they survive the KVM renaming ports.
- Until phase 2's Quickshell launcher exists, `Super+Space` and clipboard history temporarily use rofi.

#### Details Claude chose during phase 1 (not discussed in grilling, all changeable)
**Palette / settings**
- `palette.json` gained an **`ansi` block** (green, blue, cyan + bright variants, bright black), because terminal programs need all 16 ANSI colours. Only terminal colours use them.
- `tools/generate.py` builds every colour/settings format into `~/rice/generated/` (Hyprland Lua, kitty, fish, starship, CSS, QML). Edit the JSON, never `generated/`.
- `settings.json` also holds the **monitor descriptions, modes, positions and workspace lists**, the weather location/units, and a **first-draft widget layout** (anchors + margins per monitor) for phases 2–3 to refine.

**Hyprland**
- **Inactive border colour = `overlay`** (`#1C1C24`), the palette's "borders at rest".
- **Blur stays on** normally (size 4, 2 passes). **Shadows off.** Resize by dragging borders is on.
- Animations: short ease-out curve, windows pop in at 90%, **workspaces slide vertically**, special workspaces slide+fade.
- **Workspaces 1–10 are persistent** (always exist, so the bars can always show them).
- **Special workspaces don't hide on a workspace switch**: Spotify/Discord stay up until you press their key again.
- Mouse sensitivity **0.2** (carried over from the old config).
- **Super+F = real fullscreen** (not maximise). **Super+Tab follows the window** to the other monitor.
- Extra binds not in the original list: **Super+Left/Right-drag** move/resize, and **media keys** (volume ±5% capped at 100%, mute, mic mute, play/pause/next/prev).

**Spotify / Discord toggles**
- Showing an app **focuses its window**. Hiding it **returns focus to the monitor you came from**, and switching straight from one app to the other keeps that return point.
- If the app isn't running, the key launches it first.
- Vesktop's Flatpak reports the class `dev.vencord.Vesktop`, so both that and `vesktop` are matched.
- The toggle can be called from scripts/widgets: `hyprctl eval 'rice.toggle_app("spotify")'` (or `"discord"`).
- On a config reload, any Spotify/Discord window that ended up elsewhere is moved back to its hidden workspace.

**KVM**
- When a monitor comes back, its workspaces (1–5 or 6–10) are moved back to it automatically.
- Any unknown monitor plugged in gets its preferred mode, placed automatically.

**Game mode**
- Triggers on **any real fullscreen window** on main (a fullscreen video counts too, Hyprland can't tell games apart). Maximised windows don't trigger it.
- Also turns off **shadows** for main-monitor windows.
- Writes `1`/`0` to **`$XDG_RUNTIME_DIR/rice/gamemode`** for the Quickshell bar to read.

**Startup**
- "Nothing else" means no other *apps*. Session plumbing also starts at login: **polkit agent** (hyprpolkitagent), the **clipboard history watcher** (`wl-paste --watch cliphist store`) and the D-Bus environment update.
- The old rumda Quickshell bar is no longer started; there is **no bar until phase 2**. The hyprlock config moved to the backup, so **Super+L uses hyprlock's default look until phase 5**.

**Terminal / shell**
- kitty: JetBrainsMono Nerd Font **11.5pt**, **96% background opacity**, 10px padding, no title bar, **red non-blinking block cursor**, no bell, copy-on-select, tabs at the bottom.
- fish: fresh minimal config (none of the old abbreviations were carried over), `~/.local/bin` and `~/.cargo/bin` on PATH, **`ls`/`ll`/`la`/`lt` via eza with icons**, **`cd` via zoxide**.
- Rajdhani is installed per-user (`~/.local/share/fonts`) by `tools/install-fonts.sh`.

**Install**
- What gets linked is listed in **`links.txt`**. `install.sh` **moves** (not copies) the old files into `~/rice-old-backup/<timestamp>/` with a manifest. `rollback.sh` undoes every install newest first (or `--last` for just the latest), and leaves alone anything you changed by hand since.
- Phase 1 links: `~/.config/hypr` (whole folder), `~/.config/kitty` (whole folder), `~/.config/fish/config.fish` (just the file, so fish's own state stays put), `~/.config/starship.toml`.

---

## 4. Build plan
Built in 6 phases. Details, steps and done-checks are in **`docs/phases.md`**. Progress is tracked in **`docs/progress.md`**.
Each phase is started with its slash command in Claude Code: `/rice-phase-1` … `/rice-phase-6`. `/rice-status` shows where things stand.

## 5. Later / out of scope (do NOT build unless asked)
- Neovim config from blank (separate learning sessions)
- Terminal image (e.g. Johnny's gun) via fastfetch
- Login screen (GDM) theming
- Wallpaper: the user supplies it in phase 6
- Pushing the repo to GitHub
