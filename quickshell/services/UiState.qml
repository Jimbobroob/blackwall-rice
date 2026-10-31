pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Open/closed state of the side-monitor popups (power menu, notification history).
Singleton {
    id: root
    property bool powerOpen: false
    property bool historyOpen: false
    // side-monitor widgets are a drawer that slides out from the screen edges
    property bool widgetsOpen: false

    function togglePower() { historyOpen = false; powerOpen = !powerOpen }
    function toggleHistory() { powerOpen = false; historyOpen = !historyOpen }
    function toggleWidgets() { widgetsOpen = !widgetsOpen }
    function closeAll() { powerOpen = false; historyOpen = false }

    IpcHandler {
        target: "side"
        function power(): void { root.togglePower() }
        function history(): void { root.toggleHistory() }
        function widgets(): void { root.toggleWidgets() }
        function close(): void { root.closeAll() }
    }
}
