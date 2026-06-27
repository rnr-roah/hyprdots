import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

Scope {
    id: root

    // =========================
    // Theme values
    // These get passed from shell.qml
    // =========================
    property color colBg: "#050a2d"
    property color colFg: "#a9b1d6"
    property color colBlue: "#7aa2f7"
    property color colMuted: "#5d668f"
    property string fontFamily: "JetBrainsMono Nerd Font"

    // =========================
    // Volume state
    // =========================
    property int volumePercent: 0
    property bool volumeMuted: false
    property bool osdVisible: false

    // =========================
    // Watch for volume changes
    // pactl subscribe stays running and reports audio changes.
    // =========================
    Process {
        id: volumeWatchProc

        command: ["sh", "-c", "pactl subscribe"]

        stdout: SplitParser {
            onRead: data => {
                console.log("PACTL EVENT:", data)

                // Output volume changes usually trigger sink events.
                // Server events are included just in case your setup emits those.
                if (data.includes("sink") || data.includes("server")) {
                    volumeReadProc.running = true
                }
            }
        }

        Component.onCompleted: running = true
    }

    // =========================
    // Read the current volume
    // Example:
    // Volume: 0.52
    // Volume: 0.52 [MUTED]
    // =========================
    Process {
        id: volumeReadProc

        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]

        stdout: SplitParser {
            onRead: data => {
                console.log("VOLUME READ:", data)

                var muted = data.includes("MUTED")
                var match = data.match(/([0-9]+\\.[0-9]+)/)

                if (match) {
                    root.volumePercent = Math.round(parseFloat(match[1]) * 100)
                    root.volumeMuted = muted

                    root.osdVisible = true
                    hideTimer.restart()
                }
            }
        }

        // Read once on startup so value exists.
        Component.onCompleted: running = true
    }

    // =========================
    // Hide the OSD after a short delay
    // =========================
    Timer {
        id: hideTimer

        interval: 1000
        repeat: false

        onTriggered: {
            root.osdVisible = false
        }
    }

    // =========================
    // OSD window
    //
    // This is a transparent top overlay.
    // exclusiveZone: 0 means it does NOT push windows down.
    // mask makes only osdBox clickable; transparent area is click-through.
    // =========================
    PanelWindow {
        id: osdWindow

        visible: root.osdVisible

        anchors {
            top: true
            left: true
            right: true
        }

        height: 110
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

                        color: root.colBlue

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
