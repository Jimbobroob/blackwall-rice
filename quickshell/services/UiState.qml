pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Open/closed state of the side-monitor popups (power menu, notification history).
Singleton {
    id: root
    property bool powerOpen: false
    property bool historyOpen: false

    function togglePower() { historyOpen = false; powerOpen = !powerOpen }
    function toggleHistory() { powerOpen = false; historyOpen = !historyOpen }
    function closeAll() { powerOpen = false; historyOpen = false }

    IpcHandler {
        target: "side"
        function power(): void { root.togglePower() }
        function history(): void { root.toggleHistory() }
        function close(): void { root.closeAll() }
    }
}
