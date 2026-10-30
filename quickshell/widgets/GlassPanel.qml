import QtQuick
import "../theme"
import "../services"

// Liquid-glass backing for the bars: translucent red-tinted fill (Hyprland blurs what is behind it,
// see the layer rules in hypr/modules/rules.lua), a soft top sheen, a thin bright rim at the top
// and a red edge. Opacity and tint come from settings.json -> look.glass.bar_*.
Rectangle {
    id: root
    readonly property var glass: Settings.data.look.glass || ({})
    readonly property real fillAlpha: glass.bar_opacity !== undefined ? glass.bar_opacity : 0.4
    readonly property real tint: glass.bar_tint !== undefined ? glass.bar_tint : 0.08

    color: {
        const b = Theme.base, r = Theme.red
        return Qt.rgba(b.r + (r.r - b.r) * tint, b.g + (r.g - b.g) * tint, b.b + (r.b - b.b) * tint, fillAlpha)
    }
    border.width: 1
    border.color: Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.5)

    // soft sheen over the upper half
    Rectangle {
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 }
        height: parent.height * 0.5
        radius: Math.max(0, root.radius - 1)
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.09) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }
    // bright rim along the top edge
    Rectangle {
        x: root.radius; y: 1
        width: root.width - root.radius * 2; height: 1
        color: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.28)
    }
}
