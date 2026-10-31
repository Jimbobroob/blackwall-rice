pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// The media player the widgets follow: the one picked by hand (cycle()), else whatever is
// playing, else the last one that played, else Spotify, else the first one around.
Singleton {
    id: root
    readonly property var list: Mpris.players.values.filter(p => p.trackTitle !== "")
    property var pinned: null
    property var last: null

    readonly property var player: list.includes(pinned) ? pinned
        : list.find(p => p.isPlaying) || (list.includes(last) ? last : null)
          || list.find(p => nameOf(p) === "spotify") || list[0] || null
    readonly property bool playing: player !== null && player.isPlaying

    // remember the last player that started playing
    Instantiator {
        model: Mpris.players
        delegate: Connections {
            required property var modelData
            target: modelData
            function onIsPlayingChanged() { if (modelData.isPlaying) { root.last = modelData; root.pinned = null } }
        }
    }

    function cycle() {
        if (list.length < 2) return
        pinned = list[(list.indexOf(player) + 1) % list.length]
    }

    // "spotify", "firefox", ...
    function nameOf(p) {
        if (!p) return ""
        const n = (p.identity || p.desktopEntry || "player").toLowerCase().replace(/^mozilla /, "")
        return n.split(".").pop()     // org.mozilla.firefox -> firefox
    }
}
