import QtQuick
import Quickshell
import "../theme"
import "../services"

// Side-monitor clock. Analog by default ("an actual clock"), digital if settings say so.
Card {
    id: root
    bare: true
    readonly property bool analog: Settings.clock.side_style !== "digital"
    readonly property bool h12: Settings.clock.format === "12h"
    readonly property int size: 260

    SystemClock { id: clock; precision: SystemClock.Seconds }

    Item {
        width: root.size
        height: root.analog ? root.size + 54 : 150

        // analog face
        Canvas {
            id: face
            visible: root.analog
            width: root.size; height: root.size
            property date now: clock.date
            onNowChanged: requestPaint()
            Component.onCompleted: requestPaint()
            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                const c = width / 2, r = c - 6
                // outer ring
                ctx.strokeStyle = Theme.overlay; ctx.lineWidth = 2
                ctx.beginPath(); ctx.arc(c, c, r, 0, Math.PI * 2); ctx.stroke()
                // ticks
                for (let i = 0; i < 60; i++) {
                    const a = i * Math.PI / 30, major = i % 5 === 0
                    const r1 = r - (major ? 14 : 6), r2 = r - 2
                    ctx.strokeStyle = major ? Theme.red : Theme.muted
                    ctx.lineWidth = major ? 2.5 : 1
                    ctx.beginPath()
                    ctx.moveTo(c + Math.sin(a) * r1, c - Math.cos(a) * r1)
                    ctx.lineTo(c + Math.sin(a) * r2, c - Math.cos(a) * r2)
                    ctx.stroke()
                }
                const d = now
                const s = d.getSeconds(), m = d.getMinutes() + s / 60, h = (d.getHours() % 12) + m / 60
                function hand(angle, len, w, col, tail) {
                    ctx.strokeStyle = col; ctx.lineWidth = w; ctx.lineCap = "butt"
                    ctx.beginPath()
                    ctx.moveTo(c - Math.sin(angle) * tail, c + Math.cos(angle) * tail)
                    ctx.lineTo(c + Math.sin(angle) * len, c - Math.cos(angle) * len)
                    ctx.stroke()
                }
                hand(h * Math.PI / 6, r * 0.5, 5, Theme.text, 0)
                hand(m * Math.PI / 30, r * 0.76, 3, Theme.text, 0)
                hand(s * Math.PI / 30, r * 0.86, 1.5, Theme.red, 18)
                ctx.fillStyle = Theme.red
                ctx.beginPath(); ctx.arc(c, c, 5, 0, Math.PI * 2); ctx.fill()
            }
        }

        // digital alternative
        Text {
            visible: !root.analog
            anchors.horizontalCenter: parent.horizontalCenter
            y: 0
            text: Qt.formatTime(clock.date, root.h12 ? "h:mm AP" : "HH:mm")
            color: Theme.text
            font.family: "Rajdhani"; font.pixelSize: 84; font.weight: Font.DemiBold
        }

        // date
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: root.analog ? root.size + 8 : 100
            text: Qt.formatDate(clock.date, "dddd d MMMM").toUpperCase()
            color: Theme.muted
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; font.letterSpacing: 2
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: root.analog ? root.size + 30 : 122
            text: Qt.formatDate(clock.date, "yyyy")
            color: Theme.red
            font.family: "Rajdhani"; font.pixelSize: 18; font.weight: Font.DemiBold; font.letterSpacing: 4
        }
    }
}
