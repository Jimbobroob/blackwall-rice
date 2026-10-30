pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Hyprland 0.57 is configured in Lua, so actions go through `hyprctl eval`.
Singleton {
    function lua(code) {
        run.exec(["hyprctl", "eval", code])
    }
    function gotoWorkspace(id) {
        lua("hl.dispatch(hl.dsp.focus({ workspace = " + id + " }))")
    }
    Process { id: run }
}
