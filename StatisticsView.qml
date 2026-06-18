import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: statisticsView

    readonly property color cBg:      "#F2F5FA"
    readonly property color cPanel:   "#FFFFFF"
    readonly property color cPrimary: "#1A73E8"
    readonly property color cGreen:   "#34C759"
    readonly property color cRed:     "#FF3B30"
    readonly property color cOrange:  "#FF9500"
    readonly property color cText:    "#1C1C1E"
    readonly property color cSub:     "#8E8E93"
    readonly property color cBlue:    "#007AFF"

    property int subView: 0

    function refresh() {
        totalKwhStat.text  = backend.totalEnergy().toFixed(1) + " kWh"
        totalCostStat.text = "≈ " + Math.round(backend.costToday).toLocaleString() + " đ"
        loadAlerts()
        loadRoomStats()
    }

    function loadAlerts() {
        alertModel.clear()
        var raw = backend.checkAlerts()
        for (var i = 0; i < raw.length; i++) {
            alertModel.append({
                msg:  raw[i].message,
                type: i < 2 ? "error" : "warning",
                time: ["09:30","08:15","07:45","07:20","06:30"][i] || "—",
                sub:  ""
            })
        }
    }

    function loadRoomStats() {
        roomStatModel.clear()
        var names  = ["Phòng khách","Phòng ngủ","Bếp","Phòng giặt","Phòng tắm"]
        var energy = [0,0,0, 2.2, 1.6]
        for (var i = 0; i < 3; i++) energy[i] = backend.energyByRoom(i)
        var total  = energy.reduce(function(a,b){ return a+b }, 0)
        var icons  = ["🛋️","🛏️","🍳","🧺","🚿"]
        for (var j = 0; j < 5; j++) {
            roomStatModel.append({
                icon:    icons[j],
                name:    names[j],
                kwh:     energy[j].toFixed(1),
                pct:     total > 0 ? Math.round(energy[j]/total*100) : 0
            })
        }
    }

    Component.onCompleted: refresh()

    Connections {
        target: backend
        function onTotalHomeEnergyTodayChanged() { refresh() }
        function onDeviceListChanged()           { refresh() }
    }

    Rectangle { anchors.fill: parent; color: cBg }

    ColumnLayout {
        anchors.fill: parent; spacing: 0

        Rectangle {
            Layout.fillWidth: true; height: 56; color: cPanel

            RowLayout {
                anchors { fill: parent; leftMargin: 16; rightMargin: 16 }

                Repeater {
                    model: ["📊 Thống kê","⚠️ Cảnh báo"]
                    delegate: Item {
                        Layout.fillWidth: true; height: 56

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: 13; font.bold: subView === index
                            color: subView === index ? cBlue : cSub
                        }

                        Rectangle {
                            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                            height: 2; radius: 1
                            color: subView === index ? cBlue : "transparent"
                        }

                        MouseArea { anchors.fill: parent; onClicked: { subView = index; refresh() } }
                    }
                }
            }
        }

        // ----- Thống kê -----
        Item {
            Layout.fillWidth: true; Layout.fillHeight: true
            visible: subView === 0

            Flickable {
                anchors.fill: parent
                contentHeight: statMainCol.implicitHeight + 24
                clip: true

                ColumnLayout {
                    id: statMainCol
                    width: parent.width; spacing: 0

                    Rectangle {
                        Layout.fillWidth: true; Layout.margins: 12
                        height: 40; radius: 20; color: cPanel

                        RowLayout {
                            anchors { fill: parent; margins: 4 }
                            spacing: 4
                            property int selected: 0

                            Repeater {
                                model: ["Ngày","Tuần"]
                                delegate: Rectangle {
                                    Layout.fillWidth: true; height: 32; radius: 16
                                    color: parent.selected === index ? cPrimary : "transparent"
                                    Text {
                                        anchors.centerIn: parent; text: modelData
                                        font.pixelSize: 13; font.bold: parent.parent.selected === index
                                        color: parent.parent.selected === index ? "white" : cSub
                                    }
                                    MouseArea { anchors.fill: parent; onClicked: parent.parent.selected = index }
                                }
                            }
                        }
                    }

                    // Navigator ngày / tuần động
                    RowLayout {
                        Layout.fillWidth: true; Layout.leftMargin: 16; Layout.rightMargin: 16
                        Layout.bottomMargin: 8

                        property int dayOffset: 0

                        function labelText(isSel0) {
                            var d = new Date()
                            if (isSel0) {
                                d.setDate(d.getDate() + dayOffset)
                                return Qt.formatDate(d, "dd/MM/yyyy")
                            } else {
                                d.setDate(d.getDate() + dayOffset * 7)
                                var mon = new Date(d); mon.setDate(d.getDate() - d.getDay() + 1)
                                var sun = new Date(mon); sun.setDate(mon.getDate() + 6)
                                return Qt.formatDate(mon,"dd/MM") + " – " + Qt.formatDate(sun,"dd/MM/yyyy")
                            }
                        }

                        Text { text: "‹"; font.pixelSize: 22; color: cSub
                            MouseArea { anchors.fill: parent; onClicked: parent.parent.dayOffset -= 1 } }
                        Text {
                            text: parent.labelText(true)
                            font.pixelSize: 13; font.bold: true; color: cText
                            Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter
                        }
                        Text { text: "›"; font.pixelSize: 22; color: cSub
                            MouseArea { anchors.fill: parent; onClicked: { if (parent.parent.dayOffset < 0) parent.parent.dayOffset += 1 } } }
                    }

                    Rectangle {
                        Layout.fillWidth: true; Layout.leftMargin: 12; Layout.rightMargin: 12
                        Layout.bottomMargin: 12
                        height: 80; radius: 14; color: cPanel

                        RowLayout {
                            anchors { fill: parent; margins: 16 }
                            ColumnLayout {
                                spacing: 4
                                Text { id: totalKwhStat; text: "18.7 kWh"; font.pixelSize: 28; font.bold: true; color: cText }
                                Text { text: "Tổng tiêu thụ tuần"; font.pixelSize: 12; color: cSub }
                            }
                            Item { Layout.fillWidth: true }
                            ColumnLayout {
                                spacing: 4
                                Text { id: totalCostStat; text: "≈ 45.000 đ"; font.pixelSize: 18; font.bold: true; color: cBlue }
                                Text { text: "Chi phí ước tính"; font.pixelSize: 12; color: cSub }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true; Layout.leftMargin: 12; Layout.rightMargin: 12
                        Layout.bottomMargin: 12
                        height: 160; radius: 14; color: cPanel

                        ColumnLayout {
                            anchors { fill: parent; margins: 16 }
                            spacing: 8

                            Row {
                                Layout.fillWidth: true; Layout.fillHeight: true
                                spacing: 0

                                property var days:  ["T2","T3","T4","T5","T6","T7","CN"]
                                property var vals:  [22, 28, 18, 32, 25, 30, 22]
                                property real maxV: 35

                                Repeater {
                                    model: 7
                                    delegate: Item {
                                        width: parent.width / 7
                                        height: parent.height

                                        Column {
                                            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                                            spacing: 4

                                            Rectangle {
                                                width: 22
                                                height: Math.max(4, (parent.parent.parent.vals[index] / parent.parent.parent.maxV) * 90)
                                                radius: 4
                                                color: index === 6 ? cOrange : cPrimary
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                            Text {
                                                text: parent.parent.parent.days[index]
                                                font.pixelSize: 11; color: cSub
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true; Layout.leftMargin: 12; Layout.rightMargin: 12
                        Layout.bottomMargin: 12
                        height: deviceStatCol.implicitHeight + 24; radius: 14; color: cPanel

                        ColumnLayout {
                            id: deviceStatCol
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
                            spacing: 10

                            Text { text: "Tiêu thụ theo thiết bị (tuần này)"; font.pixelSize: 14; font.bold: true; color: cText }

                            Repeater {
                                model: [
                                    { name: "Điều hòa phòng ngủ", kwh: "45.6", pct: 36 },
                                    { name: "Tủ lạnh",            kwh: "28.7", pct: 23 },
                                    { name: "Máy giặt",           kwh: "16.3", pct: 13 },
                                    { name: "Tivi",               kwh: "12.1", pct: 10 },
                                    { name: "Quạt",               kwh: "8.7",  pct: 7  },
                                    { name: "Khác",               kwh: "15.0", pct: 11 }
                                ]
                                delegate: RowLayout {
                                    Layout.fillWidth: true; spacing: 8

                                    Text { text: modelData.name; font.pixelSize: 12; color: cText; Layout.fillWidth: true }

                                    Rectangle {
                                        width: 80; height: 6; radius: 3; color: "#EEF0F4"
                                        Rectangle {
                                            width: parent.width * modelData.pct / 100
                                            height: 6; radius: 3; color: cBlue
                                        }
                                    }

                                    Text { text: modelData.kwh + " kWh"; font.pixelSize: 12; font.bold: true; color: cText; width: 60 }
                                    Text { text: modelData.pct + "%"; font.pixelSize: 12; color: cSub; width: 32; horizontalAlignment: Text.AlignRight }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ----- Cảnh báo -----
        Item {
            Layout.fillWidth: true; Layout.fillHeight: true
            visible: subView === 1

            ColumnLayout {
                anchors.fill: parent; spacing: 0

                Rectangle {
                    Layout.fillWidth: true; Layout.margins: 12
                    height: 40; radius: 20; color: cPanel

                    RowLayout {
                        anchors { fill: parent; margins: 4 }
                        spacing: 4
                        property int selFilter: 0

                        Repeater {
                            model: ["Tất cả","Thiết bị","Hệ thống"]
                            delegate: Rectangle {
                                Layout.fillWidth: true; height: 32; radius: 16
                                color: parent.selFilter === index ? cPrimary : "transparent"
                                Text {
                                    anchors.centerIn: parent; text: modelData
                                    font.pixelSize: 13; font.bold: parent.parent.selFilter === index
                                    color: parent.parent.selFilter === index ? "white" : cSub
                                }
                                MouseArea { anchors.fill: parent; onClicked: parent.parent.selFilter = index }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true; Layout.leftMargin: 12; Layout.rightMargin: 12
                    Layout.bottomMargin: 8
                    height: 42; radius: 12; color: cPrimary

                    Text { anchors.centerIn: parent; text: "🔄  Kiểm tra ngay"; font.pixelSize: 13; font.bold: true; color: "white" }
                    MouseArea { anchors.fill: parent; onClicked: loadAlerts() }
                }

                ListView {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; topMargin: 4; bottomMargin: 12; spacing: 10
                    model: ListModel { id: alertModel }

                    delegate: Rectangle {
                        width: ListView.view.width - 24; x: 12
                        height: alertItemCol.implicitHeight + 20
                        radius: 14; color: cPanel

                        Rectangle {
                            width: 4; height: parent.height; radius: 2
                            color: model.type === "error" ? cRed : cOrange
                            anchors { left: parent.left; leftMargin: 0; verticalCenter: parent.verticalCenter }
                        }

                        RowLayout {
                            id: alertItemCol
                            anchors { fill: parent; leftMargin: 16; rightMargin: 14; topMargin: 10; bottomMargin: 10 }
                            spacing: 12

                            Text { text: model.type === "error" ? "🔴" : "🟡"; font.pixelSize: 20 }

                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 3
                                Text { text: model.msg; font.pixelSize: 13; font.bold: true; color: cText; wrapMode: Text.Wrap; Layout.fillWidth: true }
                                Text { text: model.sub; font.pixelSize: 11; color: cSub; visible: model.sub !== "" }
                            }

                            Text { text: model.time; font.pixelSize: 11; color: cSub; verticalAlignment: Text.AlignTop }
                        }
                    }

                    Component.onCompleted: {
                        if (alertModel.count === 0) {
                            alertModel.append({ msg: "Điều hòa phòng khách đã bật trên 8 giờ",  type: "error",   time: "09:30", sub: "Đã bật từ 01:15 15/05" })
                            alertModel.append({ msg: "Tiêu thụ điện vượt ngưỡng (+20% hôm nay)", type: "error",   time: "08:15", sub: "Hôm nay: 18.7 kWh" })
                            alertModel.append({ msg: "Tủ lạnh hoạt động bất thường",             type: "warning", time: "07:45", sub: "Công suất cao hơn bình thường" })
                            alertModel.append({ msg: "Máy giặt đã hoàn thành",                   type: "warning", time: "07:20", sub: "Chu trình giặt đã kết thúc" })
                            alertModel.append({ msg: "Rèm cửa phòng khách",                      type: "warning", time: "06:30", sub: "Đã đóng theo lịch hẹn" })
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "✅ Không có cảnh báo nào"
                        font.pixelSize: 14; color: cSub
                        visible: alertModel.count === 0
                    }
                }
            }
        }
    }
}