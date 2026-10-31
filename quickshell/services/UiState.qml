pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Open/closed state of the side-monitor popups (power menu, notification history).
Singleton {
    id: root
    property bool powerOpen: false
    property bool historyOpen: false
    // top drawer on the side monitor (hover the top edge): pinned keeps it open, tab = shown group
    property bool drawerPinned: false
    property int drawerTab: 0

    function togglePower() { historyOpen = false; powerOpen = !powerOpen }
    function toggleHistory() { powerOpen = false; historyOpen = !historyOpen }
    function toggleDrawer() { drawerPinned = !drawerPinned }
    function closeAll() { powerOpen = false; historyOpen = false }

    IpcHandler {
        target: "side"
        function power(): void { root.togglePower() }
        function history(): void { root.toggleHistory() }
        function widgets(): void { root.toggleDrawer() }
        function close(): void { root.closeAll() }
    }
}
