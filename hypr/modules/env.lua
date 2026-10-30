-- Environment variables for the session.
return function(rice)
    local home = os.getenv("HOME")

    hl.env("XCURSOR_SIZE", "24")
    hl.env("HYPRCURSOR_SIZE", "24")
    hl.env("TERMINAL", "kitty")
    hl.env("BROWSER", "firefox")
    -- Let launchers see Flatpak apps (Spotify, Vesktop).
    hl.env("XDG_DATA_DIRS", "/usr/local/share:/usr/share:/var/lib/flatpak/exports/share:"
        .. home .. "/.local/share/flatpak/exports/share")
end
