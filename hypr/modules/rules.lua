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

    -- Liquid-glass terminals: translucent (kitty background_opacity) over strong blur,
    -- with a soft red edge, and a red-tinted background (look.glass.tint).
    hl.window_rule({
        name  = "glass-kitty",
        match = { class = "^kitty$" },
        border_color = rice.rgb("red", "88"),
        no_shadow = true,
    })

    -- Liquid-glass side bar: blur whatever is behind it (the main bar is solid).
    hl.layer_rule({ match = { namespace = "rice-sidebar" }, blur = true, ignore_alpha = 0.05 })
    -- ...and the side widget cards (Card.qml draws the glass).
    hl.layer_rule({ match = { namespace = "^rice-widget-.*" }, blur = true, ignore_alpha = 0.05 })

    -- Spotify and Discord always open hidden in their special workspace.
    for name, app in pairs(rice.apps) do
        hl.window_rule({
            name  = "hide-" .. name,
            match = { class = "(?i)^(" .. table.concat(app.classes, "|"):gsub("%.", "\\.") .. ")$" },
            workspace = "special:" .. name .. " silent",
        })
    end
end
