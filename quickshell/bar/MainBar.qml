import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../theme"
import "../services"
import "../widgets"

// Slim bottom bar for the main monitor. Hidden completely in game mode.
PanelWindow {
    id: win

    visible: !GameMode.on
    anchors { left: true; right: true; bottom: true }
    margins { left: 6; right: 6; bottom: 6 }
    implicitHeight: Settings.bar.main_height
    color: "transparent"
    WlrLayershell.namespace: "rice-bar"

    readonly property var mon: Hyprland.monitorFor(screen)
    readonly property int fontSize: Settings.bar.font_size

    // floating rounded pill with a thin red edge
    GlassPanel {
        anchors.fill: parent
        radius: Math.min(Settings.radius, height / 2)
    }

    // left: workspaces
    Row {
        anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
        spacing: 4
        Repeater {
            model: Settings.monitors.main.workspaces
            delegate: Rectangle {
                id: ws
                required property int modelData
                readonly property var hw: Hyprland.workspaces.values.find(w => w.id === modelData)
                readonly property bool active: win.mon && win.mon.activeWorkspace && win.mon.activeWorkspace.id === modelData
                readonly property bool occupied: !!(hw && hw.toplevels && hw.toplevels.values.length > 0)
                width: 24; height: 18
                radius: Settings.radiusSmall / 2 + 1
                color: active ? Theme.red : (hover.hovered ? Theme.overlay : "transparent")
                border.width: active ? 0 : 1
                border.color: occupied ? Theme.red_dim : Theme.overlay
                Behavior on color { ColorAnimation { duration: 80 } }
                Text {
                    anchors.centerIn: parent
                    text: ws.modelData
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: win.fontSize
                    font.bold: ws.active
                    color: ws.active ? Theme.base : (ws.occupied ? Theme.text : Theme.muted)
                }
                HoverHandler { id: hover }
                TapHandler { onTapped: Hypr.gotoWorkspace(ws.modelData) }
            }
        }
    }

    // centre: focused window title
    Text {
        anchors.centerIn: parent
        width: Math.min(implicitWidth, parent.width * 0.4)
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        text: {
            const w = win.mon && win.mon.activeWorkspace ? win.mon.activeWorkspace : null
            const t = w && w.lastIpcObject ? (w.lastIpcObject.lastwindowtitle || "") : ""
            return t
        }
        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: win.fontSize
        color: Theme.muted
    }

    // right: now-playing | volume | network | clock
    Row {
        anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
        spacing: 16
        NowPlaying {}
        Volume {}
        Network {}
        Clock {}
    }
}
