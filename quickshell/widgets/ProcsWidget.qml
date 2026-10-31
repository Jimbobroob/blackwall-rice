import QtQuick
import "../theme"
import "../services"

// Top apps by CPU, btop-style. Data comes from the always-running Procs service.
Card {
    id: root
    title: "processes"

    readonly property int w: 568
    readonly property int segs: 14

    function fmtMem(pct) {
        const gb = pct / 100 * SysStats.ramTotalGb
        return gb >= 1 ? gb.toFixed(1) + " GB" : Math.round(gb * 1024) + " MB"
    }

    component Head: Text {
        color: Theme.muted
        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; font.letterSpacing: 2
    }

    Column {
        spacing: 4
        Item {
            width: root.w; height: 20
            Head { text: "NAME" + (Procs.tasks ? "   · " + Procs.tasks : "") }
            Head { x: 300; text: "CPU" }
            Head { anchors.right: parent.right; text: "MEM" }
        }
        Repeater {
            model: Procs.rows.length ? Procs.rows : [{ name: "sampling…", cpu: 0, mem: 0 }]
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
