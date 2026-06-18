import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: root
    visible: true
    width: 393
    height: 852
    title: "🏠 Smart Home Energy Manager"

    readonly property color cBg:      "#F2F5FA"
    readonly property color cPanel:   "#FFFFFF"
    readonly property color cPrimary: "#1A73E8"
    readonly property color cGreen:   "#34C759"
    readonly property color cRed:     "#FF3B30"
    readonly property color cOrange:  "#FF9500"
    readonly property color cText:    "#1C1C1E"
    readonly property color cSub:     "#8E8E93"
    readonly property color cBlue:    "#007AFF"

    StackView {
        id: stack
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: bottomNav.top
        }
        initialItem: dashboardComp

        pushEnter: Transition {
            PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 180 }
        }
        pushExit: Transition {
            PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 100 }
        }
        popEnter: Transition {
            PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 180 }
        }
        popExit: Transition {
            PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 100 }
        }
    }

    Component { id: dashboardComp;   DashboardView   { } }
    Component { id: deviceComp;      DeviceControlView { } }
    Component { id: statisticsComp;  StatisticsView  { } }

    Component {
        id: settingsComp
        Item {
            Rectangle { anchors.fill: parent; color: cBg }
            Flickable {
                anchors.fill: parent
                contentHeight: settCol.implicitHeight + 32
                clip: true
                ColumnLayout {
                    id: settCol
                    width: parent.width
                    spacing: 0
                    Rectangle {
                        Layout.fillWidth: true; height: 56; color: cPanel
                        Text { anchors.centerIn: parent; text: "Cài đặt"; font.pixelSize: 18; font.bold: true; color: cText }
                    }
                    Rectangle {
                        Layout.fillWidth: true; Layout.margins: 12
                        height: 80; radius: 14; color: cPanel
                        RowLayout {
                            anchors { fill: parent; margins: 16 }
                            spacing: 14
                            Rectangle {
                                width: 48; height: 48; radius: 24; color: cPrimary
                                Text { anchors.centerIn: parent; text: "🏠"; font.pixelSize: 24 }
                            }
                            ColumnLayout {
                                spacing: 3
                                Text { text: "Nhà của tôi"; font.pixelSize: 16; font.bold: true; color: cText }
                                Text { text: "Chủ nhà"; font.pixelSize: 12; color: cSub }
                            }
                            Item { Layout.fillWidth: true }
                            Text { text: "›"; font.pixelSize: 20; color: cSub }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true; Layout.leftMargin: 12; Layout.rightMargin: 12
                        Layout.bottomMargin: 12
                        radius: 14; color: cPanel
                        height: settListCol.implicitHeight + 8
                        ColumnLayout {
                            id: settListCol
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 0 }
                            spacing: 0
                            Repeater {
                                model: [
                                    { icon: "🏠", label: "Quản lý nhà",          val: ""              },
                                    { icon: "👥", label: "Quản lý thành viên",    val: ""              },
                                    { icon: "⚡", label: "Giá điện",             val: "2,436 kWh/đ"  },
                                    { icon: "📏", label: "Đơn vị tính",          val: "kWh · đ"      },
                                    { icon: "🔔", label: "Thông báo",            val: ""              },
                                    { icon: "💾", label: "Sao lưu & khôi phục",  val: ""              },
                                    { icon: "ℹ️", label: "Giới thiệu",            val: ""              }
                                ]
                                delegate: Rectangle {
                                    Layout.fillWidth: true; height: 52; color: "transparent"
                                    RowLayout {
                                        anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                                        spacing: 12
                                        Text { text: modelData.icon; font.pixelSize: 20 }
                                        Text { text: modelData.label; font.pixelSize: 14; color: cText; Layout.fillWidth: true }
                                        Text { text: modelData.val;   font.pixelSize: 13; color: cSub }
                                        Switch { visible: index === 4; checked: true }
                                        Text { text: index !== 4 ? "›" : ""; font.pixelSize: 18; color: cSub }
                                    }
                                    Rectangle {
                                        anchors { bottom: parent.bottom; left: parent.left; right: parent.right; leftMargin: 16 }
                                        height: 1; color: "#EEF0F4"
                                        visible: index < 6
                                    }
                                }
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true; Layout.leftMargin: 12; Layout.rightMargin: 12
                        height: 50; radius: 14; color: "#FFF0EE"
                        border.color: cRed; border.width: 1
                        Text { anchors.centerIn: parent; text: "Đăng xuất"; font.pixelSize: 15; font.bold: true; color: cRed }
                    }
                }
            }
        }
    }

    Rectangle {
        id: bottomNav
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: 80
        color: cPanel

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1; color: "#E5E5EA"
        }

        property int currentTab: 0

        RowLayout {
            anchors { fill: parent; bottomMargin: 8 }
            spacing: 0

            Repeater {
                model: [
                    { icon: "🏠", label: "Trang chủ" },
                    { icon: "🏘️", label: "Phòng"     },
                    { icon: "📊", label: "Thống kê"  },
                    { icon: "⚙️", label: "Cài đặt"   }
                ]
                delegate: Item {
                    Layout.fillWidth: true
                    height: parent.height

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 3

                        Item {
                            Layout.alignment: Qt.AlignHCenter
                            width: 28; height: 28
                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                font.pixelSize: 22
                                opacity: bottomNav.currentTab === index ? 1.0 : 0.45
                            }
                            Rectangle {
                                visible: index === 2 && backend.activeDevicesCount > 0
                                anchors { top: parent.top; right: parent.right }
                                width: 16; height: 16; radius: 8; color: cRed
                                Text { anchors.centerIn: parent; text: "2"; font.pixelSize: 9; font.bold: true; color: "white" }
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.label
                            font.pixelSize: 10; font.bold: bottomNav.currentTab === index
                            color: bottomNav.currentTab === index ? cBlue : cSub
                        }
                    }

                    Rectangle {
                        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
                        width: 4; height: 4; radius: 2
                        color: cBlue
                        visible: bottomNav.currentTab === index
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (bottomNav.currentTab === index) return
                            bottomNav.currentTab = index
                            switch(index) {
                                case 0: stack.replace(dashboardComp);  break
                                case 1: stack.replace(deviceComp); break
                                case 2: stack.replace(statisticsComp); break
                                case 3: stack.replace(settingsComp);   break
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: toastBar
        anchors { bottom: bottomNav.top; horizontalCenter: parent.horizontalCenter; bottomMargin: 12 }
        width: toastText.implicitWidth + 32; height: 40; radius: 20
        color: "#1C1C1E"; opacity: 0; visible: opacity > 0

        Text { id: toastText; anchors.centerIn: parent; text: ""; color: "white"; font.pixelSize: 13 }

        function show(msg) {
            toastText.text = msg
            toastAnim.restart()
        }

        SequentialAnimation {
            id: toastAnim
            NumberAnimation { target: toastBar; property: "opacity"; to: 0.92; duration: 200 }
            PauseAnimation { duration: 2000 }
            NumberAnimation { target: toastBar; property: "opacity"; to: 0;    duration: 300 }
        }
    }

    Connections {
        target: backend
        function onAlertMessage(msg) { toastBar.show(msg) }
    }
}