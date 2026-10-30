import QtQuick
import "../theme"
import "../services"

// Glitch pop-in for an item: hides `target`, shows a glitching copy that settles, then reveals it.
// Put it next to the target (same parent) and call play(delayMs). Length and strength come from
// the active glitch level; with nothing configured it does nothing.
Item {
    id: root
    required property Item target
    property bool running: false
    property real progress: 0

    x: target ? target.x : 0
    y: target ? target.y : 0
    width: target ? target.width : 0
    height: target ? target.height : 0
    visible: running

    function play(delay) {
        if (!target || Settings.glitch.pop_ms <= 0) return
        anim.stop()
        progress = 1
        running = true
        pause.duration = delay || 0
        anim.restart()
    }

    SequentialAnimation {
        id: anim
        PauseAnimation { id: pause }
        NumberAnimation { target: root; property: "progress"; from: 1; to: 0; duration: Settings.glitch.pop_ms; easing.type: Easing.OutQuad }
        ScriptAction { script: root.running = false }
    }

    ShaderEffectSource { id: src; sourceItem: root.target; hideSource: root.running; live: true; visible: false }

    ShaderEffect {
        anchors.fill: parent
        property variant source: src
        property real progress: root.progress
        property real strength: Settings.glitch.strength
        property real seed: Math.random() * 10
        // held invisible while waiting out the stagger delay
        opacity: pause.running ? 0 : 1
        fragmentShader: Qt.resolvedUrl("glitch.frag.qsb")
    }
}
