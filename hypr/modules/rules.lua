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

    -- Spotify and Discord always open hidden in their special workspace.
    for name, app in pairs(rice.apps) do
        hl.window_rule({
            name  = "hide-" .. name,
            match = { class = "(?i)^" .. app.class .. "$" },
            workspace = "special:" .. name .. " silent",
        })
    end
end
