-- Monitors + workspace locking, KVM-safe.
-- Side (1440p) on the left at 0x0, main (1080p 144 Hz) on the right, 360px down.
-- Workspaces 1-5 live on main, 6-10 on side.
return function(rice)
    local mons = rice.settings.monitors

    for _, role in ipairs({ "main", "side" }) do
        local m = mons[role]
        local output = "desc:" .. m.desc
        hl.monitor({ output = output, mode = m.mode, position = m.position, scale = 1 })
        for i, ws in ipairs(m.workspaces) do
            hl.workspace_rule({ workspace = tostring(ws), monitor = output, default = (i == 1), persistent = true })
        end
    end

    -- Anything else that gets plugged in just works.
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

    -- When the KVM switches back, Hyprland has parked this screen's workspaces on the
    -- other one. Send them home.
    local function rehome()
        for _, role in ipairs({ "main", "side" }) do
            local mon = rice.monitor(role)
            if mon then
                for _, id in ipairs(mons[role].workspaces) do
                    local ws = hl.get_workspace(id)
                    if ws and ws.monitor and ws.monitor.name ~= mon.name then
                        hl.dispatch(hl.dsp.workspace.move({ workspace = id, monitor = mon.name }))
                    end
                end
            end
        end
    end

    hl.on("monitor.added", function()
        -- Give the new output a moment to finish configuring.
        hl.timer(rehome, { timeout = 500, type = "oneshot" })
    end)
end
