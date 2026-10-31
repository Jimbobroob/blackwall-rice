pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// Alt+Tab window switcher state. Hyprland binds (hypr/modules/binds.lua) drive it:
//   Alt+Tab        -> qs ipc call switcher next   (opens on the previous window, then steps)
//   Alt+Shift+Tab  -> qs ipc call switcher prev
//   release Alt    -> qs ipc call switcher commit (focus the picked window)
Singleton {
    id: root

    property bool open: false
    property int index: 0
    // [{ address, title, cls, wsName, special, toplevel }], most recently used first
    property var items: []

    property bool loading: false
    property int pendingStep: 0       // steps pressed while the list was still loading
    property bool pendingCommit: false // Alt released before the list arrived (quick tap)

    function strip(a) { return (a || "").replace(/^0x/, "") }

    function step(dir) {
        if (open) {
            if (items.length > 0) index = (index + dir + items.length) % items.length
            return
        }
        if (loading) { pendingStep += dir; return }
        loading = true
        pendingStep = dir
        pendingCommit = false
        clients.running = true
    }

    function finishLoad(list) {
        loading = false
        items = list
        if (list.length === 0) return
        // first press lands on the previous window, like Windows
        // (Alt+Shift+Tab first lands on the oldest one)
        const n = list.length
        const raw = pendingStep > 0 ? (n > 1 ? 1 : 0) + pendingStep - 1 : pendingStep
        index = ((raw % n) + n) % n
        if (pendingCommit) { pendingCommit = false; focus(items[index]); return }
        open = true
    }

    function commit() {
        if (loading) { pendingCommit = true; return }
        if (!open) return
        pick(index)
    }

    function pick(i) {
        const item = items[i]
        open = false
        if (item) focus(item)
    }

    function cancel() { open = false; loading = false; pendingCommit = false }

    function focus(item) {
        Hypr.lua("rice.focus_window(\"0x" + strip(item.address) + "\")")
    }

    Process {
        id: clients
        command: ["hyprctl", "-j", "clients"]
        stdout: StdioCollector {
            onStreamFinished: {
                let list = []
                try {
                    const tops = Hyprland.toplevels.values
                    list = JSON.parse(text)
                        .filter(c => c.mapped && !c.hidden && c.workspace && c.workspace.id !== 0)
                        .sort((a, b) => a.focusHistoryID - b.focusHistoryID)
                        .map(c => {
                            const special = (c.workspace.name || "").startsWith("special:")
                            return {
                                address: c.address,
                                title: c.title || c.class,
                                cls: c.class || "",
                                wsName: special ? c.workspace.name.slice(8).toUpperCase() : "WS " + c.workspace.id,
                                special: special,
                                toplevel: tops.find(t => root.strip(t.address) === root.strip(c.address)) || null
                            }
                        })
                } catch (e) { console.warn("switcher:", e) }
                root.finishLoad(list)
            }
        }
    }

    IpcHandler {
        target: "switcher"
        function next(): void { root.step(1) }
        function prev(): void { root.step(-1) }
        function commit(): void { root.commit() }
        function cancel(): void { root.cancel() }
    }
}
