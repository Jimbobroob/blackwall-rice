import QtQuick
import "../theme"
import "../services"

// Countdown timer (presets, -1/+1 min, start/pause, reset) beside a stopwatch. State lives in
// services/Timers.qml, so both keep running while the drawer is closed.
Card {
    id: root
    title: "timer"
    interactive: true

    property int w: 420           // content width; the drawer can stretch it
    readonly property int half: (w - 25) / 2

    component Chip: Rectangle {
        id: chip
        property string label: ""
        property bool on: false
        signal clicked()
        width: Math.max(30, t.implicitWidth + 16); height: 24
        radius: Settings.radiusSmall
        color: on ? Theme.red : ma.containsMouse ? Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.15) : "transparent"
        border.width: 1; border.color: on || ma.containsMouse ? Theme.red : Theme.red_dim
        Text {
            id: t
            anchors.centerIn: parent
            text: chip.label
            color: chip.on ? Theme.base : Theme.text
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
        }
        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onClicked: chip.clicked() }
    }
    component Big: Text {
        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 34; font.bold: true
    }
    component Small: Text {
        color: Theme.muted
        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; font.letterSpacing: 2
    }

    Row {
        spacing: 12

        // countdown
        Column {
            width: root.half
            spacing: 8
            Small { text: "COUNTDOWN" }
            Big {
                text: Timers.fmt(Timers.timerLeft)
                color: Timers.timerRunning ? Theme.red : Theme.text
                // scroll to change the length
                MouseArea { anchors.fill: parent; onWheel: w => Timers.nudge(w.angleDelta.y > 0 ? 1 : -1) }
            }
            Rectangle {
                width: parent.width; height: 3; radius: 2
                color: Theme.overlay
                Rectangle {
                    width: parent.width * (Timers.set > 0 ? Timers.timerLeft / Timers.set : 0)
                    height: parent.height; radius: 2; color: Theme.red
                }
            }
            Row {
                spacing: 6
                Chip { label: "5m"; onClicked: Timers.preset(5) }
                Chip { label: "15m"; onClicked: Timers.preset(15) }
                Chip { label: "25m"; onClicked: Timers.preset(25) }
                Chip { label: "-1"; onClicked: Timers.nudge(-1) }
                Chip { label: "+1"; onClicked: Timers.nudge(1) }
            }
            Row {
                spacing: 6
                Chip { label: Timers.timerRunning ? "󰏤 pause" : "󰐊 start"; on: Timers.timerRunning; onClicked: Timers.toggleTimer() }
                Chip { label: "󰑓 reset"; onClicked: Timers.resetTimer() }
            }
        }

        Rectangle { width: 1; height: parent.height; color: Theme.red_dim; opacity: 0.6 }

        // stopwatch
        Column {
            width: root.half
            spacing: 8
            Small { text: "STOPWATCH" }
            Row {
                Big {
                    text: Timers.fmt(Math.floor(Timers.swTime))
                    color: Timers.swRunning ? Theme.red : Theme.text
                }
                Text {
                    anchors.baseline: parent.children[0].baseline
                    text: "." + Math.floor(Timers.swTime * 10) % 10
                    color: Theme.muted
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18
                }
            }
            Item { width: 1; height: 3 }
            Item { width: 1; height: 24 }
            Row {
                spacing: 6
                Chip { label: Timers.swRunning ? "󰏤 pause" : "󰐊 start"; on: Timers.swRunning; onClicked: Timers.toggleSw() }
                Chip { label: "󰑓 reset"; onClicked: Timers.resetSw() }
            }
        }
    }
}
