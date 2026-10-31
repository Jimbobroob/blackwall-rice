pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// "Remind me" list. Add from the launcher ("remind 18:30 raid", "remind 20m tea", "remind in 1h30m
// stretch") or `qs ipc call reminders add "20m tea"`. Saved to ~/.local/state/rice/reminders.json so
// they survive reloads and reboots; one that came due while the shell was off fires on start.
Singleton {
    id: root
    property var items: []        // [{ at (ms), text }], soonest first
    property real now: Date.now()

    // "18:30 raid" | "20m tea" | "1h30m x" | "in 2h x" | "at 9:05 x" -> { at, text } or null
    function parse(spec) {
        let s = (spec || "").trim().replace(/^(in|at)\s+/i, "")
        const clock = s.match(/^(\d{1,2})[:.](\d{2})\s*(.*)$/)
        const rel = s.match(/^(?:(\d+)\s*h)?\s*(?:(\d+)\s*m(?:ins?)?)?(?:\s+(.*))?$/i)
        let at = 0, text = ""
        if (clock) {
            if (Number(clock[1]) > 23 || Number(clock[2]) > 59) return null
            const d = new Date()
            d.setHours(Number(clock[1]), Number(clock[2]), 0, 0)
            if (d.getTime() <= Date.now()) d.setDate(d.getDate() + 1)       // already gone today -> tomorrow
            at = d.getTime(); text = clock[3]
        } else if (rel && (rel[1] || rel[2])) {
            at = Date.now() + ((Number(rel[1]) || 0) * 60 + (Number(rel[2]) || 0)) * 60000
            text = rel[3] || ""
        } else return null
        return { at, text: text.trim() || "reminder" }
    }

    function add(spec) {
        const r = parse(spec)
        if (!r) return false
        items = [...items, r].sort((a, b) => a.at - b.at)
        save()
        return true
    }
    function remove(i) { items = items.filter((_, j) => j !== i); save() }

    // "in 1h 5m" / "in 40s"
    function untilText(at) {
        const s = Math.max(0, Math.round((at - now) / 1000))
        if (s < 60) return "in " + s + "s"
        const h = Math.floor(s / 3600), m = Math.ceil(s % 3600 / 60)
        return "in " + (h ? h + "h " : "") + (m ? m + "m" : "")
    }
    function clockText(at) {
        const d = new Date(at)
        const t = String(d.getHours()).padStart(2, "0") + ":" + String(d.getMinutes()).padStart(2, "0")
        return d.toDateString() === new Date().toDateString() ? t : "tmrw " + t
    }

    function fireDue() {
        now = Date.now()
        const due = items.filter(r => r.at <= now)
        if (!due.length) return
        for (const r of due) {
            const late = now - r.at > 5 * 60000 ? "  (missed at " + clockText(r.at) + ")" : ""
            Quickshell.execDetached(["notify-send", "-a", "Reminder", "-u", "critical", "󰀠  " + r.text, "Reminder" + late])
        }
        Quickshell.execDetached(["pw-play", "/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"])
        items = items.filter(r => r.at > now)
        save()
    }

    Timer { interval: 1000; repeat: true; running: root.items.length > 0; onTriggered: root.fireDue() }

    function save() { file.setText(JSON.stringify(items)) }
    FileView {
        id: file
        path: Quickshell.env("HOME") + "/.local/state/rice/reminders.json"
        printErrors: false
        onLoaded: {
            try { root.items = JSON.parse(text()).filter(r => r && r.at && r.text) } catch (e) { root.items = [] }
            root.fireDue()
        }
    }

    IpcHandler {
        target: "reminders"
        function add(spec: string): bool { return root.add(spec) }
        function list(): string { return root.items.map(r => root.clockText(r.at) + "  " + r.text).join("\n") }
        function clear(): void { root.items = []; root.save() }
    }
}
