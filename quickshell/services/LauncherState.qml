pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property bool open: false
    function toggle() { open = !open }
    function close() { open = false }

    // Super+Enter runs: qs ipc call launcher toggle
    IpcHandler {
        target: "launcher"
        function toggle(): void { root.toggle() }
        function open(): void { root.open = true }
        function close(): void { root.open = false }
    }
}
