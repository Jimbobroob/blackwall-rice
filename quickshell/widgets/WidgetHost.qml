import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import "../theme"
import "../services"
import "../fx"

// One passive desktop widget. Anchor and margin come from settings.json:
//   { "id": "clock", "anchor": "top-right", "margin": [horizontal, vertical] }
// Optional "when": "playing" (Spotify is playing) or "call" (in a Discord call) shows it only then;
// it lingers a few seconds after, so a quick pause or rejoin doesn't flicker it.
PanelWindow {
    id: win
    required property var spec
    property string role: "main"

    readonly property string a: spec.anchor || "top-left"
    readonly property var m: spec.margin || [48, 48]

    readonly property var spotify: Mpris.players.values.find(p =>
        (p.desktopEntry || "").toLowerCase().includes("spotify")
        || (p.identity || "").toLowerCase().includes("spotify")) || null
    readonly property bool cond: !spec.when
        || (spec.when === "playing" && spotify !== null && spotify.isPlaying)
        || (spec.when === "call" && DiscordVoice.connected)
    property bool shown: cond
    onCondChanged: if (cond) { hideTimer.stop(); shown = true } else hideTimer.restart()
    Timer { id: hideTimer; interval: 8000; onTriggered: win.shown = false }
    visible: shown

    anchors {
        left: a.includes("left"); right: a.includes("right")
        top: a.includes("top");   bottom: a.includes("bottom")
    }
    margins {
        left: a.includes("left") ? m[0] : 0
        right: a.includes("right") ? m[0] : 0
        top: a.includes("top") ? m[1] : 0
        bottom: a.includes("bottom") ? m[1] : 0
    }

    implicitWidth: loader.item ? loader.item.implicitWidth : 1
    implicitHeight: loader.item ? loader.item.implicitHeight : 1
    color: "transparent"
    // passive widgets are click-through; interactive ones (Card.interactive) take input
    mask: Region { item: loader.item && loader.item.interactive ? loader.item : null }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "rice-widget-" + spec.id

    // widget id -> file, per monitor role
    QtObject {
        id: files
        readonly property var mainFiles: ({ clock: "MainClock.qml", weather: "MainWeather.qml" })
        readonly property var sideFiles: ({
            clock: "SideClock.qml", calendar: "SideCalendar.qml", weather: "SideWeather.qml",
            spotify: "SpotifyWidget.qml", discord: "DiscordWidget.qml", sysstats: "SysStatsWidget.qml", network: "NetSpeed.qml", cava: "CavaWidget.qml"
        })
    }

    Loader {
        id: loader
        active: win.shown
        source: (win.role === "side" ? files.sideFiles : files.mainFiles)[win.spec.id] || ""
        onLoaded: pop.play(Math.random() * 300)
    }
    GlitchIn { id: pop; target: loader }
}
