import QtQuick
import "../theme"
import "../services"

// Upcoming reminders (services/Reminders.qml) with a countdown each; ✕ deletes one.
// New ones come from the launcher: "remind 18:30 raid", "remind 20m tea".
Card {
    id: root
    title: "reminders"
    interactive: true

    property int w: 300           // content width; the drawer can stretch it
    readonly property int maxShown: 4

    // keep the countdowns moving while the card is open
    Timer { interval: 1000; repeat: true; running: true; onTriggered: Reminders.now = Date.now() }

    Column {
        width: root.w
        spacing: 4
        Repeater {
            model: Reminders.items.slice(0, root.maxShown)
            delegate: Item {
                id: rem
                required property var modelData
                required property int index
                width: root.w; height: 26
                Text {
                    width: 82
                    anchors.verticalCenter: parent.verticalCenter
                    text: Reminders.clockText(rem.modelData.at)
                    color: rem.index === 0 ? Theme.red : Theme.text
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                }
                Text {
                    x: 86; width: root.w - 86 - 100
                    anchors.verticalCenter: parent.verticalCenter
                    text: rem.modelData.text
                    elide: Text.ElideRight
                    color: Theme.text
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                }
                Text {
                    anchors.right: parent.right; anchors.rightMargin: 26
                    anchors.verticalCenter: parent.verticalCenter
                    text: Reminders.untilText(rem.modelData.at)
                    color: Theme.muted
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                }
                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰅖"
                    color: delMa.containsMouse ? Theme.red : Theme.muted
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14
                    MouseArea { id: delMa; anchors.fill: parent; anchors.margins: -4; hoverEnabled: true; onClicked: Reminders.remove(rem.index) }
                }
            }
        }
        Text {
            visible: Reminders.items.length > root.maxShown
            text: "+" + (Reminders.items.length - root.maxShown) + " more"
            color: Theme.muted
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
        }
        Text {
            visible: Reminders.items.length === 0
            height: 26; verticalAlignment: Text.AlignVCenter
            text: "nothing set"
            color: Theme.muted
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
        }
        Text {
            topPadding: 4
            text: "launcher: remind 18:30 raid  ·  remind 20m tea"
            color: Theme.muted; opacity: 0.7
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
        }
    }
}
