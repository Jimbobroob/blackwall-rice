import QtQuick
import Quickshell
import "../theme"
import "../services"

// Main-monitor clock: big digital time (24h by default). Analog is the side monitor's style (phase 3).
Item {
    implicitWidth: col.implicitWidth
    implicitHeight: col.implicitHeight

    SystemClock { id: clock; precision: SystemClock.Minutes }
    readonly property bool h12: Settings.clock.format === "12h"

    Column {
        id: col
        spacing: 0
        Row {
            spacing: 6
            Text {
                text: Qt.formatTime(clock.date, parent.parent.parent.h12 ? "h:mm AP" : "HH:mm")
                color: Theme.text
                font.family: "Rajdhani"; font.pixelSize: 96; font.weight: Font.DemiBold
            }
        }
        Rectangle { width: 120; height: 2; color: Theme.red }
        Text {
            topPadding: 6
            text: Qt.formatDate(clock.date, "dddd d MMMM").toUpperCase()
            color: Theme.muted
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; font.letterSpacing: 2
        }
    }
}
