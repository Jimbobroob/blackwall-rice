# Blackwall rice

> **Disclaimer:** this rice was made entirely by [Claude](https://claude.ai), Anthropic's AI, apart from the art.

Darker-cyberpunk Hyprland rice for Fedora 44: near-black base, signature red `#FF0033`, magenta details.
Quickshell draws the bars, widgets, launcher, notifications and power menu. Everything is built from
this folder and symlinked into `~/.config`. Design decisions live in `docs/design.md`, keybinds in
`docs/keybinds.md`, build history in `docs/progress.md`.

## What's where
| Path | What |
|---|---|
| `theme/palette.json` | **The** palette. Every colour comes from here. |
| `settings.json` | Everything you'd want to tweak (see below). |
| `generated/` | Built from the two files above by `tools/generate.py`. Never edit by hand. |
| `hypr/` | Hyprland config (Lua, `hyprland.lua` + `modules/`), hyprlock, hypridle, helper scripts |
| `quickshell/` | Bars, widgets, launcher, OSD, notifications, menus, services; `fx/` holds the glitch shaders |
| `kitty/`, `fish/`, `btop/` | Terminal, shell, system monitor |
| `vencord/` | RiceVoice plugin that feeds the Discord voice widget |
| `tools/` | Generators and installers (below) |
| `install.sh`, `rollback.sh`, `links.txt` | Install and undo |

## Changing things
Edit `theme/palette.json` or `settings.json`, then run `python3 tools/generate.py` (Quickshell and
Hyprland pick up most changes live; run `hyprctl reload` for Hyprland-side ones).

Personal values go in `~/.config/blackwall-rice/private.json`, which overrides `settings.json` and stays out of the repo, e.g. `{"weather": {"location": "...", "latitude": 0.0, "longitude": 0.0}}`.

`settings.json` highlights:
- `glitch_level`: `subtle`, `medium` or `heavy` (profiles in `glitch_levels`: pop-in length, slice strength, scanlines, workspace tear).
- `clock`: `format` (`24h`/`12h`), `main_style`, `side_style` (`digital`/`analog`).
- `widgets.main` / `widgets.side`: which widgets show, anchor and margin `[horizontal, vertical]`.
- `wallpaper`: image per monitor (`main`, `side`) and `fit`. Regenerate, then restart hyprpaper
  (`pkill hyprpaper; hyprpaper -c ~/.config/hypr/generated/hyprpaper.conf &`).
- `look`: corner `radius`, terminal `glass` (opacity, blur, tint), `cursor`, `icon_theme`.
- `weather`, `lock.idle_minutes`, `bar`, `launcher`, `notifications`, `osd`, monitor descriptions and workspaces.

## Install / rollback
```
~/Source/rices/blackwall-rice/install.sh        # back up current ~/.config entries to ~/rice-old-backup/<timestamp>/, then symlink (see links.txt)
~/Source/rices/blackwall-rice/rollback.sh       # undo every install, newest first (--last = just the latest)
```
Nothing is ever deleted: old files are moved to the backup folder.

## Tools
- `tools/generate.py` (+ `gen_apps.py`): palette/settings to every config format.
- `tools/build-shaders.sh`: recompile `quickshell/fx/*.frag` to `.qsb` after editing a shader.
- `tools/install-fonts.sh` (Rajdhani), `tools/apply-gsettings.sh` (GTK; `--restore` undoes),
  `tools/install-vesktop-theme.sh`, `tools/build-vencord.sh`.

## Notes
- Monitors are matched by description, so the KVM renaming ports is fine; widgets and workspaces follow when a screen returns.
- Game mode (any real fullscreen window on the main monitor) turns blur, animations, borders and the bar off there; the side monitor is untouched.
- Keybinds: see `docs/keybinds.md`. Super+Enter launcher, Super+S Spotify, Super+D Discord, Super+L lock.
