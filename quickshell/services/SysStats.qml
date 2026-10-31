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
    property real diskUsedGb: 0   // root filesystem
    property real diskTotalGb: 0
    readonly property real disk: diskTotalGb > 0 ? diskUsedGb / diskTotalGb * 100 : 0
    property real vramUsedGb: 0
    property real vramTotalGb: 0
    readonly property real vram: vramTotalGb > 0 ? vramUsedGb / vramTotalGb * 100 : 0
    property real uptime: 0       // seconds

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

    // slower figures (disk, VRAM, uptime), every 5 s from scripts/slowstats.sh
    Process {
        running: true
        command: [Quickshell.shellPath("scripts/slowstats.sh")]
        stdout: SplitParser {
            onRead: line => {
                const f = line.trim().split(" ").map(Number)
                if (f.length < 5 || f.some(isNaN)) return
                root.diskUsedGb = f[0] / 1e9
                root.diskTotalGb = f[1] / 1e9
                root.vramUsedGb = f[2] / 1073741824
                root.vramTotalGb = f[3] / 1073741824
                root.uptime = f[4]
            }
        }
    }

    function fmtUptime(s) {
        const d = Math.floor(s / 86400), h = Math.floor(s % 86400 / 3600), m = Math.floor(s % 3600 / 60)
        return (d > 0 ? d + "d " : "") + (d > 0 || h > 0 ? h + "h " : "") + m + "m"
    }

    function fmtRate(b) {
        if (b >= 1048576) return (b / 1048576).toFixed(1) + " MB/s"
        if (b >= 1024) return Math.round(b / 1024) + " KB/s"
        return Math.round(b) + " B/s"
    }
}
