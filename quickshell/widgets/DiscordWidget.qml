import QtQuick
import "../theme"
import "../services"

// Discord voice panel: channel members, who is speaking, mute / deafen buttons.
// Fed by the RiceVoice Vencord plugin (see services/DiscordVoice.qml).
Card {
    id: root
    title: "discord"
    interactive: true

    readonly property int w: 300

    component Toggle: Rectangle {
        id: t
        property string icon: ""
        property bool on: false
        signal clicked()
        width: 40; height: 32
        radius: Settings.radius / 2
        color: on ? Theme.red : (ma.containsMouse ? Theme.overlay : "transparent")
        border.width: 1; border.color: on ? Theme.red : Theme.overlay
        Text {
            anchors.centerIn: parent
            text: t.icon
            color: t.on ? Theme.base : Theme.text
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16
        }
        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onClicked: t.clicked() }
    }

    Column {
        width: root.w
        spacing: 10

        Item {
            width: parent.width; height: 32
            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 100
                elide: Text.ElideRight
                text: !DiscordVoice.online ? "󰙯  discord offline"
                    : DiscordVoice.connected ? "󰕾  " + DiscordVoice.channel : "󰙯  not in a call"
                color: DiscordVoice.connected ? Theme.magenta : Theme.muted
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.letterSpacing: 1
            }
            Row {
                anchors.right: parent.right
                spacing: 8
                visible: DiscordVoice.connected
                Toggle { icon: DiscordVoice.mute ? "󰍭" : "󰍬"; on: DiscordVoice.mute; onClicked: DiscordVoice.toggleMute() }
                Toggle { icon: DiscordVoice.deaf ? "󰟎" : "󰋋"; on: DiscordVoice.deaf; onClicked: DiscordVoice.toggleDeafen() }
            }
        }

        Repeater {
            model: DiscordVoice.members
            delegate: Row {
                required property var modelData
                spacing: 12
                Rectangle {
                    width: 32; height: 32; radius: 16
                    color: Theme.overlay
                    border.width: 2
                    border.color: modelData.speaking ? Theme.magenta : "transparent"
                    clip: true
                    Image {
                        anchors.fill: parent; anchors.margins: 2
                        source: modelData.avatar || ""
                        asynchronous: true
                        visible: status === Image.Ready
                    }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: root.w - 90
                    elide: Text.ElideRight
                    text: modelData.name
                    color: modelData.speaking ? Theme.text : Theme.muted
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.deaf ? "󰟎" : (modelData.mute ? "󰍭" : "")
                    color: Theme.red
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13
                }
            }
        }
    }
}
