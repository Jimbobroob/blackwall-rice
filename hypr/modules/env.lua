-- Environment variables for the session.
return function(rice)
    local home = os.getenv("HOME")

    local cursor = rice.settings.look.cursor
    hl.env("XCURSOR_THEME", cursor.theme)
    hl.env("XCURSOR_SIZE", tostring(cursor.size))
    hl.env("HYPRCURSOR_THEME", cursor.theme)
    hl.env("HYPRCURSOR_SIZE", tostring(cursor.size))
    hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
    hl.env("TERMINAL", "kitty")
    hl.env("BROWSER", "firefox")
    -- Let launchers see Flatpak apps (Spotify, Vesktop).
    hl.env("XDG_DATA_DIRS", "/usr/local/share:/usr/share:/var/lib/flatpak/exports/share:"
        .. home .. "/.local/share/flatpak/exports/share")
end
