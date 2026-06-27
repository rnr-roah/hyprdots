import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import Quickshell.Services.SystemTray
import "./components"

PanelWindow {
    id: root

    mask: Region { item: sideBg }

    anchors {
        left: true
        top: true
        bottom: true
    }

    property color colBg: "#000000"
    property color colFg: "#a9b1d6"
    property color colWhite: "#ffffff"
    property color colMuted: "#5d668f"
    property color colCyan: "#0db9d7"
    property color colBlue: "#7aa2f7"
    property color colYellow: "#e0af68"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14

    property int cpuUsage: 0
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0
    property int memUsage: 0
    property string gpuUsage: "0"

    property string powerIcon: "="
    property string powerColor: "#f1c40f"
    property string powerMode: "Balanced"

    property string mediaIcon: ""
    property string mediaStatus: "Stopped"
    property string activePanel: ""

    property string mediaTitle: "No media"
    property string mediaArtist: ""
    property string mediaAlbum: ""
    property string mediaArtUrl: ""
    property int mediaPosition: 0
    property int mediaLength: 0
    property real mediaProgress: 0

    function formatMediaTime(seconds) {
        seconds = Math.max(0, Math.floor(seconds))
        var m = Math.floor(seconds / 60)
        var s = seconds % 60
        return m + ":" + (s < 10 ? "0" + s : s)
    }
    function safeMediaText(value) {
        if (!value)
            return ""

        return ("" + value)
            .replace(/[^\x20-\x7E]/g, "")
            .replace(/\s+/g, " ")
            .trim()
    }
    property int batteryPercent: 0
    property bool batteryCharging: false
    property string batteryIcon: "󰁹"

    property int wifiStrength: 0
    property bool wifiConnected: false
    property bool bluetoothPowered: false
    property real chargingAnimation: 0

    property string wifiSsid: "Unknown"
    property string bluetoothText: "Off"
    property bool showWifiList: false
    property var wifiNetworks: []

    property int infoIndex: 0
    property string clockHourText: "00"
    property string clockMinuteText: "00"

    property string dateDayText: "Thu"
    property string dateMonthText: "06"
    property string dateDateText: "12"

    function updateClockText() {
        var now = new Date()

        var h = now.getHours()
        var m = now.getMinutes()

        // 24h / military format
        root.clockHourText = h < 10 ? "0" + h : "" + h
        root.clockMinuteText = m < 10 ? "0" + m : "" + m

        var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

        var month = now.getMonth() + 1
        var date = now.getDate()

        root.dateDayText = days[now.getDay()]
        root.dateMonthText = month < 10 ? "0" + month : "" + month
        root.dateDateText = date < 10 ? "0" + date : "" + date
    }

    // Shared hover/active styling helpers.
    // Use these on small cards/buttons so all interactions feel consistent.
    function cardBg(active, hovered) {
        if (active)
            return hovered ? "#16205a" : "#101a4a"

        return hovered ? "#0e1742" : "#0b1238"
    }

    function cardBorder(active, hovered) {
        if (active)
            return "#4f63b8"

        return hovered ? "#3d4f9f" : "transparent"
    }

    function cardBorderWidth(active, hovered) {
        return active ? 2 : hovered ? 1 : 0
    }


    width: 500
    exclusiveZone: 50
    color: "transparent"

    VolumeOsd {
        colBg: root.colBg
        colFg: root.colFg
        colBlue: root.colBlue
        colMuted: root.colMuted
        fontFamily: root.fontFamily
    }

    BrightnessOsd {
        colBg: root.colBg
        colFg: root.colFg
        colBlue: root.colBlue
        colMuted: root.colMuted
        fontFamily: root.fontFamily
    }

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]

        stdout: SplitParser {
            onRead: data => {
                var p = data.trim().split(/\s+/)
                var idle = parseInt(p[4]) + parseInt(p[5])
                var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)

                if (root.lastCpuTotal > 0) {
                    root.cpuUsage = Math.round(
                        100 * (1 - (idle - root.lastCpuIdle) / (total - root.lastCpuTotal))
                    )
                }

                root.lastCpuTotal = total
                root.lastCpuIdle = idle
            }
        }

        Component.onCompleted: running = true
    }

    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]

        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(/\s+/)
                var total = parseInt(parts[1]) || 1
                var used = parseInt(parts[2]) || 0
                root.memUsage = Math.round(100 * used / total)
            }
        }

        Component.onCompleted: running = true
    }

    Process {
        id: gpuProc
        command: ["sh", "-c", "~/.config/waybar/scripts/gpu.sh | jq -r .text"]

        stdout: SplitParser {
            onRead: data => {
                root.gpuUsage = data.trim().replace("%", "")
            }
        }

        Component.onCompleted: running = true
    }

    Process {
        id: powerProc
        command: ["sh", "-c", "~/.config/quickshell/scripts/power_mode_toggle.sh"]

        stdout: SplitParser {
            onRead: data => {
                var obj = JSON.parse(data.trim())
                root.powerIcon = obj.text
                root.powerColor = obj.color
                root.powerMode = obj.mode
            }
        }

        Component.onCompleted: running = true
    }

    Process {
        id: powerToggleProc
        command: ["sh", "-c", "~/.config/quickshell/scripts/power_mode_toggle.sh toggle"]
    }

    Process {
        id: mediaProc

        command: [
            "sh",
            "-c",
            "status=$(playerctl status 2>/dev/null || echo Stopped); " +
            "if [ \"$status\" = \"Stopped\" ]; then jq -nc --arg status \"$status\" '{status:$status}'; exit 0; fi; " +
            "title=$(playerctl metadata title 2>/dev/null || echo \"\"); " +
            "artist=$(playerctl metadata artist 2>/dev/null || echo \"\"); " +
            "album=$(playerctl metadata album 2>/dev/null || echo \"\"); " +
            "art=$(playerctl metadata mpris:artUrl 2>/dev/null || echo \"\"); " +
            "length=$(playerctl metadata mpris:length 2>/dev/null || echo 0); " +
            "position=$(playerctl position 2>/dev/null || echo 0); " +
            "jq -nc --arg status \"$status\" --arg title \"$title\" --arg artist \"$artist\" --arg album \"$album\" --arg art \"$art\" --argjson length \"${length:-0}\" --argjson position \"${position:-0}\" '{status:$status,title:$title,artist:$artist,album:$album,art:$art,length:$length,position:$position}'"
        ]

        stdout: SplitParser {
            onRead: data => {
                var obj = JSON.parse(data.trim())

                root.mediaStatus = obj.status || "Stopped"

                if (root.mediaStatus === "Playing")
                    root.mediaIcon = ""
                else if (root.mediaStatus === "Paused")
                    root.mediaIcon = ""
                else
                    root.mediaIcon = ""

                root.mediaTitle = obj.title || "No title"
                root.mediaArtist = obj.artist || ""
                root.mediaAlbum = obj.album || ""
                root.mediaArtUrl = obj.art || ""

                root.mediaLength = Math.round((obj.length || 0) / 1000000)
                root.mediaPosition = Math.round(obj.position || 0)

                root.mediaProgress = root.mediaLength > 0
                    ? Math.min(1, Math.max(0, root.mediaPosition / root.mediaLength))
                    : 0
            }
        }

        Component.onCompleted: running = true
    }


    Process {
        id: mediaPlayPauseProc
        command: ["sh", "-c", "playerctl play-pause"]
    }

    Process {
        id: mediaPreviousProc
        command: ["sh", "-c", "playerctl previous"]
    }

    Process {
        id: mediaNextProc
        command: ["sh", "-c", "playerctl next"]
    }

    Process {
        id: mediaSeekProc

        property int seekTo: 0

        command: ["sh", "-c", "playerctl position " + seekTo]
    }

    Timer {
        id: mediaRefreshDelay
        interval: 160
        repeat: false

        onTriggered: {
            mediaProc.running = false
            mediaProc.running = true
        }
    }
    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            root.updateClockText()
        }

        Component.onCompleted: {
            root.updateClockText()
        }
    }


    Process {
        id: batteryProc
        command: ["sh", "-c", "echo \"$(cat /sys/class/power_supply/BAT*/capacity) $(cat /sys/class/power_supply/BAT*/status)\""]

        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(/\s+/)

                root.batteryPercent = parseInt(parts[0]) || 0
                root.batteryCharging = parts[1] === "Charging"

                if (root.batteryCharging)
                    root.batteryIcon = "󰂄"
                else if (root.batteryPercent >= 80)
                    root.batteryIcon = "󰁹"
                else if (root.batteryPercent >= 50)
                    root.batteryIcon = "󰁾"
                else if (root.batteryPercent >= 20)
                    root.batteryIcon = "󰁻"
                else
                    root.batteryIcon = "󰁺"
            }
        }

        Component.onCompleted: running = true
    }

    Process {
        id: wifiProc
        command: ["sh", "-c", "echo \"$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | grep '^yes' | head -1)\""]

        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(":")
                root.wifiSsid = parts[1] || "Disconnected"
                root.wifiStrength = parseInt(parts[2]) || 0
                root.wifiConnected = root.wifiStrength > 0
                wifiCanvas.requestPaint()
            }
        }

        Component.onCompleted: running = true
    }

    Process {
        id: bluetoothProc
        command: ["sh", "-c", "bluetoothctl show 2>/dev/null | grep 'Powered:' | awk '{print $2}' || echo no"]

        stdout: SplitParser {
            onRead: data => {
                root.bluetoothPowered = data.trim() === "yes"
                root.bluetoothText = root.bluetoothPowered ? "On" : "Off"
            }
        }

        Component.onCompleted: running = true
    }

    Process {
        id: wifiListProc
        command: ["sh", "-c", "nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list --rescan yes | awk -F: '$1 != \"\" {print}' | sort -t: -k2 -nr | paste -sd '|' -"]

        stdout: SplitParser {
            onRead: data => {
                root.wifiNetworks = data.trim().length > 0
                    ? data.trim().split("|")
                    : []
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true

        onTriggered: {
            cpuProc.running = true
            memProc.running = true
            gpuProc.running = true
            powerProc.running = true
            batteryProc.running = true
            wifiProc.running = true
            bluetoothProc.running = true
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            mediaProc.running = true
        }
    }

    Rectangle {
        id: sideBg

        anchors {
            left: parent.left
            leftMargin: 8
            verticalCenter: parent.verticalCenter
        }

        width: root.activePanel !== "" ? 270 : 36
        height: sideColumn.implicitHeight + 20
        radius: 18
        color: root.colBg
        clip: true
        border.width: 1
        border.color: "#1f2a5aaa"

        Behavior on border.color {
            ColorAnimation {
                duration: 160
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        Row {
            id: mainRow

            anchors {
                left: parent.left
                leftMargin: 8
                verticalCenter: parent.verticalCenter
            }

            spacing: root.activePanel !== "" ? 16 : 0

            Column {
                id: sideColumn
                width: 20
                spacing: 5
                

               Rectangle {
                    id: powerButton

                    property bool hovered: powerMouse.containsMouse

                    anchors.horizontalCenter: parent.horizontalCenter

                    width: 24
                    height: 24

                    // fully rounded/circle
                    radius: Math.min(width, height) / 2

                    color: "transparent"

                    // tiny border only on hover
                    border.width: hovered ? 0.5 : 0
                    border.color: hovered ? "#3d4f9f" : "transparent"

                    scale: hovered ? 1.1 : 1.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 160
                        }
                    }

                    Text {
                        anchors.centerIn: parent

                        text: root.powerIcon

                        // keep power icon color from script, no hover color change
                        color: root.powerColor

                        font.family: root.fontFamily
                        font.pixelSize: 16
                        font.bold: true
                        renderType: Text.NativeRendering
                    }

                    MouseArea {
                        id: powerMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            powerToggleProc.running = true
                            powerProc.running = true
                        }
                    }
                }

               Repeater {
                    model: 3

                    Rectangle {
                        id: workspacePill

                        property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                        property bool isActive: Hyprland.focusedWorkspace?.id === index + 1
                        property bool hovered: workspaceMouse.containsMouse

                        anchors.horizontalCenter: parent.horizontalCenter

                        // Original pill sizing restored
                        width: 11
                        height: isActive ? 40 : 20
                        radius: 20

                        // No scale. No border. Only background changes.
                        color: isActive
                            ? "#3E4278"
                            : hovered
                                ? "#34344a"
                                : "#27272c"

                        Behavior on height {
                            NumberAnimation {
                                duration: 180
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 180
                            }
                        }

                        MouseArea {
                            id: workspaceMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                Hyprland.dispatch("workspace " + (index + 1))
                            }
                        }
                    }
                }

                Item { width: 1; height: 1 }

                Text {
                    id: media

                    property bool active: root.activePanel === "media"
                    property bool hovered: mediaMouse.containsMouse

                    visible: root.mediaStatus !== "Stopped"
                    height: visible ? implicitHeight : 0

                    anchors.horizontalCenter: parent.horizontalCenter

                    text: root.mediaIcon
                    color: active || hovered ? root.colBlue : root.colFg

                    scale: hovered ? 1.12 : 1.0

                    font.family: root.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    renderType: Text.NativeRendering

                    Behavior on color {
                        ColorAnimation { duration: 160 }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }

                    MouseArea {
                        id: mediaMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            mediaProc.running = true
                            root.activePanel = root.activePanel === "media" ? "" : "media"
                        }
                    }
                }

                // Item { width: 1; height: 1 }


                // =========================
                // ROTATING INFO / CLOCK PILL
                // =========================
                Rectangle {
                    id: rotatingInfoPill

                    property bool hovered: rotatingInfoMouse.containsMouse

                    anchors.horizontalCenter: parent.horizontalCenter

                    width: 28
                    height: 42
                    radius: 9

                    color: hovered
                        ? "#101a4a"
                        : "#0b123800"

                    border.width: hovered ? 0.5 : 0
                    border.color: hovered
                        ? "#3d4f9f"
                        : "transparent"

                    scale: hovered ? 1.04 : 1.0

                    // Makes the flip smoother instead of looking like a cursed paper cutout.
                    layer.enabled: true
                    layer.smooth: true

                    transform: Rotation {
                        id: infoFlipRotation

                        origin.x: rotatingInfoPill.width / 2
                        origin.y: rotatingInfoPill.height / 2

                        // Y-axis rotation = right-to-left card flip
                        axis {
                            x: 0
                            y: 1
                            z: 0
                        }

                        angle: 0
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 160
                        }
                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 160
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }

                    // Auto flip every few seconds
                    Timer {
                        interval: 5000
                        running: true
                        repeat: true

                        onTriggered: {
                            if (!infoFlipAnim.running)
                                infoFlipAnim.start()
                        }
                    }

                    // Flip animation:
                    // 0 -> 90 degrees: old face rotates away
                    // switch content while edge-on
                    // -90 -> 0 degrees: new face rotates into view
                    SequentialAnimation {
                        id: infoFlipAnim

                        NumberAnimation {
                            target: infoFlipRotation
                            property: "angle"
                            from: 0
                            to: 90
                            duration: 180
                            easing.type: Easing.InCubic
                        }

                        ScriptAction {
                            script: {
                                root.infoIndex = (root.infoIndex + 1) % 2
                            }
                        }

                        PropertyAction {
                            target: infoFlipRotation
                            property: "angle"
                            value: -90
                        }

                        NumberAnimation {
                            target: infoFlipRotation
                            property: "angle"
                            from: -90
                            to: 0
                            duration: 220
                            easing.type: Easing.OutCubic
                        }
                    }

                    // Clock mode: HH on top, MM on bottom
                    Column {
                        anchors.centerIn: parent
                        spacing: -3
                        visible: root.infoIndex === 0

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: root.clockHourText
                            color: root.colBlue

                            font.family: root.fontFamily
                            font.pixelSize: 14
                            font.bold: true

                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: root.clockMinuteText
                            color: root.colFg

                            font.family: root.fontFamily
                            font.pixelSize: 13
                            font.bold: true

                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    // Date mode: day / month / date
                    Column {
                        anchors.centerIn: parent
                        spacing: -2
                        visible: root.infoIndex === 1

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: root.dateDayText
                            color: root.colBlue

                            font.family: root.fontFamily
                            font.pixelSize: 8
                            font.bold: true

                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: root.dateMonthText
                            color: root.colFg

                            font.family: root.fontFamily
                            font.pixelSize: 12
                            font.bold: true

                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: root.dateDateText
                            color: root.colFg

                            font.family: root.fontFamily
                            font.pixelSize: 12
                            font.bold: true

                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    MouseArea {
                        id: rotatingInfoMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (!infoFlipAnim.running)
                                infoFlipAnim.start()
                        }
                    }
                }
                Rectangle {
                    id: quickStatusGroup

                    property bool active: root.activePanel === "connectivity" || root.activePanel === "wifiList" || root.activePanel === "battery"
                    property bool hovered: quickStatusMouse.containsMouse

                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 24
                    height: wifiCanvas.height + batteryMini.height + 18
                    radius: 10
                    scale: hovered ? 1.07 : 1.0

                    color: root.cardBg(active, hovered)
                    border.width: root.cardBorderWidth(active, hovered)
                    border.color: root.cardBorder(active, hovered)

                    Behavior on color { ColorAnimation { duration: 160 } }
                    Behavior on border.color { ColorAnimation { duration: 160 } }
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        Canvas {
                            id: wifiCanvas
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 14
                            height: 10

                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                var strength = root.wifiStrength
                                var arcs = 0
                                if (strength > 0) arcs = 1
                                if (strength >= 40) arcs = 2
                                if (strength >= 80) arcs = 3
                                var cx = width / 2
                                var cy = height - 1
                                ctx.lineWidth = 1.5
                                ctx.lineCap = "round"
                                for (var i = 1; i <= 3; i++) {
                                    ctx.beginPath()
                                    ctx.strokeStyle = i <= arcs ? root.colWhite : root.colMuted
                                    var radius = i * 2.8
                                    ctx.arc(cx, cy, radius, Math.PI * 1.20, Math.PI * 1.80)
                                    ctx.stroke()
                                }
                                ctx.beginPath()
                                ctx.fillStyle = arcs > 0 ? root.colWhite : root.colMuted
                                ctx.arc(cx, height - 1, 1.3, 0, Math.PI * 2)
                                ctx.fill()
                            }
                        }

                        Item {
                            id: batteryMini
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 12
                            height: 18

                            Rectangle {
                                id: miniBatteryOutline
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 10
                                height: 15
                                radius: 3
                                color: "transparent"
                                border.width: 1
                                border.color: root.batteryCharging ? "#50fa7b" : root.batteryPercent <= 20 ? "#ff5555" : root.colFg
                            }

                            Rectangle {
                                anchors.horizontalCenter: miniBatteryOutline.horizontalCenter
                                anchors.bottom: miniBatteryOutline.top
                                anchors.bottomMargin: -1
                                width: 4
                                height: 3
                                radius: 1
                                color: miniBatteryOutline.border.color
                            }

                            Rectangle {
                                id: miniBatteryFill
                                property real chargeAnim: 0.05
                                anchors.bottom: miniBatteryOutline.bottom
                                anchors.bottomMargin: 2
                                anchors.horizontalCenter: miniBatteryOutline.horizontalCenter
                                width: miniBatteryOutline.width - 4
                                height: Math.max(2, (miniBatteryOutline.height - 4) * (root.batteryCharging ? chargeAnim : root.batteryPercent / 100))
                                radius: 1.5
                                color: root.batteryCharging ? "#50fa7b" : root.batteryPercent > 40 ? "#50fa7b" : root.batteryPercent > 20 ? "#ffb86c" : "#ff5555"

                                NumberAnimation on chargeAnim {
                                    running: root.batteryCharging
                                    loops: Animation.Infinite
                                    from: Math.max(0.05, root.batteryPercent / 100)
                                    to: 1.0
                                    duration: 1200
                                    easing.type: Easing.InOutCubic
                                }

                                Behavior on height {
                                    enabled: !root.batteryCharging
                                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: quickStatusMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.activePanel = root.activePanel === "connectivity" ? "" : "connectivity"
                    }
                }
            }

            Column {
                id: batteryPanel
                width: root.activePanel === "battery" ? 210 : 0
                height: root.activePanel === "battery" ? sideColumn.implicitHeight : 0
                opacity: root.activePanel === "battery" ? 1 : 0
                clip: true
                spacing: 12

                Text { text: "Battery"; color: root.colBlue; font.family: root.fontFamily; font.pixelSize: 16; font.bold: true }

                Row {
                    spacing: 8

                    Item {
                        width: 80
                        height: 110

                        Rectangle {
                            id: batteryOutline
                            anchors.bottom: parent.bottom
                            width: 80
                            height: 100
                            radius: 10
                            border.width: 2
                            border.color: root.colFg
                            color: "transparent"
                        }

                        Rectangle {
                            anchors.horizontalCenter: batteryOutline.horizontalCenter
                            anchors.bottom: batteryOutline.top
                            anchors.bottomMargin: -2
                            width: 12
                            height: 5
                            radius: 2
                            color: root.colFg
                        }

                        Rectangle {
                            id: batteryFill
                            anchors.bottom: batteryOutline.bottom
                            anchors.horizontalCenter: batteryOutline.horizontalCenter
                            anchors.bottomMargin: 4
                            width: batteryOutline.width - 8
                            height: Math.max(8, (batteryOutline.height - 6) * root.batteryPercent / 100)
                            radius: 5
                            color: root.batteryCharging ? "#50fa7b" : root.batteryPercent > 40 ? "#50fa7b" : root.batteryPercent > 15 ? "#ffb86c" : "#ff5555"
                            Behavior on color { ColorAnimation { duration: 250 } }
                            Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                        }
                    }

                    Column {
                        width: 100
                        spacing: 8
                        Text { text: root.batteryPercent + "%"; color: root.colFg; font.family: root.fontFamily; font.pixelSize: 14; font.bold: true }
                        Text { text: root.batteryCharging ? "Charging" : "Discharging"; color: root.colFg; font.family: root.fontFamily; font.pixelSize: 12 }
                        Text { text: root.powerMode; color: root.powerColor; font.family: root.fontFamily; font.pixelSize: 12 }
                    }
                }
            }

            Column {
                id: connectivityPanel
                width: root.activePanel === "connectivity" ? 210 : 0
                height: root.activePanel === "connectivity" ? sideColumn.implicitHeight : 0
                opacity: root.activePanel === "connectivity" ? 1 : 0
                clip: true
                spacing: 12

                Text { text: "Quick Settings"; color: root.colBlue; font.family: root.fontFamily; font.pixelSize: 16; font.bold: true }

                Row {
                    spacing: 10

                    Rectangle {
                        id: connectivityBatteryCard

                        property bool active: root.activePanel === "battery"
                        property bool hovered: connectivityBatteryMouse.containsMouse

                        width: 90
                        height: 144
                        radius: 16

                        color: root.cardBg(active, hovered)
                        border.width: root.cardBorderWidth(active, hovered)
                        border.color: root.cardBorder(active, hovered)

                        scale: hovered ? 1.03 : 1.0

                        Behavior on color {
                            ColorAnimation { duration: 160 }
                        }

                        Behavior on border.color {
                            ColorAnimation { duration: 160 }
                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: 120
                                easing.type: Easing.OutCubic
                            }
                        }

                        Item {
                            anchors.fill: parent
                            anchors.margins: 10

                            Rectangle {
                                id: qsBatteryOutline
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width - 5
                                height: parent.height - 5
                                radius: 8
                                color: "transparent"
                                border.width: 2
                                border.color: root.batteryCharging ? "#50fa7b" : root.batteryPercent <= 20 ? "#ff5555" : root.colFg
                            }

                            Rectangle {
                                anchors.horizontalCenter: qsBatteryOutline.horizontalCenter
                                anchors.bottom: qsBatteryOutline.top
                                anchors.bottomMargin: -2
                                width: 12
                                height: 5
                                radius: 2
                                color: qsBatteryOutline.border.color
                            }

                            Rectangle {
                                id: qsBatteryFill
                                property real chargeAnim: 0.05
                                anchors.bottom: qsBatteryOutline.bottom
                                anchors.bottomMargin: 4
                                anchors.horizontalCenter: qsBatteryOutline.horizontalCenter
                                width: qsBatteryOutline.width - 8
                                height: Math.max(6, (qsBatteryOutline.height - 8) * (root.batteryCharging ? chargeAnim : root.batteryPercent / 100))
                                radius: 4
                                color: root.batteryCharging ? "#50fa7b" : root.batteryPercent > 40 ? "#50fa7b" : root.batteryPercent > 15 ? "#ffb86c" : "#ff5555"

                                NumberAnimation on chargeAnim {
                                    running: root.batteryCharging
                                    loops: Animation.Infinite
                                    from: Math.max(0.05, root.batteryPercent / 100)
                                    to: 1.0
                                    duration: 1200
                                    easing.type: Easing.InOutCubic
                                }

                                Behavior on height { enabled: !root.batteryCharging; NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                                Behavior on color { ColorAnimation { duration: 250 } }
                            }

                            Text {
                                z: 10
                                anchors.horizontalCenter: qsBatteryFill.horizontalCenter
                                y: qsBatteryFill.y + (qsBatteryFill.height / 2) - (height / 2)
                                text: root.batteryPercent + ""
                                color: root.batteryPercent > 40 ? root.colBg : "#000000"
                                font.family: root.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }

                        MouseArea {
                            id: connectivityBatteryMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: root.activePanel = "battery"
                        }
                    }

                    Column {
                        spacing: 10

                        Rectangle {
                            id: connectivityWifiCard

                            property bool active: root.activePanel === "wifiList"
                            property bool hovered: connectivityWifiMouse.containsMouse

                            width: 110
                            height: 67
                            radius: 16

                            color: root.cardBg(active, hovered)
                            border.width: root.cardBorderWidth(active, hovered)
                            border.color: root.cardBorder(active, hovered)

                            scale: hovered ? 1.03 : 1.0

                            Behavior on color {
                                ColorAnimation { duration: 160 }
                            }

                            Behavior on border.color {
                                ColorAnimation { duration: 160 }
                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 120
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 4
                                Text { text: "WiFi"; color: root.colFg; font.family: root.fontFamily; font.pixelSize: 13; font.bold: true }
                                Text {
                                    width: parent.width
                                    text: root.wifiConnected ? root.wifiSsid : "Disconnected"
                                    color: root.wifiConnected ? root.colBlue : root.colMuted
                                    font.family: root.fontFamily
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                id: connectivityWifiMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    wifiListProc.running = true
                                    root.activePanel = "wifiList"
                                }
                            }
                        }

                        Rectangle {
                            id: connectivityBluetoothCard

                            property bool hovered: connectivityBluetoothMouse.containsMouse

                            width: 110
                            height: 67
                            radius: 16

                            color: root.cardBg(false, hovered)
                            border.width: root.cardBorderWidth(false, hovered)
                            border.color: root.cardBorder(false, hovered)

                            scale: hovered ? 1.03 : 1.0

                            Behavior on color {
                                ColorAnimation { duration: 160 }
                            }

                            Behavior on border.color {
                                ColorAnimation { duration: 160 }
                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 120
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 4
                                Text { text: "Bluetooth"; color: root.colFg; font.family: root.fontFamily; font.pixelSize: 13; font.bold: true }
                                Text { text: root.bluetoothText; color: root.bluetoothPowered ? root.colBlue : root.colMuted; font.family: root.fontFamily; font.pixelSize: 10 }
                            }

                            MouseArea {
                                id: connectivityBluetoothMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: Hyprland.dispatch("exec blueman-manager")
                            }
                        }
                    }
                }
            }

            Column {
                id: mediaPanel

                width: root.activePanel === "media" && root.mediaStatus !== "Stopped" ? 210 : 0
                height: root.activePanel === "media" ? sideColumn.implicitHeight : 0
                opacity: root.activePanel === "media" && root.mediaStatus !== "Stopped" ? 1 : 0

                clip: true
                spacing: 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 180
                    }
                }

                Rectangle {
                    id: mediaPanelCard

                    width: 210
                    height: sideColumn.implicitHeight
                    radius: 18

                    clip: true
                    color: "#0b1238"

                    // Soft cover background fallback.
                    Image {
                        anchors.centerIn: parent

                        width: parent.width * 1.55
                        height: parent.height * 1.55

                        source: root.mediaArtUrl
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true

                        visible: root.mediaArtUrl !== ""
                        opacity: 0.20
                    }

                    // Strong dark overlay so controls/text stay readable.
                    Rectangle {
                        anchors.fill: parent
                        color: "#000000cc"
                    }

                    // Album art stays on top.
                    Rectangle {
                        id: albumArtCard

                        anchors {
                            top: parent.top
                            topMargin: 10
                            horizontalCenter: parent.horizontalCenter
                        }

                        width: 185
                        height: 105
                        radius: 16

                        color: "#0b1238"
                        border.width: 1
                        border.color: "#1f2a5a"
                        clip: true

                        Image {
                            anchors.fill: parent

                            source: root.mediaArtUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true

                            visible: root.mediaArtUrl !== ""
                        }

                        Text {
                            anchors.centerIn: parent

                            visible: root.mediaArtUrl === ""

                            text: root.mediaIcon
                            color: root.colBlue

                            font.family: root.fontFamily
                            font.pixelSize: 28
                            font.bold: true
                            renderType: Text.NativeRendering
                        }
                    }

                    Text {
                        id: mediaTitleText

                        anchors {
                            top: albumArtCard.bottom
                            topMargin: 9
                            horizontalCenter: parent.horizontalCenter
                        }

                        width: 186

                        text: root.mediaTitle
                        color: root.colFg

                        font.family: root.fontFamily
                        font.pixelSize: 11
                        font.bold: true

                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Text {
                        id: mediaArtistText

                        anchors {
                            top: mediaTitleText.bottom
                            topMargin: 4
                            horizontalCenter: parent.horizontalCenter
                        }

                        width: 186

                        text: root.mediaArtist !== "" ? root.mediaArtist : root.mediaStatus
                        color: root.colMuted

                        font.family: root.fontFamily
                        font.pixelSize: 9

                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    // Solid bottom control plate: timeline + buttons.
                    Rectangle {
                        id: mediaControlPlate

                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                            margins: 10
                        }

                        height: 86
                        radius: 16

                        color: "#050a2dee"
                        border.width: 1
                        border.color: "#1f2a5a"

                        Column {
                            anchors {
                                fill: parent
                                margins: 10
                            }

                            spacing: 6

                            Rectangle {
                                id: mediaProgressTrack

                                width: parent.width
                                height: 8
                                radius: 4

                                color: mediaSeekMouse.containsMouse
                                    ? "#26346c"
                                    : "#1f2a5a"

                                Behavior on color {
                                    ColorAnimation { duration: 160 }
                                }

                                Rectangle {
                                    id: mediaProgressFill

                                    height: parent.height
                                    radius: 4

                                    width: parent.width * root.mediaProgress
                                    color: root.colBlue

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 100
                                            easing.type: Easing.OutCubic
                                        }
                                    }
                                }

                                MouseArea {
                                    id: mediaSeekMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    preventStealing: true

                                    function seekFromX(xpos) {
                                        if (root.mediaLength <= 0)
                                            return

                                        var ratio = Math.max(0, Math.min(1, xpos / width))
                                        var seekTo = Math.round(root.mediaLength * ratio)

                                        // Update UI instantly.
                                        root.mediaPosition = seekTo
                                        root.mediaProgress = ratio

                                        // Run playerctl directly instead of going through Hyprland.dispatch.
                                        mediaSeekProc.running = false
                                        mediaSeekProc.seekTo = seekTo
                                        mediaSeekProc.running = true

                                        mediaRefreshDelay.restart()
                                    }

                                    onPressed: mouse => {
                                        seekFromX(mouse.x)
                                    }

                                    onPositionChanged: mouse => {
                                        if (pressed)
                                            seekFromX(mouse.x)
                                    }
                                }
                            }

                            Row {
                                width: parent.width

                                Text {
                                    width: parent.width / 2

                                    text: root.formatMediaTime(root.mediaPosition)
                                    color: root.colMuted

                                    font.family: root.fontFamily
                                    font.pixelSize: 8
                                }

                                Text {
                                    width: parent.width / 2
                                    horizontalAlignment: Text.AlignRight

                                    text: root.formatMediaTime(root.mediaLength)
                                    color: root.colMuted

                                    font.family: root.fontFamily
                                    font.pixelSize: 8
                                }
                            }

                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 14

                                Rectangle {
                                    width: 38
                                    height: 28
                                    radius: 10
                                    color: root.cardBg(false, previousMouse.containsMouse)
                                    border.width: root.cardBorderWidth(false, previousMouse.containsMouse)
                                    border.color: root.cardBorder(false, previousMouse.containsMouse)

                                    Text {
                                        anchors.centerIn: parent
                                        text: ""
                                        color: root.colFg
                                        font.family: root.fontFamily
                                        font.pixelSize: 16
                                        renderType: Text.NativeRendering
                                    }

                                    MouseArea {
                                        id: previousMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor

                                        onClicked: {
                                            mediaPreviousProc.running = false
                                            mediaPreviousProc.running = true
                                            mediaRefreshDelay.restart()
                                        }
                                    }
                                }

                                Rectangle {
                                    width: 44
                                    height: 30
                                    radius: 11
                                    color: root.cardBg(root.mediaStatus === "Playing", playPauseMouse.containsMouse)
                                    border.width: root.cardBorderWidth(root.mediaStatus === "Playing", playPauseMouse.containsMouse)
                                    border.color: root.cardBorder(root.mediaStatus === "Playing", playPauseMouse.containsMouse)

                                    Text {
                                        anchors.centerIn: parent
                                        text: root.mediaIcon
                                        color: root.colBlue
                                        font.family: root.fontFamily
                                        font.pixelSize: 18
                                        font.bold: true
                                        renderType: Text.NativeRendering
                                    }

                                    MouseArea {
                                        id: playPauseMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor

                                        onClicked: {
                                            mediaPlayPauseProc.running = false
                                            mediaPlayPauseProc.running = true
                                            mediaRefreshDelay.restart()
                                        }
                                    }
                                }

                                Rectangle {
                                    width: 38
                                    height: 28
                                    radius: 10
                                    color: root.cardBg(false, nextMouse.containsMouse)
                                    border.width: root.cardBorderWidth(false, nextMouse.containsMouse)
                                    border.color: root.cardBorder(false, nextMouse.containsMouse)

                                    Text {
                                        anchors.centerIn: parent
                                        text: ""
                                        color: root.colFg
                                        font.family: root.fontFamily
                                        font.pixelSize: 16
                                        renderType: Text.NativeRendering
                                    }

                                    MouseArea {
                                        id: nextMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor

                                        onClicked: {
                                            mediaNextProc.running = false
                                            mediaNextProc.running = true
                                            mediaRefreshDelay.restart()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Column {
                id: wifiListPanel
                width: root.activePanel === "wifiList" ? 210 : 0
                height: root.activePanel === "wifiList" ? sideColumn.implicitHeight : 0
                opacity: root.activePanel === "wifiList" ? 1 : 0
                clip: true
                spacing: 10

                Text { text: "WiFi Networks"; color: root.colBlue; font.family: root.fontFamily; font.pixelSize: 16; font.bold: true }
                Text { text: "Connected: " + root.wifiSsid; color: root.colFg; font.family: root.fontFamily; font.pixelSize: 11 }

                Flickable {
                    width: 190
                    height: Math.max(120, sideColumn.implicitHeight - 55)
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    contentWidth: width
                    contentHeight: wifiListColumn.implicitHeight

                    Column {
                        id: wifiListColumn
                        width: parent.width
                        spacing: 6

                        Repeater {
                            model: root.wifiNetworks

                            Rectangle {
                                property var parts: modelData.split(":")
                                property string ssid: parts[0] || "Hidden"
                                property string signal: parts[1] || "0"

                                property bool active: ssid === root.wifiSsid
                                property bool hovered: wifiNetworkMouse.containsMouse

                                width: 190
                                height: 30
                                radius: 10

                                color: root.cardBg(active, hovered)
                                border.width: root.cardBorderWidth(active, hovered)
                                border.color: root.cardBorder(active, hovered)

                                Behavior on color {
                                    ColorAnimation { duration: 160 }
                                }

                                Behavior on border.color {
                                    ColorAnimation { duration: 160 }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: ssid + "  " + signal + "%"
                                    color: root.colFg
                                    font.family: root.fontFamily
                                    font.pixelSize: 10
                                }

                                MouseArea {
                                    id: wifiNetworkMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: Hyprland.dispatch("exec nmcli dev wifi connect '" + ssid + "'")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
