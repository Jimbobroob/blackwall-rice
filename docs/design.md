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
- ~~Sharp corners (0px rounding).~~ **Superseded by Afterthoughts: everything is rounded.**
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

### Phase 2 build decisions (2026-10-30)
- Quickshell config lives in `~/rice/quickshell`, linked to `~/.config/quickshell`. `quickshell/theme` is a symlink to `generated/` (palette singleton is **`Theme`**, because `Palette` clashes with a Qt type).
- Windows are keyed by monitor **role** (matched by description), so a KVM switch just recreates that monitor's windows. If the side monitor is away, notifications show on main.
- Workspace clicks use `hyprctl eval` (Lua config). Weather is Open-Meteo (no key); lat/long are in `settings.json`.
- Widget `margin` is `[horizontal, vertical]`. Main widgets: clock top-right, weather below it.
- Clipboard history (Super+Shift+V) is still rofi; it wasn't in the phase 2 scope.

### Phase 3 build decisions (2026-10-30)
- Side bar is 44px wide. Bell shows the history count; the power and history popups open next to the bar, bottom-left. Both also work via `qs ipc call side power|history|close`.
- Updates count uses `dnf check-update` every 30 min; clicking it opens kitty running `sudo dnf upgrade`.
- Side widgets are cards (surface fill, thin border, red tick). Clock style (analog/digital) follows `clock.side_style`.
- Stats come from `quickshell/scripts/stats.sh` (1 s samples); GPU is read from the amdgpu hwmon/`gpu_busy_percent`.

### Phase 4 build decisions (2026-10-30)
- **Discord voice widget uses a custom Vencord plugin** (option B). Discord's local RPC is out: Vesktop's arRPC has no voice/speaking events and `rpc.voice.read` needs Discord approval. The plugin reads voice state from Discord's stores inside Vesktop and talks to Quickshell over a Unix socket in `$XDG_RUNTIME_DIR`; mute/deafen go back over the same socket. Needs a locally built Vencord that Vesktop is pointed at.
- Spotify widget is interactive: `Card.interactive` makes `WidgetHost` accept mouse input (other widgets stay click-through).

---

### Phase 5 build decisions (2026-10-30)
- App themes are all generated by `tools/gen_apps.py` from the palette into `generated/`, then linked (see `links.txt`). Qt uses qt6ct + Fusion with a generated colour scheme (no Kvantum). GTK uses adw-gtk3-dark with libadwaita colour overrides, Papirus-Dark icons.
- Cursor theme is `settings.json` → `look.cursor` (Adwaita for now). Lock timeout is `lock.idle_minutes` (60).
- hyprlock: main monitor gets clock + date + weather + password field; the side monitor shows only a quiet clock. hypridle locks via `loginctl lock-session`; fullscreen windows (games, video) inhibit it via a Hyprland window rule, and browsers' video inhibitors count too.
- Vesktop's theme is *copied* (not linked) because the Flatpak sandbox can't see `~/rice`: run `tools/install-vesktop-theme.sh`.

