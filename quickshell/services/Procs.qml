pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Top apps by CPU from a long-running `top`, refreshed every 2 s so the processes card is
// filled the moment it opens. Processes with the same name are summed (browser tabs etc.);
// CPU is per core like top/btop (a busy game can pass 100%).
Singleton {
    id: root
    property int count: 8
    property var rows: []
    property string tasks: ""
    property var _frame: ({})

    function flush() {
        if (Object.keys(_frame).length === 0) return
        const list = Object.keys(_frame).map(k => ({ name: k, cpu: _frame[k].cpu, mem: _frame[k].mem }))
        list.sort((a, b) => b.cpu - a.cpu || b.mem - a.mem)
        rows = list.slice(0, count)
        _frame = ({})
    }

    Process {
        running: true
        command: ["top", "-b", "-d", "2", "-w", "512", "-o", "%CPU"]
        stdout: SplitParser {
            onRead: line => {
                if (line.startsWith("Tasks:")) { root.tasks = line.split(",")[0].replace("Tasks:", "").trim(); return }
                const f = line.trim().split(/\s+/)
                // the column header starts each frame: publish the frame collected before it
                if (f[0] === "PID") { root.flush(); return }
                if (!/^\d+$/.test(f[0]) || f.length < 12) return
                const name = f.slice(11).join(" ")
                if (name === "top") return
                const e = root._frame[name] || (root._frame[name] = { cpu: 0, mem: 0 })
                e.cpu += Number(f[8]) || 0
                e.mem += Number(f[9]) || 0
            }
        }
    }
}
