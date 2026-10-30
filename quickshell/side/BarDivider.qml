import QtQuick
import "../theme"

// Thin separator between groups of buttons in the side bar.
Item {
    implicitWidth: 44
    implicitHeight: 11
    Rectangle {
        anchors.centerIn: parent
        width: parent.width - 14; height: 1
        color: Theme.red_dim
    }
}
