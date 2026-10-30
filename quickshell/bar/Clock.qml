import QtQuick
import Quickshell
import "../theme"
import "../services"

// 24h by default; settings.json clock.format = "12h" switches it.
Text {
    SystemClock { id: clock; precision: SystemClock.Minutes }
    text: Qt.formatTime(clock.date, Settings.clock.format === "12h" ? "h:mm AP" : "HH:mm")
    font.family: "Rajdhani"; font.pixelSize: Settings.bar.font_size + 3; font.bold: true
    color: Theme.magenta
}
