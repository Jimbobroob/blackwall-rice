import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "../theme"
import "../services"

// Per-app volume: the output device on top, then one row per app that is playing audio
// (an app's streams are grouped, e.g. Spotify opens two). Drag or scroll a bar; click the icon to mute.
Card {
    id: root
    title: "mixer"
    interactive: true

    readonly property int w: 364
    readonly property var sink: Pipewire.defaultAudioSink
    // stream properties/audio only fill in once tracked, so track every stream and filter after
    readonly property var allStreams: Pipewire.nodes.values.filter(n => n.isStream)
    readonly property var streams: allStreams.filter(n => n.audio && n.properties["media.class"] === "Stream/Output/Audio")
    // [{ name, nodes }] in first-seen order
    readonly property var apps: {
        const groups = []
        for (const n of streams) {
            const name = n.properties["application.name"] || n.nickname || n.name || "app"
            const g = groups.find(x => x.name === name)
            g ? g.nodes.push(n) : groups.push({ name, nodes: [n] })
        }
        return groups
    }

    PwObjectTracker { objects: [root.sink, ...root.allStreams] }

    component Slider: Item {
        id: sl
        property string label: ""
        property string icon: "󰕾"
        property var nodes: []
        readonly property var audio: nodes.length && nodes[0].audio ? nodes[0].audio : null
        readonly property real value: audio ? audio.volume : 0
        readonly property bool muted: audio ? audio.muted : false
        width: root.w; height: 30

        function set(v) { for (const n of nodes) if (n.audio) n.audio.volume = Math.max(0, Math.min(1, v)) }
        function toggleMute() { const m = !muted; for (const n of nodes) if (n.audio) n.audio.muted = m }

        Text {
            id: ico
            width: 22
            anchors.verticalCenter: parent.verticalCenter
            text: sl.muted ? "󰝟" : sl.icon
            color: sl.muted ? Theme.red : icoMa.containsMouse ? Theme.red : Theme.text
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15
            MouseArea { id: icoMa; anchors.fill: parent; anchors.margins: -4; hoverEnabled: true; onClicked: sl.toggleMute() }
        }
        Text {
            x: 28; width: 92
            anchors.verticalCenter: parent.verticalCenter
            text: sl.label
            elide: Text.ElideRight
            color: sl.muted ? Theme.muted : Theme.text
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
        }
        Item {
            id: track
            x: 128; width: root.w - 128 - 44; height: parent.height
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width; height: barMa.containsMouse || barMa.pressed ? 6 : 4; radius: 3
                color: Theme.overlay
                Rectangle {
                    width: parent.width * Math.min(1, sl.value); height: parent.height; radius: 3
                    color: sl.muted ? Theme.muted : Theme.red
                }
            }
            MouseArea {
                id: barMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onPressed: m => sl.set(m.x / width)
                onPositionChanged: m => { if (pressed) sl.set(m.x / width) }
                onWheel: w => sl.set(sl.value + (w.angleDelta.y > 0 ? 0.05 : -0.05))
            }
        }
        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(sl.value * 100)
            color: Theme.muted
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
        }
    }

    Column {
        spacing: 2
        Slider { label: "output"; icon: "󰓃"; nodes: root.sink ? [root.sink] : [] }
        Rectangle { width: root.w; height: 1; color: Theme.red_dim; opacity: 0.6 }
        Repeater {
            model: root.apps
            delegate: Slider {
                required property var modelData
                label: modelData.name.toLowerCase()
                nodes: modelData.nodes
            }
        }
        Text {
            visible: root.apps.length === 0
            height: 30; verticalAlignment: Text.AlignVCenter
            text: "no apps playing audio"
            color: Theme.muted
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
        }
    }
}
