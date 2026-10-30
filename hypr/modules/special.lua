-- Hidden Spotify / Discord windows living in special workspaces.
-- Super+S / Super+D show them on the SIDE monitor (never main), and hide them again.
return function(rice)
    rice.apps = {
        spotify = { class = "spotify", cmd = "flatpak run com.spotify.Client" },
        discord = { class = "vesktop", cmd = "flatpak run dev.vencord.Vesktop" },
    }

    local function app_for(window)
        local class = (window.class or ""):lower()
        for name, app in pairs(rice.apps) do
            if class == app.class then return name end
        end
    end

    local function windows_of(name)
        local found = {}
        for _, w in ipairs(hl.get_windows()) do
            if app_for(w) == name then found[#found + 1] = w end
        end
        return found
    end

    -- Park a window in its app's special workspace without following it.
    local function park(window)
        local name = app_for(window)
        if name and window.workspace and window.workspace.name ~= "special:" .. name then
            hl.dispatch(hl.dsp.window.move({ window = "address:" .. window.address, workspace = "special:" .. name, follow = false }))
        end
    end

    -- The window rules in rules.lua catch most windows at open time, but Spotify sets
    -- its class late, so also catch class changes.
    hl.on("window.class", function(window)
        if window then park(window) end
    end)

    local return_to -- monitor to give focus back to when hiding

    function rice.toggle_app(name)
        local app = rice.apps[name]
        local side = rice.monitor("side") or hl.get_active_monitor()
        local shown = side.active_special_workspace

        if shown and shown.name == "special:" .. name then
            side:set_special_workspace(nil)
            if return_to and return_to ~= side.name and hl.get_monitor(return_to) then
                hl.dispatch(hl.dsp.focus({ monitor = return_to }))
            end
            return
        end

        local active = hl.get_active_monitor()
        return_to = active and active.name

        if #windows_of(name) == 0 then
            hl.exec_cmd(app.cmd)
        end
        side:set_special_workspace(name)

        local win = windows_of(name)[1]
        if win then
            hl.dispatch(hl.dsp.focus({ window = "address:" .. win.address }))
        end
    end
end
