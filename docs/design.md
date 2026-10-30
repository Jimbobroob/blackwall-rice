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
- **Prompt: starship**, themed with the palette, in a **"bubbles" layout** (after oh-my-posh's bubblesextra, the user's old prompt): dark rounded pills with coloured Nerd Font icons; path/git/languages right-aligned on line 1, time + status + `user ❯` on line 2. `ls` uses eza with icons. (Changed 2026-10-30: the plain version was too barren.)
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
