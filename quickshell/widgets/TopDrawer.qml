import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../services"
import "../fx"

// Widget tabs that drop down from the top edge of the side monitor. Hover the top-centre strip
// (or Super+W / the bar button to pin it); hover a tab chip to switch group, click it to pin. Groups come from
// settings.json -> widgets.tabs: [{ name, ids, layout: "row" | "column" }]. In a column, an entry can be
// a list of ids that share one line, e.g. [["sysstats", "network"], "procs"].
Scope {
    id: root
    required property var screen

    readonly property var tabs: (Settings.data.widgets && Settings.data.widgets.tabs) || []
    readonly property bool want: UiState.drawerPinned || zoneHover.hovered || panelHover.hovered
    property bool open: false
    property real p: open ? 1 : 0
    Behavior on p { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }

    onWantChanged: {
        if (want) { closeTimer.stop(); open = true }
        else closeTimer.restart()
    }
    // small grace period so crossing the gap between strip and panel doesn't close it
    Timer { id: closeTimer; interval: 350; onTriggered: root.open = false }

    readonly property var files: ({
        calendar: "SideCalendar.qml", weather: "SideWeather.qml", spotify: "SpotifyWidget.qml",
        discord: "DiscordWidget.qml", sysstats: "SysStatsWidget.qml", network: "NetSpeed.qml",
        procs: "ProcsWidget.qml", mixer: "MixerWidget.qml", lyrics: "LyricsWidget.qml"
    })

    // hover strip at the top edge
    PanelWindow {
        screen: root.screen
        anchors { top: true }
        implicitWidth: 720; implicitHeight: 3
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "rice-drawer-zone"
        HoverHandler { id: zoneHover }
    }

    PanelWindow {
        id: win
        screen: root.screen
        anchors { top: true }
        implicitWidth: 1040; implicitHeight: 800
        visible: root.p > 0
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "rice-drawer"
        // only the panel takes input; the rest of the window is click-through
        mask: Region { item: panel }

        Item {
            id: panel
            readonly property var grid: stack.children[Math.min(UiState.drawerTab, stack.children.length - 1)]
            readonly property int pad: 14
            x: (win.width - width) / 2
            y: -(1 - root.p) * (height + 16)
            opacity: root.p
            width: Math.max(tabRow.width, stack.width) + pad * 2
            height: pad + tabRow.height + 12 + stack.height + pad

            HoverHandler { id: panelHover }

            // one box around tabs + widgets, hanging from the top edge (top corners/border off-screen)
            Rectangle {
                y: -radius
                width: parent.width; height: parent.height + radius
                radius: Settings.radius
                color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, Settings.panelAlpha)
                border.width: 1; border.color: Theme.red_dim
            }

            Row {
                id: tabRow
                y: panel.pad
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 6
                Repeater {
                    model: root.tabs
                    delegate: Rectangle {
                        id: chip
                        required property var modelData
                        required property int index
                        readonly property bool active: UiState.drawerTab === index
                        width: label.implicitWidth + 28; height: 26
                        radius: Settings.radiusSmall
                        color: active ? Theme.red : Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, Settings.panelAlpha)
                        border.width: 1; border.color: active ? Theme.red : Theme.red_dim
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text {
                            id: label
                            anchors.centerIn: parent
                            // pin glyph on the active tab while the drawer is pinned
                            text: chip.modelData.name.toUpperCase() + (chip.active && UiState.drawerPinned ? "  󰐃" : "")
                            color: chip.active ? Theme.base : Theme.text
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; font.letterSpacing: 2
                        }
                        HoverHandler { onHoveredChanged: if (hovered) UiState.drawerTab = chip.index }
                        // click pins the drawer on this tab; clicking the pinned tab again unpins
                        TapHandler {
                            onTapped: {
                                if (UiState.drawerPinned && chip.active) UiState.drawerPinned = false
                                else { UiState.drawerTab = chip.index; UiState.drawerPinned = true }
                            }
                        }
                    }
                }
            }

            // one grid per group; only the active one is visible, the stack sizes to it
            Item {
                id: stack
                y: panel.pad + tabRow.height + 12
                anchors.horizontalCenter: parent.horizontalCenter
                width: panel.grid ? panel.grid.implicitWidth : 0
                height: panel.grid ? panel.grid.implicitHeight : 0
                Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                Repeater {
                    model: root.tabs
                    delegate: Column {
                        id: grp
                        required property var modelData
                        required property int index
                        // each line is a list of ids laid side by side
                        readonly property var lines: modelData.layout === "column"
                            ? modelData.ids.map(i => [].concat(i)) : [modelData.ids]
                        spacing: 12
                        visible: opacity > 0
                        opacity: UiState.drawerTab === index ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 160 } }
                        Repeater {
                            model: grp.lines
                            delegate: Row {
                                id: line
                                required property var modelData
                                spacing: 12
                                Repeater {
                                    model: line.modelData
                                    delegate: Loader {
                                        required property string modelData
                                        active: win.visible && grp.visible
                                        source: root.files[modelData] || ""
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
