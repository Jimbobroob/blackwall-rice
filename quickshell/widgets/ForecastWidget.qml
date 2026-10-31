import QtQuick
import "../theme"
import "../services"

// Next 12 hours (time, icon, temp, rain chance) over the next 5 days (icon, rain, low-high range bar).
Card {
    id: root
    title: "forecast"

    property int w: 600           // content width; the drawer can stretch it
    readonly property var days: ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    // shared scale for the day range bars
    readonly property real minT: Weather.daily.length ? Math.min(...Weather.daily.map(d => d.lo)) : 0
    readonly property real maxT: Weather.daily.length ? Math.max(...Weather.daily.map(d => d.hi)) : 1

    component Small: Text {
        color: Theme.muted
        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; font.letterSpacing: 1
    }

    Column {
        spacing: 10

        // hourly strip
        Row {
            Repeater {
                model: Weather.hourly
                delegate: Column {
                    id: hr
                    required property var modelData
                    required property int index
                    width: root.w / 12
                    spacing: 4
                    Small {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: hr.index === 0 ? "NOW" : String(new Date(hr.modelData.t).getHours()).padStart(2, "0")
                        color: hr.index === 0 ? Theme.red : Theme.muted
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Weather.iconFor(hr.modelData.code, hr.modelData.night)
                        color: hr.index === 0 ? Theme.red : Theme.text
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 20
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Math.round(hr.modelData.temp) + "°"
                        color: Theme.text
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                    }
                    Small {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: hr.modelData.rain >= 10 ? hr.modelData.rain + "%" : "·"
                        color: hr.modelData.rain >= 50 ? Theme.red : Theme.muted
                    }
                }
            }
        }

        Rectangle { width: root.w; height: 1; color: Theme.red_dim; opacity: 0.6 }

        // 5 days
        Repeater {
            model: Weather.daily
            delegate: Item {
                id: day
                required property var modelData
                required property int index
                width: root.w; height: 22
                Small {
                    anchors.verticalCenter: parent.verticalCenter
                    text: day.index === 0 ? "TODAY" : root.days[new Date(day.modelData.t).getDay()]
                    color: day.index === 0 ? Theme.red : Theme.muted
                }
                Text {
                    x: 64
                    anchors.verticalCenter: parent.verticalCenter
                    text: Weather.iconFor(day.modelData.code, false)
                    color: Theme.text
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16
                }
                Small {
                    x: 96; width: 40
                    anchors.verticalCenter: parent.verticalCenter
                    text: day.modelData.rain >= 10 ? "󰖌 " + day.modelData.rain + "%" : ""
                    color: day.modelData.rain >= 50 ? Theme.red : Theme.muted
                }
                Text {
                    x: 150; width: 36
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(day.modelData.lo) + "°"
                    color: Theme.muted
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                }
                // low..high on the 5-day scale
                Rectangle {
                    id: track
                    x: 196; width: root.w - 196 - 46; height: 4; radius: 2
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.overlay
                    readonly property real span: Math.max(1, root.maxT - root.minT)
                    Rectangle {
                        x: track.width * (day.modelData.lo - root.minT) / track.span
                        width: Math.max(4, track.width * (day.modelData.hi - day.modelData.lo) / track.span)
                        height: parent.height; radius: 2
                        color: Theme.red
                    }
                }
                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(day.modelData.hi) + "°"
                    color: Theme.text
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                }
            }
        }

        Small { visible: !Weather.daily.length; text: "loading forecast…" }
    }
}
