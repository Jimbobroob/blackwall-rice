import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Io
import "../theme"
import "../services"
import "../widgets"

// Vertical bar on the left edge of the side monitor.
// launcher | ws 6-10 | space | GPU temp | updates | tray | mic | volume | network | bell | power
PanelWindow {
    id: win

    anchors { left: true; top: true; bottom: true }
    margins { left: 6; top: 6; bottom: 6 }
    implicitWidth: 44
    color: "transparent"
    WlrLayershell.namespace: "rice-sidebar"

    readonly property var mon: Hyprland.monitorFor(screen)
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    PwObjectTracker { objects: [win.sink, win.source] }

    // floating rounded strip with a thin red edge
    GlassPanel {
        anchors.fill: parent
        radius: Settings.radius
    }

    // top: launcher + workspaces
    Column {
        anchors { top: parent.top; topMargin: 6; left: parent.left; right: parent.right; rightMargin: 1 }
        spacing: 4

        BarButton {
            width: parent.width
            icon: "󰀻"
            iconColor: Theme.red
            onClicked: LauncherState.toggle()
        }

        Rectangle { width: parent.width - 16; height: 1; x: 8; color: Theme.overlay }

        Repeater {
            model: Settings.monitors.side.workspaces
            delegate: Rectangle {
                id: ws
                required property int modelData
                readonly property var hw: Hyprland.workspaces.values.find(w => w.id === modelData)
                readonly property bool active: win.mon && win.mon.activeWorkspace && win.mon.activeWorkspace.id === modelData
                readonly property bool occupied: !!(hw && hw.toplevels && hw.toplevels.values.length > 0)
                x: 9
                width: 24; height: 24
                radius: Settings.radiusSmall
                color: active ? Theme.red : (wsHover.hovered ? Theme.overlay : "transparent")
                border.width: active ? 0 : 1
                border.color: occupied ? Theme.red_dim : Theme.overlay
                Behavior on color { ColorAnimation { duration: 80 } }
                Text {
                    anchors.centerIn: parent
                    text: ws.modelData
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: Settings.bar.font_size
                    font.bold: ws.active
                    color: ws.active ? Theme.base : (ws.occupied ? Theme.text : Theme.muted)
                }
                HoverHandler { id: wsHover }
                TapHandler { onTapped: Hypr.gotoWorkspace(ws.modelData) }
            }
        }
    }

    // bottom: status + system buttons
    Column {
        anchors { bottom: parent.bottom; bottomMargin: 6; left: parent.left; right: parent.right; rightMargin: 1 }
        spacing: 2

        // GPU temp
        BarButton {
            width: parent.width
            icon: "󰢮"
            label: Math.round(SysStats.gpuTemp) + "°"
            iconColor: SysStats.gpuTemp >= 80 ? Theme.warning : Theme.text
            labelColor: SysStats.gpuTemp >= 80 ? Theme.warning : Theme.muted
        }

        // dnf updates
        BarButton {
            width: parent.width
            icon: "󰚰"
            label: Updates.checking && Updates.count === 0 ? "…" : String(Updates.count)
            iconColor: Updates.count > 0 ? Theme.magenta : Theme.muted
            labelColor: Updates.count > 0 ? Theme.magenta : Theme.muted
            onClicked: Updates.runUpdate()
        }

        Rectangle { width: parent.width - 16; height: 1; x: 8; color: Theme.overlay }

        // system tray
        Repeater {
            model: SystemTray.items
            delegate: Item {
                id: trayItem
                required property var modelData
                width: parent.width; height: 32
                Rectangle { anchors.fill: parent; radius: Settings.radiusSmall; color: trayHover.hovered ? Theme.overlay : "transparent" }
                Image {
                    anchors.centerIn: parent
                    width: 18; height: 18
                    sourceSize: Qt.size(36, 36)
                    // Vesktop's tray icon is its own logo; show Discord's real one instead
                    readonly property bool isDiscord: /vesktop|discord|vencord/i.test((trayItem.modelData.id || "") + (trayItem.modelData.title || ""))
                    source: isDiscord ? Quickshell.iconPath("discord", trayItem.modelData.icon) : trayItem.modelData.icon
                }
                HoverHandler { id: trayHover }
                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onTapped: trayItem.modelData.hasMenu && trayItem.modelData.onlyMenu ? menu.open() : trayItem.modelData.activate()
                }
                TapHandler {
                    acceptedButtons: Qt.RightButton
                    onTapped: if (trayItem.modelData.hasMenu) menu.open()
                }
                QsMenuAnchor {
                    id: menu
                    menu: trayItem.modelData.menu
                    anchor.window: win
                    anchor.rect.x: win.width
                    anchor.rect.y: trayItem.mapToItem(null, 0, 0).y
                    anchor.rect.width: 1
                    anchor.rect.height: trayItem.height
                }
            }
        }

        // mic mute (red when muted)
        BarButton {
            width: parent.width
            readonly property bool muted: win.source && win.source.audio ? win.source.audio.muted : false
            icon: muted ? "󰍭" : "󰍬"
            lit: muted
            onClicked: if (win.source && win.source.audio) win.source.audio.muted = !win.source.audio.muted
        }

        // volume
        BarButton {
            id: vol
            width: parent.width
            readonly property var audio: win.sink ? win.sink.audio : null
            readonly property int pct: audio ? Math.round(audio.volume * 100) : 0
            readonly property bool muted: audio ? audio.muted : false
            icon: muted ? "󰝟" : (pct > 60 ? "󰕾" : pct > 20 ? "󰖀" : "󰕿")
            label: pct + "%"
            iconColor: muted ? Theme.red : Theme.text
            onClicked: if (audio) audio.muted = !audio.muted
            onScrolled: dir => { if (audio) audio.volume = Math.max(0, Math.min(1, audio.volume + dir * 0.05)) }
        }

        // network
        BarButton {
            id: net
            width: parent.width
            property string kind: ""
            icon: kind === "ethernet" ? "󰈀" : kind === "wifi" ? "󰖩" : "󰖪"
            iconColor: kind === "" ? Theme.red : Theme.text

            Process {
                id: poll
                command: ["nmcli", "-t", "-f", "TYPE,STATE", "device", "status"]
                stdout: StdioCollector {
                    onStreamFinished: {
                        let kind = ""
                        for (const line of text.split("\n")) {
                            const f = line.split(":")
                            if (f[1] === "connected" && (f[0] === "ethernet" || f[0] === "wifi")) {
                                kind = f[0]
                                if (kind === "ethernet") break
                            }
                        }
                        net.kind = kind
                    }
                }
            }
            Timer { interval: 5000; running: true; repeat: true; triggeredOnStart: true; onTriggered: poll.running = true }
        }

        // notification bell: history panel
        BarButton {
            width: parent.width
            icon: Notifs.history.length > 0 ? "󰂚" : "󰂜"
            label: Notifs.history.length > 0 ? String(Notifs.history.length) : ""
            iconColor: Notifs.history.length > 0 ? Theme.magenta : Theme.text
            labelColor: Theme.magenta
            lit: UiState.historyOpen
            onClicked: UiState.toggleHistory()
        }

        // power menu
        BarButton {
            width: parent.width
            icon: "󰐥"
            iconColor: Theme.red
            lit: UiState.powerOpen
            onClicked: UiState.togglePower()
        }
    }
}
