import QtQuick
import Quickshell
import "../theme"
import "../services"

// Sunrise / sunset with a daylight bar: the marker shows how far through the day the sun is.
Card {
    id: root
    title: "sun"

    property int w: 300           // content width; the drawer can stretch it
    SystemClock { id: clock; precision: SystemClock.Minutes }
    readonly property real now: clock.date.getTime()
    readonly property bool up: now >= Weather.sunrise && now < Weather.sunset
    readonly property real frac: Weather.sunset > Weather.sunrise
        ? Math.max(0, Math.min(1, (now - Weather.sunrise) / (Weather.sunset - Weather.sunrise))) : 0

    function hm(ms) {
        if (!ms) return "--:--"
        const d = new Date(ms)
        return String(d.getHours()).padStart(2, "0") + ":" + String(d.getMinutes()).padStart(2, "0")
    }
    function span(ms) {
        const m = Math.max(0, Math.round(ms / 60000))
        return (m >= 60 ? Math.floor(m / 60) + "h " : "") + m % 60 + "m"
    }

    component Small: Text {
        color: Theme.muted
        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; font.letterSpacing: 1
    }

    Column {
        spacing: 10
        Item {
            width: root.w; height: 34
            Column {
                Small { text: "󰖜  SUNRISE" }
                Text { text: root.hm(Weather.sunrise); color: Theme.text; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16 }
            }
            Column {
                anchors.right: parent.right
                Small { anchors.right: parent.right; text: "SUNSET  󰖛" }
                Text { anchors.right: parent.right; text: root.hm(Weather.sunset); color: Theme.text; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16 }
            }
        }
        // daylight bar
        Item {
            width: root.w; height: 12
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width; height: 4; radius: 2
                color: Theme.overlay
                Rectangle { width: parent.width * root.frac; height: parent.height; radius: 2; color: root.up ? Theme.red : Theme.red_dim }
            }
            Rectangle {
                visible: root.up
                x: parent.width * root.frac - width / 2
                anchors.verticalCenter: parent.verticalCenter
                width: 12; height: 12; radius: 6
                color: Theme.red
                border.width: 2; border.color: Theme.base
            }
        }
        Item {
            width: root.w; height: 14
            Small { text: "DAYLIGHT  " + root.span(Weather.sunset - Weather.sunrise) }
            Small {
                anchors.right: parent.right
                color: Theme.text
                text: !Weather.sunrise ? ""
                    : root.now < Weather.sunrise ? "sunrise in " + root.span(Weather.sunrise - root.now)
                    : root.up ? "sunset in " + root.span(Weather.sunset - root.now)
                    : "sunrise in " + root.span(Weather.nextSunrise - root.now)
            }
        }
    }
}
