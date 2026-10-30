import QtQuick
import "../theme"
import "../services"

// Dark scanlines over a panel, clipped to its rounded corners. Drop it in as the topmost child.
ShaderEffect {
    anchors.fill: parent
    property real radius: Settings.radius
    property size size: Qt.size(width, height)
    property real pitch: Settings.glitch.scan_pitch
    property real alpha: Settings.glitch.scan_alpha
    visible: alpha > 0
    fragmentShader: Qt.resolvedUrl("scan.frag.qsb")
}
