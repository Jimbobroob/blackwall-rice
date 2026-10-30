import QtQuick
import Quickshell.Io
import "../theme"
import "../services"

Text {
    id: root
    property string kind: ""
    property string name: ""

    text: kind === "ethernet" ? "󰈀 " + name : kind === "wifi" ? "󰖩 " + name : "󰖪 offline"
    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: Settings.bar.font_size
    color: kind === "" ? Theme.red : Theme.text

    Process {
        id: poll
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                let kind = "", name = ""
                for (const line of text.split("\n")) {
                    const f = line.split(":")
                    if (f[1] === "connected" && (f[0] === "ethernet" || f[0] === "wifi")) {
                        kind = f[0]; name = f.slice(2).join(":")
                        if (kind === "ethernet") break
                    }
                }
                root.kind = kind; root.name = name
            }
        }
    }
    Timer { interval: 5000; running: true; repeat: true; triggeredOnStart: true; onTriggered: poll.running = true }
}
