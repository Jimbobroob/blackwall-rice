import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../theme"
import "../services"
import "../fx"

// Alt+Tab window switcher, centred on the main monitor. Every open window on both monitors
// (Spotify / Discord included) as a live preview tile, most recently used first.
// Hold Alt and tap Tab to step, let go of Alt to switch. Arrows / mouse also move, Enter or
// click picks, Esc cancels. State and IPC live in services/SwitcherState.qml.
PanelWindow {
    id: win

    readonly property int tileW: 248
    readonly property int tileH: 176
    readonly property int gap: 10
    readonly property int pad: 14
    readonly property int maxCols: 5
    readonly property int maxRows: 3
    readonly property int count: SwitcherState.items.length
    readonly property int cols: Math.max(1, Math.min(count, maxCols))
    readonly property int rows: Math.max(1, Math.min(Math.ceil(count / maxCols), maxRows))

    visible: SwitcherState.open || card.opacity > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "rice-switcher"
    WlrLayershell.keyboardFocus: SwitcherState.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    implicitWidth: cols * (tileW + gap) - gap + pad * 2
    implicitHeight: 34 + rows * (tileH + gap) - gap + pad * 2

    HyprlandFocusGrab {
        windows: [win]
        active: SwitcherState.open
        onCleared: SwitcherState.cancel()
    }

    Connections {
        target: SwitcherState
        function onOpenChanged() {
            if (SwitcherState.open) { pop.play(0); keys.forceActiveFocus() }
        }
    }

    GlitchIn { id: pop; target: card; z: 1 }

    Rectangle {
        id: card
        anchors.fill: parent
        color: Theme.surface
        border.width: 1
        border.color: Theme.red
        radius: Settings.radius
        opacity: SwitcherState.open ? 1 : 0
        scale: SwitcherState.open ? 1 : 0.97
        Behavior on opacity { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }

        // red corner tick
        Rectangle { x: Settings.radius; width: 28; height: 3; color: Theme.red }
        Scanlines {}

        Item {
            id: keys
            focus: true
            Keys.onEscapePressed: SwitcherState.cancel()
            Keys.onReturnPressed: SwitcherState.pick(SwitcherState.index)
            Keys.onEnterPressed: SwitcherState.pick(SwitcherState.index)
            Keys.onRightPressed: SwitcherState.step(1)
            Keys.onLeftPressed: SwitcherState.step(-1)
            Keys.onDownPressed: SwitcherState.index = Math.min(SwitcherState.index + win.maxCols, win.count - 1)
            Keys.onUpPressed: SwitcherState.index = Math.max(SwitcherState.index - win.maxCols, 0)
        }

        // header: "// WINDOWS 05" + picked window's title
        RowLayout {
            id: header
            anchors { left: parent.left; right: parent.right; top: parent.top; leftMargin: win.pad; rightMargin: win.pad; topMargin: 10 }
            height: 22
            spacing: 10
            Text {
                text: "// WINDOWS"
                color: Theme.red
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.bold: true
                font.letterSpacing: 1.5
            }
            Text {
                text: String(win.count).padStart(2, "0")
                color: Theme.muted
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
            }
            Item { Layout.fillWidth: true }
            Text {
                Layout.maximumWidth: win.width * 0.6
                elide: Text.ElideRight
                text: { const it = SwitcherState.items[SwitcherState.index]; return it ? it.cls.toLowerCase() : "" }
                color: Theme.magenta
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
            }
        }

        GridView {
            id: grid
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom; top: header.bottom
                      leftMargin: win.pad; rightMargin: win.pad - win.gap; bottomMargin: win.pad - win.gap; topMargin: 12 }
            cellWidth: win.tileW + win.gap
            cellHeight: win.tileH + win.gap
            clip: true
            interactive: false
            model: SwitcherState.items
            currentIndex: SwitcherState.index
            highlightFollowsCurrentItem: false
            onCurrentIndexChanged: positionViewAtIndex(currentIndex, GridView.Contain)

            delegate: Rectangle {
                id: tile
                required property var modelData
                required property int index
                readonly property bool picked: tile.index === SwitcherState.index
                readonly property var entry: DesktopEntries.heuristicLookup(modelData.cls)

                width: win.tileW
                height: win.tileH
                radius: Settings.radiusSmall
                color: picked ? Theme.overlay : Theme.base
                border.width: 1
                border.color: picked ? Theme.red : Theme.overlay
                Behavior on border.color { ColorAnimation { duration: 80 } }

                // live preview (falls back to the app icon while hidden / no frame yet)
                Item {
                    id: preview
                    anchors { left: parent.left; right: parent.right; top: parent.top; bottom: label.top; margins: 6 }
                    clip: true

                    ScreencopyView {
                        id: shot
                        anchors.centerIn: parent
                        width: implicitWidth; height: implicitHeight
                        constraintSize: Qt.size(preview.width, preview.height)
                        captureSource: SwitcherState.open && tile.modelData.toplevel ? tile.modelData.toplevel.wayland : null
                        live: SwitcherState.open
                        opacity: tile.picked ? 1 : 0.7
                    }
                    Image {
                        visible: !shot.hasContent
                        anchors.centerIn: parent
                        width: 56; height: 56
                        sourceSize: Qt.size(112, 112)
                        source: Quickshell.iconPath(tile.entry ? tile.entry.icon : tile.modelData.cls.toLowerCase(), "application-x-executable")
                        opacity: tile.picked ? 1 : 0.6
                    }
                }

                RowLayout {
                    id: label
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: 8; rightMargin: 8; bottomMargin: 6 }
                    height: 22
                    spacing: 6
                    Image {
                        Layout.preferredWidth: 16; Layout.preferredHeight: 16
                        sourceSize: Qt.size(32, 32)
                        source: Quickshell.iconPath(tile.entry ? tile.entry.icon : tile.modelData.cls.toLowerCase(), "application-x-executable")
                    }
                    Text {
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        text: tile.modelData.title
                        color: tile.picked ? Theme.text : Theme.muted
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                    }
                    Text {
                        text: tile.modelData.wsName
                        color: tile.modelData.special ? Theme.magenta : (tile.picked ? Theme.red : Theme.muted)
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; font.bold: true
                    }
                }

                // selected: red marker on the left edge, like the launcher rows
                Rectangle {
                    visible: tile.picked
                    x: 3; y: 10; width: 2; height: parent.height - 20; radius: 1; color: Theme.red
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: SwitcherState.index = tile.index
                    onClicked: SwitcherState.pick(tile.index)
                }
            }
        }
    }
}
