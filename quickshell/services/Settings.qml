pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// Live view of ~/rice/settings.json (via theme/settings.json). Edits apply without a restart.
Singleton {
    id: root

    property var data: ({
        glitch_level: "medium",
        glitch_levels: { medium: { pop_ms: 260, strength: 0.045, scan_alpha: 0.10, scan_pitch: 3, ws_ms: 200, ws_intensity: 0.8 } },
        clock: { format: "24h", main_style: "digital", side_style: "analog" },
        weather: { latitude: 51.5, longitude: -0.13, temperature_unit: "C", wind_unit: "mph", refresh_minutes: 15 },
        monitors: { main: { desc: "", output: "HDMI-A-1", workspaces: [1, 2, 3, 4, 5] },
                    side: { desc: "", output: "DP-2", workspaces: [6, 7, 8, 9, 10] } },
        bar: { main_height: 28, font_size: 12 },
        launcher: { width: 640, max_results: 8 },
        notifications: { timeout_ms: 6000, width: 380 },
        osd: { timeout_ms: 1100 },
        look: { radius: 12 },
        widgets: { main: [], side: [] }
    })

    readonly property var clock: data.clock
    readonly property var monitors: data.monitors
    readonly property var bar: data.bar
    // active glitch profile (settings.json -> glitch_level picks one of glitch_levels)
    readonly property var glitch: (data.glitch_levels && data.glitch_levels[data.glitch_level]) || ({ pop_ms: 0, strength: 0, scan_alpha: 0, scan_pitch: 3, ws_ms: 0, ws_intensity: 0 })
    // corner radius for everything (settings.json -> look.radius); small = chips, buttons, bars
    readonly property int radius: data.look ? data.look.radius : 12
    readonly property int radiusSmall: Math.round(radius / 2)
    // side widgets that exist so far
    readonly property var sideWidgetIds: ["clock", "calendar", "weather", "spotify", "discord", "sysstats", "network", "cava"]

    FileView {
        path: Quickshell.shellPath("theme/settings.json")
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try { root.data = JSON.parse(text()) } catch (e) { console.warn("settings.json:", e) }
        }
    }

    // Monitors are matched by description (survives the KVM renaming ports), output name as fallback.
    function roleOf(screen) {
        const mon = Hyprland.monitorFor(screen)
        const desc = mon && mon.lastIpcObject ? (mon.lastIpcObject.description || "") : ""
        for (const role of ["main", "side"]) {
            const m = data.monitors[role]
            if (desc && m.desc && desc.startsWith(m.desc)) return role
        }
        for (const role of ["main", "side"])
            if (screen.name === data.monitors[role].output) return role
        return ""
    }

    function hasRole(role) {
        for (const s of Quickshell.screens)
            if (roleOf(s) === role) return true
        return false
    }
}
