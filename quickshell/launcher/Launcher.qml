import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../theme"
import "../services"
import "../fx"

// Search launcher, centred on the main monitor. Super+Enter -> `qs ipc call launcher toggle`.
PanelWindow {
    id: win

    visible: LauncherState.open || card.opacity > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "rice-launcher"
    WlrLayershell.keyboardFocus: LauncherState.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    implicitWidth: Settings.data.launcher.width
    // margins + search box + rows (36 tall, 8 spacing)
    implicitHeight: 64 + Settings.data.launcher.max_results * 44

    HyprlandFocusGrab {
        windows: [win]
        active: LauncherState.open
        onCleared: LauncherState.close()
    }

    property string query: ""
    property int index: 0

    // Rice binds that open an app, shown on the far right of its row (desktop entry id -> label).
    // Keep in sync with hypr/modules/binds.lua. Super+D opens Vesktop, not the Discord flatpak.
    readonly property var appBinds: ({
        "kitty": "Super+Space",
        "org.mozilla.firefox": "Super+B",
        "dev.vencord.Vesktop": "Super+D"
    })

    // "remind <when> <text>" turns the launcher into the reminder prompt (services/Reminders.qml)
    readonly property var reminder: {
        const m = query.match(/^\s*remind(?:\s+me)?\s*(.*)$/i)
        if (!m) return null
        const r = Reminders.parse(m[1])
        return {
            icon: "alarm-symbolic",
            name: r ? "󰀠  " + Reminders.clockText(r.at) + "  ·  " + r.text
                    : "󰀠  remind 18:30 raid  ·  remind 20m tea  ·  remind 1h30m stretch",
            execute: () => { if (r) Reminders.add(m[1]) }
        }
    }

    readonly property var results: {
        if (reminder) return [reminder]
        const q = query.trim().toLowerCase()
        const apps = DesktopEntries.applications.values.filter(a => !a.noDisplay)
        const scored = []
        for (const a of apps) {
            const name = a.name.toLowerCase()
            let score = -1
            if (q === "") score = 0
            else if (name.startsWith(q)) score = 3
            else if (name.includes(q)) score = 2
            else if ((a.genericName || "").toLowerCase().includes(q)
                  || (a.keywords || []).join(" ").toLowerCase().includes(q)) score = 1
            if (score >= 0) scored.push({ a, score })
        }
        scored.sort((x, y) => y.score - x.score || x.a.name.localeCompare(y.a.name))
        return scored.slice(0, Settings.data.launcher.max_results).map(s => s.a)
    }

    Connections {
        target: LauncherState
        function onOpenChanged() {
            if (LauncherState.open) { pop.play(0); win.query = ""; win.index = 0; input.text = ""; input.forceActiveFocus() }
        }
    }

    function launch(entry) {
        if (!entry) return
        LauncherState.close()
        entry.execute()
    }

    GlitchIn { id: pop; target: card; z: 1 }

    Rectangle {
        id: card
        anchors.fill: parent
        color: Theme.surface
        border.width: 1
        border.color: Theme.red
        radius: Settings.radius
        opacity: LauncherState.open ? 1 : 0
        scale: LauncherState.open ? 1 : 0.97
        Behavior on opacity { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }

        // red corner tick
        Rectangle { x: Settings.radius; width: 28; height: 3; color: Theme.red }
        Scanlines {}

        ColumnLayout {
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: Settings.radiusSmall
                color: Theme.base
                border.width: 1
                border.color: Theme.overlay
                Row {
                    anchors { fill: parent; leftMargin: 12 }
                    spacing: 10
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰍉"; color: Theme.red
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16
                    }
                    TextInput {
                        id: input
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 50
                        color: Theme.text
                        selectionColor: Theme.red; selectedTextColor: Theme.base
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15
                        clip: true
                        onTextChanged: { win.query = text; win.index = 0 }
                        Keys.onEscapePressed: LauncherState.close()
                        Keys.onReturnPressed: win.launch(win.results[win.index])
                        Keys.onEnterPressed: win.launch(win.results[win.index])
                        Keys.onDownPressed: win.index = Math.min(win.index + 1, win.results.length - 1)
                        Keys.onUpPressed: win.index = Math.max(win.index - 1, 0)
                        // Alt+1..9 launches that row (not the reminder row, it has no id)
                        Keys.onPressed: event => {
                            if ((event.modifiers & Qt.AltModifier) && event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
                                const entry = win.results[event.key - Qt.Key_1]
                                if (entry && entry.id) win.launch(entry)
                                event.accepted = true
                            }
                        }
                    }
                }
            }

            Repeater {
                model: win.results
                delegate: Rectangle {
                    id: row
                    required property var modelData
                    required property int index
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: Settings.radiusSmall
                    color: row.index === win.index ? Theme.overlay : "transparent"
                    Rectangle {
                        visible: row.index === win.index
                        x: 3; y: 8; width: 2; height: parent.height - 16; radius: 1; color: Theme.red
                    }
                    Row {
                        anchors { fill: parent; leftMargin: 12 }
                        spacing: 12
                        Image {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 22; height: 22
                            sourceSize: Qt.size(44, 44)
                            source: Quickshell.iconPath(row.modelData.icon, "application-x-executable")
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: row.modelData.name
                            color: row.index === win.index ? Theme.text : Theme.muted
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14
                        }
                    }
                    Row {
                        anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                        spacing: 16
                        Text {
                            text: win.appBinds[row.modelData.id] || ""
                            color: row.index === win.index ? Theme.red : Theme.muted
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                        }
                        Text {
                            text: row.modelData.id && row.index < 9 ? "Alt+" + (row.index + 1) : ""
                            color: row.index === win.index ? Theme.red : Theme.muted
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: win.index = row.index
                        onClicked: win.launch(row.modelData)
                    }
                }
            }
        }
    }
}
