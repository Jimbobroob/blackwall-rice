import QtQuick
import Quickshell.Services.Pipewire
import "../theme"
import "../services"

Text {
    id: root
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null
    readonly property int pct: audio ? Math.round(audio.volume * 100) : 0
    readonly property bool muted: audio ? audio.muted : false

    PwObjectTracker { objects: [root.sink] }

    text: (muted ? "󰝟 " : (pct > 60 ? "󰕾 " : pct > 20 ? "󰖀 " : "󰕿 ")) + pct + "%"
    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: Settings.bar.font_size
    color: muted ? Theme.red : Theme.text

    TapHandler { onTapped: if (root.audio) root.audio.muted = !root.audio.muted }
    WheelHandler {
        onWheel: e => {
            if (!root.audio) return
            const step = e.angleDelta.y > 0 ? 0.05 : -0.05
            root.audio.volume = Math.max(0, Math.min(1, root.audio.volume + step))
        }
    }
}
