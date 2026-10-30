pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Pending dnf updates. `dnf check-update` exits 100 when there are some.
Singleton {
    id: root
    property int count: 0
    property bool checking: false

    function refresh() {
        if (!check.running) { checking = true; check.running = true }
    }

    // click on the bar: update in a terminal
    function runUpdate() {
        launch.exec(["kitty", "--title", "dnf update", "sh", "-c",
            "sudo dnf upgrade; echo; echo 'Done. Press Enter to close.'; read _"])
        recheck.restart()
    }

    Process { id: launch }

    Process {
        id: check
        command: ["dnf", "check-update", "-q"]
        stdout: StdioCollector {
            onStreamFinished: {
                // package lines look like: name.arch  version  repo
                root.count = text.split("\n").filter(l => /^\S+\.\S+\s+\S+\s+\S+\s*$/.test(l)).length
            }
        }
        onExited: root.checking = false
    }

    // after an update terminal opens, look again in a few minutes
    Timer { id: recheck; interval: 180000; onTriggered: root.refresh() }
    Timer { interval: 30 * 60000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.refresh() }
}
