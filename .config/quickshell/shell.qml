import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import Quickshell.Services.SystemTray

PanelWindow {
    id: root
    mask: Region {
        item: sideBg
    }
    property color colBg: "#050a2d"
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

    property int batteryPercent: 0
    property bool batteryCharging: false
    property string batteryIcon: "󰁹"
    
    property int wifiStrength: 0
    property bool wifiConnected: false
    
    property bool bluetoothPowered: false
    property real chargingAnimation: 0
    anchors {
        left: true
        top: true
        bottom: true
    }

    width: 500
    exclusiveZone: 50
    color: "transparent"

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
        command: ["sh", "-c", "playerctl status 2>/dev/null || echo Stopped"]

        stdout: SplitParser {
            onRead: data => {
                var status = data.trim()
                root.mediaStatus = status

                if (status === "Playing")
                    root.mediaIcon = ""
                else if (status === "Paused")
                    root.mediaIcon = ""
                else
                    root.mediaIcon = ""
                    // root.mediaPopupOpen = false
            }
        }

        Component.onCompleted: running = true
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
        command: ["sh", "-c", "nmcli -t -f IN-USE,SIGNAL dev wifi | grep '^*' | cut -d: -f2 || echo 0"]

        stdout: SplitParser {
            onRead: data => {
                root.wifiStrength = parseInt(data.trim()) || 0
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
            }
        }

        Component.onCompleted: running = true
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
        height: Math.max(sideColumn.implicitHeight, mediaPanel.implicitHeight) + 20
        radius: 18
        color: root.colBg
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: 250  // this for side panel animation speed
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

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.powerIcon
                    color: root.powerColor

                    font.family: root.fontFamily
                    font.pixelSize: 16
                    font.bold: true
                    renderType: Text.NativeRendering

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            powerToggleProc.running = true
                            powerProc.running = true
                        }
                    }
                }

                Repeater {
                    model: 3

                    Rectangle {
                        property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                        property bool isActive: Hyprland.focusedWorkspace?.id === index + 1

                        anchors.horizontalCenter: parent.horizontalCenter

                        width: 11
                        height: isActive ? 40 : 20
                        radius: 20
                        color: isActive ? "#3E4278" : "#27272c"

                        Behavior on height {
                            NumberAnimation {
                                duration: 180
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on color {
                            ColorAnimation{
                                duration: 180
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Hyprland.dispatch("workspace " + (index + 1))
                        }
                    }
                }
                Item{
                    width: 1
                    height: 1
                }
                Text {
                    id: media
                    visible: root.mediaStatus !== "Stopped"
                    height: visible ? implicitHeight : 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.mediaIcon
                    color: root.colFg

                    font.family: root.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    renderType: Text.NativeRendering

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            mediaProc.running = true
                            root.activePanel =
                                root.activePanel === "media"
                                ? ""
                                : "media"
                        }
                    }
                }
                Item{
                    width: 1
                    height: 1
                }
// quick wifi and battery module
         Rectangle {
                id: quickStatusGroup

                anchors.horizontalCenter: parent.horizontalCenter

                width: 24
                height: wifiCanvas.height + batteryMini.height + 18
                radius: 10

                color: "#0b1238"
                border.width: 1
                border.color: "#2b3870"

                Column {
                    anchors.centerIn: parent
                    spacing: 6
// wifi canvas
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
                            ctx.arc(
                                cx,
                                cy,
                                radius,
                                Math.PI * 1.20,
                                Math.PI * 1.80
                            )

                            ctx.stroke()
                        }

                        // dot
                        ctx.beginPath()
                        ctx.fillStyle = arcs > 0 ? root.colWhite : root.colMuted
                        ctx.arc(cx, height - 1, 1.3, 0, Math.PI * 2)
                        ctx.fill()
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.activePanel =
                                root.activePanel === "connectivity"
                                ? ""
                                : "connectivity"
                        }
                    }
                }
