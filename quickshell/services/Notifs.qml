pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

// The notification daemon (replaces dunst). No sound, no do-not-disturb.
// `popups` are the live toasts; `history` is kept for the bell panel (phase 3).
Singleton {
    id: root
    property var popups: []
    property var history: []

    function dismissPopup(n) {
        root.popups = root.popups.filter(p => p !== n)
    }

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        actionsSupported: true

        onNotification: n => {
            n.tracked = true
            root.popups = [...root.popups, n]
            root.history = [{
                id: n.id, appName: n.appName, summary: n.summary, body: n.body,
                urgency: n.urgency, time: Date.now()
            }, ...root.history].slice(0, 100)
            n.closed.connect(() => root.dismissPopup(n))
        }
    }

    function clearHistory() { history = [] }
}
