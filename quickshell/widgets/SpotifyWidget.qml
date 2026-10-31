import QtQuick
import "../theme"
import "../services"

// Now-playing card for any MPRIS player (Players service): art, title, artist, seekable progress,
// prev / play-pause / next, volume knob; the switch button under the knob cycles players.
Card {
    id: root
    title: Players.player ? Players.nameOf(Players.player) : "media"
    interactive: true

    readonly property var player: Players.player
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

    // Rotary volume knob (Spotify's own volume over MPRIS). Drag around it or scroll; 270 degree sweep.
    component Knob: Item {
        id: k
        property real value: 0
        property bool enabled: true
        signal moved(real v)
        width: 72; height: 72
        onValueChanged: arc.requestPaint()

        function setFromPoint(x, y) {
            // angle 0 = bottom-left start (135 deg), sweeping clockwise through the top to 405 deg
            let a = Math.atan2(y - height / 2, x - width / 2) * 180 / Math.PI   // -180..180, 0 = right
            a = (a + 360) % 360
            let rel = (a - 135 + 360) % 360
            if (rel > 270) rel = rel < 315 ? 270 : 0                            // dead zone at the bottom
            k.moved(rel / 270)
        }

        Canvas {
            id: arc
            anchors.fill: parent
            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                const c = width / 2, r = c - 6
                const a0 = 135 * Math.PI / 180, sweep = 270 * Math.PI / 180
                ctx.lineWidth = 4; ctx.lineCap = "round"
                ctx.strokeStyle = Theme.overlay
                ctx.beginPath(); ctx.arc(c, c, r, a0, a0 + sweep); ctx.stroke()
                if (k.value > 0.005) {
                    ctx.strokeStyle = Theme.red
                    ctx.beginPath(); ctx.arc(c, c, r, a0, a0 + sweep * k.value); ctx.stroke()
                }
                const ang = a0 + sweep * k.value
                ctx.fillStyle = Theme.red
                ctx.beginPath(); ctx.arc(c + Math.cos(ang) * (r - 12), c + Math.sin(ang) * (r - 12), 3, 0, Math.PI * 2); ctx.fill()
            }
        }
        Text {
            anchors.centerIn: parent
            text: Math.round(k.value * 100)
            color: ma.containsMouse || ma.pressed ? Theme.red : Theme.text
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14
        }
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            enabled: k.enabled
            onPressed: m => k.setFromPoint(m.x, m.y)
            onPositionChanged: m => { if (pressed) k.setFromPoint(m.x, m.y) }
            onWheel: w => k.moved(Math.max(0, Math.min(1, k.value + (w.angleDelta.y > 0 ? 0.05 : -0.05))))
        }
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
                text: "󰝚"; color: Theme.muted
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 48
            }
        }

        Column {
            width: 300
            spacing: 6
            Text {
                width: parent.width
                text: root.active ? root.player.trackTitle : "Nothing playing"
                color: root.active && root.player.isPlaying ? Theme.red : Theme.text
                elide: Text.ElideRight
                font.family: "Rajdhani"; font.pixelSize: 26; font.bold: true
            }
            Text {
                width: parent.width
                text: root.active ? root.player.trackArtist : (root.player ? "paused" : "no player running")
                color: Theme.muted
                elide: Text.ElideRight
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
            }
            Item { width: 1; height: 6 }
            // progress; click or drag to seek
            Item {
                id: seek
                readonly property bool can: root.active && root.player.canSeek && root.player.length > 0
                property real dragFrac: -1
                width: parent.width; height: 12
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width; height: seekMa.containsMouse ? 6 : 4; radius: 3
                    color: Theme.overlay
                    Rectangle {
                        width: parent.width * (seek.dragFrac >= 0 ? seek.dragFrac : root.frac)
                        height: parent.height; radius: 3; color: Theme.red
                    }
                }
                MouseArea {
                    id: seekMa
                    anchors.fill: parent
                    enabled: seek.can
                    hoverEnabled: true
                    cursorShape: seek.can ? Qt.PointingHandCursor : Qt.ArrowCursor
                    function at(x) { return Math.max(0, Math.min(1, x / width)) }
                    onPressed: m => seek.dragFrac = at(m.x)
                    onPositionChanged: m => { if (pressed) seek.dragFrac = at(m.x) }
                    onReleased: m => {
                        root.player.position = at(m.x) * root.player.length
                        seek.dragFrac = -1
                    }
                }
            }
            Item {
                width: parent.width; height: 14
                Text {
                    text: root.active ? root.fmt(seek.dragFrac >= 0 ? seek.dragFrac * root.player.length : root.player.position) : "0:00"
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

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            Knob {
                enabled: root.player !== null && root.player.volumeSupported
                value: root.player && root.player.volumeSupported ? root.player.volume : 0
                onMoved: v => { if (root.player && root.player.volumeSupported) root.player.volume = v }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "VOL"
                color: Theme.muted
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9; font.letterSpacing: 2
            }
            // next player (only when more than one has something loaded)
            Ctl {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: Players.list.length > 1
                text: "󰒝 " + (Players.list.indexOf(root.player) + 1) + "/" + Players.list.length
                font.pixelSize: 11
                onClicked: Players.cycle()
            }
        }
    }
}
