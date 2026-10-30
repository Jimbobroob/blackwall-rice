import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../theme"
import "../services"

// Notification history, opened from the bell. Esc / click outside closes.
PanelWindow {
    id: win

    visible: UiState.historyOpen || card.opacity > 0
    anchors { left: true; bottom: true }
    margins { left: 52; bottom: 8 }
    implicitWidth: 380
    implicitHeight: 520
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "rice-history"
    WlrLayershell.keyboardFocus: UiState.historyOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    HyprlandFocusGrab {
        windows: [win]
        active: UiState.historyOpen
        onCleared: UiState.historyOpen = false
    }

    function ago(t) {
        const s = Math.floor((Date.now() - t) / 1000)
        if (s < 60) return "now"
        if (s < 3600) return Math.floor(s / 60) + "m"
        if (s < 86400) return Math.floor(s / 3600) + "h"
        return Math.floor(s / 86400) + "d"
    }

    // re-evaluate the "ago" labels while open
    property int tick: 0
    Timer { interval: 30000; running: UiState.historyOpen; repeat: true; onTriggered: win.tick++ }

    Rectangle {
        id: card
        anchors.fill: parent
        color: Theme.surface
        border.width: 1
        border.color: Theme.red_dim
        opacity: UiState.historyOpen ? 1 : 0
        x: UiState.historyOpen ? 0 : -16
        Behavior on opacity { NumberAnimation { duration: 100 } }
        Behavior on x { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

        focus: true
        Keys.onEscapePressed: UiState.historyOpen = false

        // header
        Item {
            id: head
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: 44
            Text {
                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                text: "NOTIFICATIONS"
                color: Theme.magenta
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.letterSpacing: 2
            }
            Rectangle {
                anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                width: clearText.implicitWidth + 20; height: 24
                color: clearHover.hovered ? Theme.red : "transparent"
                border.width: 1; border.color: Theme.red_dim
                Text {
                    id: clearText
                    anchors.centerIn: parent
                    text: "CLEAR"
                    color: clearHover.hovered ? Theme.base : Theme.text
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; font.letterSpacing: 1
                }
                HoverHandler { id: clearHover }
                TapHandler { onTapped: Notifs.clearHistory() }
            }
            Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
 height: 1; color: Theme.overlay }
        }

        Text {
            anchors.centerIn: parent
            visible: Notifs.history.length === 0
            text: "NOTHING HERE"
            color: Theme.muted
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.letterSpacing: 2
        }

        ListView {
            anchors { left: parent.left; right: parent.right; top: head.bottom; bottom: parent.bottom; margins: 1 }
            clip: true
            model: Notifs.history
            boundsBehavior: Flickable.StopAtBounds
            delegate: Item {
                id: item
                required property var modelData
                width: ListView.view.width
                height: body.implicitHeight + 20
                readonly property bool critical: modelData.urgency === 2

                Rectangle { width: 3; height: parent.height - 8; y: 4; color: item.critical ? Theme.red : Theme.red_dim }
                ColumnLayout {
                    id: body
                    anchors { fill: parent; leftMargin: 16; rightMargin: 12; topMargin: 10; bottomMargin: 10 }
                    spacing: 2
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true
                            text: item.modelData.appName.toUpperCase()
                            elide: Text.ElideRight
                            color: Theme.magenta
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                        }
                        Text {
                            text: { win.tick; return win.ago(item.modelData.time) }
                            color: Theme.muted
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: item.modelData.summary
                        wrapMode: Text.Wrap
                        color: Theme.text
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.bold: true
                    }
                    Text {
                        Layout.fillWidth: true
                        visible: text !== ""
                        text: item.modelData.body
                        textFormat: Text.StyledText
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        color: Theme.muted
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                    }
                }
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
 height: 1; color: Theme.overlay }
            }
        }
    }
}
