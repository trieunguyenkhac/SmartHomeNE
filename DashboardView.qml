import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: dashboardView

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
    readonly property var roomColors: [cBlue, "#5AC8FA", cOrange, cGreen, "#AF52DE"]

    function refresh() {
        activeCountLabel.text = backend.activeDevicesCount
        alertsCountLabel.text = backend.checkAlerts().length
        for (var i = 0; i < 3; i++) {
            roomEnergyRepeater.itemAt(i).energyVal = backend.energyByRoom(i)
        }
    }

    Component.onCompleted: refresh()

    Connections {
        target: backend
        function onTotalHomeEnergyTodayChanged() { refresh() }
        function onActiveDevicesCountChanged()   { refresh() }
        function onDeviceListChanged()           { refresh() }
    }

    Rectangle { anchors.fill: parent; color: cBg }

    Flickable {
        anchors.fill: parent
        contentHeight: mainCol.implicitHeight + 32
        clip: true

        ColumnLayout {
            id: mainCol
            width: parent.width
            spacing: 0

            // Header
            Rectangle {
                Layout.fillWidth: true
                height: 56
                color: cPanel
                RowLayout {
                    anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                    Text { text: "Nhà của tôi ⌄"; font.pixelSize: 16; font.bold: true; color: cText }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: 36; height: 36; radius: 18; color: "#F2F5FA"
                        Text { anchors.centerIn: parent; text: "🔔"; font.pixelSize: 18 }
                    }
                }
            }

            // Card năng lượng
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 168
                color: cPrimary
                radius: 16
                clip: true

                Rectangle {
                    x: parent.width - 110; y: -50
                    width: 200; height: 200; radius: 100
                    color: Qt.rgba(1,1,1,0.08)
                }
                Rectangle {
                    x: parent.width - 70; y: 30
                    width: 140; height: 140; radius: 70
                    color: Qt.rgba(1,1,1,0.06)
                }

                ColumnLayout {
                    anchors { left: parent.left; top: parent.top; margins: 20 }
                    spacing: 2
                    Text { text: "Công suất hiện tại"; font.pixelSize: 13; color: Qt.rgba(1,1,1,0.75) }
                    Text {
                        id: totalKwhLabel
                        text: Math.round(backend.currentTotalWatt) + " W"
                        font.pixelSize: 36; font.bold: true; color: "white"
                    }
                    Text {
                        id: totalCostLabel
                        text: backend.totalHomeEnergyToday.toFixed(2) + " kWh hôm nay  ≈ " + Math.round(backend.costToday).toLocaleString() + " đ"
                        font.pixelSize: 14; color: Qt.rgba(1,1,1,0.82)
                    }
                    Rectangle {
                        width: pctRow.implicitWidth + 14; height: 22; radius: 11
                        color: Qt.rgba(1,1,1,0.18)
                        RowLayout {
                            id: pctRow
                            anchors.centerIn: parent; spacing: 3
                            Text { text: "▲"; font.pixelSize: 9; color: "#FFD60A" }
                            Text { text: "12%"; font.pixelSize: 11; color: "white" }
                        }
                    }
                    Text { text: "So với hôm qua"; font.pixelSize: 11; color: Qt.rgba(1,1,1,0.55) }
                }

                Rectangle {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 22 }
                    width: 68; height: 68; radius: 34; color: Qt.rgba(1,1,1,0.18)
                    Text { anchors.centerIn: parent; text: "⚡"; font.pixelSize: 32 }
                }
            }

            // 3 KPI
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 12
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true; height: 74; radius: 12; color: cPanel
                    ColumnLayout {
                        anchors.centerIn: parent; spacing: 3
                        Text { Layout.alignment: Qt.AlignHCenter; text: "Thiết bị bật"; font.pixelSize: 11; color: cSub }
                        Text { id: activeCountLabel; Layout.alignment: Qt.AlignHCenter; text: "4"; font.pixelSize: 24; font.bold: true; color: cBlue }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true; height: 74; radius: 12; color: cPanel
                    ColumnLayout {
                        anchors.centerIn: parent; spacing: 3
                        Text { Layout.alignment: Qt.AlignHCenter; text: "Phòng"; font.pixelSize: 11; color: cSub }
                        Text { Layout.alignment: Qt.AlignHCenter; text: "5"; font.pixelSize: 24; font.bold: true; color: cGreen }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true; height: 74; radius: 12; color: "#FFF0EE"
                    border.color: "#FFCDD2"; border.width: 1
                    ColumnLayout {
                        anchors.centerIn: parent; spacing: 3
                        Text { Layout.alignment: Qt.AlignHCenter; text: "Cảnh báo"; font.pixelSize: 11; color: cRed }
                        Text { id: alertsCountLabel; Layout.alignment: Qt.AlignHCenter; text: "2"; font.pixelSize: 24; font.bold: true; color: cRed }
                    }
                }
            }

            // Tiêu thụ theo phòng
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 12; Layout.rightMargin: 12
                Layout.bottomMargin: 10
                radius: 12; color: cPanel
                height: roomCol.implicitHeight + 28

                ColumnLayout {
                    id: roomCol
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Tiêu thụ theo phòng (hôm nay)"; font.pixelSize: 14; font.bold: true; color: cText; Layout.fillWidth: true }
                        Text { text: "Xem chi tiết ›"; font.pixelSize: 12; color: cBlue }
                    }

                    Repeater {
                        id: roomEnergyRepeater
                        model: 5
                        delegate: Item {
                            property real energyVal: index < 3 ? backend.energyByRoom(index) : (index === 3 ? 2.2 : 1.6)
                            property real maxE: 7.5
                            Layout.fillWidth: true; height: 42

                            ColumnLayout {
                                anchors.fill: parent; spacing: 4
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { text: roomNames[index]; font.pixelSize: 13; color: cText; Layout.fillWidth: true }
                                    Text { text: energyVal.toFixed(1) + " kWh"; font.pixelSize: 13; font.bold: true; color: cText; rightPadding: 6 }
                                    Text { text: Math.round(energyVal / 19.7 * 100) + "%"; font.pixelSize: 12; color: cSub; width: 34 }
                                }
                                Rectangle {
                                    Layout.fillWidth: true; height: 6; radius: 3; color: "#EEF0F4"
                                    Rectangle {
                                        width: Math.max(8, parent.width * energyVal / maxE)
                                        height: 6; radius: 3
                                        color: roomColors[index]
                                        Behavior on width { NumberAnimation { duration: 700; easing.type: Easing.OutCubic } }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Thiết bị thường dùng
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 12; Layout.rightMargin: 12
                Layout.bottomMargin: 16
                radius: 12; color: cPanel
                height: quickCol.implicitHeight + 28

                ColumnLayout {
                    id: quickCol
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
                    spacing: 12

                    Text { text: "Thiết bị thường dùng"; font.pixelSize: 14; font.bold: true; color: cText }

                    RowLayout {
                        Layout.fillWidth: true; spacing: 10

                        Repeater {
                            model: [
                                { icon: "💡", name: "Đèn phòng\nkhách",    bg: "#FFF3CD" },
                                { icon: "❄️", name: "Điều hòa\nphòng ngủ", bg: "#D1ECF1" },
                                { icon: "🌀", name: "Quạt\nphòng khách",   bg: "#D4EDDA" },
                                { icon: "📺", name: "Tivi\nphòng khách",   bg: "#F8D7DA" }
                            ]
                            delegate: Rectangle {
                                Layout.fillWidth: true; height: 82; radius: 12
                                color: modelData.bg
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 5
                                    Text { Layout.alignment: Qt.AlignHCenter; text: modelData.icon; font.pixelSize: 26 }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: modelData.name; font.pixelSize: 10; color: cText
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}