"""Phase 5 outputs: app themes + lock screen, all built from the palette.

Called from generate.py. Everything lands in ~/Source/rices/blackwall-rice/generated/ (never edit by hand).
"""
from generate import HEADER, OUT, hexbare, mix


def write(rel, text):
    path = OUT / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)


def rgb_triplet(h):
    return ";".join(str(int(h.lstrip("#")[i:i + 2], 16)) for i in (0, 2, 4))


def gen_gtk(c, ansi):
    """libadwaita named colours: read by GTK4/libadwaita apps and by adw-gtk3 (GTK3)."""
    pairs = {
        "accent_bg_color": c["red"], "accent_fg_color": c["base"], "accent_color": c["red"],
        "destructive_bg_color": c["red_dim"], "destructive_fg_color": c["text"], "destructive_color": c["red"],
        "success_bg_color": ansi["green"], "success_fg_color": c["base"], "success_color": ansi["green"],
        "warning_bg_color": c["warning"], "warning_fg_color": c["base"], "warning_color": c["warning"],
        "error_bg_color": c["red_dim"], "error_fg_color": c["text"], "error_color": c["red"],
        "window_bg_color": c["base"], "window_fg_color": c["text"],
        "view_bg_color": c["surface"], "view_fg_color": c["text"],
        "headerbar_bg_color": c["surface"], "headerbar_fg_color": c["text"],
        "headerbar_border_color": c["overlay"], "headerbar_backdrop_color": c["base"],
        "headerbar_shade_color": c["base"],
        "card_bg_color": c["surface"], "card_fg_color": c["text"], "card_shade_color": c["base"],
        "dialog_bg_color": c["surface"], "dialog_fg_color": c["text"],
        "popover_bg_color": c["surface"], "popover_fg_color": c["text"], "popover_shade_color": c["base"],
        "sidebar_bg_color": c["surface"], "sidebar_fg_color": c["text"],
        "sidebar_backdrop_color": c["base"], "sidebar_border_color": c["overlay"], "sidebar_shade_color": c["base"],
        "secondary_sidebar_bg_color": c["base"], "secondary_sidebar_fg_color": c["text"],
        "secondary_sidebar_backdrop_color": c["base"], "secondary_sidebar_shade_color": c["base"],
        "thumbnail_bg_color": c["overlay"], "thumbnail_fg_color": c["text"],
        "shade_color": mix(c["base"], "#000000", 0.5),
        "scrollbar_outline_color": c["base"],
    }
    css = f"/* {HEADER} */\n" + "".join(f"@define-color {k} {v};\n" for k, v in pairs.items())
    css += (
        "\n/* thin red focus ring + selection to match the Hyprland borders */\n"
        f"selection {{ background-color: alpha({c['red']}, 0.45); color: {c['text']}; }}\n"
    )
    write("gtk/gtk.css", css)


def gen_qt(c, ansi):
    """qt5ct/qt6ct colour scheme. 22 roles for Qt6 (qt5ct ignores the extra one)."""
    def row(text, button, base, window, hl, hl_text, link, dim=False):
        light = mix(button, c["text"], 0.18)
        mid_light = mix(button, c["text"], 0.09)
        dark = mix(button, c["base"], 0.55)
        mid = mix(button, c["base"], 0.3)
        return ", ".join([
            text, button, light, mid_light, dark, mid, text, "#FFFFFF", text,
            base, window, "#000000", hl, hl_text, link, c["red_dim"],
            mix(base, c["overlay"], 0.5), "#000000", c["surface"], c["text"], c["muted"], hl,
        ])
    active = row(c["text"], c["overlay"], c["surface"], c["base"], c["red"], c["base"], c["magenta"])
    disabled = row(c["muted"], c["overlay"], c["surface"], c["base"], c["red_dim"], c["muted"], c["muted"])
    write("qt/blackwall.conf",
          f"# {HEADER}\n[ColorScheme]\nactive_colors={active}\ninactive_colors={active}\ndisabled_colors={disabled}\n")


UI_FONT = "JetBrainsMono Nerd Font"


def gen_toolkit_settings(settings):
    """GTK settings.ini and the qt5ct/qt6ct configs (cursor, icons, font, colour scheme)."""
    from pathlib import Path
    look = settings["look"]
    cur, icons = look["cursor"], look["icon_theme"]
    gtk = (f"# {HEADER}\n[Settings]\ngtk-theme-name=adw-gtk3-dark\ngtk-application-prefer-dark-theme=true\n"
           f"gtk-icon-theme-name={icons}\ngtk-font-name={UI_FONT} 10\n"
           f"gtk-cursor-theme-name={cur['theme']}\ngtk-cursor-theme-size={cur['size']}\n")
    write("gtk/settings.ini", gtk)
    scheme = Path.home() / ".config/qt6ct/colors/blackwall.conf"
    font = f'"{UI_FONT},10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"'
    for n in ("5", "6"):
        write(f"qt/qt{n}ct.conf", f"""# {HEADER}
[Appearance]
color_scheme_path={scheme}
custom_palette=true
icon_theme={icons}
standard_dialogs=default
style=Fusion

[Fonts]
fixed={font}
general={font}

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3

[Troubleshooting]
force_raster_widgets=1
ignored_applications=@Invalid()
""")


def gen_btop(c, ansi):
    def grad(prefix, a, b, mid=None):
        lines = [f'theme[{prefix}_start]="{a}"']
        if mid:
            lines.append(f'theme[{prefix}_mid]="{mid}"')
        lines.append(f'theme[{prefix}_end]="{b}"')
        return lines
    t = [
        f"# btop theme. {HEADER}",
        'theme[main_bg]=""',  # empty = terminal background, so the glass shows through
        f'theme[main_fg]="{c["text"]}"',
        f'theme[title]="{c["text"]}"',
        f'theme[hi_fg]="{c["red"]}"',
        f'theme[selected_bg]="{c["red_dim"]}"',
        f'theme[selected_fg]="{c["text"]}"',
        f'theme[inactive_fg]="{c["muted"]}"',
        f'theme[graph_text]="{c["muted"]}"',
        f'theme[meter_bg]="{c["overlay"]}"',
        f'theme[proc_misc]="{c["magenta"]}"',
        f'theme[cpu_box]="{c["red_dim"]}"',
        f'theme[mem_box]="{c["red_dim"]}"',
        f'theme[net_box]="{c["red_dim"]}"',
        f'theme[proc_box]="{c["red_dim"]}"',
        f'theme[div_line]="{c["overlay"]}"',
    ]
    t += grad("temp", ansi["cyan"], c["red"], c["warning"])
    t += grad("cpu", c["red_dim"], c["red"], c["magenta"])
    t += grad("free", c["red_dim"], ansi["green"])
    t += grad("cached", c["red_dim"], c["magenta"])
    t += grad("available", c["red_dim"], c["warning"])
    t += grad("used", c["red_dim"], c["red"])
    t += grad("download", c["red_dim"], c["red"], c["magenta"])
    t += grad("upload", c["red_dim"], c["magenta"], c["red"])
    write("btop/blackwall.theme", "\n".join(t) + "\n")


