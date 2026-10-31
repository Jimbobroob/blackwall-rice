import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../services"
import "../fx"

// One passive desktop widget. Anchor and margin come from settings.json:
//   { "id": "clock", "anchor": "top-right", "margin": [horizontal, vertical] }
PanelWindow {
    id: win
    required property var spec
    property string role: "main"

    readonly property string a: spec.anchor || "top-left"
    readonly property var m: spec.margin || [48, 48]

    // side widgets are a drawer: slide 0 = parked off the nearest screen edge, 1 = in place
    readonly property bool drawer: role === "side"
    property real slide: drawer ? (UiState.widgetsOpen ? 1 : 0) : 1
    Behavior on slide { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    readonly property real away: (1 - slide) * (implicitWidth + m[0])
    onSlideChanged: if (slide === 1 && drawer) pop.play(Math.random() * 120)

    anchors {
        left: a.includes("left"); right: a.includes("right")
        top: a.includes("top");   bottom: a.includes("bottom")
    }
    margins {
        left: a.includes("left") ? m[0] - win.away : 0
        right: a.includes("right") ? m[0] - win.away : 0
        top: a.includes("top") ? m[1] : 0
        bottom: a.includes("bottom") ? m[1] : 0
    }

    implicitWidth: loader.item ? loader.item.implicitWidth : 1
    implicitHeight: loader.item ? loader.item.implicitHeight : 1
    color: "transparent"
    visible: slide > 0
    // passive widgets are click-through; interactive ones (Card.interactive) take input
    mask: Region { item: loader.item && loader.item.interactive ? loader.item : null }
    exclusionMode: ExclusionMode.Ignore
    // the drawer floats above windows; always-on widgets stay under them
    WlrLayershell.layer: drawer ? WlrLayer.Top : WlrLayer.Bottom
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
        source: (win.role === "side" ? files.sideFiles : files.mainFiles)[win.spec.id] || ""
        onLoaded: pop.play(Math.random() * 300)
    }
    GlitchIn { id: pop; target: loader }
}
