import Quickshell
import Quickshell.Hyprland
import QtQuick

PopupWindow {
    id: panel

    // Passed from shell.qml
    property var anchorWindow
    property string mediaStatus: "Stopped"
    property string mediaIcon: ""

    property color colBg: "#050a2d"
    property color colFg: "#a9b1d6"
    property color colBlue: "#7aa2f7"
    property string fontFamily: "JetBrainsMono Nerd Font"

    // Attach popup to the sidebar window
    anchor.window: panel.anchorWindow

    // Position popup to the right of the sidebar
    anchor.rect.x: 40
    anchor.rect.y: 520

    width: 230
    height: 120
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: panel.colBg

        Column {
            anchors.centerIn: parent
            spacing: 12

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Media"
                color: panel.colBlue

                font.family: panel.fontFamily
                font.pixelSize: 16
                font.bold: true
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: panel.mediaStatus
                color: panel.colFg

                font.family: panel.fontFamily
                font.pixelSize: 13
                font.bold: true
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20

                Text {
                    text: ""
                    color: panel.colBlue

                    font.family: panel.fontFamily
                    font.pixelSize: 20
                    renderType: Text.NativeRendering

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("exec playerctl previous")
                    }
                }

                Text {
                    text: panel.mediaIcon
                    color: panel.colBlue

                    font.family: panel.fontFamily
                    font.pixelSize: 22
                    renderType: Text.NativeRendering

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("exec playerctl play-pause")
                    }
                }

                Text {
                    text: ""
                    color: panel.colBlue

                    font.family: panel.fontFamily
                    font.pixelSize: 20
                    renderType: Text.NativeRendering

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("exec playerctl next")
                    }
                }
            }
        }
    }
}