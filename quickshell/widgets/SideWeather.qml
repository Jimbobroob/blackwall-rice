import QtQuick
import "../theme"
import "../services"

Card {
    title: "weather"
    Row {
        spacing: 18
        Text {
            text: Weather.icon
            color: Theme.red
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 64
            anchors.verticalCenter: parent.verticalCenter
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: Weather.ok ? Math.round(Weather.temp) + Weather.unit : "--"
                color: Theme.text
                font.family: "Rajdhani"; font.pixelSize: 56; font.weight: Font.DemiBold
            }
            Text {
                text: Weather.ok ? Weather.label.toUpperCase() : "NO DATA"
                color: Theme.text
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.letterSpacing: 1
            }
            Text {
                text: Weather.ok ? ("FEELS " + Math.round(Weather.feels) + "° · " + Math.round(Weather.wind) + " " + Weather.windUnit).toUpperCase() : ""
                color: Theme.muted
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; font.letterSpacing: 1
            }
            Text {
                text: Settings.data.weather.location.toUpperCase()
                color: Theme.red_dim
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; font.letterSpacing: 1
            }
        }
    }
}
