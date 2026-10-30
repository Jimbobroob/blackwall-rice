import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../services"

// One passive desktop widget. Anchor and margin come from settings.json:
//   { "id": "clock", "anchor": "top-right", "margin": [horizontal, vertical] }
PanelWindow {
    id: win
    required property var spec
    property string role: "main"

    readonly property string a: spec.anchor || "top-left"
    readonly property var m: spec.margin || [48, 48]

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
    mask: Region {}
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "rice-widget-" + spec.id

    // widget id -> file, per monitor role
    QtObject {
        id: files
        readonly property var mainFiles: ({ clock: "MainClock.qml", weather: "MainWeather.qml" })
        readonly property var sideFiles: ({
            clock: "SideClock.qml", calendar: "SideCalendar.qml", weather: "SideWeather.qml",
            sysstats: "SysStatsWidget.qml", network: "NetSpeed.qml", cava: "CavaWidget.qml"
        })
    }

    Loader {
        id: loader
        source: (win.role === "side" ? files.sideFiles : files.mainFiles)[win.spec.id] || ""
    }
}