def gen_spotify_player(c, ansi):
    """spotify_player TUI theme. No background is set, so it stays on the terminal's."""
    def st(fg=None, bg=None, bold=False):
        parts = []
        if fg:
            parts.append(f'fg = "{fg}"')
        if bg:
            parts.append(f'bg = "{bg}"')
        if bold:
            parts.append('modifiers = ["Bold"]')
        return "{ " + ", ".join(parts) + " }"
    t = f"""# {HEADER}
[[themes]]
name = "blackwall"

[themes.palette]
foreground = "{c['text']}"
black = "{c['base']}"
red = "{c['red']}"
green = "{ansi['green']}"
yellow = "{c['warning']}"
blue = "{ansi['blue']}"
magenta = "{c['magenta']}"
cyan = "{ansi['cyan']}"
white = "{c['text']}"
bright_black = "{ansi['bright_black']}"
bright_red = "{c['red']}"
bright_green = "{ansi['bright_green']}"
bright_yellow = "{ansi['bright_yellow']}"
bright_blue = "{ansi['bright_blue']}"
bright_magenta = "{c['magenta']}"
bright_cyan = "{ansi['bright_cyan']}"
bright_white = "{c['text']}"

[themes.component_style]
block_title = {st(c['red'], bold=True)}
border = {st(c['overlay'])}
playback_status = {st(c['red'], bold=True)}
playback_track = {st(c['red'], bold=True)}
playback_artists = {st(c['text'], bold=True)}
playback_album = {st(c['magenta'])}
playback_genres = {st(c['muted'])}
playback_metadata = {st(c['muted'])}
playback_progress_bar = {st(c['red'])}
playback_progress_bar_unfilled = {st(c['overlay'])}
current_playing = {st(c['magenta'], bold=True)}
page_desc = {st(c['red'], bold=True)}
playlist_desc = {st(c['muted'])}
table_header = {st(c['muted'], bold=True)}
selection = {st(c['red'], bold=True)}
like = {st(c['red'])}
lyrics_played = {st(c['muted'])}
lyrics_playing = {st(c['red'], bold=True)}
visualization = {{ low = "{mix(c['red_dim'], c['base'], 0.35)}", mid = "{c['red']}", high = "{mix(c['magenta'], c['text'], 0.45)}" }}
"""
    write("spotify-player/theme.toml", t)


def gen_yazi(c, ansi):
    def st(fg=None, bg=None, bold=False):
        parts = []
        if fg:
            parts.append(f'fg = "{fg}"')
        if bg:
            parts.append(f'bg = "{bg}"')
        if bold:
            parts.append('bold = true')
        return "{ " + ", ".join(parts) + " }"
    t = f"""# {HEADER}
[mgr]
cwd = {st(c['red'], bold=True)}
hovered = {st(c['base'], c['red'])}
preview_hovered = {st(c['base'], c['muted'])}
find_keyword = {st(c['magenta'], bold=True)}
find_position = {st(c['magenta'])}
marker_copied = {st(c['green'] if 'green' in c else ansi['green'], ansi['green'])}
marker_cut = {st(c['red'], c['red'])}
marker_marked = {st(c['magenta'], c['magenta'])}
marker_selected = {st(c['warning'], c['warning'])}
count_copied = {st(c['base'], ansi['green'])}
count_cut = {st(c['base'], c['red'])}
count_selected = {st(c['base'], c['warning'])}
border_style = {st(c['red_dim'])}

[tabs]
active = {st(c['base'], c['red'], True)}
inactive = {st(c['muted'], c['overlay'])}

[mode]
normal_main = {st(c['base'], c['red'], True)}
normal_alt = {st(c['red'], c['overlay'])}
select_main = {st(c['base'], c['magenta'], True)}
select_alt = {st(c['magenta'], c['overlay'])}
unset_main = {st(c['base'], c['warning'], True)}
unset_alt = {st(c['warning'], c['overlay'])}

[status]
overall = {st(c['text'], c['surface'])}
sep_left = {{ open = "", close = "" }}
sep_right = {{ open = "", close = "" }}
perm_type = {st(ansi['green'])}
perm_read = {st(c['warning'])}
perm_write = {st(c['red'])}
perm_exec = {st(ansi['cyan'])}
perm_sep = {st(c['muted'])}
progress_label = {st(c['text'], bold=True)}
progress_normal = {st(c['red'], c['overlay'])}
progress_error = {st(c['warning'], c['overlay'])}

[pick]
border = {st(c['red'])}
active = {st(c['magenta'], bold=True)}
inactive = {st(c['text'])}

[input]
border = {st(c['red'])}
title = {{}}
value = {{}}
selected = {{ reversed = true }}

[completion]
border = {st(c['red'])}
active = {st(c['base'], c['red'])}
inactive = {{}}

[tasks]
border = {st(c['red'])}
title = {{}}
hovered = {st(c['red'], bold=True)}

[which]
cols = 3
mask = {st(bg=c['surface'])}
cand = {st(ansi['cyan'])}
rest = {st(c['muted'])}
desc = {st(c['magenta'])}
separator = "  "
separator_style = {st(c['muted'])}

[help]
on = {st(c['red'])}
run = {st(c['magenta'])}
desc = {st(c['text'])}
hovered = {st(c['base'], c['red'])}
footer = {st(c['text'], c['surface'])}

[notify]
title_info = {st(ansi['cyan'])}
title_warn = {st(c['warning'])}
title_error = {st(c['red'])}

[filetype]
rules = [
    {{ mime = "image/*", fg = "{ansi['cyan']}" }},
    {{ mime = "{{audio,video}}/*", fg = "{c['magenta']}" }},
    {{ mime = "application/{{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}}", fg = "{c['warning']}" }},
    {{ mime = "application/{{pdf,doc,rtf}}", fg = "{ansi['bright_blue']}" }},
    {{ url = "*", is = "orphan", bg = "{c['red_dim']}" }},
    {{ url = "*", is = "exec", fg = "{ansi['green']}" }},
    {{ url = "*/", fg = "{c['red']}" }},
    {{ url = "*", fg = "{c['text']}" }},
]
"""
    write("yazi/theme.toml", t)


def gen_cava(c, ansi):
    t = f"""# {HEADER}
[general]
framerate = 60

[input]
method = pulse
source = auto

[output]
method = noncurses
orientation = bottom
channels = stereo
bar_width = 2
bar_spacing = 1

[color]
gradient = 1
gradient_count = 3
gradient_color_1 = '{c['red_dim']}'
gradient_color_2 = '{c['red']}'
gradient_color_3 = '{c['magenta']}'

[smoothing]
noise_reduction = 77
monstercat = 1
waves = 0
gravity = 120
"""
    write("cava/config", t)


