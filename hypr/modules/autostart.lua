-- Autostart (login only, not on reload).
-- Apps: just Spotify and Vesktop, launched hidden (rules.lua parks them).
return function(rice)
    hl.on("hyprland.start", function()
        -- Session plumbing.
        hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
        hl.exec_cmd("systemctl --user start hyprpolkitagent")
        hl.exec_cmd("hyprctl setcursor " .. rice.settings.look.cursor.theme .. " " .. rice.settings.look.cursor.size)
        hl.exec_cmd("hypridle")
        hl.exec_cmd("qs")
        hl.exec_cmd("wl-paste --watch cliphist store")

        for _, app in pairs(rice.apps) do
            hl.exec_cmd(app.cmd)
        end
    end)
end
