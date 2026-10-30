import QtQuick
import "../theme"
import "../services"

Item {
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        spacing: 14
        Text {
            text: Weather.icon
            color: Theme.magenta
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 44
        }
        Column {
            Text {
                text: Weather.ok ? Math.round(Weather.temp) + Weather.unit : "--"
                color: Theme.text
                font.family: "Rajdhani"; font.pixelSize: 40; font.weight: Font.DemiBold
            }
            Text {
                text: Weather.ok ? (Weather.label + " · " + Math.round(Weather.wind) + " " + Weather.windUnit).toUpperCase() : "NO DATA"
                color: Theme.muted
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; font.letterSpacing: 1
            }
            Text {
                text: Settings.data.weather.location.toUpperCase()
                color: Theme.red_dim
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; font.letterSpacing: 1
            }
        }
    }
}