def gen_fastfetch(c, ansi):
    red, mag, muted = rgb_triplet(c["red"]), rgb_triplet(c["magenta"]), rgb_triplet(c["muted"])
    text = rgb_triplet(c["text"])
    cfg = f"""// {HEADER}
{{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {{
        "type": "small",
        "color": {{ "1": "38;2;{red}", "2": "38;2;{mag}" }},
        "padding": {{ "top": 1, "left": 2, "right": 4 }}
    }},
    "display": {{
        "separator": "  ",
        "color": {{ "keys": "38;2;{red}", "title": "38;2;{text}", "output": "38;2;{text}", "separator": "38;2;{muted}" }},
        "percent": {{ "color": {{ "green": "38;2;{text}", "yellow": "38;2;{mag}", "red": "38;2;{red}" }} }}
    }},
    "modules": [
        "break",
        {{ "type": "title", "color": {{ "user": "1;38;2;{red}", "at": "38;2;{muted}", "host": "1;38;2;{mag}" }} }},
        {{ "type": "separator", "string": "─", "outputColor": "38;2;{muted}" }},
        {{ "type": "os", "key": "OS    " }},
        {{ "type": "kernel", "key": "KERNEL", "format": "{{release}}" }},
        {{ "type": "wm", "key": "WM    ", "format": "{{pretty-name}}" }},
        {{ "type": "shell", "key": "SHELL " }},
        {{ "type": "terminal", "key": "TERM  ", "format": "{{pretty-name}}" }},
        {{ "type": "cpu", "key": "CPU   ", "format": "{{name}}" }},
        {{ "type": "gpu", "key": "GPU   ", "format": "{{name}}" }},
        {{ "type": "memory", "key": "MEMORY" }},
        {{ "type": "uptime", "key": "UPTIME" }},
        "break",
        {{ "type": "colors", "symbol": "circle" }},
        "break"
    ]
}}
"""
    write("fastfetch/config.jsonc", cfg)


def gen_lock(c, ansi, settings):
    h = {k: hexbare(v) for k, v in {**c, **ansi}.items()}
    radius = settings["look"]["radius"]
    fmt = "%H:%M" if settings["clock"]["format"] == "24h" else "%I:%M"
    mono = "JetBrainsMono Nerd Font"
    main_desc = settings["monitors"]["main"]["desc"]
    side_desc = settings["monitors"]["side"]["desc"]
    lock = f"""# {HEADER}
general {{
    hide_cursor = true
    ignore_empty_input = true
    grace = {settings['lock']['grace_seconds']}
}}

animations {{
    enabled = true
    bezier = snap, 0.16, 1, 0.3, 1
    animation = fadeIn, 1, 3, snap
    animation = fadeOut, 1, 3, snap
    animation = inputFieldDots, 1, 2, snap
}}

# Wallpaper arrives in phase 6; until then, a dark blurred copy of the screen.
background {{
    monitor =
    path = screenshot
    color = rgb({h['base']})
    blur_passes = 3
    blur_size = 8
    brightness = 0.35
    vibrancy = 0.1
}}

# ---------- main monitor: clock, date, weather, password ----------
label {{
    monitor = desc:{main_desc}
    text = cmd[update:1000] date +"{fmt}"
    color = rgb({h['text']})
    font_size = 190
    font_family = Rajdhani Bold
    position = 0, 190
    halign = center
    valign = center
    shadow_passes = 2
    shadow_size = 6
    shadow_color = rgba({h['red']}66)
}}

label {{
    monitor = desc:{main_desc}
    text = cmd[update:60000] date +"%A  ·  %d %B %Y" | tr a-z A-Z
    color = rgb({h['magenta']})
    font_size = 22
    font_family = Rajdhani SemiBold
    position = 0, 40
    halign = center
    valign = center
}}

label {{
    monitor = desc:{main_desc}
    text = cmd[update:30000] $HOME/.config/hypr/scripts/lock_weather.py
    color = rgb({h['text']})
    font_size = 15
    font_family = {mono}
    position = 0, -10
    halign = center
    valign = center
}}

label {{
    monitor = desc:{main_desc}
    text = // SESSION LOCKED
    color = rgb({h['red']})
    font_size = 12
    font_family = {mono}
    position = 0, -110
    halign = center
    valign = center
}}

input-field {{
    monitor = desc:{main_desc}
    size = 320, 52
    outline_thickness = 2
    dots_size = 0.22
    dots_spacing = 0.35
    dots_center = true
    rounding = {radius}
    outer_color = rgb({h['red']})
    inner_color = rgba({h['surface']}E6)
    font_color = rgb({h['text']})
    font_family = {mono}
    check_color = rgb({h['magenta']})
    fail_color = rgb({h['red']})
    fail_text = <i>ACCESS DENIED</i>
    capslock_color = rgb({h['warning']})
    placeholder_text = <span foreground="##{h['muted']}">enter password</span>
    fade_on_empty = false
    position = 0, -170
    halign = center
    valign = center
}}

# ---------- side monitor: quiet clock only ----------
label {{
    monitor = desc:{side_desc}
    text = cmd[update:1000] date +"{fmt}"
    color = rgb({h['text']})
    font_size = 220
    font_family = Rajdhani Bold
    position = 0, 40
    halign = center
    valign = center
    shadow_passes = 2
    shadow_size = 6
    shadow_color = rgba({h['red']}66)
}}

label {{
    monitor = desc:{side_desc}
    text = // LOCKED
    color = rgb({h['red']})
    font_size = 14
    font_family = {mono}
    position = 0, -90
    halign = center
    valign = center
}}
"""
    write("hyprlock.conf", lock)

    idle = f"""# {HEADER}
general {{
    lock_cmd = pidof hyprlock || hyprlock
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
    # Respect idle inhibitors (fullscreen games/video, browsers playing video).
    ignore_dbus_inhibit = false
    ignore_systemd_inhibit = false
}}

listener {{
    timeout = {settings['lock']['idle_minutes'] * 60}
    on-timeout = loginctl lock-session
}}
"""
    write("hypridle.conf", idle)


