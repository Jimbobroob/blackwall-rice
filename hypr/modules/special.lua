-- Hidden Discord window living in a special workspace.
-- Super+D shows it on the SIDE monitor (never main), and hides it again.
return function(rice)
    rice.apps = {
        -- classes: lowercase; Flatpak builds may report the app id instead of the short name.
        discord = { classes = { "vesktop", "dev.vencord.vesktop" }, cmd = "flatpak run dev.vencord.Vesktop" },
    }

    local function app_for(window)
        local class = (window.class or ""):lower()
        for name, app in pairs(rice.apps) do
            for _, c in ipairs(app.classes) do
                if class == c then return name end
            end
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

    -- The window rules in rules.lua catch most windows at open time, but an app can set
    -- its class late, so also catch class changes.
    hl.on("window.class", function(window)
        if window then park(window) end
    end)

    -- On (re)load, tidy any app windows that ended up somewhere else.
    for _, w in ipairs(hl.get_windows()) do park(w) end

    local return_to -- monitor to give focus back to when hiding

    function rice.toggle_app(name)
        local app = rice.apps[name]

        -- Showing anywhere? Then this press hides it.
        for _, mon in ipairs(hl.get_monitors()) do
            local shown = mon.active_special_workspace
            if shown and shown.name == "special:" .. name then
                mon:set_special_workspace(nil)
                if return_to and return_to ~= mon.name and hl.get_monitor(return_to) then
                    hl.dispatch(hl.dsp.focus({ monitor = return_to }))
                end
                return
            end
        end

        -- Remember where you were, unless you're just switching from the other app.
        local active = hl.get_active_monitor()
        local current = active and active.active_special_workspace
        local switching = current and rice.apps[(current.name:gsub("^special:", ""))]
        if not switching then
            return_to = active and active.name
        end

        if #windows_of(name) == 0 then
            hl.exec_cmd(app.cmd)
        end
        -- Specials open on the focused monitor, so focus the side one first.
        local side = rice.monitor("side") or active
        hl.dispatch(hl.dsp.focus({ monitor = side.name }))
        side:set_special_workspace(name)

        local win = windows_of(name)[1]
        if win then
            hl.dispatch(hl.dsp.focus({ window = "address:" .. win.address }))
        end
    end

    -- Focus any window by address (the Alt+Tab switcher calls this through hyprctl eval).
    -- A hidden Discord window is shown on the side monitor first, the same way Super+D does.
    function rice.focus_window(address)
        local want = (address or ""):gsub("^0x", "")
        for _, w in ipairs(hl.get_windows()) do
            if (w.address or ""):gsub("^0x", "") == want then
                local name = app_for(w)
                local ws = w.workspace and w.workspace.name or ""
                if name and ws == "special:" .. name then
                    local shown = false
                    for _, mon in ipairs(hl.get_monitors()) do
                        local s = mon.active_special_workspace
                        if s and s.name == ws then shown = true end
                    end
                    if not shown then rice.toggle_app(name) end
                end
                hl.dispatch(hl.dsp.focus({ window = "address:" .. w.address }))
                return
            end
        end
    end
end
