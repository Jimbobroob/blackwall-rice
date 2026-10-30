-- Look and feel: sharp corners, 2px red/grey borders, 6px gaps, quick animations.
return function(rice)
    hl.config({
        general = {
            gaps_in     = 3, -- 3 per side = 6px between windows
            gaps_out    = 6,
            border_size = 2,
            col = {
                active_border   = rice.rgb("red"),
                inactive_border = rice.rgb("overlay"),
            },
            resize_on_border = true,
            layout = "dwindle",
        },

        decoration = {
            rounding = 0,
            active_opacity   = 1.0,
            inactive_opacity = 1.0,
            shadow = { enabled = false },
            blur = {
                enabled  = true,
                size     = 4,
                passes   = 2,
                vibrancy = 0.15,
            },
        },

        animations = { enabled = true },

        dwindle = { preserve_split = true },

        misc = {
            force_default_wallpaper = 0,
            disable_hyprland_logo   = true,
            disable_splash_rendering = true,
            background_color = rice.rgb("base"),
        },

        binds = {
            -- Special workspaces (Spotify/Discord) stay put when you switch workspaces.
            hide_special_on_workspace_change = false,
        },
    })

    -- Smooth and quick: short durations, sharp ease-out, nothing floaty.
    hl.curve("snap",   { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
    hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })

    hl.animation({ leaf = "global",      enabled = true, speed = 3,   bezier = "snap" })
    hl.animation({ leaf = "border",      enabled = true, speed = 2,   bezier = "snap" })
    hl.animation({ leaf = "windowsIn",   enabled = true, speed = 2.5, bezier = "snap",   style = "popin 90%" })
    hl.animation({ leaf = "windowsOut",  enabled = true, speed = 1.5, bezier = "linear", style = "popin 90%" })
    hl.animation({ leaf = "windowsMove", enabled = true, speed = 2.5, bezier = "snap" })
    hl.animation({ leaf = "fade",        enabled = true, speed = 2,   bezier = "snap" })
    hl.animation({ leaf = "layers",      enabled = true, speed = 2,   bezier = "snap",   style = "fade" })
    hl.animation({ leaf = "workspaces",  enabled = true, speed = 2.5, bezier = "snap",   style = "slidevert" })
    hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.5, bezier = "snap", style = "slidefadevert 15%" })
end
