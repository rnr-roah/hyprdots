import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

Scope {
    id: root

    property color colBg: "#050a2d"
    property color colFg: "#a9b1d6"
    property color colBlue: "#7aa2f7"
    property color colMuted: "#5d668f"
    property string fontFamily: "JetBrainsMono Nerd Font"

    property int volumePercent: 0
    property bool volumeMuted: false
    property bool osdVisible: false

    Process {
        id: volumeWatchProc

        command: ["sh", "-c", "pactl subscribe"]

        stdout: SplitParser {
            onRead: data => {
                if (data.includes("sink") || data.includes("server")) {
                    volumeReadProc.running = false
                    volumeReadProc.running = true
                }
            }
        }

        Component.onCompleted: {
            running = true
        }
    }

    Process {
        id: volumeReadProc

        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]

        stdout: SplitParser {
            onRead: data => {
                console.log("VOLUME READ:", data)

                var muted = data.includes("MUTED")
                var match = data.match(new RegExp("([0-9]+\\.[0-9]+)"))

                if (match) {
                    root.volumePercent = Math.round(parseFloat(match[1]) * 100)
                    root.volumeMuted = muted
                    root.osdVisible = true
                    hideTimer.restart()
                }
            }
        }

        Component.onCompleted: {
            running = true
        }
    }

    Timer {
        id: hideTimer

        interval: 1000
        repeat: false

        onTriggered: {
            root.osdVisible = false
        }
    }

    PanelWindow {
        id: osdWindow

        visible: root.osdVisible

        anchors {
            top: true
            left: true
            right: true
        }

        height: 120
        color: "transparent"
        exclusiveZone: 0

        mask: Region {
            item: osdBox
        }

        Rectangle {
            id: osdBox

            width: 280
            height: 82
            radius: 20

            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: 24
            }

            color: root.colBg
            border.width: 1
            border.color: "#2b3870"

            Column {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: root.volumeMuted
                        ? "Volume Muted"
                        : "Volume " + root.volumePercent + "%"

                    color: root.volumeMuted
                        ? root.colMuted
                        : root.colFg

                    font.family: root.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                }

                Rectangle {
                    width: 220
                    height: 8
                    radius: 4
                    color: "#1f2a5a"

                    Rectangle {
                        height: parent.height
                        radius: 4

                        width: root.volumeMuted
                            ? 0
                            : parent.width * Math.min(root.volumePercent, 100) / 100

                        color: root.volumeMuted
                            ? root.colMuted
                            : root.colBlue

                        Behavior on width {
                            NumberAnimation {
                                duration: 120
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }
        }
    }
}