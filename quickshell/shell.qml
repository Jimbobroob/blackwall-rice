//@ pragma UseQApplication
import QtQuick
import Quickshell
import "bar"
import "launcher"
import "osd"
import "notifications"
import "widgets"
import "services"

// Rice shell. One scope per monitor, keyed by role (main/side) not port name,
// so a KVM switch just removes and re-adds that monitor's windows.
ShellRoot {
    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: scope
            required property var modelData
            readonly property string role: Settings.roleOf(modelData)
            // toasts go to the side monitor; main takes over only when side is away
            readonly property bool notifHost: role === "side" || (role === "main" && !Settings.hasRole("side"))

            LazyLoader { active: scope.role === "main"; MainBar { screen: scope.modelData } }
            LazyLoader { active: scope.role === "main"; Launcher { screen: scope.modelData } }
            LazyLoader { active: scope.role === "main"; VolumeOsd { screen: scope.modelData } }
            LazyLoader { active: scope.notifHost; NotificationPopups { screen: scope.modelData } }

            Variants {
                model: scope.role === "main" ? Settings.data.widgets.main : []
                delegate: WidgetHost { required property var modelData; spec: modelData; screen: scope.modelData }
            }
        }
    }
}
