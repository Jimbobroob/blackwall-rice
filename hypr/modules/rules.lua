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

    -- Liquid-glass terminals: translucent (kitty background_opacity) over strong blur,
    -- with a pale thin edge instead of the red/grey border.
    hl.window_rule({
        name  = "glass-kitty",
        match = { class = "^kitty$" },
        border_color = rice.rgb("text", "55"),
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
