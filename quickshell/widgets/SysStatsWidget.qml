import QtQuick
import "../theme"
import "../services"

// CPU / GPU usage + temps, RAM, VRAM, disk as upward bars; uptime underneath.
Card {
    id: root
    title: "system"

    // one upward bar: percent on top, detail (temp / GB) under it, label at the foot
    component Meter: Column {
        property string label: ""
        property real value: 0          // 0..100
        property string detail: ""
        property color tint: Theme.red
        width: 40; spacing: 4

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(parent.value) + "%"
            color: Theme.text
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: parent.detail
            color: Theme.muted
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
        }
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 16; height: 172
            radius: 4
            clip: true
            color: Theme.overlay
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: parent.height * Math.max(0, Math.min(100, value)) / 100
                color: value > 90 ? Theme.warning : tint
                Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: parent.label
            color: Theme.muted
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; font.letterSpacing: 1
        }
    }

    Column {
        spacing: 12
        Row {
            spacing: 15
            Meter { label: "CPU"; value: SysStats.cpu; detail: Math.round(SysStats.cpuTemp) + "°C" }
            Meter { label: "GPU"; value: SysStats.gpu; detail: Math.round(SysStats.gpuTemp) + "°C" }
            Meter { label: "RAM"; value: SysStats.ram; tint: Theme.red_dim; detail: SysStats.ramUsedGb.toFixed(1) + "G" }
            Meter { label: "VRAM"; value: SysStats.vram; tint: Theme.red_dim; detail: SysStats.vramUsedGb.toFixed(1) + "G" }
            Meter { label: "DISK"; value: SysStats.disk; tint: Theme.red_dim; detail: Math.round(SysStats.diskUsedGb) + "G" }
        }
        Item {
            width: 260; height: 18
            Text {
                text: "UPTIME"
                color: Theme.muted
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; font.letterSpacing: 2
            }
            Text {
                anchors.right: parent.right
                text: SysStats.fmtUptime(SysStats.uptime)
                color: Theme.text
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
            }
        }
    }
}
