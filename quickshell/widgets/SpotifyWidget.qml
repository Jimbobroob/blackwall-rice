import QtQuick
import Quickshell.Services.Mpris
import "../theme"
import "../services"

// Spotify now-playing card (MPRIS): art, title, artist, progress, prev / play-pause / next.
Card {
    id: root
    title: "spotify"
    interactive: true

    readonly property var player: Mpris.players.values.find(p =>
        (p.desktopEntry || "").toLowerCase().includes("spotify")
        || (p.identity || "").toLowerCase().includes("spotify")) || null
    readonly property bool active: player !== null && player.trackTitle !== ""
    readonly property real frac: active && player.length > 0 ? Math.min(1, player.position / player.length) : 0

    function fmt(s) {
        s = Math.max(0, Math.floor(s))
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0")
    }

    // MPRIS doesn't push position updates; poll while playing.
    Timer {
        interval: 1000; repeat: true
        running: root.active && root.player.isPlaying
        onTriggered: root.player.positionChanged()
    }

    component Ctl: Text {
        id: ctl
        property bool big: false
        signal clicked()
        color: ma.containsMouse ? Theme.red : Theme.text
        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: big ? 30 : 22
        MouseArea { id: ma; anchors.fill: parent; anchors.margins: -8; hoverEnabled: true; onClicked: ctl.clicked() }
    }

    Row {
        spacing: 18

        Rectangle {
            width: 132; height: 132
            radius: Settings.radius / 2
            color: Theme.overlay
            border.width: 1; border.color: Theme.red_dim
            clip: true
            Image {
                anchors.fill: parent
                source: root.active ? root.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: status === Image.Ready
            }
            Text {
                anchors.centerIn: parent
                visible: !root.active
                text: "󰓇"; color: Theme.muted
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 48
            }
        }

        Column {
            width: 300
            spacing: 6
            Text {
                width: parent.width
                text: root.active ? root.player.trackTitle : "Nothing playing"
                color: root.active && root.player.isPlaying ? Theme.magenta : Theme.text
                elide: Text.ElideRight
                font.family: "Rajdhani"; font.pixelSize: 26; font.bold: true
            }
            Text {
                width: parent.width
                text: root.active ? root.player.trackArtist : (root.player ? "paused" : "spotify not running")
                color: Theme.muted
                elide: Text.ElideRight
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
            }
            Item { width: 1; height: 6 }
            // progress
            Rectangle {
                width: parent.width; height: 4; radius: 2
                color: Theme.overlay
                Rectangle { width: parent.width * root.frac; height: parent.height; radius: 2; color: Theme.red }
            }
            Item {
                width: parent.width; height: 14
                Text {
                    text: root.active ? root.fmt(root.player.position) : "0:00"
                    color: Theme.muted
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                }
                Text {
                    anchors.right: parent.right
                    text: root.active ? root.fmt(root.player.length) : "0:00"
                    color: Theme.muted
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                }
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 28
                Ctl { text: "󰒮"; onClicked: if (root.player) root.player.previous() }
                Ctl {
                    big: true
                    text: root.player && root.player.isPlaying ? "󰏤" : "󰐊"
                    onClicked: if (root.player) root.player.togglePlaying()
                }
                Ctl { text: "󰒭"; onClicked: if (root.player) root.player.next() }
            }
        }
    }
}
