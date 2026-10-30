import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../theme"
import "../services"

// Slim bottom bar for the main monitor. Hidden completely in game mode.
PanelWindow {
    id: win

    visible: !GameMode.on
    anchors { left: true; right: true; bottom: true }
    // The window also covers the 6px gap under the pill, so the pointer at the very screen edge reaches it.
    margins { left: 6; right: 6 }
    implicitHeight: Settings.bar.main_height + 6
    color: "transparent"
    WlrLayershell.namespace: "rice-bar"

    // Auto-hide (settings.json -> bar.main_autohide): slides away, reappears when the pointer
    // touches the bottom edge, hides again shortly after it leaves. Off = always shown, reserves space.
    readonly property bool autohide: !!Settings.bar.main_autohide
    property bool revealed: false
    readonly property bool open: !autohide || revealed
    exclusionMode: autohide ? ExclusionMode.Ignore : ExclusionMode.Auto
    // click-through while hidden, except a thin strip at the screen edge that wakes the bar
    mask: Region { item: win.open ? hit : trigger }

    readonly property var mon: Hyprland.monitorFor(screen)
    readonly property int fontSize: Settings.bar.font_size

    Item { id: hit; anchors.fill: parent
        HoverHandler {
            onHoveredChanged: {
                if (hovered) { hideTimer.stop(); win.revealed = true }
                else hideTimer.restart()
            }
        }
    }
    Item { id: trigger; anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 4 }
    Timer { id: hideTimer; interval: 450; onTriggered: win.revealed = false }

    Item {
        id: body
        width: parent.width
        height: Settings.bar.main_height
        y: win.open ? 0 : height + 6
        Behavior on y { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    // floating rounded pill with a thin red edge
    Rectangle {
        anchors.fill: parent
        radius: Math.min(Settings.radius, height / 2)
        color: Theme.base
        border.width: 1
        border.color: Theme.red_dim
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
}