def gen_firefox(c, ansi):
    root = f"""/* {HEADER} */
:root {{
  --rice-base: {c['base']};
  --rice-surface: {c['surface']};
  --rice-overlay: {c['overlay']};
  --rice-text: {c['text']};
  --rice-muted: {c['muted']};
  --rice-red: {c['red']};
  --rice-red-dim: {c['red_dim']};
  --rice-magenta: {c['magenta']};
}}
"""
    chrome = root + """
:root {
  --toolbar-bgcolor: var(--rice-surface) !important;
  --toolbar-color: var(--rice-text) !important;
  --toolbar-field-background-color: var(--rice-base) !important;
  --toolbar-field-color: var(--rice-text) !important;
  --toolbar-field-border-color: var(--rice-overlay) !important;
  --toolbar-field-focus-background-color: var(--rice-base) !important;
  --toolbar-field-focus-color: var(--rice-text) !important;
  --toolbar-field-focus-border-color: var(--rice-red) !important;
  --lwt-accent-color: var(--rice-base) !important;
  --lwt-text-color: var(--rice-text) !important;
  --lwt-selected-tab-background-color: var(--rice-surface) !important;
  --tab-selected-bgcolor: var(--rice-surface) !important;
  --tab-selected-textcolor: var(--rice-text) !important;
  --tab-loading-fill: var(--rice-red) !important;
  --arrowpanel-background: var(--rice-surface) !important;
  --arrowpanel-color: var(--rice-text) !important;
  --arrowpanel-border-color: var(--rice-overlay) !important;
  --urlbarView-highlight-background: var(--rice-red-dim) !important;
  --urlbarView-highlight-color: var(--rice-text) !important;
  --focus-outline-color: var(--rice-red) !important;
  --sidebar-background-color: var(--rice-base) !important;
  --sidebar-text-color: var(--rice-text) !important;
  --button-primary-bgcolor: var(--rice-red) !important;
  --button-primary-color: var(--rice-base) !important;
  --button-primary-hover-bgcolor: var(--rice-magenta) !important;
}
#navigator-toolbox { background: var(--rice-base) !important; border-bottom: 1px solid var(--rice-red-dim) !important; }
#nav-bar, #PersonalToolbar { background: var(--rice-surface) !important; }
.tab-background { border-radius: 8px !important; }
.tab-background[selected] { background: var(--rice-surface) !important; border: 1px solid var(--rice-red) !important; box-shadow: none !important; }
.tabbrowser-tab:not([selected]):hover .tab-background { background: var(--rice-overlay) !important; }
#urlbar-background { border-radius: 8px !important; border: 1px solid var(--rice-overlay) !important; }
#urlbar[focused] #urlbar-background { border-color: var(--rice-red) !important; box-shadow: none !important; }
"""
    content = root + """
@-moz-document url-prefix("about:") {
  :root {
    --in-content-page-background: var(--rice-base) !important;
    --in-content-page-color: var(--rice-text) !important;
    --in-content-box-background: var(--rice-surface) !important;
    --in-content-box-border-color: var(--rice-overlay) !important;
    --in-content-item-hover: var(--rice-overlay) !important;
    --in-content-item-selected: var(--rice-red-dim) !important;
    --in-content-primary-button-background: var(--rice-red) !important;
    --in-content-primary-button-text-color: var(--rice-base) !important;
    --in-content-accent-color: var(--rice-red) !important;
    --in-content-link-color: var(--rice-magenta) !important;
    --newtab-background-color: var(--rice-base) !important;
    --newtab-text-primary-color: var(--rice-text) !important;
    --newtab-primary-action-background: var(--rice-red) !important;
  }
}
"""
    write("firefox/chrome/userChrome.css", chrome)
    write("firefox/chrome/userContent.css", content)
    write("firefox/user.js", """// Generated by tools/generate.py. Do not edit.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("browser.startup.homepage", "about:home");
user_pref("browser.theme.content-theme", 0);
user_pref("browser.theme.toolbar-theme", 0);
user_pref("layout.css.prefers-color-scheme.content-override", 0);
""")


def gen_spicetify(c, ansi):
    def bare(k):
        return hexbare(c[k])
    ini = f"""; {HEADER}
[base]
text               = {bare('text')}
subtext            = {bare('muted')}
main               = {bare('base')}
main-elevated      = {bare('surface')}
highlight          = {bare('overlay')}
highlight-elevated = {bare('overlay')}
sidebar            = {bare('base')}
player             = {bare('base')}
card               = {bare('surface')}
shadow             = 000000
selected-row       = {bare('text')}
button             = {bare('red')}
button-active      = {bare('magenta')}
button-disabled    = {bare('red_dim')}
tab-active         = {bare('overlay')}
notification       = {bare('surface')}
notification-error = {bare('red')}
equalizer          = {bare('magenta')}
misc               = {bare('overlay')}
"""
    css = f"""/* {HEADER} */
/* Thin red accents + rounded cards on top of the recoloured Spotify UI. */
.main-nowPlayingBar-nowPlayingBar {{ border-top: 1px solid {c['red_dim']} !important; }}
.main-trackList-selected, .main-trackList-trackListRow:hover {{ border-radius: 8px; }}
.Root__main-view, .main-view-container {{ border-radius: 12px; }}
/* Spotify tints page headers from cover art (home shortcuts, playlists, albums, artists): pin them to red. */
.main-home-homeHeader, .main-entityHeader-background, .main-entityHeader-backgroundColor,
.main-actionBarBackground-background, .main-entityHeader-overlay {{ background-color: {c['red_dim']} !important; }}
"""
    write("spicetify/Blackwall/color.ini", ini)
    write("spicetify/Blackwall/user.css", css)


