import QtQuick
import "../theme"
import "../services"

// Synced lyrics for the current track (Lyrics service). The sung line is red and centred;
// unsynced lyrics are shown as plain text you can scroll.
Card {
    id: root
    title: "lyrics"
    interactive: true

    readonly property int w: 540
    readonly property int lineH: 28
    readonly property var player: Players.player
    readonly property bool synced: Lyrics.lines.length > 0
    readonly property var model: synced ? Lyrics.lines
        : Lyrics.plain ? Lyrics.plain.split("\n").map(text => ({ t: -1, text })) : []
    property real pos: 0
    // last line already started (a little early so it lands with the singing)
    readonly property int idx: {
        if (!synced) return -1
        let i = -1
        for (let j = 0; j < Lyrics.lines.length && Lyrics.lines[j].t <= pos + 0.25; j++) i = j
        return i
    }

    // MPRIS position is estimated between updates; re-read it often while playing
    Timer {
        interval: 200; repeat: true; triggeredOnStart: true
        running: root.synced && root.player !== null && root.player.isPlaying
        onTriggered: root.pos = root.player.position
    }
    Connections {
        target: root.player
        // catch seeks while paused
        function onPositionChanged() { root.pos = root.player.position }
    }

    Item {
        width: root.w; height: root.lineH * 7

        ListView {
            id: view
            anchors.fill: parent
            visible: root.model.length > 0
            clip: true
            model: root.model
            interactive: !root.synced
            currentIndex: root.synced ? Math.max(0, root.idx) : -1
            highlightRangeMode: root.synced ? ListView.StrictlyEnforceRange : ListView.NoHighlightRange
            preferredHighlightBegin: height / 2 - root.lineH / 2
            preferredHighlightEnd: height / 2 + root.lineH / 2
            highlightMoveDuration: 350
            delegate: Text {
                required property var modelData
                required property int index
                readonly property bool now: root.synced && index === root.idx
                readonly property int dist: root.synced ? Math.abs(index - Math.max(0, root.idx)) : 0
                width: root.w; height: root.lineH
                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                text: modelData.text || "♪"
                color: now ? Theme.red : Theme.text
                opacity: now ? 1 : Math.max(0.2, 0.75 - dist * 0.17)
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: now ? 15 : 12; font.bold: now
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: root.model.length === 0
            text: !root.player ? "nothing playing"
                : Lyrics.status === "loading" ? "searching lyrics…"
                : Lyrics.status === "instrumental" ? "♪  instrumental"
                : Lyrics.status === "offline" ? "lyrics server unreachable, retries next song"
                : "no lyrics found"
            color: Theme.muted
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
        }
    }
}
