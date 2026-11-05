-- Game mode: automatic while a window is fullscreen on the MAIN monitor.
-- Blur, animations, shadows and borders go off for main-monitor windows only;
-- the side monitor is untouched. Focus also stops following the mouse (click to
-- change focus) until the game leaves fullscreen. Hyprland's blur/animation switches are global,
-- so this uses a toggled window rule scoped to main's workspaces instead.
--
-- State is written to $XDG_RUNTIME_DIR/rice/gamemode ("1"/"0") so the
-- Quickshell bar (phase 2) can hide itself.
return function(rice)
    local main = "desc:" .. rice.settings.monitors.main.desc

    local rule = hl.window_rule({
        name    = "rice-gamemode",
        enabled = false,
        match   = { workspace = "m[" .. main .. "]" },
        no_blur     = true,
        no_anim     = true,
        no_shadow   = true,
        border_size = 0,
    })

    local state_dir  = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/rice"
    local state_file = state_dir .. "/gamemode"
    os.execute("mkdir -p '" .. state_dir .. "'")

    local active
    local normal_follow = hl.get_config("input.follow_mouse") or 1

    local function update()
        local mon = hl.get_monitor(main)
        local ws  = mon and mon.active_workspace
        -- fullscreen_mode 2 = real fullscreen (1 is maximised, which isn't a game).
        local on  = ws ~= nil and ws.has_fullscreen and ws.fullscreen_mode == 2
        if on == active then return end
        active = on

        rule:set_enabled(on)
        hl.exec_scheduled_prop_refresh_immediately()

        -- While a game is fullscreen, keyboard focus only moves on click (follow_mouse 2),
        -- so the cursor slipping onto the side monitor can't steal focus mid-keypress
        -- and leave keys "stuck" in the game.
        hl.config({ input = { follow_mouse = on and 2 or normal_follow } })

        local f = io.open(state_file, "w")
        if f then
            f:write(on and "1\n" or "0\n")
            f:close()
        end
    end

    for _, ev in ipairs({
        "window.fullscreen", "window.open", "window.close", "window.destroy",
        "window.move_to_workspace", "workspace.active", "monitor.added", "monitor.removed",
    }) do
        hl.on(ev, update)
    end
    update()
end
