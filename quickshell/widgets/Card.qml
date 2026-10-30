import QtQuick
import "../theme"
import "../services"

// Framed panel used by the side-monitor widgets: surface fill, thin red-dim border,
// small techy title, angled (cut) top-right corner marker.
Rectangle {
    id: root
    property string title: ""
    default property alias content: holder.data
    property int pad: 18
    // true: the widget takes mouse input (WidgetHost drops its click-through mask)
    property bool interactive: false

    implicitWidth: holder.childrenRect.width + pad * 2
    implicitHeight: holder.childrenRect.height + pad * 2 + (title !== "" ? 22 : 0)
    color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.88)
    border.width: 1
    border.color: Theme.overlay
    radius: Settings.radius

    Rectangle { x: Settings.radius; width: 28; height: 2; color: Theme.red }
    Text {
        visible: root.title !== ""
        x: root.pad; y: 12
        text: root.title.toUpperCase()
        color: Theme.red_dim
        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; font.letterSpacing: 2
    }
    Item {
        id: holder
        x: root.pad
        y: root.pad + (root.title !== "" ? 22 : 0)
    }
}