def gen_vesktop(c, ansi):
    css = f"""/**
 * @name Blackwall
 * @description Red-on-black theme generated from the rice palette
 * @author rice
 * {HEADER}
 */
:root, .theme-dark, .theme-darker, .theme-light {{
  --background-primary: {c['base']};
  --background-secondary: {c['surface']};
  --background-secondary-alt: {c['surface']};
  --background-tertiary: {c['base']};
  --background-accent: {c['overlay']};
  --background-floating: {c['surface']};
  --background-modifier-hover: {mix(c['overlay'], c['base'], 0.4)};
  --background-modifier-active: {c['overlay']};
  --background-modifier-selected: {c['overlay']};
  --background-modifier-accent: {c['overlay']};
  --channeltextarea-background: {c['surface']};
  --text-normal: {c['text']};
  --text-muted: {c['muted']};
  --text-link: {c['magenta']};
  --header-primary: {c['text']};
  --header-secondary: {c['muted']};
  --interactive-normal: {c['muted']};
  --interactive-hover: {c['text']};
  --interactive-active: {c['red']};
  --brand-experiment: {c['red']};
  --brand-experiment-560: {c['red']};
  --brand-500: {c['red']};
  --brand-360: {c['red']};
  --scrollbar-thin-thumb: {c['red_dim']};
  --scrollbar-auto-thumb: {c['red_dim']};
  --scrollbar-thin-track: transparent;
  --scrollbar-auto-track: transparent;
  --bg-base-primary: {c['base']};
  --bg-base-secondary: {c['surface']};
  --bg-base-tertiary: {c['base']};
  --background-base-lowest: {c['base']};
  --background-base-lower: {c['base']};
  --background-base-low: {c['surface']};
  --background-surface-high: {c['surface']};
  --background-surface-higher: {c['overlay']};
  --background-surface-highest: {c['overlay']};
  --chat-background-default: {c['base']};
  --bg-surface-overlay: {c['surface']};
  --modal-background: {c['surface']};
  --input-background: {c['surface']};
  --text-default: {c['text']};
  --text-strong: {c['text']};
  --text-subtle: {c['muted']};
  --interactive-icon-default: {c['muted']};
  --interactive-icon-hover: {c['text']};
  --interactive-icon-active: {c['red']};
  --border-subtle: {c['overlay']};
  --border-normal: {c['overlay']};
  --brand-100: {c['red']};
  --brand-experiment-100: {c['red']};
  --blurple-100: {c['red']};
  --brand-130: {c['red']};
  --brand-experiment-130: {c['red']};
  --blurple-130: {c['red']};
  --brand-160: {c['red']};
  --brand-experiment-160: {c['red']};
  --blurple-160: {c['red']};
  --brand-200: {c['red']};
  --brand-experiment-200: {c['red']};
  --blurple-200: {c['red']};
  --brand-230: {c['red']};
  --brand-experiment-230: {c['red']};
  --blurple-230: {c['red']};
  --brand-260: {c['red']};
  --brand-experiment-260: {c['red']};
  --blurple-260: {c['red']};
  --brand-300: {c['red']};
  --brand-experiment-300: {c['red']};
  --blurple-300: {c['red']};
  --brand-330: {c['red']};
  --brand-experiment-330: {c['red']};
  --blurple-330: {c['red']};
  --brand-360: {c['red']};
  --brand-experiment-360: {c['red']};
  --blurple-360: {c['red']};
  --brand-345: {c['red']};
  --background-brand: {c['red']};
  --control-primary-background-default: {c['red']};
  --control-primary-background-hover: {c['red_dim']};
  --control-primary-background-active: {c['red_dim']};
  --badge-primary-background: {c['red']};
  --badge-primary-border: {c['red']};
  --brand-05a: color-mix(in srgb, {c['red']} 5%, transparent);
  --brand-10a: color-mix(in srgb, {c['red']} 10%, transparent);
  --brand-15a: color-mix(in srgb, {c['red']} 15%, transparent);
  --brand-20a: color-mix(in srgb, {c['red']} 20%, transparent);
  --brand-25a: color-mix(in srgb, {c['red']} 25%, transparent);
  --brand-30a: color-mix(in srgb, {c['red']} 30%, transparent);
  --brand-35a: color-mix(in srgb, {c['red']} 35%, transparent);
  --brand-40a: color-mix(in srgb, {c['red']} 40%, transparent);
  --brand-45a: color-mix(in srgb, {c['red']} 45%, transparent);
  --brand-50a: color-mix(in srgb, {c['red']} 50%, transparent);
  --brand-55a: color-mix(in srgb, {c['red']} 55%, transparent);
  --brand-60a: color-mix(in srgb, {c['red']} 60%, transparent);
  --brand-65a: color-mix(in srgb, {c['red']} 65%, transparent);
  --brand-70a: color-mix(in srgb, {c['red']} 70%, transparent);
  --brand-75a: color-mix(in srgb, {c['red']} 75%, transparent);
  --brand-80a: color-mix(in srgb, {c['red']} 80%, transparent);
  --brand-85a: color-mix(in srgb, {c['red']} 85%, transparent);
  --brand-90a: color-mix(in srgb, {c['red']} 90%, transparent);
  --brand-95a: color-mix(in srgb, {c['red']} 95%, transparent);
  --brand-400: {c['red']};
  --brand-experiment-400: {c['red']};
  --blurple-400: {c['red']};
  --brand-430: {c['red']};
  --brand-experiment-430: {c['red']};
  --blurple-430: {c['red']};
  --brand-460: {c['red']};
  --brand-experiment-460: {c['red']};
  --blurple-460: {c['red']};
  --brand-500: {c['red']};
  --brand-experiment-500: {c['red']};
  --blurple-500: {c['red']};
  --brand-530: {c['red']};
  --brand-experiment-530: {c['red']};
  --blurple-530: {c['red']};
  --brand-560: {c['red']};
  --brand-experiment-560: {c['red']};
  --blurple-560: {c['red']};
  --brand-600: {c['red']};
  --brand-experiment-600: {c['red']};
  --blurple-600: {c['red']};
  --brand-630: {c['red']};
  --brand-experiment-630: {c['red']};
  --blurple-630: {c['red']};
  --brand-660: {c['red']};
  --brand-experiment-660: {c['red']};
  --blurple-660: {c['red']};
  --brand-700: {c['red']};
  --brand-experiment-700: {c['red']};
  --blurple-700: {c['red']};
  --brand-730: {c['red']};
  --brand-experiment-730: {c['red']};
  --blurple-730: {c['red']};
  --brand-760: {c['red']};
  --brand-experiment-760: {c['red']};
  --blurple-760: {c['red']};
  --brand-800: {c['red']};
  --brand-experiment-800: {c['red']};
  --blurple-800: {c['red']};
  --brand-830: {c['red']};
  --brand-experiment-830: {c['red']};
  --blurple-830: {c['red']};
  --brand-860: {c['red']};
  --brand-experiment-860: {c['red']};
  --blurple-860: {c['red']};
  --brand-900: {c['red']};
  --brand-experiment-900: {c['red']};
  --blurple-900: {c['red']};
  --blurple-1: {c['red']};
  --blurple-2: {c['red']};
  --blurple-3: {c['red']};
  --blurple-4: {c['red']};
  --blurple-5: {c['red']};
  --brand: {c['red']};
  --bg-brand: {c['red']};
  --button-filled-brand-background: {c['red']};
  --button-filled-brand-background-hover: {c['red_dim']};
  --button-filled-brand-background-active: {c['red_dim']};
  --button-filled-brand-text: {c['text']};
  --button-outline-brand-border: {c['red']};
  --button-outline-brand-text: {c['red']};
  --button-outline-brand-background-hover: {c['red_dim']};
  --text-brand: {c['red']};
  --icon-brand: {c['red']};
  --border-brand: {c['red']};
  --focus-primary: {c['red']};
  --guild-icon-brand: {c['red']};
  --control-brand-foreground: {c['red']};
  --control-brand-foreground-new: {c['red']};
  --status-danger: {c['red']};
  --mention-foreground: {c['magenta']};
  --mention-background: {mix(c['base'], c['magenta'], 0.2)};
}}
"""
    write("vesktop/blackwall.theme.css", css)


