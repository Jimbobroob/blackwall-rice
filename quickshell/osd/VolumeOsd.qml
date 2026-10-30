import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import "../theme"
import "../services"

// Thin volume bar just above the bottom bar. Quick in, quick out. Shows in game mode too.
PanelWindow {
    id: win

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null
    property bool shown: false
    property bool ready: false

    PwObjectTracker { objects: [win.sink] }

    visible: shown || box.opacity > 0
    anchors { bottom: true }
    margins.bottom: Settings.bar.main_height + 10
    implicitWidth: 320
    implicitHeight: 22
    color: "transparent"
    mask: Region {}       // click-through
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "rice-osd"

    function poke() {
        if (!ready) return
        shown = true
        hide.restart()
    }

    // ignore the volume values reported while the sink is first picked up
    Timer { interval: 1500; running: true; onTriggered: win.ready = true }
    onSinkChanged: { ready = false; settle.restart() }
    Timer { id: settle; interval: 800; onTriggered: win.ready = true }
    Timer { id: hide; interval: Settings.data.osd.timeout_ms; onTriggered: win.shown = false }

    Connections {
        target: win.audio
        function onVolumeChanged() { win.poke() }
        function onMutedChanged() { win.poke() }
    }

    Rectangle {
        id: box
        anchors.fill: parent
        color: Theme.base
        border.width: 1
        border.color: win.audio && win.audio.muted ? Theme.red_dim : Theme.red
        opacity: win.shown ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 70 } }

        Text {
            id: icon
            anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
            text: win.audio && win.audio.muted ? "󰝟" : "󰕾"
            color: win.audio && win.audio.muted ? Theme.red : Theme.text
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13
        }
        Rectangle {
            id: track
            anchors { left: icon.right; leftMargin: 8; right: pct.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
            height: 4
            color: Theme.overlay
            Rectangle {
                height: parent.height
                width: parent.width * Math.min(1, win.audio ? win.audio.volume : 0)
                color: win.audio && win.audio.muted ? Theme.red_dim : Theme.red
                Behavior on width { NumberAnimation { duration: 60 } }
            }
        }
        Text {
            id: pct
            anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
            width: 34
            horizontalAlignment: Text.AlignRight
            text: Math.round((win.audio ? win.audio.volume : 0) * 100)
            color: Theme.magenta
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
        }
    }
}
