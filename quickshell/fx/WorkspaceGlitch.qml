import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../theme"
import "../services"

// Brief red/magenta tear across a monitor when its workspace changes. Click-through overlay.
// Skipped in game mode on the main monitor (it would flash over the game).
PanelWindow {
    id: win
    property string role: ""

    readonly property var mon: Hyprland.monitorFor(screen)
    readonly property int wsId: mon && mon.activeWorkspace ? mon.activeWorkspace.id : -1
    property int lastWs: -2
    property real progress: 0

    visible: progress > 0
    anchors { left: true; right: true; top: true; bottom: true }
    color: "transparent"
    mask: Region {}
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "rice-wsglitch"

    onWsIdChanged: {
        const first = lastWs === -2
        lastWs = wsId
        if (first || wsId < 0 || Settings.glitch.ws_ms <= 0 || Settings.glitch.ws_intensity <= 0) return
        if (role === "main" && GameMode.on) return
        seed = Math.random() * 100
        variance = 0.6 + Math.random() * 0.8
        anim.restart()
    }
    property real seed: 0
    property real variance: 1

    NumberAnimation { id: anim; target: win; property: "progress"; from: 1; to: 0; duration: Settings.glitch.ws_ms * (0.8 + win.variance * 0.3); easing.type: Easing.OutQuad }

    ShaderEffect {
        anchors.fill: parent
        property real progress: win.progress
        property real intensity: Math.min(1, Settings.glitch.ws_intensity * win.variance)
        property real seed: win.seed
        property color red: Theme.red
        property color magenta: Theme.magenta
        fragmentShader: Qt.resolvedUrl("tear.frag.qsb")
    }
}