NVIM_TEMPLATE = r"""-- __HEADER__
-- Blackwall colourscheme for Neovim: palette-generated, covers core, treesitter, LSP,
-- diagnostics, gitsigns, mini.nvim (statusline/pick/files/clue/icons) and blink.cmp.
vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.g.colors_name = "blackwall"
vim.o.termguicolors = true
vim.o.background = "dark"

local c = __PALETTE__
local transparent = __TRANSPARENT__
local bg = transparent and "NONE" or c.base

local function hl(name, spec) vim.api.nvim_set_hl(0, name, spec) end
local function link(name, to) vim.api.nvim_set_hl(0, name, { link = to }) end

-- Editor ---------------------------------------------------------------
hl("Normal",       { fg = c.text, bg = bg })
hl("NormalNC",     { fg = c.text, bg = bg })
hl("NormalFloat",  { fg = c.text, bg = c.surface })
hl("FloatBorder",  { fg = c.red_dim, bg = c.surface })
hl("FloatTitle",   { fg = c.red, bg = c.surface, bold = true })
hl("SignColumn",   { bg = bg })
hl("EndOfBuffer",  { fg = c.base, bg = bg })
hl("LineNr",       { fg = c.bright_black })
hl("LineNrAbove",  { fg = c.bright_black })
hl("LineNrBelow",  { fg = c.bright_black })
hl("CursorLineNr", { fg = c.red, bold = true })
hl("CursorLine",   { bg = c.surface })
hl("CursorColumn", { bg = c.surface })
hl("ColorColumn",  { bg = c.surface })
hl("Cursor",       { fg = c.base, bg = c.red })
hl("lCursor",      { fg = c.base, bg = c.red })
hl("TermCursor",   { fg = c.base, bg = c.red })
hl("Visual",       { bg = c.visual })
hl("VisualNOS",    { bg = c.visual })
hl("Search",       { fg = c.base, bg = c.warning })
hl("CurSearch",    { fg = c.base, bg = c.red, bold = true })
hl("IncSearch",    { fg = c.base, bg = c.red, bold = true })
hl("Substitute",   { fg = c.base, bg = c.magenta })
hl("MatchParen",   { fg = c.magenta, bold = true, underline = true })
hl("Folded",       { fg = c.muted, bg = c.surface })
hl("FoldColumn",   { fg = c.muted })
hl("NonText",      { fg = c.bright_black })
hl("Whitespace",   { fg = c.overlay })
hl("SpecialKey",   { fg = c.bright_black })
hl("Conceal",      { fg = c.muted })
hl("Directory",    { fg = c.red })
hl("Title",        { fg = c.red, bold = true })
hl("Question",     { fg = c.cyan })
hl("MoreMsg",      { fg = c.green })
hl("ModeMsg",      { fg = c.text, bold = true })
hl("ErrorMsg",     { fg = c.red, bold = true })
hl("WarningMsg",   { fg = c.warning })
hl("WinSeparator", { fg = c.red_dim, bg = bg })
link("VertSplit", "WinSeparator")
hl("WinBar",       { fg = c.text, bg = bg, bold = true })
hl("WinBarNC",     { fg = c.muted, bg = bg })
hl("StatusLine",   { fg = c.text, bg = c.surface })
hl("StatusLineNC", { fg = c.muted, bg = c.surface })
hl("TabLine",      { fg = c.muted, bg = c.surface })
hl("TabLineFill",  { bg = c.base })
hl("TabLineSel",   { fg = c.base, bg = c.red, bold = true })
hl("Pmenu",        { fg = c.text, bg = c.surface })
hl("PmenuSel",     { fg = c.base, bg = c.red })
hl("PmenuSbar",    { bg = c.overlay })
hl("PmenuThumb",   { bg = c.red_dim })
hl("PmenuKind",    { fg = c.magenta, bg = c.surface })
hl("PmenuExtra",   { fg = c.muted, bg = c.surface })
hl("WildMenu",     { fg = c.base, bg = c.red })
hl("QuickFixLine", { bg = c.overlay, bold = true })
hl("Underlined",   { fg = c.magenta, underline = true })
hl("SpellBad",     { sp = c.red, undercurl = true })
hl("SpellCap",     { sp = c.warning, undercurl = true })
hl("SpellRare",    { sp = c.magenta, undercurl = true })
hl("SpellLocal",   { sp = c.cyan, undercurl = true })

-- Syntax ---------------------------------------------------------------
hl("Comment",      { fg = c.muted, italic = true })
hl("Constant",     { fg = c.warning })
hl("String",       { fg = c.green })
hl("Character",    { fg = c.green })
hl("Number",       { fg = c.warning })
hl("Boolean",      { fg = c.warning, bold = true })
hl("Float",        { fg = c.warning })
hl("Identifier",   { fg = c.text })
hl("Function",     { fg = c.magenta })
hl("Statement",    { fg = c.red })
hl("Conditional",  { fg = c.red })
hl("Repeat",       { fg = c.red })
hl("Label",        { fg = c.red })
hl("Operator",     { fg = c.bright_black_text })
hl("Keyword",      { fg = c.red })
hl("Exception",    { fg = c.red })
hl("PreProc",      { fg = c.bright_blue })
hl("Include",      { fg = c.bright_blue })
hl("Define",       { fg = c.bright_blue })
hl("Macro",        { fg = c.bright_blue })
hl("PreCondit",    { fg = c.bright_blue })
hl("Type",         { fg = c.cyan })
hl("StorageClass", { fg = c.red })
hl("Structure",    { fg = c.cyan })
hl("Typedef",      { fg = c.cyan })
hl("Special",      { fg = c.bright_cyan })
hl("SpecialChar",  { fg = c.bright_cyan })
hl("Tag",          { fg = c.red })
hl("Delimiter",    { fg = c.muted })
hl("SpecialComment", { fg = c.muted, italic = true })
hl("Debug",        { fg = c.warning })
hl("Error",        { fg = c.red, bold = true })
hl("Todo",         { fg = c.base, bg = c.warning, bold = true })
hl("Ignore",       { fg = c.muted })

-- Treesitter -----------------------------------------------------------
local ts = {
  ["@variable"] = { fg = c.text },
  ["@variable.builtin"] = { fg = c.red, italic = true },
  ["@variable.parameter"] = { fg = c.bright_blue },
  ["@variable.member"] = { fg = c.text },
  ["@constant"] = { fg = c.warning },
  ["@constant.builtin"] = { fg = c.warning, bold = true },
  ["@constant.macro"] = { fg = c.bright_blue },
  ["@module"] = { fg = c.bright_blue },
  ["@label"] = { fg = c.red },
  ["@string"] = { fg = c.green },
  ["@string.escape"] = { fg = c.bright_cyan },
  ["@string.regexp"] = { fg = c.bright_cyan },
  ["@string.special"] = { fg = c.bright_cyan },
  ["@character"] = { fg = c.green },
  ["@number"] = { fg = c.warning },
  ["@boolean"] = { fg = c.warning, bold = true },
  ["@type"] = { fg = c.cyan },
  ["@type.builtin"] = { fg = c.cyan, italic = true },
  ["@attribute"] = { fg = c.bright_blue },
  ["@property"] = { fg = c.text },
  ["@function"] = { fg = c.magenta },
  ["@function.builtin"] = { fg = c.magenta, italic = true },
  ["@function.macro"] = { fg = c.bright_blue },
  ["@constructor"] = { fg = c.cyan },
  ["@operator"] = { fg = c.bright_black_text },
  ["@keyword"] = { fg = c.red },
  ["@keyword.function"] = { fg = c.red },
  ["@keyword.return"] = { fg = c.red, bold = true },
  ["@keyword.import"] = { fg = c.bright_blue },
  ["@punctuation"] = { fg = c.muted },
  ["@punctuation.special"] = { fg = c.bright_cyan },
  ["@comment"] = { fg = c.muted, italic = true },
  ["@comment.error"] = { fg = c.base, bg = c.red, bold = true },
  ["@comment.warning"] = { fg = c.base, bg = c.warning, bold = true },
  ["@comment.todo"] = { fg = c.base, bg = c.warning, bold = true },
  ["@comment.note"] = { fg = c.base, bg = c.cyan, bold = true },
  ["@markup.heading"] = { fg = c.red, bold = true },
  ["@markup.strong"] = { bold = true },
  ["@markup.italic"] = { italic = true },
  ["@markup.link"] = { fg = c.magenta },
  ["@markup.link.url"] = { fg = c.magenta, underline = true },
  ["@markup.raw"] = { fg = c.green },
  ["@markup.list"] = { fg = c.red },
  ["@tag"] = { fg = c.red },
  ["@tag.attribute"] = { fg = c.bright_blue },
  ["@tag.delimiter"] = { fg = c.muted },
  ["@diff.plus"] = { fg = c.green },
  ["@diff.minus"] = { fg = c.red },
  ["@diff.delta"] = { fg = c.blue },
}
for name, spec in pairs(ts) do hl(name, spec) end

-- LSP / diagnostics ----------------------------------------------------
link("@lsp.type.namespace", "@module")
link("@lsp.type.class", "@type")
link("@lsp.type.struct", "@type")
link("@lsp.type.enum", "@type")
link("@lsp.type.interface", "@type")
link("@lsp.type.typeParameter", "@type")
link("@lsp.type.parameter", "@variable.parameter")
link("@lsp.type.property", "@property")
link("@lsp.type.function", "@function")
link("@lsp.type.method", "@function")
link("@lsp.type.macro", "@function.macro")
hl("LspReferenceText",  { bg = c.overlay })
hl("LspReferenceRead",  { bg = c.overlay })
hl("LspReferenceWrite", { bg = c.overlay, underline = true })
hl("LspSignatureActiveParameter", { fg = c.red, bold = true })
hl("LspInlayHint", { fg = c.bright_black, italic = true })
hl("LspCodeLens", { fg = c.muted })
hl("DiagnosticError", { fg = c.red })
hl("DiagnosticWarn",  { fg = c.warning })
hl("DiagnosticInfo",  { fg = c.cyan })
hl("DiagnosticHint",  { fg = c.bright_blue })
hl("DiagnosticOk",    { fg = c.green })
hl("DiagnosticVirtualTextError", { fg = c.red, bg = c.diag_error })
hl("DiagnosticVirtualTextWarn",  { fg = c.warning, bg = c.diag_warn })
hl("DiagnosticVirtualTextInfo",  { fg = c.cyan, bg = c.diag_info })
hl("DiagnosticVirtualTextHint",  { fg = c.bright_blue, bg = c.diag_hint })
hl("DiagnosticUnderlineError", { sp = c.red, undercurl = true })
hl("DiagnosticUnderlineWarn",  { sp = c.warning, undercurl = true })
hl("DiagnosticUnderlineInfo",  { sp = c.cyan, undercurl = true })
hl("DiagnosticUnderlineHint",  { sp = c.bright_blue, undercurl = true })
hl("DiagnosticDeprecated", { sp = c.muted, strikethrough = true })

-- Diff / git -----------------------------------------------------------
hl("DiffAdd",    { bg = c.diff_add })
hl("DiffDelete", { fg = c.red_dim, bg = c.diff_delete })
hl("DiffChange", { bg = c.diff_change })
hl("DiffText",   { bg = c.diff_text })
hl("Added",      { fg = c.green })
hl("Removed",    { fg = c.red })
hl("Changed",    { fg = c.blue })
hl("GitSignsAdd",    { fg = c.green })
hl("GitSignsChange", { fg = c.blue })
hl("GitSignsDelete", { fg = c.red })
hl("GitSignsCurrentLineBlame", { fg = c.bright_black, italic = true })

-- mini.nvim ------------------------------------------------------------
hl("MiniStatuslineModeNormal",  { fg = c.base, bg = c.red, bold = true })
hl("MiniStatuslineModeInsert",  { fg = c.base, bg = c.magenta, bold = true })
hl("MiniStatuslineModeVisual",  { fg = c.base, bg = c.warning, bold = true })
hl("MiniStatuslineModeReplace", { fg = c.text, bg = c.red_dim, bold = true })
hl("MiniStatuslineModeCommand", { fg = c.base, bg = c.cyan, bold = true })
hl("MiniStatuslineModeOther",   { fg = c.base, bg = c.muted, bold = true })
hl("MiniStatuslineDevinfo",     { fg = c.text, bg = c.overlay })
hl("MiniStatuslineFilename",    { fg = c.text, bg = c.surface })
hl("MiniStatuslineFileinfo",    { fg = c.muted, bg = c.overlay })
hl("MiniStatuslineInactive",    { fg = c.muted, bg = c.surface })
hl("MiniCursorword",        { bg = c.overlay })
hl("MiniCursorwordCurrent", { bg = c.overlay })
hl("MiniIndentscopeSymbol", { fg = c.red_dim })
hl("MiniJump",              { fg = c.base, bg = c.magenta })
hl("MiniPickBorder",        { fg = c.red_dim, bg = c.surface })
hl("MiniPickBorderBusy",    { fg = c.warning, bg = c.surface })
hl("MiniPickBorderText",    { fg = c.red, bg = c.surface, bold = true })
hl("MiniPickMatchCurrent",  { bg = c.overlay })
hl("MiniPickMatchMarked",   { bg = c.visual })
hl("MiniPickMatchRanges",   { fg = c.magenta, bold = true })
hl("MiniPickPrompt",        { fg = c.text, bg = c.surface })
hl("MiniPickPromptCaret",   { fg = c.red, bg = c.surface })
hl("MiniPickPromptPrefix",  { fg = c.red, bg = c.surface })
hl("MiniPickNormal",        { fg = c.text, bg = c.surface })
hl("MiniFilesBorder",       { fg = c.red_dim, bg = c.surface })
hl("MiniFilesBorderModified", { fg = c.warning, bg = c.surface })
hl("MiniFilesNormal",       { fg = c.text, bg = c.surface })
hl("MiniFilesTitle",        { fg = c.muted, bg = c.surface })
hl("MiniFilesTitleFocused", { fg = c.red, bg = c.surface, bold = true })
hl("MiniFilesDirectory",    { fg = c.red })
hl("MiniFilesFile",         { fg = c.text })
hl("MiniClueBorder",        { fg = c.red_dim, bg = c.surface })
hl("MiniClueTitle",         { fg = c.red, bg = c.surface, bold = true })
hl("MiniClueNextKey",       { fg = c.magenta, bg = c.surface })
hl("MiniClueNextKeyWithPostkeys", { fg = c.red, bg = c.surface })
hl("MiniClueDescGroup",     { fg = c.red, bg = c.surface })
hl("MiniClueDescSingle",    { fg = c.text, bg = c.surface })
hl("MiniClueSeparator",     { fg = c.muted, bg = c.surface })
hl("MiniIconsAzure",  { fg = c.cyan })
hl("MiniIconsBlue",   { fg = c.blue })
hl("MiniIconsCyan",   { fg = c.bright_cyan })
hl("MiniIconsGreen",  { fg = c.green })
hl("MiniIconsGrey",   { fg = c.text })
hl("MiniIconsOrange", { fg = c.warning })
hl("MiniIconsPurple", { fg = c.magenta })
hl("MiniIconsRed",    { fg = c.red })
hl("MiniIconsYellow", { fg = c.bright_yellow })
hl("MiniTrailspace",  { bg = c.red_dim })
hl("MiniStarterCurrent", {})
hl("MiniStarterHeader", { fg = c.red })
hl("MiniStarterItemBullet", { fg = c.red_dim })
hl("MiniStarterQuery", { fg = c.magenta })
hl("MiniStarterSection", { fg = c.red })

-- blink.cmp ------------------------------------------------------------
hl("BlinkCmpMenu",          { fg = c.text, bg = c.surface })
hl("BlinkCmpMenuBorder",    { fg = c.red_dim, bg = c.surface })
hl("BlinkCmpMenuSelection", { fg = c.base, bg = c.red })
hl("BlinkCmpScrollBarThumb", { bg = c.red_dim })
hl("BlinkCmpLabel",         { fg = c.text })
hl("BlinkCmpLabelDeprecated", { fg = c.muted, strikethrough = true })
hl("BlinkCmpLabelMatch",    { fg = c.magenta, bold = true })
hl("BlinkCmpLabelDetail",   { fg = c.muted })
hl("BlinkCmpLabelDescription", { fg = c.muted })
hl("BlinkCmpKind",          { fg = c.magenta })
hl("BlinkCmpSource",        { fg = c.muted })
hl("BlinkCmpGhostText",     { fg = c.bright_black })
hl("BlinkCmpDoc",           { fg = c.text, bg = c.surface })
hl("BlinkCmpDocBorder",     { fg = c.red_dim, bg = c.surface })
hl("BlinkCmpDocSeparator",  { fg = c.red_dim, bg = c.surface })
hl("BlinkCmpSignatureHelp", { fg = c.text, bg = c.surface })
hl("BlinkCmpSignatureHelpBorder", { fg = c.red_dim, bg = c.surface })
hl("BlinkCmpSignatureHelpActiveParameter", { fg = c.red, bold = true })

-- :terminal colours (same 16 as kitty) ---------------------------------
local term = { c.surface, c.red, c.green, c.warning, c.blue, c.magenta, c.cyan, c.text,
               c.bright_black, c.red, c.bright_green, c.bright_yellow, c.bright_blue, c.magenta, c.bright_cyan, "#FFFFFF" }
for i, col in ipairs(term) do vim.g["terminal_color_" .. (i - 1)] = col end
"""


