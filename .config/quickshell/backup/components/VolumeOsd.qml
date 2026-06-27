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

        visible: root.osdVisible || osdBox.opacity > 0

        anchors {
            top: true
            bottom: true
            right: true
        }

        width: 110
        color: "transparent"
        exclusiveZone: 0

        mask: Region {
            item: osdBox
        }

        Item {
            id: osdBox

            width: 100
            height: 560

            // Shape tuning
            property real bodyX: 62          // left straight wall; bigger = thinner body
            property real bodyTop: 100       // where straight wall starts
            property real bodyBottom: height - bodyTop
            property real cornerSoft: 48     // roundness at the two mouth corners
            property real edgeSoft: 40       // softness near screen edge

            x: root.osdVisible ? parent.width - width : parent.width
            anchors.verticalCenter: parent.verticalCenter

            opacity: root.osdVisible ? 1 : 0

            Behavior on x {
                NumberAnimation {
                    duration: 240
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 140
                    easing.type: Easing.OutCubic
                }
            }

            Canvas {
                id: osdShape

                anchors.fill: parent

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()

                    var w = width
                    var h = height

                    var bodyX = osdBox.bodyX
                    var bodyTop = osdBox.bodyTop
                    var bodyBottom = osdBox.bodyBottom
                    var cornerSoft = osdBox.cornerSoft
                    var edgeSoft = osdBox.edgeSoft

                    ctx.beginPath()

                    // Right edge: flush with screen side.
                    ctx.moveTo(w, 0)
                    ctx.lineTo(w, h)

                    // Bottom concave tear curve.
                    // Smoothly enters the straight wall.
                    ctx.bezierCurveTo(
                        w - 2, h - edgeSoft,
                        bodyX, bodyBottom + cornerSoft,
                        bodyX, bodyBottom
                    )

                    // Straight left wall beside the volume meter.
                    ctx.lineTo(bodyX, bodyTop)

                    // Top concave tear curve.
                    // Smoothly exits the straight wall.
                    ctx.bezierCurveTo(
                        bodyX, bodyTop - cornerSoft,
                        w - 2, edgeSoft,
                        w, 0
                    )

                    ctx.closePath()

                    ctx.fillStyle = root.colBg
                    ctx.fill()

                    ctx.strokeStyle = "#2b3870"
                    ctx.lineWidth = 1
                    ctx.lineJoin = "round"
                    ctx.stroke()
                }
            }

            Column {
                id: osdContent

                width: 42

                // Keep content centered inside the visible body area.
                x: osdBox.bodyX
                    + ((osdBox.width - osdBox.bodyX) / 2)
                    - (width / 2)

                anchors.verticalCenter: parent.verticalCenter
                spacing: 18

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: root.volumeMuted
                        ? "M"
                        : root.volumePercent + ""

                    color: root.volumeMuted
                        ? root.colMuted
                        : root.colFg

                    font.family: root.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                }

                Rectangle {
                    id: volumeTrack

                    anchors.horizontalCenter: parent.horizontalCenter

                    width: 12
                    height: 330
                    radius: 6

                    color: "#1f2a5a"

                    Rectangle {
                        id: volumeFill

                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter

                        width: parent.width

                        height: root.volumeMuted
                            ? 0
                            : parent.height * Math.min(root.volumePercent, 100) / 100

                        radius: 6

                        color: root.volumeMuted
                            ? root.colMuted
                            : root.colBlue

                        Behavior on height {
                            NumberAnimation {
                                duration: 140
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 140
                            }
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: root.volumeMuted ? "󰝟" : "󰕾"

                    color: root.volumeMuted
                        ? root.colMuted
                        : root.colFg

                    font.family: root.fontFamily
                    font.pixelSize: 15
                    font.bold: true
                    renderType: Text.NativeRendering
                }
            }
        }
    }
}