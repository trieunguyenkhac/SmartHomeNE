import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: deviceControlView

    readonly property color cBg:      "#F2F5FA"
    readonly property color cPanel:   "#FFFFFF"
    readonly property color cPrimary: "#1A73E8"
    readonly property color cGreen:   "#34C759"
    readonly property color cRed:     "#FF3B30"
    readonly property color cOrange:  "#FF9500"
    readonly property color cText:    "#1C1C1E"
    readonly property color cSub:     "#8E8E93"
    readonly property color cBlue:    "#007AFF"

    readonly property var roomNames:  ["Phòng khách","Phòng ngủ","Bếp","Phòng giặt","Phòng tắm"]
    readonly property var roomIcons:  ["🛋️","🛏️","🍳","🧺","🚿"]
    readonly property var roomDevCnt: [5, 3, 4, 2, 2]
    readonly property var roomEnergy: [7.2, 4.1, 3.6, 2.2, 1.6]

    property int viewState: 0
    property int selectedRoom: 0
    property string selectedDevice: ""
    property bool selectedDeviceIsOn: true
    property string selectedDeviceType: "ac"
    property real selectedTargetTemp: 24.0
    property int selectedFanSpeed: 3
    property string selectedMode: "cool"

    function goRoomList()   { viewState = 0 }
    function goDeviceList(roomIdx) { selectedRoom = roomIdx; viewState = 1; loadDevices() }
    function goDeviceDetail(devName, devType, isOn) {
        selectedDevice = devName
        selectedDeviceType = devType
        selectedDeviceIsOn = isOn
        viewState = 2
    }
    function goAddDevice()  { viewState = 3 }

    function loadDevices() {
        deviceModel.clear()
        var list = backend.getDevices(selectedRoom)
        for (var i = 0; i < list.length; i++) deviceModel.append(list[i])
    }

    Connections {
        target: backend
        function onDeviceListChanged() { if (viewState === 1) loadDevices() }
    }

    Rectangle { anchors.fill: parent; color: cBg }

    // Màn danh sách phòng
    Item {
        anchors.fill: parent
        visible: viewState === 0

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true; height: 56; color: cPanel
                RowLayout {
                    anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                    Text { text: "Phòng"; font.pixelSize: 18; font.bold: true; color: cText; Layout.fillWidth: true }
                    Rectangle {
                        width: 32; height: 32; radius: 16; color: cPrimary
                        Text { anchors.centerIn: parent; text: "+"; font.pixelSize: 20; font.bold: true; color: "white" }
                        MouseArea { anchors.fill: parent; onClicked: goAddDevice() }
                    }
                }
            }

            ListView {
                Layout.fillWidth: true; Layout.fillHeight: true
                clip: true; topMargin: 12; bottomMargin: 12; spacing: 10
                model: 5
                delegate: Rectangle {
                    width: ListView.view.width - 24; x: 12
                    height: 72; radius: 14; color: cPanel

                    RowLayout {
                        anchors { fill: parent; margins: 14 }
                        spacing: 14

                        Rectangle {
                            width: 44; height: 44; radius: 12
                            color: ["#EBF2FF","#EDF7EE","#FFF4E5","#F3EBFF","#E5F6FF"][index]
                            Text { anchors.centerIn: parent; text: roomIcons[index]; font.pixelSize: 22 }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true; spacing: 3
                            Text { text: roomNames[index]; font.pixelSize: 15; font.bold: true; color: cText }
                            Text { text: roomDevCnt[index] + " thiết bị"; font.pixelSize: 12; color: cSub }
                        }

                        Text {
                            text: roomEnergy[index] + " kWh"
                            font.pixelSize: 13; font.bold: true; color: cBlue
                        }

                        Text { text: "›"; font.pixelSize: 18; color: cSub }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (index < 3) goDeviceList(index)
                            else { selectedRoom = index; deviceModel.clear(); viewState = 1 }
                        }
                    }
                }
            }
        }
    }

    // Màn danh sách thiết bị
    Item {
        anchors.fill: parent
        visible: viewState === 1

        ColumnLayout {
            anchors.fill: parent; spacing: 0

            Rectangle {
                Layout.fillWidth: true; height: 56; color: cPanel
                RowLayout {
                    anchors { fill: parent; leftMargin: 12; rightMargin: 16 }
                    spacing: 8
                    Rectangle {
                        width: 36; height: 36; radius: 18; color: "#F2F5FA"
                        Text { anchors.centerIn: parent; text: "←"; font.pixelSize: 18; color: cBlue }
                        MouseArea { anchors.fill: parent; onClicked: goRoomList() }
                    }
                    Text { text: roomNames[selectedRoom]; font.pixelSize: 17; font.bold: true; color: cText; Layout.fillWidth: true }
                    Rectangle {
                        width: 32; height: 32; radius: 16; color: cPrimary
                        Text { anchors.centerIn: parent; text: "+"; font.pixelSize: 20; font.bold: true; color: "white" }
                        MouseArea { anchors.fill: parent; onClicked: goAddDevice() }
                    }
                }
            }

            ListView {
                id: deviceListView
                Layout.fillWidth: true; Layout.fillHeight: true
                clip: true; topMargin: 12; bottomMargin: 12; spacing: 10
                model: ListModel { id: deviceModel }

                delegate: Rectangle {
                    width: deviceListView.width - 24; x: 12
                    height: model.type === "ac" ? 138 : 78
                    radius: 14; color: cPanel

                    ColumnLayout {
                        anchors { fill: parent; margins: 14 }
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true; spacing: 12

                            Rectangle {
                                width: 40; height: 40; radius: 20
                                color: model.isOn ? "#EBF2FF" : "#F2F5FA"
                                Text {
                                    anchors.centerIn: parent
                                    text: model.type === "ac" ? "❄️" : (model.type === "fan" ? "🌀" : (model.type === "light" ? "💡" : "📺"))
                                    font.pixelSize: 20
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 2
                                Text { text: model.name; font.pixelSize: 14; font.bold: true; color: cText }
                                Text {
                                    text: model.wattHour + " W" + (model.type === "ac" ? "  Nhiệt độ: " + selectedTargetTemp.toFixed(0) + "°C" : "")
                                    font.pixelSize: 11; color: cSub
                                }
                            }

                            Switch {
                                checked: model.isOn
                                onToggled: {
                                    backend.toggleDevice(model.name)
                                    if (model.type === "ac") selectedDeviceIsOn = !model.isOn
                                }
                            }
                        }

                        ColumnLayout {
                            visible: model.type === "light"
                            Layout.fillWidth: true; spacing: 2
                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: "Độ sáng: 80%"; font.pixelSize: 11; color: cSub; Layout.fillWidth: true }
                            }
                            Slider { Layout.fillWidth: true; from: 0; to: 100; value: 80; enabled: model.isOn }
                        }

                        ColumnLayout {
                            visible: model.type === "fan"
                            Layout.fillWidth: true; spacing: 2
                            Text { text: "Tốc độ: 3"; font.pixelSize: 11; color: cSub }
                            Slider { Layout.fillWidth: true; from: 1; to: 5; stepSize: 1; value: 3; enabled: model.isOn }
                        }

                        RowLayout {
                            visible: model.type === "ac"
                            Layout.fillWidth: true; spacing: 8
                            Text { text: "Nhiệt độ: 24°C"; font.pixelSize: 11; color: cSub; Layout.fillWidth: true }
                            Text { text: "Chế độ: Làm mát ❄️"; font.pixelSize: 11; color: cBlue }
                            Text {
                                text: "Chi tiết ›"; font.pixelSize: 11; color: cBlue
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: goDeviceDetail(model.name, model.type, model.isOn)
                                }
                            }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "Không có thiết bị"
                    font.pixelSize: 14; color: cSub
                    visible: deviceModel.count === 0
                }
            }
        }
    }

    // Màn chi tiết điều hòa
    Item {
        anchors.fill: parent
        visible: viewState === 2

        ColumnLayout {
            anchors.fill: parent; spacing: 0

            Rectangle {
                Layout.fillWidth: true; height: 56; color: cPanel
                RowLayout {
                    anchors { fill: parent; leftMargin: 12; rightMargin: 16 }
                    spacing: 8
                    Rectangle {
                        width: 36; height: 36; radius: 18; color: "#F2F5FA"
                        Text { anchors.centerIn: parent; text: "←"; font.pixelSize: 18; color: cBlue }
                        MouseArea { anchors.fill: parent; onClicked: viewState = 1 }
                    }
                    Text { text: selectedDevice; font.pixelSize: 17; font.bold: true; color: cText; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter }
                    Rectangle {
                        width: 36; height: 36; radius: 18; color: "#F2F5FA"
                        Text { anchors.centerIn: parent; text: "⚙"; font.pixelSize: 18; color: cSub }
                    }
                }
            }

            Flickable {
                Layout.fillWidth: true; Layout.fillHeight: true
                contentHeight: detailCol.implicitHeight + 24; clip: true

                ColumnLayout {
                    id: detailCol
                    width: parent.width; spacing: 0

                    Rectangle {
                        Layout.fillWidth: true; Layout.margins: 16
                        height: 120; radius: 16; color: "#F8FAFB"
                        border.color: "#E5E9EF"; border.width: 1
                        Rectangle {
                            anchors.centerIn: parent
                            width: 200; height: 60; radius: 12; color: "#E8EDF2"
                            Rectangle {
                                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 6 }
                                height: 8; radius: 4; color: "#C8D0DA"
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true; Layout.leftMargin: 16; Layout.rightMargin: 16
                        Layout.bottomMargin: 12
                        height: 120; radius: 16; color: cPanel

                        ColumnLayout {
                            anchors.centerIn: parent; spacing: 4

                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter; spacing: 24

                                Rectangle {
                                    width: 44; height: 44; radius: 22
                                    color: "#F2F5FA"; border.color: "#DDE1E8"; border.width: 1
                                    Text { anchors.centerIn: parent; text: "−"; font.pixelSize: 24; font.bold: true; color: cText }
                                    MouseArea { anchors.fill: parent; onClicked: if (selectedTargetTemp > 16) selectedTargetTemp -= 1 }
                                }

                                Row {
                                    spacing: 2
                                    Text { text: selectedTargetTemp.toFixed(0); font.pixelSize: 48; font.bold: true; color: cText; baselineOffset: 0 }
                                    Text { text: "°C"; font.pixelSize: 20; font.bold: true; color: cSub; topPadding: 8 }
                                }

                                Rectangle {
                                    width: 44; height: 44; radius: 22
                                    color: "#F2F5FA"; border.color: "#DDE1E8"; border.width: 1
                                    Text { anchors.centerIn: parent; text: "+"; font.pixelSize: 24; font.bold: true; color: cText }
                                    MouseArea { anchors.fill: parent; onClicked: if (selectedTargetTemp < 30) selectedTargetTemp += 1 }
                                }
                            }

                            Text { Layout.alignment: Qt.AlignHCenter; text: "Nhiệt độ hiện tại: 27°C"; font.pixelSize: 12; color: cSub }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true; Layout.leftMargin: 16; Layout.rightMargin: 16
                        Layout.bottomMargin: 12
                        height: modeCol.implicitHeight + 24; radius: 16; color: cPanel

                        ColumnLayout {
                            id: modeCol
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
                            spacing: 12

                            Text { text: "Chế độ"; font.pixelSize: 14; font.bold: true; color: cText }

                            RowLayout {
                                Layout.fillWidth: true; spacing: 10

                                Repeater {
                                    model: [
                                        { icon: "❄️", label: "Làm mát", key: "cool" },
                                        { icon: "🔥", label: "Sưởi ấm", key: "heat" },
                                        { icon: "🌀", label: "Quạt", key: "fan" },
                                        { icon: "🤖", label: "Tự động", key: "auto" },
                                        { icon: "💧", label: "Khử ẩm", key: "dry" }
                                    ]
                                    delegate: Rectangle {
                                        Layout.fillWidth: true; height: 64; radius: 12
                                        color: selectedMode === modelData.key ? cPrimary : "#F2F5FA"
                                        ColumnLayout {
                                            anchors.centerIn: parent; spacing: 4
                                            Text { Layout.alignment: Qt.AlignHCenter; text: modelData.icon; font.pixelSize: 20 }
                                            Text {
                                                Layout.alignment: Qt.AlignHCenter
                                                text: modelData.label; font.pixelSize: 9
                                                color: selectedMode === modelData.key ? "white" : cSub
                                            }
                                        }
                                        MouseArea { anchors.fill: parent; onClicked: selectedMode = modelData.key }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true; Layout.leftMargin: 16; Layout.rightMargin: 16
                        Layout.bottomMargin: 12
                        height: fanCol.implicitHeight + 24; radius: 16; color: cPanel

                        ColumnLayout {
                            id: fanCol
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
                            spacing: 12

                            Text { text: "Tốc độ quạt"; font.pixelSize: 14; font.bold: true; color: cText }

                            RowLayout {
                                Layout.fillWidth: true; spacing: 8

                                Repeater {
                                    model: ["Tự động","1","2","3","4","5"]
                                    delegate: Rectangle {
                                        Layout.fillWidth: true; height: 36; radius: 18
                                        color: (index === selectedFanSpeed) ? cPrimary : "#F2F5FA"
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData; font.pixelSize: 12; font.bold: index === selectedFanSpeed
                                            color: index === selectedFanSpeed ? "white" : cSub
                                        }
                                        MouseArea { anchors.fill: parent; onClicked: selectedFanSpeed = index }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true; Layout.leftMargin: 16; Layout.rightMargin: 16
                        Layout.bottomMargin: 12
                        height: infoCol.implicitHeight + 24; radius: 16; color: cPanel

                        ColumnLayout {
                            id: infoCol
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
                            spacing: 0

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: "Hẹn giờ"; font.pixelSize: 14; color: cText; Layout.fillWidth: true }
                                Text { text: "2 giờ  ›"; font.pixelSize: 13; color: cBlue }
                            }
                            Rectangle { Layout.fillWidth: true; height: 1; color: "#EEF0F4"; Layout.topMargin: 10; Layout.bottomMargin: 10 }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: "Tiêu thụ điện"; font.pixelSize: 14; color: cText; Layout.fillWidth: true }
                                Text { text: "0.9 kWh (hôm nay)  ›"; font.pixelSize: 13; color: cBlue }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true; Layout.leftMargin: 16; Layout.rightMargin: 16
                        Layout.bottomMargin: 24
                        height: 52; radius: 14
                        color: selectedDeviceIsOn ? "#FFF0EE" : "#EBF2FF"
                        border.color: selectedDeviceIsOn ? cRed : cBlue; border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: selectedDeviceIsOn ? "Tắt thiết bị" : "Bật thiết bị"
                            font.pixelSize: 16; font.bold: true
                            color: selectedDeviceIsOn ? cRed : cBlue
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                backend.toggleDevice(selectedDevice)
                                selectedDeviceIsOn = !selectedDeviceIsOn
                            }
                        }
                    }
                }
            }
        }
    }

    // Màn thêm thiết bị — scan + add to room
    Item {
        anchors.fill: parent
        visible: viewState === 3

        // State: 0 = scanning, 1 = found
        property int scanState: 0
        property int scanProgress: 0   // 0-100

        // Danh sách thiết bị mô phỏng tìm thấy
        ListModel {
            id: foundModel
        }

        // Timer mô phỏng quét
        Timer {
            id: scanTimer
            interval: 60; repeat: true; running: viewState === 3
            property int tick: 0
            // Thiết bị xuất hiện tại tick 20, 50, 75
            property var devices: [
                { icon: "❄️", name: "Điều hòa Daikin",      watt: 950, type: "ac"    },
                { icon: "📺", name: "Tivi LG 55\"",          watt: 130, type: "tv"    },
                { icon: "💡", name: "Đèn Philips Hue",       watt: 12,  type: "light" },
                { icon: "🌀", name: "Quạt Panasonic",        watt: 55,  type: "fan"   },
                { icon: "🧊", name: "Tủ lạnh Samsung",        watt: 150, type: "tv"    },
                { icon: "💡", name: "Đèn LED phòng ngủ",     watt: 9,   type: "light" },
                { icon: "🔌", name: "Ổ cắm thông minh Xiaomi", watt: 5,  type: "light" },
                { icon: "📷", name: "Camera an ninh Ezviz",   watt: 8,  type: "light" }
            ]
            property int nextDevice: 0
            onTriggered: {
                tick = Math.min(tick + 1, 100)
                parent.scanProgress = tick
                // Chia đều việc reveal thiết bị trong khoảng 15%-92% tiến trình quét
                var startPct = 15
                var endPct = 92
                var step = (endPct - startPct) / devices.length
                while (nextDevice < devices.length && tick >= startPct + step * nextDevice) {
                    foundModel.append(devices[nextDevice])
                    nextDevice++
                }
                if (tick >= 100) { parent.scanState = 1; stop() }
            }
            onRunningChanged: {
                if (running) { tick = 0; nextDevice = 0; foundModel.clear(); parent.scanState = 0; parent.scanProgress = 0 }
            }
        }

        ColumnLayout {
            anchors.fill: parent; spacing: 0

            // Header
            Rectangle {
                Layout.fillWidth: true; height: 56; color: cPanel
                RowLayout {
                    anchors { fill: parent; leftMargin: 12; rightMargin: 16 }
                    spacing: 8
                    Rectangle {
                        width: 36; height: 36; radius: 18; color: "#F2F5FA"
                        Text { anchors.centerIn: parent; text: "←"; font.pixelSize: 18; color: cBlue }
                        MouseArea { anchors.fill: parent; onClicked: viewState = 0 }
                    }
                    Text {
                        text: parent.parent.parent.scanState === 0 ? "Đang quét..." : "Thiết bị tìm thấy"
                        font.pixelSize: 17; font.bold: true; color: cText
                        Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter
                    }
                    Item { width: 36 }
                }
            }

            Flickable {
                Layout.fillWidth: true; Layout.fillHeight: true
                contentHeight: scanCol.implicitHeight + 32; clip: true

                ColumnLayout {
                    id: scanCol
                    width: parent.width; spacing: 0

                    // ── Radar animation area ──
                    Item {
                        Layout.fillWidth: true
                        height: 220

                        // Outer pulse rings
                        Repeater {
                            model: 3
                            delegate: Rectangle {
                                property real baseSize: 80 + index * 46
                                width: baseSize; height: baseSize; radius: baseSize / 2
                                anchors.centerIn: parent
                                color: "transparent"
                                border.color: cPrimary
                                border.width: 1.5
                                opacity: 0

                                SequentialAnimation on opacity {
                                    running: viewState === 3
                                    loops: Animation.Infinite
                                    PauseAnimation  { duration: index * 600 }
                                    NumberAnimation { from: 0; to: 0.55; duration: 400 }
                                    NumberAnimation { from: 0.55; to: 0; duration: 900 }
                                }

                                SequentialAnimation on scale {
                                    running: viewState === 3
                                    loops: Animation.Infinite
                                    PauseAnimation  { duration: index * 600 }
                                    NumberAnimation { from: 0.85; to: 1.28; duration: 1300; easing.type: Easing.OutCubic }
                                }
                            }
                        }

                        // Rotating sweep line
                        Item {
                            anchors.centerIn: parent
                            width: 2; height: 80
                            transformOrigin: Item.Bottom
                            Rectangle {
                                anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                                width: 2; height: 80; radius: 1
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "transparent" }
                                    GradientStop { position: 1.0; color: cPrimary }
                                }
                            }
                            RotationAnimation on rotation {
                                from: 0; to: 360; duration: 2200
                                loops: Animation.Infinite; running: viewState === 3 && parent.parent.parent.parent.scanState === 0
                            }
                        }

                        // Center circle
                        Rectangle {
                            anchors.centerIn: parent
                            width: 64; height: 64; radius: 32
                            color: cPrimary
                            Text { anchors.centerIn: parent; text: "📡"; font.pixelSize: 26 }

                            // Heartbeat scale
                            SequentialAnimation on scale {
                                running: viewState === 3 && parent.parent.parent.scanState === 0
                                loops: Animation.Infinite
                                NumberAnimation { to: 1.12; duration: 400; easing.type: Easing.OutQuad }
                                NumberAnimation { to: 1.0;  duration: 400; easing.type: Easing.InQuad }
                            }
                        }

                        // Progress bar + label
                        ColumnLayout {
                            anchors { bottom: parent.bottom; left: parent.left; right: parent.right; bottomMargin: 10; leftMargin: 32; rightMargin: 32 }
                            spacing: 6

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: parent.parent.parent.parent.parent.scanState === 0
                                      ? "Đang dò tìm thiết bị trong mạng...  " + parent.parent.parent.parent.parent.scanProgress + "%"
                                      : "✅  Hoàn tất — " + foundModel.count + " thiết bị tìm thấy"
                                font.pixelSize: 12; color: cSub
                            }

                            Rectangle {
                                Layout.fillWidth: true; height: 5; radius: 3; color: "#E5EAF3"
                                Rectangle {
                                    width: parent.width * parent.parent.parent.parent.parent.parent.scanProgress / 100
                                    height: 5; radius: 3; color: cPrimary
                                    Behavior on width { NumberAnimation { duration: 120 } }
                                }
                            }
                        }
                    }

                    // ── Thiết bị tìm thấy ──
                    Rectangle {
                        id: addDeviceView
                        property alias foundRepeater: foundRepeaterInst
                        Layout.fillWidth: true; Layout.leftMargin: 16; Layout.rightMargin: 16
                        Layout.bottomMargin: 16
                        height: Math.max(72, foundListCol.implicitHeight + 24)
                        radius: 14; color: cPanel
                        visible: foundModel.count > 0

                        ColumnLayout {
                            id: foundListCol
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
                            spacing: 0

                            Text {
                                text: "Thiết bị tìm thấy (" + foundModel.count + ")"
                                font.pixelSize: 13; font.bold: true; color: cSub; bottomPadding: 6
                            }

                            Repeater {
                                id: foundRepeaterInst
                                model: foundModel
                                delegate: Rectangle {
                                    Layout.fillWidth: true; height: 62
                                    color: "transparent"
                                    opacity: 0

                                    // Slide-in + fade-in when item appears
                                    NumberAnimation on opacity { from: 0; to: 1; duration: 450; running: true; easing.type: Easing.OutCubic }
                                    NumberAnimation on anchors.leftMargin { from: 24; to: 0; duration: 450; running: true; easing.type: Easing.OutCubic }

                                    // Added indicator
                                    property bool added: false

                                    RowLayout {
                                        anchors { fill: parent; leftMargin: 4; rightMargin: 4 }
                                        spacing: 12

                                        Rectangle {
                                            width: 38; height: 38; radius: 19
                                            color: added ? "#E9F9EF" : "#F2F5FA"
                                            Text { anchors.centerIn: parent; text: model.icon; font.pixelSize: 20 }
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true; spacing: 2
                                            Text { text: model.name; font.pixelSize: 13; font.bold: true; color: cText }
                                            Text {
                                                text: added ? "✅ Đã thêm vào phòng" : model.watt + " W"
                                                font.pixelSize: 11
                                                color: added ? cGreen : cSub
                                            }
                                        }

                                        // Nút "+" mở room picker
                                        Rectangle {
                                            width: 32; height: 32; radius: 16
                                            color: added ? "#E9F9EF" : "#EBF2FF"
                                            visible: !added
                                            Text {
                                                anchors.centerIn: parent; text: "+"
                                                font.pixelSize: 20; font.bold: true; color: added ? cGreen : cBlue
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    roomPicker.targetName  = model.name
                                                    roomPicker.targetWatt  = model.watt
                                                    roomPicker.targetIndex = index
                                                    roomPicker.open()
                                                }
                                            }
                                        }

                                        // Check icon sau khi đã thêm
                                        Text {
                                            visible: added
                                            text: "✅"; font.pixelSize: 20
                                        }
                                    }

                                    Rectangle {
                                        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                                        height: 1; color: "#EEF0F4"
                                        visible: index < foundModel.count - 1
                                    }
                                }
                            }
                        }
                    }

                    // ── Nhập thủ công ──
                    Rectangle {
                        Layout.fillWidth: true; Layout.leftMargin: 16; Layout.rightMargin: 16
                        Layout.bottomMargin: 8
                        height: manualForm.implicitHeight + 24; radius: 14; color: cPanel

                        ColumnLayout {
                            id: manualForm
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
                            spacing: 10

                            Text { text: "Thêm thủ công"; font.pixelSize: 13; font.bold: true; color: cSub }

                            TextField {
                                id: manualName; Layout.fillWidth: true
                                placeholderText: "Tên thiết bị"; font.pixelSize: 13
                                background: Rectangle { radius: 8; color: "#F2F5FA"; border.color: "#DDE1E8"; border.width: 1 }
                            }
                            TextField {
                                id: manualWatt; Layout.fillWidth: true
                                placeholderText: "Công suất (W)"; font.pixelSize: 13
                                inputMethodHints: Qt.ImhDigitsOnly
                                background: Rectangle { radius: 8; color: "#F2F5FA"; border.color: "#DDE1E8"; border.width: 1 }
                            }
                            ComboBox {
                                id: manualRoom; Layout.fillWidth: true
                                model: ["🛋️ Phòng khách","🛏️ Phòng ngủ","🍳 Bếp"]
                                font.pixelSize: 13
                            }
                            Text { id: manualErr; text: ""; color: cRed; font.pixelSize: 12 }
                        }
                    }

                    // ── Buttons ──
                    RowLayout {
                        Layout.fillWidth: true; Layout.leftMargin: 16; Layout.rightMargin: 16
                        Layout.bottomMargin: 24; spacing: 12

                        Rectangle {
                            Layout.fillWidth: true; height: 50; radius: 14
                            color: "#F2F5FA"; border.color: "#DDE1E8"; border.width: 1
                            Text { anchors.centerIn: parent; text: "Quét lại"; font.pixelSize: 14; font.bold: true; color: cText }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    scanTimer.stop()
                                    Qt.callLater(function() { scanTimer.start() })
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true; height: 50; radius: 14; color: cPrimary
                            Text { anchors.centerIn: parent; text: "Thêm thủ công"; font.pixelSize: 14; font.bold: true; color: "white" }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var n = manualName.text.trim()
                                    var w = parseFloat(manualWatt.text)
                                    if (n === "" || isNaN(w)) { manualErr.text = "Vui lòng nhập đủ thông tin"; return }
                                    if (!backend.addDevice(n, w, manualRoom.currentIndex)) {
                                        manualErr.text = "Tên đã tồn tại!"
                                    } else {
                                        manualName.clear(); manualWatt.clear(); manualErr.text = ""
                                        viewState = 0
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Room Picker Popup ──
    Popup {
        id: roomPicker
        anchors.centerIn: Overlay.overlay
        width: 300; padding: 0
        modal: true; dim: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property string targetName: ""
        property int    targetWatt: 0
        property int    targetIndex: -1

        background: Rectangle { radius: 18; color: cPanel }

        ColumnLayout {
            width: parent.width; spacing: 0

            // Title
            Rectangle {
                Layout.fillWidth: true; height: 54
                color: "transparent"
                Text {
                    anchors.centerIn: parent
                    text: "Thêm vào phòng nào?"
                    font.pixelSize: 16; font.bold: true; color: cText
                }
            }
            Rectangle { Layout.fillWidth: true; height: 1; color: "#EEF0F4" }

            // Device preview
            Rectangle {
                Layout.fillWidth: true; height: 52
                color: "#F8FAFF"
                RowLayout {
                    anchors { fill: parent; leftMargin: 20; rightMargin: 20 }
                    spacing: 12
                    Rectangle {
                        width: 34; height: 34; radius: 17; color: "#EBF2FF"
                        Text {
                            anchors.centerIn: parent
                            text: roomPicker.targetIndex >= 0 && roomPicker.targetIndex < foundModel.count
                                  ? foundModel.get(roomPicker.targetIndex).icon : "📦"
                            font.pixelSize: 18
                        }
                    }
                    Text { text: roomPicker.targetName; font.pixelSize: 13; font.bold: true; color: cText; Layout.fillWidth: true }
                    Text { text: roomPicker.targetWatt + " W"; font.pixelSize: 12; color: cSub }
                }
            }
            Rectangle { Layout.fillWidth: true; height: 1; color: "#EEF0F4" }

            // Room list
            Repeater {
                model: [
                    { icon: "🛋️", name: "Phòng khách", color: "#EBF2FF" },
                    { icon: "🛏️", name: "Phòng ngủ",   color: "#EDF7EE" },
                    { icon: "🍳", name: "Bếp",          color: "#FFF4E5" }
                ]
                delegate: Rectangle {
                    Layout.fillWidth: true; height: 54
                    color: "transparent"
                    property bool hovered: false

                    Rectangle {
                        anchors.fill: parent; anchors.margins: 6
                        radius: 10; color: hovered ? modelData.color : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    RowLayout {
                        anchors { fill: parent; leftMargin: 20; rightMargin: 20 }
                        spacing: 14
                        Rectangle {
                            width: 36; height: 36; radius: 12; color: modelData.color
                            Text { anchors.centerIn: parent; text: modelData.icon; font.pixelSize: 18 }
                        }
                        Text { text: modelData.name; font.pixelSize: 14; color: cText; Layout.fillWidth: true }
                        Text { text: "›"; font.pixelSize: 16; color: cSub }
                    }

                    MouseArea {
                        anchors.fill: parent; hoverEnabled: true
                        onEntered: parent.hovered = true
                        onExited:  parent.hovered = false
                        onClicked: {
                            // Add to backend
                            backend.addDevice(roomPicker.targetName, roomPicker.targetWatt, index)
                            // Mark as added in UI
                            if (roomPicker.targetIndex >= 0 && roomPicker.targetIndex < foundModel.count) {
                                foundModel.setProperty(roomPicker.targetIndex, "added_flag", true)
                            }
                            roomPicker.close()

                            // Update the delegate's "added" property via workaround
                            var rep = addDeviceView.foundRepeater
                            if (rep) {
                                var item = rep.itemAt(roomPicker.targetIndex)
                                if (item) item.added = true
                            }
                        }
                    }

                    Rectangle {
                        anchors { bottom: parent.bottom; left: parent.left; right: parent.right; leftMargin: 16; rightMargin: 16 }
                        height: 1; color: "#EEF0F4"
                        visible: index < 2
                    }
                }
            }

            // Cancel
            Rectangle { Layout.fillWidth: true; height: 1; color: "#EEF0F4" }
            Rectangle {
                Layout.fillWidth: true; height: 52
                color: "transparent"
                Text { anchors.centerIn: parent; text: "Hủy"; font.pixelSize: 14; color: cSub }
                MouseArea { anchors.fill: parent; onClicked: roomPicker.close() }
            }
        }
    }

    Dialog {
        id: deleteDialog
        title: "Xóa thiết bị"; modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Ok | Dialog.Cancel
        property string targetName: ""
        function openFor(n) { targetName = n; open() }
        Text { text: "Xóa thiết bị \"" + deleteDialog.targetName + "\"?"; font.pixelSize: 13 }
        onAccepted: { backend.removeDevice(targetName); loadDevices() }
    }
}