-- Keybinds. Every bind here is listed in ~/rice/docs/keybinds.md: keep them in sync.
return function(rice)
    local mod = "SUPER"
    local function key(k) return mod .. " + " .. k end

    -- Apps
    hl.bind(key("Return"), hl.dsp.exec_cmd("kitty"))
    hl.bind(key("B"), hl.dsp.exec_cmd("firefox"))
    hl.bind(key("Space"), hl.dsp.exec_cmd("qs ipc call launcher toggle"))
    hl.bind(key("S"), function() rice.toggle_app("spotify") end)
    hl.bind(key("D"), function() rice.toggle_app("discord") end)

    -- Windows
    -- Spotify and Vesktop keep running in the tray after their window closes: quit the flatpak instead.
    local quit_apps = { spotify = "com.spotify.Client", vesktop = "dev.vencord.Vesktop", discord = "dev.vencord.Vesktop" }
    hl.bind(key("Q"), function()
        local win = hl.get_active_window()
        local app = win and quit_apps[(win.class or ""):lower()]
        if app then hl.dispatch(hl.dsp.exec_cmd("flatpak kill " .. app))
        else hl.dispatch(hl.dsp.window.close()) end
    end)
    hl.bind(key("F"), hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" }))
    hl.bind(key("V"), hl.dsp.window.float({ action = "toggle" }))
    for _, dir in ipairs({ "left", "right", "up", "down" }) do
        hl.bind(key(dir), hl.dsp.focus({ direction = dir }))
    end
    hl.bind(key("mouse:272"), hl.dsp.window.drag(),   { mouse = true })
    hl.bind(key("mouse:273"), hl.dsp.window.resize(), { mouse = true })

    -- Throw the focused window to the other monitor's current workspace.
    hl.bind(key("Tab"), function()
        local win = hl.get_active_window()
        if not win or not win.monitor then return end
        for _, mon in ipairs(hl.get_monitors()) do
            if mon.name ~= win.monitor.name then
                hl.dispatch(hl.dsp.window.move({ monitor = mon.name, follow = true }))
                return
            end
        end
    end)

    -- Workspaces: 1-5 main, 6-10 side (Super+0 = 10). Monitor locking is in monitors.lua.
    for i = 1, 10 do
        local k = tostring(i % 10)
        hl.bind(key(k),              hl.dsp.focus({ workspace = i }))
        hl.bind(key("SHIFT + " .. k), hl.dsp.window.move({ workspace = i }))
    end

    -- System
    hl.bind(key("L"), hl.dsp.exec_cmd("hyprlock"))
    hl.bind("Print", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | swappy -f -]]))
    hl.bind(key("SHIFT + S"), hl.dsp.exec_cmd("~/.config/hypr/scripts/snip.sh"))
    -- Clipboard history: rofi picker themed from the palette (scripts/clippick.sh).
    hl.bind(key("SHIFT + V"), hl.dsp.exec_cmd(rice.dir .. "/scripts/clippick.sh"))

    -- Media keys
    local media = { locked = true, repeating = true }
    hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), media)
    hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), media)
    hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
    hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
    hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
    hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
end
