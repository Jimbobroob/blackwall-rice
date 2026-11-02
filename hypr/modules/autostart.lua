-- Autostart (login only, not on reload).
-- Apps: just Vesktop, launched hidden (rules.lua parks it).
return function(rice)
    hl.on("hyprland.start", function()
        -- Session plumbing.
        hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
        hl.exec_cmd("systemctl --user start hyprpolkitagent")
        hl.exec_cmd("hyprctl setcursor " .. rice.settings.look.cursor.theme .. " " .. rice.settings.look.cursor.size)
        hl.exec_cmd("hypridle")
        hl.exec_cmd("hyprpaper -c " .. rice.dir .. "/generated/hyprpaper.conf")
        hl.exec_cmd("qs")
        hl.exec_cmd(rice.dir .. "/scripts/clipwatch.sh")

        for _, app in pairs(rice.apps) do
            hl.exec_cmd(app.cmd)
        end
    end)
end
