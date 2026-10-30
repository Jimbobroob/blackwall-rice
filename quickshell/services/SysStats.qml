pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// CPU / GPU / RAM / network figures, sampled once a second by scripts/stats.sh.
Singleton {
    id: root
    property real cpu: 0          // 0..100
    property real cpuTemp: 0      // °C
    property real gpu: 0          // 0..100
    property real gpuTemp: 0      // °C
    property real ramUsedGb: 0
    property real ramTotalGb: 0
    readonly property real ram: ramTotalGb > 0 ? ramUsedGb / ramTotalGb * 100 : 0
    property real rxRate: 0       // bytes/s
    property real txRate: 0

    // short history for the network graph
    property var rxHistory: new Array(60).fill(0)
    property var txHistory: new Array(60).fill(0)

    property var _prev: null

    Process {
        running: true
        command: [Quickshell.shellPath("scripts/stats.sh")]
        stdout: SplitParser {
            onRead: line => {
                const f = line.trim().split(" ").map(Number)
                if (f.length < 9 || f.some(isNaN)) return
                const [total, idle, used, tot, ct, gt, gb, rx, tx] = f
                if (root._prev) {
                    const dt = total - root._prev.total
                    if (dt > 0) root.cpu = (1 - (idle - root._prev.idle) / dt) * 100
                    root.rxRate = Math.max(0, rx - root._prev.rx)
                    root.txRate = Math.max(0, tx - root._prev.tx)
                    root.rxHistory = [...root.rxHistory.slice(1), root.rxRate]
                    root.txHistory = [...root.txHistory.slice(1), root.txRate]
                }
                root._prev = { total, idle, rx, tx }
                root.ramUsedGb = used / 1048576
                root.ramTotalGb = tot / 1048576
                root.cpuTemp = ct / 1000
                root.gpuTemp = gt / 1000
                root.gpu = gb
            }
        }
    }

    function fmtRate(b) {
        if (b >= 1048576) return (b / 1048576).toFixed(1) + " MB/s"
        if (b >= 1024) return Math.round(b / 1024) + " KB/s"
        return Math.round(b) + " B/s"
    }
}