### Phase 6 build decisions (2026-10-30)
- **Wallpaper differs per monitor** (user choice, overrides "same on both"): main = kimono (1920x1080), side = dark red cyberpunk (2560x1440). Files in `~/Pictures/Wallpapers`, paths in `settings.json` → `wallpaper`; drawn by hyprpaper from `generated/hyprpaper.conf`. Desktop widgets moved to the Bottom layer so they sit above it.
- Glitch effects are Quickshell shaders (`quickshell/fx/`, built by `tools/build-shaders.sh`): widget/launcher/power-menu pop-in (slice shift + RGB split), scanlines on cards, and a red/magenta tear overlay on workspace change (skipped in game mode on main). Levels come from `settings.json` → `glitch_levels`.
- **Widgets are black + red** (user request): cards are near-black (`base` at 90%) with `red_dim` borders, and magenta is dropped from the desktop widgets (the bars keep it for small details). The side tray shows Discord's own icon instead of Vesktop's.
- **Main bar auto-hides** (user request): it slides away and returns when the pointer touches the bottom edge of the main monitor (hides ~0.45s after it leaves); windows use the full screen height. `settings.json` → `bar.main_autohide` (false = always visible, reserves space). The side bar is unchanged.
- **Side widget layout re-planned around the wallpaper** (user request): top strip = clock, Discord, Spotify (above the head); bottom-left = system stats + Spotify (dark floor); bottom-right = network above cava (cava narrowed to 560px); Discord sits under the weather card (grows downward during a call). Left-middle and the figure stay clear. It's all `settings.json` → `widgets.side`, so a new wallpaper means re-placing here.
- **Cards and both bars share one plain translucent style** (user request; liquid glass tried and dropped): `base` at `look.glass.card_opacity` (0.65) with a thin `red_dim` border, no blur or sheen. The side clock has its background back. (Auto-hide for the main bar is unchanged.)
- **Neovim matches the rice** (user request): a palette-generated `blackwall` colourscheme (`tools/gen_apps.py` → `generated/nvim/colors/blackwall.lua`, linked to `~/.config/nvim/colors`) covering core, treesitter, LSP/diagnostics, gitsigns, mini.nvim and blink.cmp, with a transparent background so the terminal's glass shows through (`settings.json` → `look.nvim_transparent`). The user's own existing `init.lua` (C++/C# setup) is untouched apart from its colorscheme line (catppuccin stays installed; `:colorscheme catppuccin` switches back). The from-blank Neovim learning sessions remain separate.
- **Clipboard history is supervised and themed** (user request, used a lot): `hypr/scripts/clipwatch.sh` keeps one text and one image `wl-paste --watch cliphist store` running (restarted if they exit; started at login), and `Super+Shift+V` opens `hypr/scripts/clippick.sh`, a rofi picker themed from the palette (`generated/rofi/blackwall.rasi`, passed with `-theme` so the user's own rofi config is untouched). A Quickshell-native picker is still a possible later upgrade.

## Afterthoughts (2026-10-30, after phase 3)
Changes the user decided after seeing the rice running. These **override** earlier sections where they conflict.
- **Everything is rounded** (replaces "sharp corners / sharp or angled corners"). One setting, `settings.json` → `look.radius` (default **12px**); chips, buttons and small items use half of it. Applies to:
  - Hyprland windows (rounding with a slightly squircle curve),
  - both bars (now **floating pills** with a 6px gap to the screen edge, not flush),
  - all Quickshell widgets/cards, the launcher, notification toasts, the volume OSD, the power menu and the history panel.
- ~~**Terminals are "liquid glass"**~~ **Superseded: terminals are plain translucent** (opacity `look.glass.terminal_opacity` 0.82, no blur, no red tint, normal borders). Original: **Terminals are "liquid glass"**: kitty is translucent (`look.glass.terminal_opacity`, default **0.16**) over a stronger background blur (`look.glass.blur_size` 10, `blur_passes` 3, vibrancy up), with a **red tint** (`look.glass.tint`, default 0.06: the base colour blended toward the signature red) and a soft translucent red edge. Other windows keep their normal look. Opacity is generated into kitty's `colors.conf`, so edit `settings.json` and run `tools/generate.py`.
- The "sharp/angled corners" part of the glitch/HUD description no longer applies. Thin red borders, monospace labels, scanlines and glitch effects (phase 6) still do.

## 4. Build plan
Built in 6 phases. Details, steps and done-checks are in **`docs/phases.md`**. Progress is tracked in **`docs/progress.md`**.
Each phase is started with its slash command in Claude Code: `/rice-phase-1` … `/rice-phase-6`. `/rice-status` shows where things stand.

## 5. Later / out of scope (do NOT build unless asked)
- Neovim config from blank (separate learning sessions)
- Terminal image (e.g. Johnny's gun) via fastfetch
- Login screen (GDM) theming
- Wallpaper: the user supplies it in phase 6
- Pushing the repo to GitHub
- Side bar is docked (flush to the screen edge, full height, no rounding, red_dim line on the inner edge only), not floating. Main bar unchanged. (R4)
- Tiled windows sit flush against the docked side bar: gaps_out left = 0 (applies to both monitors). (R5)
- Side monitor: clock and cava (audio) always on the wallpaper; everything else lives in a top drawer (Caelestia-style) that slides down when the cursor hits the top-centre of the monitor, with tabs System (sysstats, network) / Media (discord, spotify) / Date (calendar, weather); hover or click a tab to switch, `Super + W` / side-bar button pins it open. Groups come from `settings.json` -> `widgets.tabs`. Main-monitor clock/weather stay always on. (R6, R7; replaces the R6 slide-from-side version)
- Spotify and Discord also come out onto the side wallpaper on their own (bottom-left, Spotify then Discord beside it) while Spotify is playing / while in a Discord call, and go away ~8s after. Set by the `when` field (`playing` / `call`) on a `widgets.side` entry; they stay in the Media tab too. (R8)
- The drawer is one box (user request): tabs and widgets sit inside a single translucent panel that hangs from the top edge (top corners off-screen), instead of floating chips and separate cards. (R9)
- System tab (user request): system and network are narrow tall cards side by side, with a btop-style processes card under them (top 8 apps by CPU, same-name processes summed, CPU per core like top; `top` runs only while the tab is shown). The system card also shows VRAM, disk (/) and uptime. A drawer tab in `column` layout can now put several ids on one line (`[["sysstats", "network"], "procs"]`). (R10)
