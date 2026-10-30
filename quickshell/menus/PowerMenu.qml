import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "../theme"
import "../services"

// Compact power menu on the side monitor, next to the bar's power button.
// Up/Down + Enter, or click. Esc / click outside closes.
PanelWindow {
    id: win

    visible: UiState.powerOpen || card.opacity > 0
    anchors { left: true; bottom: true }
    margins { left: 58; bottom: 6 }
    implicitWidth: 220
    implicitHeight: col.implicitHeight + 10
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "rice-powermenu"
    WlrLayershell.keyboardFocus: UiState.powerOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    HyprlandFocusGrab {
        windows: [win]
        active: UiState.powerOpen
        onCleared: UiState.powerOpen = false
    }

    readonly property var actions: [
        { icon: "󰌾", name: "Lock",      cmd: ["hyprlock"] },
        { icon: "󰍃", name: "Log out",   cmd: ["hyprctl", "dispatch", "exit"] },
        { icon: "󰤄", name: "Suspend",   cmd: ["systemctl", "suspend"] },
        { icon: "󰜉", name: "Reboot",    cmd: ["systemctl", "reboot"] },
        { icon: "󰐥", name: "Shut down", cmd: ["systemctl", "poweroff"] }
    ]
    property int index: 0
    onVisibleChanged: if (visible) index = 0

    Process { id: runner }
    function activate(i) {
        UiState.powerOpen = false
        runner.exec(actions[i].cmd)
    }

    Rectangle {
        id: card
        anchors.fill: parent
        color: Theme.surface
        border.width: 1
        border.color: Theme.red_dim
        radius: Settings.radius
        opacity: UiState.powerOpen ? 1 : 0
        x: UiState.powerOpen ? 0 : -16
        Behavior on opacity { NumberAnimation { duration: 100 } }
        Behavior on x { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

        focus: true
        Keys.onPressed: e => {
            if (e.key === Qt.Key_Escape) UiState.powerOpen = false
            else if (e.key === Qt.Key_Down) win.index = (win.index + 1) % win.actions.length
            else if (e.key === Qt.Key_Up) win.index = (win.index + win.actions.length - 1) % win.actions.length
            else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) win.activate(win.index)
            else return
            e.accepted = true
        }

        Column {
            id: col
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 5 }
            Repeater {
                model: win.actions
                delegate: Rectangle {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool sel: win.index === index
                    readonly property bool danger: modelData.name === "Shut down" || modelData.name === "Reboot"
                    width: col.width; height: 40
                    radius: Settings.radiusSmall
                    color: sel ? Theme.red : "transparent"
                    Behavior on color { ColorAnimation { duration: 60 } }
                    Row {
                        anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                        spacing: 14
                        Text {
                            text: row.modelData.icon
                            color: row.sel ? Theme.base : (row.danger ? Theme.red : Theme.text)
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18
                        }
                        Text {
                            text: row.modelData.name.toUpperCase()
                            color: row.sel ? Theme.base : Theme.text
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; font.letterSpacing: 1.5
                        }
                    }
                    HoverHandler { onHoveredChanged: if (hovered) win.index = row.index }
                    TapHandler { onTapped: win.activate(row.index) }
                }
            }
        }
    }
}
