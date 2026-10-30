import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../services"

// Toasts, top-right of the side monitor (falls back to main if the side monitor is away).
PanelWindow {
    id: win

    visible: Notifs.popups.length > 0
    anchors { top: true; right: true }
    margins { top: 16; right: 16 }
    implicitWidth: Settings.data.notifications.width
    implicitHeight: Math.max(1, col.implicitHeight)
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "rice-notifications"

    Column {
        id: col
        width: parent.width
        spacing: 8

        Repeater {
            model: Notifs.popups
            delegate: Rectangle {
                id: toast
                required property var modelData
                readonly property bool critical: modelData.urgency === 2
                width: col.width
                implicitHeight: content.implicitHeight + 24
                height: implicitHeight
                color: Theme.surface
                border.width: 1
                border.color: critical ? Theme.red : Theme.overlay
                radius: Settings.radius

                Rectangle { x: 6; y: 12; width: 3; height: parent.height - 24; radius: 2; color: critical ? Theme.red : Theme.red_dim }

                // slide/fade in
                opacity: 0
                x: 24
                Component.onCompleted: { opacity = 1; x = 0 }
                Behavior on opacity { NumberAnimation { duration: 110 } }
                Behavior on x { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }

                Timer {
                    interval: toast.modelData.expireTimeout > 0 ? toast.modelData.expireTimeout * 1000 : Settings.data.notifications.timeout_ms
                    running: true
                    onTriggered: Notifs.dismissPopup(toast.modelData)
                }

                ColumnLayout {
                    id: content
                    anchors { fill: parent; leftMargin: 16; rightMargin: 12; topMargin: 12; bottomMargin: 12 }
                    spacing: 4
                    Text {
                        Layout.fillWidth: true
                        text: toast.modelData.appName.toUpperCase()
                        elide: Text.ElideRight
                        color: Theme.magenta
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                    }
                    Text {
                        Layout.fillWidth: true
                        text: toast.modelData.summary
                        wrapMode: Text.Wrap
                        color: Theme.text
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; font.bold: true
                    }
                    Text {
                        Layout.fillWidth: true
                        visible: text !== ""
                        text: toast.modelData.body
                        textFormat: Text.StyledText
                        wrapMode: Text.Wrap
                        maximumLineCount: 4
                        elide: Text.ElideRight
                        color: Theme.muted
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                    }
                }

                TapHandler {
                    onTapped: { toast.modelData.dismiss(); Notifs.dismissPopup(toast.modelData) }
                }
            }
        }
    }
}