def gen_nvim(c, ansi, settings):
    pal = {**c, **ansi}
    pal.update({
        "visual": mix(c["base"], c["red"], 0.28),
        "bright_black_text": mix(c["muted"], c["text"], 0.35),
        "diag_error": mix(c["base"], c["red"], 0.14),
        "diag_warn": mix(c["base"], c["warning"], 0.12),
        "diag_info": mix(c["base"], ansi["cyan"], 0.10),
        "diag_hint": mix(c["base"], ansi["bright_blue"], 0.10),
        "diff_add": mix(c["base"], ansi["green"], 0.16),
        "diff_delete": mix(c["base"], c["red"], 0.18),
        "diff_change": mix(c["base"], ansi["blue"], 0.14),
        "diff_text": mix(c["base"], ansi["blue"], 0.30),
    })
    body = ",\n".join(f'  {k} = "{v}"' for k, v in pal.items())
    transparent = "true" if settings["look"].get("nvim_transparent", True) else "false"
    text = (NVIM_TEMPLATE.replace("__HEADER__", HEADER)
            .replace("__PALETTE__", "{\n" + body + ",\n}")
            .replace("__TRANSPARENT__", transparent))
    write("nvim/colors/blackwall.lua", text)


def gen_rofi(c, ansi, settings):
    a = format(round(settings["look"]["glass"]["card_opacity"] * 255), "02X")
    r = settings["look"]["radius"]
    write("rofi/blackwall.rasi", f"""/* {HEADER} */
* {{
    base: {c['base']}{a};
    surface: {c['surface']};
    overlay: {c['overlay']};
    text: {c['text']};
    muted: {c['muted']};
    red: {c['red']};
    red-dim: {c['red_dim']};
    background-color: transparent;
    text-color: @text;
    font: "JetBrainsMono Nerd Font 11";
}}
window {{
    location: center;
    width: 680px;
    background-color: @base;
    border: 1px;
    border-color: @red-dim;
    border-radius: {r}px;
}}
mainbox {{ padding: 12px; spacing: 8px; children: [ inputbar, listview ]; }}
inputbar {{
    padding: 8px 12px;
    spacing: 10px;
    background-color: @surface;
    border: 1px;
    border-color: @overlay;
    border-radius: {r // 2}px;
    children: [ prompt, entry ];
}}
prompt {{ text-color: @red; }}
entry {{ placeholder: "search history"; placeholder-color: @muted; }}
listview {{ lines: 10; columns: 1; scrollbar: false; fixed-height: false; spacing: 2px; }}
element {{ padding: 7px 12px; border-radius: {r // 2}px; }}
element selected.normal {{ background-color: @red; text-color: #000000; }}
element-text {{ background-color: transparent; text-color: inherit; }}
""".replace("#000000", c["base"]))


def run(c, ansi, settings):
    gen_gtk(c, ansi)
    gen_toolkit_settings(settings)
    gen_qt(c, ansi)
    gen_btop(c, ansi)
    gen_yazi(c, ansi)
    gen_spotify_player(c, ansi)
    gen_cava(c, ansi)
    gen_fastfetch(c, ansi)
    gen_lock(c, ansi, settings)
    gen_firefox(c, ansi)
    gen_spicetify(c, ansi)
    gen_vesktop(c, ansi)
    gen_nvim(c, ansi, settings)
    gen_rofi(c, ansi, settings)
