-- Window rules.
return function(rice)
    hl.window_rule({
        name  = "suppress-maximize",
        match = { class = ".*" },
        suppress_event = "maximize",
    })

    hl.window_rule({
        name  = "fix-xwayland-drags",
        match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
        no_focus = true,
    })

    -- Games and fullscreen video block the idle auto-lock (hypridle honours this).
    hl.window_rule({
        name  = "idle-inhibit-fullscreen",
        match = { class = ".*" },
        idle_inhibit = "fullscreen",
    })

    -- Terminals are plain translucent: kitty's background_opacity (look.glass.terminal_opacity),
    -- no blur behind them, normal borders.
    hl.window_rule({
        name  = "translucent-kitty",
        match = { class = "^kitty$" },
        no_blur = true,
        no_shadow = true,
    })

    -- Spotify and Discord always open hidden in their special workspace.
    for name, app in pairs(rice.apps) do
        hl.window_rule({
            name  = "hide-" .. name,
            match = { class = "(?i)^(" .. table.concat(app.classes, "|"):gsub("%.", "\\.") .. ")$" },
            workspace = "special:" .. name .. " silent",
        })
    end
end
