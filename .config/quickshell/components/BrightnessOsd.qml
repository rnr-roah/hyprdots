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

    property int brightnessPercent: 0
    property bool osdVisible: false

    // Prevent OSD from popping up once on QS startup.
    property bool initialized: false

    // Watches brightness changes by polling /sys/class/backlight.
    // This works no matter what changes brightness:
    // brightnessctl, swayosd, keybinds, KDE settings, etc.
    Process {
        id: brightnessWatchProc

        command: [
            "sh",
            "-c",
            "dev=$(ls -d /sys/class/backlight/* 2>/dev/null | head -n1); [ -z \"$dev\" ] && exit 0; last=\"\"; while true; do cur=$(cat \"$dev/brightness\" 2>/dev/null || echo 0); max=$(cat \"$dev/max_brightness\" 2>/dev/null || echo 1); pct=$((cur * 100 / max)); if [ \"$pct\" != \"$last\" ]; then echo \"$pct\"; last=\"$pct\"; fi; sleep 0.15; done"
        ]

        stdout: SplitParser {
            onRead: data => {
                var pct = parseInt(data.trim())

                if (!isNaN(pct)) {
                    root.brightnessPercent = Math.max(0, Math.min(100, pct))

                    if (root.initialized) {
                        root.osdVisible = true
                        hideTimer.restart()
                    } else {
                        root.initialized = true
                    }
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

            // Same shape tuning as VolumeOsd.
            property real bodyX: 62
            property real bodyTop: 100
            property real bodyBottom: height - bodyTop
            property real cornerSoft: 48
            property real edgeSoft: 40

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

                    ctx.moveTo(w, 0)
                    ctx.lineTo(w, h)

                    ctx.bezierCurveTo(
                        w - 2, h - edgeSoft,
                        bodyX, bodyBottom + cornerSoft,
                        bodyX, bodyBottom
                    )

                    ctx.lineTo(bodyX, bodyTop)

                    ctx.bezierCurveTo(
                        bodyX, bodyTop - cornerSoft,
                        w - 2, edgeSoft,
                        w, 0
                    )

                    ctx.closePath()

                    ctx.fillStyle = root.colBg
                    ctx.fill()

                    // ctx.strokeStyle = "#2b3870"
                    // ctx.lineWidth = 1
                    // ctx.lineJoin = "round"
                    // ctx.stroke()
                }
            }

            Column {
                id: osdContent

                width: 42

                x: osdBox.bodyX
                    + ((osdBox.width - osdBox.bodyX) / 2)
                    - (width / 2)

                anchors.verticalCenter: parent.verticalCenter
                spacing: 18

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: root.brightnessPercent + ""

                    color: root.colFg

                    font.family: root.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                }

                Rectangle {
                    id: brightnessTrack

                    anchors.horizontalCenter: parent.horizontalCenter

                    width: 12
                    height: 330
                    radius: 6

                    color: "#1f2a5a"

                    Rectangle {
                        id: brightnessFill

                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter

                        width: parent.width

                        height: parent.height * root.brightnessPercent / 100

                        radius: 6

                        // Keeping same accent as volume for identical look.
                        color: root.colBlue

                        Behavior on height {
                            NumberAnimation {
                                duration: 140
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    // Brightness / sun icon
                    text: "󰃠"

                    color: root.colFg

                    font.family: root.fontFamily
                    font.pixelSize: 15
                    font.bold: true
                    renderType: Text.NativeRendering
                }
            }
        }
    }
}