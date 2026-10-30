import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"
import "../services"

// Audio visualiser fed by cava's raw ASCII output (scripts/cava.conf).
Item {
    id: root
    implicitWidth: 720
    implicitHeight: 160

    property var bars: new Array(48).fill(0)

    Process {
        running: true
        command: ["cava", "-p", Quickshell.shellPath("scripts/cava.conf")]
        stdout: SplitParser {
            onRead: line => {
                const v = line.split(";").filter(s => s !== "").map(Number)
                if (v.length > 0 && !v.some(isNaN)) root.bars = v
            }
        }
    }

    Row {
        anchors.fill: parent
        spacing: 4
        Repeater {
            model: root.bars.length
            delegate: Item {
                required property int index
                width: (root.width - (root.bars.length - 1) * 4) / root.bars.length
                height: root.height
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: Math.max(2, root.bars[index] / 100 * root.height)
                    color: root.bars[index] > 80 ? Theme.magenta : Theme.red
                    Behavior on height { NumberAnimation { duration: 40 } }
                }
            }
        }
    }
}
