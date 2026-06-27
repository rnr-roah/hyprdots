import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick

Scope {
    id: root

    property color colBg: "#050a2d"
    property color colFg: "#a9b1d6"
    property color colBlue: "#7aa2f7"
    property color colMuted: "#5d668f"
    property string fontFamily: "JetBrainsMono Nerd Font"

    property bool osdVisible: false
    property var notificationQueue: []

    property string appName: ""
    property string summary: ""
    property string body: ""
    property string iconText: "󰂚"

    // Current visible notification grouping.
    // Same app + same title updates this OSD instead of queue-spamming.
    property string currentGroupKey: ""
    property int currentGroupCount: 0

    function cleanText(value) {
        if (!value)
            return ""

        return ("" + value)
            .replace(/<[^>]*>/g, "")
            .replace(/&amp;/g, "&")
            .replace(/&lt;/g, "<")
            .replace(/&gt;/g, ">")
            .replace(/&quot;/g, "\"")
            .replace(/&#39;/g, "'")
            .replace(/\s+/g, " ")
            .trim()
    }

    function notificationKey(item) {
        return item.appName + "::" + item.summary
    }

    function enqueueNotification(notification) {
        if (notification.lastGeneration)
            return

        var item = {
            appName: cleanText(notification.appName || "Notification"),
            summary: cleanText(notification.summary || ""),
            body: cleanText(notification.body || ""),
            urgency: notification.urgency || 0
        }

        if (item.summary.length === 0 && item.body.length === 0)
            return

        var key = notificationKey(item)

        // If the same app/title is already visible, update it in-place.
        // Do not show each new body. Just show +1, +2, +3...
        if (osdVisible && key === currentGroupKey) {
            currentGroupCount += 1
            body = ""
            hideTimer.restart()
            return
        }

        // If the same app/title is already waiting in queue, merge into that one too.
        var q = notificationQueue.slice()
        for (var i = 0; i < q.length; i++) {
            if (q[i].key === key) {
                q[i].count = (q[i].count || 0) + 1
                q[i].body = ""
                notificationQueue = q
                return
            }
        }

        item.key = key
        item.count = 0
        notificationQueue = notificationQueue.concat([item])

        if (!osdVisible && !nextNotificationDelay.running)
            showNextNotification()
    }

    function showNextNotification() {
        if (notificationQueue.length === 0) {
            osdVisible = false
            return
        }

        var item = notificationQueue[0]
        notificationQueue = notificationQueue.slice(1)

        appName = item.appName
        summary = item.summary
        body = item.count > 0 ? "" : item.body
        currentGroupKey = item.key || notificationKey(item)
        currentGroupCount = item.count || 0
        iconText = item.urgency >= 2 ? "󰀪" : "󰂚"

        osdVisible = true
        hideTimer.restart()
    }

    NotificationServer {
        id: notificationServer
        keepOnReload: false

        onNotification: notification => {
            root.enqueueNotification(notification)
        }
    }

    Timer {
        id: hideTimer
        interval: 5000
        repeat: false

        onTriggered: {
            root.osdVisible = false
            nextNotificationDelay.restart()
        }
    }

    Timer {
        id: nextNotificationDelay
        interval: 150
        repeat: false

        onTriggered: root.showNextNotification()
    }

    PanelWindow {
        id: osdWindow

        visible: root.osdVisible || osdBox.y > -osdBox.height + 2 || osdBox.opacity > 0

        anchors {
            top: true
            left: true
            right: true
        }

        height: 76
        color: "transparent"
        exclusiveZone: 0

        mask: Region {
            item: osdBox
        }

        Item {
            id: osdBox

            width: 560
            height: 50

            anchors.horizontalCenter: parent.horizontalCenter
            y: root.osdVisible ? -1 : -height
            opacity: root.osdVisible ? 1 : 0

            // Rotated volume/brightness OSD shape.
            // Top edge = screen edge. Bottom line = the straight OSD wall.
            property real bodyInset: 120
            property real bodyY: 50
            property real cornerSoft: 50
            property real edgeSoft: 72

            Behavior on y {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }

            Canvas {
                id: notificationShape
                anchors.fill: parent

                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()

                Connections {
                    target: root
                    function onColBgChanged() { notificationShape.requestPaint() }
                }

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()

                    var w = width
                    var bodyLeft = osdBox.bodyInset
                    var bodyRight = w - osdBox.bodyInset
                    var bodyY = osdBox.bodyY
                    var cornerSoft = osdBox.cornerSoft
                    var edgeSoft = osdBox.edgeSoft

                    ctx.beginPath()

                    // Screen-flush top edge.
                    ctx.moveTo(0, 0)
                    ctx.lineTo(w, 0)

                    // Right taper, rotated from the volume OSD curve.
                    ctx.bezierCurveTo(
                        w - edgeSoft, 2,
                        bodyRight + cornerSoft, bodyY,
                        bodyRight, bodyY
                    )

                    // Flat lower wall, not a rounded pill bottom.
                    ctx.lineTo(bodyLeft, bodyY)

                    // Left taper, mirrored.
                    ctx.bezierCurveTo(
                        bodyLeft - cornerSoft, bodyY,
                        edgeSoft, 2,
                        0, 0
                    )

                    ctx.closePath()

                    // Same source as volume/brightness OSD and main bar pill.
                    // In shell.qml, pass colBg: root.colBg so this stays Matugen-flexible.
                    ctx.fillStyle = root.colBg
                    ctx.fill()
                }
            }

            Row {
                id: osdContent

                width: osdBox.width - (osdBox.bodyInset * 2) - 18
                height: 36

                anchors.horizontalCenter: parent.horizontalCenter
                y: 8
                spacing: 9

                Rectangle {
                    width: 24
                    height: 24
                    radius: 12
                    anchors.verticalCenter: parent.verticalCenter

                    color: Qt.rgba(root.colBlue.r, root.colBlue.g, root.colBlue.b, 0.18)

                    Text {
                        anchors.centerIn: parent

                        text: root.iconText
                        color: root.colBlue

                        font.family: root.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        renderType: Text.NativeRendering
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 33
                    spacing: 1

                    Text {
                        width: parent.width

                        text: root.appName
                        color: root.colBlue

                        font.family: root.fontFamily
                        font.pixelSize: 7
                        font.bold: true
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        textFormat: Text.PlainText
                    }

                    Row {
                        width: parent.width
                        spacing: 7

                        Text {
                            id: titleText

                            // When grouped, do NOT let the title eat the whole row.
                            // The counter needs guaranteed room on the right.
                            width: root.currentGroupCount > 0
                                ? Math.min(220, implicitWidth)
                                : root.body.length > 0
                                    ? Math.min(260, implicitWidth)
                                    : parent.width

                            text: root.summary.length > 0 ? root.summary : root.body
                            color: root.colFg

                            font.family: root.fontFamily
                            font.pixelSize: 13
                            font.bold: true
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            textFormat: Text.PlainText
                        }

                        Text {
                            width: Math.max(0, parent.width - titleText.width - 7)

                            text: root.currentGroupCount > 0
                                ? "+" + root.currentGroupCount + " " + (root.currentGroupCount === 1 ? "notification" : "notifications")
                                : (root.summary.length > 0 ? root.body : "")

                            visible: text.length > 0 && width > 20
                            color: root.currentGroupCount > 0 ? root.colBlue : root.colMuted

                            font.family: root.fontFamily
                            font.pixelSize: root.currentGroupCount > 0 ? 12 : 10
                            font.bold: root.currentGroupCount > 0
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            textFormat: Text.PlainText
                        }
                    }
                }
            }
        }
    }
}
