# Keybinds

Every keybind in the rice. **Update this file whenever a bind is added, changed or removed.**
`Super` = Windows key.

## Apps
| Keys | Action |
|---|---|
| `Super + Enter` | Open terminal (kitty) |
| `Super + Space` | App launcher (Quickshell, centre of main monitor). Esc closes, ↑↓ + Enter |
| `Super + S` | Show/hide Spotify window (always on side monitor) |
| `Super + D` | Show/hide Discord window (always on side monitor) |

## Windows
| Keys | Action |
|---|---|
| `Super + Q` | Close window |
| `Super + F` | Fullscreen |
| `Super + V` | Toggle floating |
| `Super + ← ↑ → ↓` | Move focus |
| `Super + Tab` | Throw focused window to the other monitor |
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
| `Super + Shift + V` | Clipboard history (still a rofi picker, not part of the phase 2 scope) |

## Media keys
| Keys | Action |
|---|---|
| `Volume Up / Down` | Volume ±5% (max 100%) |
| `Mute` | Mute speakers |
| `Mic Mute` | Mute microphone |
| `Play/Pause`, `Next`, `Prev` | Control the current player (Spotify) |

## Changelog
- 2026-10-30: initial set agreed during design.
- 2026-10-30: added `Super + S` (Spotify), `Super + D` (Discord), `Super + Tab` (window to other monitor).
- 2026-10-30 (phase 1): added `Super + Left/Right-drag` (move/resize), media keys. `Super + Space` and `Super + Shift + V` use rofi until phase 2. Keyboard layout is now UK only, so `Super + Space` no longer switches layout.
- 2026-10-30 (phase 2): `Super + Space` is now the Quickshell launcher (`qs ipc call launcher toggle`). Clipboard history stays on rofi.
