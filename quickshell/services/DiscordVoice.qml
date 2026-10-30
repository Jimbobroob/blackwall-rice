pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Voice state from the RiceVoice Vencord plugin (inside Vesktop), over
// $XDG_RUNTIME_DIR/rice/discord.sock. Reconnects every 3 s while the socket is missing.
Singleton {
    id: root

    property bool online: sock.connected      // plugin reachable (Vesktop running + plugin on)
    property bool connected: false            // user is in a voice channel
    property string channel: ""
    property bool mute: false
    property bool deaf: false
    property var members: []

    function toggleMute()   { sock.write(JSON.stringify({ cmd: "mute" }) + "\n");   sock.flush() }
    function toggleDeafen() { sock.write(JSON.stringify({ cmd: "deafen" }) + "\n"); sock.flush() }

    Socket {
        id: sock
        path: Quickshell.env("XDG_RUNTIME_DIR") + "/rice/discord.sock"
        connected: true
        parser: SplitParser {
            onRead: line => {
                try {
                    const s = JSON.parse(line)
                    root.connected = !!s.connected
                    root.channel = s.channel || ""
                    root.mute = !!s.mute
                    root.deaf = !!s.deaf
                    root.members = s.members || []
                } catch (e) {}
            }
        }
        onConnectedChanged: if (!connected) {
            root.connected = false
            root.members = []
        }
    }
    // a failed connect never flips `connected`, so retry on a plain timer
    Timer {
        interval: 3000; repeat: true; running: !sock.connected
        onTriggered: { sock.connected = false; sock.connected = true }
    }
}
