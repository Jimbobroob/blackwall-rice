import QtQuick
import Quickshell
import "../theme"
import "../services"

// Month grid, weeks start Monday. Today is filled red.
Card {
    id: root
    title: "calendar"

    SystemClock { id: clock; precision: SystemClock.Minutes }

    readonly property date today: clock.date
    readonly property int year: today.getFullYear()
    readonly property int month: today.getMonth()
    readonly property int daysInMonth: new Date(year, month + 1, 0).getDate()
    readonly property int offset: (new Date(year, month, 1).getDay() + 6) % 7   // Monday = 0
    readonly property int cell: 38

    Column {
        spacing: 8
        Text {
            text: Qt.locale().monthName(root.month, Locale.LongFormat).toUpperCase() + " " + root.year
            color: Theme.text
            font.family: "Rajdhani"; font.pixelSize: 26; font.weight: Font.DemiBold; font.letterSpacing: 2
        }
        Grid {
            columns: 7
            Repeater {
                model: ["M", "T", "W", "T", "F", "S", "S"]
                delegate: Text {
                    required property string modelData
                    width: root.cell; height: 24
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    color: Theme.red_dim
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                }
            }
            Repeater {
                model: 42
                delegate: Rectangle {
                    required property int index
                    readonly property int day: index - root.offset + 1
                    readonly property bool valid: day >= 1 && day <= root.daysInMonth
                    readonly property bool isToday: valid && day === root.today.getDate()
                    readonly property bool weekend: index % 7 >= 5
                    width: root.cell; height: root.cell - 6
                    color: isToday ? Theme.red : "transparent"
                    visible: index < root.offset + root.daysInMonth || index < 35
                    Text {
                        anchors.centerIn: parent
                        text: parent.valid ? parent.day : ""
                        color: parent.isToday ? Theme.base : (parent.weekend ? Theme.magenta : Theme.text)
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13
                        font.bold: parent.isToday
                    }
                }
            }
        }
    }
}
