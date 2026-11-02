-- Keybinds. Every bind here is listed in ~/Source/rices/blackwall-rice/docs/keybinds.md: keep them in sync.
return function(rice)
    local mod = "SUPER"
    local function key(k) return mod .. " + " .. k end

    -- Apps
    hl.bind(key("Space"), hl.dsp.exec_cmd("kitty"))
    hl.bind(key("B"), hl.dsp.exec_cmd("firefox"))
    hl.bind(key("Return"), hl.dsp.exec_cmd("qs ipc call launcher toggle"))
    hl.bind(key("W"), hl.dsp.exec_cmd("qs ipc call side widgets"))
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
    -- Tiled window on this workspace lying in `dir` from `win` (overlapping it on the other axis).
    local function neighbour(win, dir)
        local ax, ay, aw, ah = win.at.x, win.at.y, win.size.x, win.size.y
        for _, o in ipairs(hl.get_workspace_windows(win.workspace.id)) do
            if o.address ~= win.address and not o.floating then
                local ox, oy, ow, oh = o.at.x, o.at.y, o.size.x, o.size.y
                local acrossY = oy < ay + ah and oy + oh > ay
                local acrossX = ox < ax + aw and ox + ow > ax
                if (dir == "right" and ox >= ax + aw and acrossY) or (dir == "left" and ox + ow <= ax and acrossY)
                    or (dir == "down" and oy >= ay + ah and acrossX) or (dir == "up" and oy + oh <= ay and acrossX) then
                    return o
                end
            end
        end
    end
    -- Super+Shift+arrow: swap with the window that way (they trade places and sizes). If there is none
    -- on this workspace but there are other tiles (e.g. two stacked, press right), flip the split so this
    -- window ends up on that side. Alone on the workspace: swap with the other monitor's window.
    local function shift(dir)
        local win = hl.get_active_window()
        if not win or win.floating or not win.workspace then return end
        local others = 0
        for _, o in ipairs(hl.get_workspace_windows(win.workspace.id)) do
            if o.address ~= win.address and not o.floating then others = others + 1 end
        end
        if neighbour(win, dir) or others == 0 then
            return hl.dispatch(hl.dsp.window.swap({ direction = dir }))
        end
        hl.dispatch(hl.dsp.layout("togglesplit"))
        -- the split flipped; if this window landed on the far side, swap it over
        win = hl.get_active_window()
        if win and neighbour(win, dir) then hl.dispatch(hl.dsp.window.swap({ direction = dir })) end
    end
    for _, dir in ipairs({ "left", "right", "up", "down" }) do
        hl.bind(key(dir), hl.dsp.focus({ direction = dir }))
        hl.bind(key("SHIFT + " .. dir), function() shift(dir) end)
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

    -- Alt+Tab window switcher (quickshell/switcher). Hold Alt, tap Tab (Shift+Tab goes back),
    -- let go of Alt to switch. The Alt release only pings Quickshell after an Alt+Tab, and
    -- never swallows the key, so Alt still works normally in games and apps.
    local switching = false
    local function switch(dir)
        switching = true
        hl.dispatch(hl.dsp.exec_cmd("qs ipc call switcher " .. dir))
    end
    hl.bind("ALT + Tab", function() switch("next") end, { repeating = true })
    hl.bind("ALT + SHIFT + Tab", function() switch("prev") end, { repeating = true })
    hl.bind("Alt_L", function()
        if not switching then return end
        switching = false
        hl.dispatch(hl.dsp.exec_cmd("qs ipc call switcher commit"))
    end, { release = true, ignore_mods = true, non_consuming = true, transparent = true })

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

    -- Same controls for keyboards without media keys.
    hl.bind(key("equal"), hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), media)
    hl.bind(key("minus"), hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), media)
    hl.bind(key("M"),         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
    hl.bind(key("SHIFT + M"), hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
    hl.bind(key("P"),            hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
    hl.bind(key("bracketright"), hl.dsp.exec_cmd("playerctl next"),       { locked = true })
    hl.bind(key("bracketleft"),  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
end
