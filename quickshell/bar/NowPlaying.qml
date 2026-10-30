import QtQuick
import Quickshell.Services.Mpris
import "../theme"
import "../services"

// Mini now-playing: magenta, click to play/pause, scroll to skip.
Text {
    id: root
    readonly property var player: {
        const list = Mpris.players.values
        return list.find(p => p.isPlaying) || list[0] || null
    }
    visible: player !== null && player.trackTitle !== ""
    width: visible ? Math.min(implicitWidth, 320) : 0
    elide: Text.ElideRight
    text: player ? ((player.isPlaying ? "󰎆 " : "󰏤 ") + (player.trackArtist ? player.trackArtist + " – " : "") + player.trackTitle) : ""
    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: Settings.bar.font_size
    color: player && player.isPlaying ? Theme.magenta : Theme.muted

    TapHandler { onTapped: if (root.player) root.player.togglePlaying() }
    WheelHandler {
        onWheel: e => {
            if (!root.player) return
            if (e.angleDelta.y > 0) root.player.next(); else root.player.previous()
        }
    }
}
