import QtQuick
import "../theme"
import "../services"

// One cell of the side bar: a Nerd Font icon with an optional small label under it.
Rectangle {
    id: root
    property string icon: ""
    property string label: ""
    property color iconColor: Theme.text
    property color labelColor: Theme.text
    property int labelSize: 9
    property bool lit: false          // filled red (e.g. mic muted)
    signal clicked()
    signal rightClicked()
    signal scrolled(int dir)

    implicitWidth: 44
    implicitHeight: label === "" ? 36 : 46
    radius: Settings.radiusSmall
    color: lit ? Theme.red : (hover.hovered ? Theme.overlay : "transparent")
    Behavior on color { ColorAnimation { duration: 80 } }

    Column {
        anchors.centerIn: parent
        spacing: 1
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.icon
            color: root.lit ? Theme.base : root.iconColor
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 17
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.label !== ""
            text: root.label
            color: root.lit ? Theme.base : root.labelColor
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: root.labelSize
        }
    }

    HoverHandler { id: hover }
    TapHandler { acceptedButtons: Qt.LeftButton; onTapped: root.clicked() }
    TapHandler { acceptedButtons: Qt.RightButton; onTapped: root.rightClicked() }
    WheelHandler { onWheel: e => root.scrolled(e.angleDelta.y > 0 ? 1 : -1) }
}
