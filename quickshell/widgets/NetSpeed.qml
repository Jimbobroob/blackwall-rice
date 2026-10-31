import QtQuick
import "../theme"
import "../services"

// Live down/up speed with a short history graph.
Card {
    id: root
    title: "network"

    component Graph: Canvas {
        id: g
        property var data: []
        property color tint: Theme.red
        width: 260; height: 101
        onDataChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            const max = Math.max(1048576, ...data)          // scale floor: 1 MB/s
            const step = width / (data.length - 1)
            ctx.beginPath()
            ctx.moveTo(0, height)
            for (let i = 0; i < data.length; i++)
                ctx.lineTo(i * step, height - (data[i] / max) * (height - 4))
            ctx.lineTo(width, height)
            ctx.closePath()
            ctx.fillStyle = Qt.rgba(tint.r, tint.g, tint.b, 0.25)
            ctx.fill()
            ctx.beginPath()
            for (let i = 0; i < data.length; i++) {
                const y = height - (data[i] / max) * (height - 4)
                i === 0 ? ctx.moveTo(0, y) : ctx.lineTo(i * step, y)
            }
            ctx.strokeStyle = tint; ctx.lineWidth = 1.5
            ctx.stroke()
        }
    }

    Column {
        spacing: 10
        Item {
            width: 260; height: 18
            Text {
                text: "󰁅  DOWN"
                color: Theme.muted
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; font.letterSpacing: 2
            }
            Text {
                anchors.right: parent.right
                text: SysStats.fmtRate(SysStats.rxRate)
                color: Theme.text
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13
            }
        }
        Graph { data: SysStats.rxHistory; tint: Theme.red }
        Item {
            width: 260; height: 18
            Text {
                text: "󰁝  UP"
                color: Theme.muted
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; font.letterSpacing: 2
            }
            Text {
                anchors.right: parent.right
                text: SysStats.fmtRate(SysStats.txRate)
                color: Theme.text
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13
            }
        }
        Graph { data: SysStats.txHistory; tint: Theme.red_dim }
    }
}
