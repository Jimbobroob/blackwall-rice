import QtQuick
import "../theme"
import "../services"

// Discord voice panel: channel members, who is speaking, mute / deafen buttons.
// Fed by the RiceVoice Vencord plugin (see services/DiscordVoice.qml).
Card {
    id: root
    title: "discord"
    interactive: true

    // members shown as a roughly square grid, filled left to right then down; capped at maxShown
    readonly property int maxShown: 20
    readonly property int cellW: 150
    readonly property var shown: {
        const all = DiscordVoice.members
        if (all.length <= maxShown) return all
        // over the cap: speakers first, then channel order
        return all.map((m, i) => ({ m, i })).sort((a, b) => (b.m.speaking - a.m.speaking) || (a.i - b.i))
                  .slice(0, maxShown).map(x => x.m)
    }
    readonly property int hidden: DiscordVoice.members.length - shown.length
    readonly property int cols: Math.max(2, Math.ceil(Math.sqrt(shown.length)))
    readonly property int w: cols * cellW

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

        Grid {
            columns: root.cols
            columnSpacing: 0; rowSpacing: 10
            Repeater {
                model: root.shown
                delegate: Row {
                    required property var modelData
                    width: root.cellW
                    spacing: 10
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
                        width: root.cellW - 32 - 10 - 28
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
        Text {
            visible: root.hidden > 0
            text: "+" + root.hidden + " more"
            color: Theme.muted
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; font.letterSpacing: 1
        }
    }
}
