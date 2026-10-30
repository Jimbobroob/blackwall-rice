pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// hypr/modules/gamemode.lua writes 1/0 to $XDG_RUNTIME_DIR/rice/gamemode.
Singleton {
    id: root
    property bool on: false

    FileView {
        path: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/rice/gamemode"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.on = text().trim() === "1"
        onLoadFailed: root.on = false
    }
}
