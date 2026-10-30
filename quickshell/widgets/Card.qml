import QtQuick
import "../theme"
import "../services"
import "../fx"

// Framed panel used by the side-monitor widgets: surface fill, thin red-dim border,
// small techy title, angled (cut) top-right corner marker.
Rectangle {
    id: root
    property string title: ""
    default property alias content: holder.data
    property int pad: 18
    // true: the widget takes mouse input (WidgetHost drops its click-through mask)
    property bool interactive: false
    // no panel at all: just the content floating on the wallpaper
    property bool bare: false

    implicitWidth: holder.childrenRect.width + pad * 2
    implicitHeight: holder.childrenRect.height + pad * 2 + (title !== "" ? 22 : 0)
    // liquid glass backing (blurred by the rice-widget-* layer rule in hypr/modules/rules.lua)
    color: "transparent"
    radius: Settings.radius
    GlassPanel {
        visible: !root.bare
        anchors.fill: parent
        radius: root.radius
        fillAlpha: root.glass.card_opacity !== undefined ? root.glass.card_opacity : 0.5
    }
    readonly property var glass: Settings.data.look.glass || ({})

    Rectangle { visible: !root.bare; x: Settings.radius; width: 28; height: 2; color: Theme.red }
    Text {
        visible: root.title !== ""
        x: root.pad; y: 12
        text: root.title.toUpperCase()
        color: Theme.red
        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; font.letterSpacing: 2
    }
    Scanlines { visible: !root.bare }
    Item {
        id: holder
        x: root.pad
        y: root.pad + (root.title !== "" ? 22 : 0)
    }
}
