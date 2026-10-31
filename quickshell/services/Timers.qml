pragma Singleton
import QtQuick
import Quickshell

// Countdown timer + stopwatch. Lives here (not in the widget) so they keep going while the drawer
// is closed. The timer ends with a notification and the freedesktop alarm sound.
Singleton {
    id: root
    property real now: Date.now()

    // timer: set = chosen length (s); while running it counts to endsAt, while paused left holds the rest
    property int set: 300
    property bool timerRunning: false
    property real endsAt: 0
    property real left: 300
    readonly property real timerLeft: timerRunning ? Math.max(0, (endsAt - now) / 1000) : left

    // stopwatch: acc = time banked before the current run (s)
    property bool swRunning: false
    property real swStart: 0
    property real acc: 0
    readonly property real swTime: acc + (swRunning ? (now - swStart) / 1000 : 0)

    Timer {
        interval: 100; repeat: true
        running: root.timerRunning || root.swRunning
        onTriggered: {
            root.now = Date.now()
            if (root.timerRunning && root.now >= root.endsAt) root.finish()
        }
    }

    function startTimer() {
        if (timerRunning) return
        if (left <= 0) left = set
        now = Date.now(); endsAt = now + left * 1000; timerRunning = true
    }
    function pauseTimer() { if (!timerRunning) return; left = timerLeft; timerRunning = false }
    function toggleTimer() { timerRunning ? pauseTimer() : startTimer() }
    function resetTimer() { timerRunning = false; left = set }
    // preset: set the length and start straight away
    function preset(min) { timerRunning = false; set = min * 60; left = set; startTimer() }
    // nudge the length (or the time left while running) by whole minutes
    function nudge(min) {
        if (timerRunning) { endsAt = Math.max(Date.now() + 1000, endsAt + min * 60000) }
        else { set = Math.max(60, set + min * 60); left = set }
    }
    function finish() {
        timerRunning = false; left = 0
        Quickshell.execDetached(["notify-send", "-a", "Timer", "-u", "critical", "󰔛  Timer done", fmt(set) + " is up"])
        Quickshell.execDetached(["pw-play", "/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"])
    }

    function toggleSw() {
        now = Date.now()
        if (swRunning) { acc = swTime; swRunning = false } else { swStart = now; swRunning = true }
    }
    function resetSw() { swRunning = false; acc = 0 }

    // 75 -> "1:15", 3725 -> "1:02:05"
    function fmt(s) {
        s = Math.ceil(s)
        const h = Math.floor(s / 3600), m = Math.floor(s % 3600 / 60), sec = s % 60
        return (h ? h + ":" + String(m).padStart(2, "0") : m) + ":" + String(sec).padStart(2, "0")
    }
}
