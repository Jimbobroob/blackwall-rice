import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"
import "../services"

// Top apps by CPU, btop-style. Processes with the same name are summed (browser tabs etc.).
// CPU is per core like top/btop (a busy game can pass 100%). Streams `top` only while loaded,
// i.e. while the drawer shows this tab.
Card {
    id: root
    title: "processes"
    property int count: 8
    property var rows: []
    property string tasks: ""
    property var _frame: ({})

    readonly property int w: 568
    readonly property int segs: 14

    function flush() {
        if (Object.keys(_frame).length === 0) return
        const list = Object.keys(_frame).map(k => ({ name: k, cpu: _frame[k].cpu, mem: _frame[k].mem }))
        list.sort((a, b) => b.cpu - a.cpu || b.mem - a.mem)
        rows = list.slice(0, count)
        _frame = ({})
    }
    function fmtMem(pct) {
        const gb = pct / 100 * SysStats.ramTotalGb
        return gb >= 1 ? gb.toFixed(1) + " GB" : Math.round(gb * 1024) + " MB"
    }

    Process {
        running: true
        command: ["top", "-b", "-d", "2", "-w", "512", "-o", "%CPU"]
        stdout: SplitParser {
            onRead: line => {
                if (line.startsWith("Tasks:")) { root.tasks = line.split(",")[0].replace("Tasks:", "").trim(); return }
                const f = line.trim().split(/\s+/)
                // the column header starts each frame: show the frame collected before it
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

    component Head: Text {
        color: Theme.muted
        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; font.letterSpacing: 2
    }

    Column {
        spacing: 4
        Item {
            width: root.w; height: 20
            Head { text: "NAME" + (root.tasks ? "   · " + root.tasks : "") }
            Head { x: 300; text: "CPU" }
            Head { anchors.right: parent.right; text: "MEM" }
        }
        Repeater {
            model: root.rows.length ? root.rows : [{ name: "sampling…", cpu: 0, mem: 0 }]
            delegate: Item {
                id: row
                required property var modelData
                required property int index
                width: root.w; height: 22

                Text {
                    width: 280
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.modelData.name
                    elide: Text.ElideRight
                    color: row.index === 0 && row.modelData.cpu > 0 ? Theme.red : Theme.text
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                }
                // segmented meter, full at 100% of one core
                Row {
                    x: 300; spacing: 3
                    anchors.verticalCenter: parent.verticalCenter
                    Repeater {
                        model: root.segs
                        delegate: Rectangle {
                            required property int index
                            width: 6; height: 10; radius: 1
                            color: index < Math.ceil(Math.min(100, row.modelData.cpu) / 100 * root.segs)
                                ? (row.modelData.cpu > 90 ? Theme.warning : Theme.red) : Theme.overlay
                        }
                    }
                }
                Text {
                    x: 430; width: 52
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    text: row.modelData.cpu.toFixed(1) + "%"
                    color: Theme.text
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                }
                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.fmtMem(row.modelData.mem)
                    color: Theme.muted
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                }
            }
        }
    }
}