// mini battery symbol
                Item {
                        id: batteryMini

                        anchors.horizontalCenter: parent.horizontalCenter

                        width: 12
                        height: 18

                        // Battery outline
                        Rectangle {
                            id: miniBatteryOutline

                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter

                            width: 10
                            height: 15
                            radius: 3

                            color: "transparent"
                            border.width: 1
                            border.color: root.batteryCharging
                                ? "#50fa7b"
                                : root.batteryPercent <= 20
                                    ? "#ff5555"
                                    : root.colFg
                        }

                        // Battery nub
                        Rectangle {
                            anchors.horizontalCenter: miniBatteryOutline.horizontalCenter
                            anchors.bottom: miniBatteryOutline.top
                            anchors.bottomMargin: -1

                            width: 4
                            height: 3
                            radius: 1

                            color: miniBatteryOutline.border.color
                        }

                        // Battery fill
                        Rectangle {
                            id: miniBatteryFill

                            property real chargeAnim: 0.05

                            anchors.bottom: miniBatteryOutline.bottom
                            anchors.bottomMargin: 2
                            anchors.horizontalCenter: miniBatteryOutline.horizontalCenter

                            width: miniBatteryOutline.width - 4

                            height: Math.max(
                                2,
                                (miniBatteryOutline.height - 4) *
                                (root.batteryCharging ? chargeAnim : root.batteryPercent / 100)
                            )

                            radius: 1.5

                            color: root.batteryCharging
                                ? "#50fa7b"
                                : root.batteryPercent > 40
                                    ? "#50fa7b"
                                    : root.batteryPercent > 20
                                        ? "#ffb86c"
                                        : "#ff5555"

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
                                NumberAnimation {
                                    duration: 250
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                        Rectangle {
                            visible: root.batteryCharging

                            anchors.bottom: miniBatteryOutline.bottom
                            anchors.horizontalCenter: miniBatteryOutline.horizontalCenter

                            width: miniBatteryOutline.width - 4

                            height:
                                (miniBatteryOutline.height - 4)
                                * root.chargingAnimation

                            color: "#ffffff"
                        }

                            MouseArea {
                                anchors.fill: parent

                            onClicked: {
                                root.activePanel =
                                    root.activePanel === "battery"
                                    ? ""
                                    : "battery"
                            }
                        }
                    }    
            }

            MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.activePanel =
                                    root.activePanel === "connectivity"
                                    ? ""
                                    : "connectivity"
                            }
                        }
                    }                
}
            Column {
                    id: batteryPanel

                    width: root.activePanel === "battery" ? 210 : 0
                    opacity: root.activePanel === "battery" ? 1 : 0

                    clip: true
                    spacing: 12

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 500
                        }
                    }

                    Text {
                        text: "Battery"
                        color: root.colBlue
                    }

                    Row {
                        spacing: 1

                        // Battery body
                        Item {
                            width: 80
                            height: 110

                            // Battery outline
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

                            // Battery tip
                            Rectangle {
                                anchors.horizontalCenter: batteryOutline.horizontalCenter
                                anchors.bottom: batteryOutline.top
                                anchors.bottomMargin: -2

                                width: 12
                                height: 5
                                radius: 2

                                color: root.colFg
                            }

                            // Battery fill
                            Rectangle {
                                Text {
                                    anchors.centerIn: parent
                                    text: root.batteryPercent + ""
                                    color: transparent
                                    font.bold: true
                                }
                                id: batteryFill

                                anchors.bottom: batteryOutline.bottom
                                anchors.horizontalCenter: batteryOutline.horizontalCenter
                                anchors.bottomMargin: 4
                                width: batteryOutline.width - 8
                                height: Math.max(
                                    8,
                                    (batteryOutline.height - 6) * root.batteryPercent / 100
                                )

                                radius: 5
                                color: root.batteryCharging     ? "#50fa7b":
                                    root.batteryPercent > 40 ? "#50fa7b" :
                                    root.batteryPercent > 15 ? "#ffb86c" :
                                    "#ff5555"
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 250
                                    }
                                }
                                Behavior on height {
                                    NumberAnimation {
                                        duration: 300
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }
                        }

                        // Battery information
                        Column {
                            width: 100
                            spacing: 8

                            Text {
                                text: root.batteryPercent + "%"
                                color: root.colFg
                                font.bold: true
                            }

                            Text {
                                text: root.batteryCharging
                                    ? "Charging"
                                    : "Discharging"

                                color: root.colFg
                            }

                            Text {
                                text: root.powerMode
                                color: root.powerColor
                            }
                        }
                    }

                }
                
            Column {
                id: mediaPanel

                width: root.activePanel === "media" && root.mediaStatus !== "Stopped" ? 210 : 0
                opacity: root.activePanel === "media" && root.mediaStatus !== "Stopped" ? 1 : 0

                clip: true
                spacing: 12

                Behavior on opacity {
                    NumberAnimation {
                        duration: 180
                    }
                }
                            Text {
                    text: "Media"
                    color: root.colBlue
                    font.family: root.fontFamily
                    font.pixelSize: 16
                    font.bold: true
                }

                Text {
                    text: root.mediaStatus
                    color: root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: 13
                    font.bold: true
                }

                Row {
                    spacing: 20

                    Text {
                        text: ""
                        color: root.colBlue
                        font.family: root.fontFamily
                        font.pixelSize: 20
                        renderType: Text.NativeRendering

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Hyprland.dispatch("exec playerctl previous")
                        }
                    }

                    Text {
                        text: root.mediaIcon
                        color: root.colBlue
                        font.family: root.fontFamily
                        font.pixelSize: 22
                        renderType: Text.NativeRendering

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                Hyprland.dispatch("exec playerctl play-pause")
                                mediaProc.running = true
                            }
                        }
                    }

                    Text {
                        text: ""
                        color: root.colBlue
                        font.family: root.fontFamily
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
}