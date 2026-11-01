# Keybinds

Every keybind in the rice. **Update this file whenever a bind is added, changed or removed.**
`Super` = Windows key.

## Apps
| Keys | Action |
|---|---|
| `Super + Enter` | Open terminal (kitty) |
| `Super + B` | Open Firefox |
| `Super + Space` | App launcher (Quickshell, centre of main monitor). Esc closes, ↑↓ + Enter |
| `Super + S` | Show/hide Spotify window (always on side monitor) |
| `Super + D` | Show/hide Discord window (always on side monitor) |

## Windows
| Keys | Action |
|---|---|
| `Super + W` | Pin the top widget drawer open/closed (also the button under the launcher in the side bar); hovering the top-centre of the side monitor opens it too; clicking a tab pins it on that tab (click the pinned tab again to unpin) |
| `Super + Q` | Close window (Spotify / Vesktop: quit the app, they otherwise stay in the tray) |
| `Super + F` | Fullscreen |
| `Super + V` | Toggle floating |
| `Super + ← ↑ → ↓` | Move focus |
| `Super + Shift + ← ↑ → ↓` | Move the focused window that way: swaps with the window there (they trade places and sizes). If there's none on the workspace that way, the split flips instead (e.g. two stacked + `→` = side by side, this one on the right). Alone on a workspace: swaps with the other monitor's window |
| `Super + Tab` | Throw focused window to the other monitor |
| `Alt + Tab` | Window switcher: live previews of every open window on both monitors (Spotify / Discord too), most recent first. Hold Alt and tap Tab to step (`Alt + Shift + Tab` goes back), let go of Alt to switch. While open: arrows / mouse move, Enter or click picks, Esc cancels |
| `Super + Left-drag` | Move window |
| `Super + Right-drag` | Resize window |

## Workspaces
| Keys | Action |
|---|---|
| `Super + 1…5` | Go to workspace 1–5 (main monitor) |
| `Super + 6…9`, `Super + 0` | Go to workspace 6–10 (side monitor) |
| `Super + Shift + 1…0` | Move focused window to that workspace |

## System
| Keys | Action |
|---|---|
| `Super + L` | Lock screen |
| `Print` | Screenshot an area, then edit it in swappy |
| `Super + Shift + S` | Snip: drag a region or click a window, then edit it in swappy |
| `Super + Shift + V` | Clipboard history: searchable list of everything you've copied (text and images), Enter copies the entry, Esc cancels. Themed rofi (`hypr/scripts/clippick.sh`) |

## Media keys
| Keys | Action |
|---|---|
| `Volume Up / Down` | Volume ±5% (max 100%) |
| `Mute` | Mute speakers |
| `Mic Mute` | Mute microphone |
| `Play/Pause`, `Next`, `Prev` | Control the current player (Spotify) |

## Audio (no media keys needed)
| Keys | Action |
|---|---|
| `Super + =` / `Super + -` | Volume ±5% (max 100%), hold to repeat |
| `Super + M` | Mute microphone |
| `Super + Shift + M` | Mute speakers |
| `Super + P` | Play/pause the current player (Spotify) |
| `Super + ]` / `Super + [` | Next / previous track |

## Changelog
- 2026-10-30: initial set agreed during design.
- 2026-10-30: added `Super + S` (Spotify), `Super + D` (Discord), `Super + Tab` (window to other monitor).
- 2026-10-30 (phase 1): added `Super + Left/Right-drag` (move/resize), media keys. `Super + Space` and `Super + Shift + V` use rofi until phase 2. Keyboard layout is now UK only, so `Super + Space` no longer switches layout.
- 2026-10-30 (phase 2): `Super + Space` is now the Quickshell launcher (`qs ipc call launcher toggle`). Clipboard history stays on rofi.
- 2026-10-30 (phase 4): added `Super + Shift + S` snip (region or window, via `hypr/scripts/snip.sh`).
- 2026-10-30 (phase 5): added `Super + B` (Firefox).
- 2026-10-30 (refine): `Super + Shift + V` clipboard history fixed (recording was not running) and themed from the palette.
- 2026-10-31 (refine): `Super + Q` quits Spotify/Vesktop (flatpak kill) instead of only closing their window.
- 2026-10-31 (refine): added `Super + W` (widget drawer).
- 2026-10-31 (refine): clicking a drawer tab pins the drawer (mouse, not a key).
- 2026-10-31 (refine): added `Super + Shift + arrows` (swap window with its neighbour).
- 2026-10-31 (refine): `Super + Shift + arrows` also flips the split (stacked <-> side by side) when there's no window that way.
- 2026-10-31 (refine): added `Alt + Tab` / `Alt + Shift + Tab` window switcher (Quickshell, `quickshell/switcher`).
- 2026-11-01: added Super audio binds for keyboards without media keys: `Super + =` / `-` (volume), `Super + M` (mic mute), `Super + Shift + M` (speaker mute), `Super + P` (play/pause), `Super + ]` / `[` (next/previous).
