import QtQuick
import "../theme"
import "../services"

// CPU / GPU usage + temps, RAM, VRAM, disk, uptime.
Card {
    id: root
    title: "system"

    component Meter: Item {
        property string label: ""
        property real value: 0          // 0..100
        property string readout: ""       // text on the right (temps etc.)
        property color tint: Theme.red
        width: 260; height: 44

        Text {
            text: parent.label
            color: Theme.muted
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; font.letterSpacing: 2
        }
        Text {
            anchors.right: parent.right
            text: parent.readout
            color: Theme.text
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
        }
        Rectangle {
            y: 20; width: parent.width; height: 8
            radius: 4
            clip: true
            color: Theme.overlay
            Rectangle {
                width: parent.width * Math.max(0, Math.min(100, value)) / 100
                height: parent.height
                color: value > 90 ? Theme.warning : tint
                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            }
        }
    }

    Column {
        spacing: 6
        Meter {
            label: "CPU"; value: SysStats.cpu
            readout: Math.round(SysStats.cpu) + "%  ·  " + Math.round(SysStats.cpuTemp) + "°C"
        }
        Meter {
            label: "GPU"; value: SysStats.gpu
            readout: Math.round(SysStats.gpu) + "%  ·  " + Math.round(SysStats.gpuTemp) + "°C"
        }
        Meter {
            label: "RAM"; value: SysStats.ram; tint: Theme.red_dim
            readout: SysStats.ramUsedGb.toFixed(1) + " / " + SysStats.ramTotalGb.toFixed(0) + " GB"
        }
        Meter {
            label: "VRAM"; value: SysStats.vram; tint: Theme.red_dim
            readout: SysStats.vramUsedGb.toFixed(1) + " / " + SysStats.vramTotalGb.toFixed(0) + " GB"
        }
        Meter {
            label: "DISK"; value: SysStats.disk; tint: Theme.red_dim
            readout: Math.round(SysStats.diskUsedGb) + " / " + Math.round(SysStats.diskTotalGb) + " GB"
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
