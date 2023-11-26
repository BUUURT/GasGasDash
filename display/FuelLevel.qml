import QtQuick 2.0

Item {
    id: item1
    width: 100
    height: 325
    property alias fuelQtyHeight: fuelQty.height
    property alias fuelBorderColor: fuelBorder.border.color
    property string state: "full"
    property int flashSlow: 400
    property int flashFast: 100

    Rectangle {
        id: fuelBorder
        y: 30
        width: 100
        height: 325
        color: "#00ffffff"
        radius: 10
        border.color: "#000000"
        border.width: 3
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            id: fuelQty
            y: 128
            height: 325
            color: "#00ff00"
            radius: 10
            border.color: fuelBorder.border.color
            border.width: 3
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            anchors.bottomMargin: 0
            SequentialAnimation {
                id: reserveFlash
                running: false
                loops: -1
                property int delay: 200
                ParallelAnimation {
                    PropertyAnimation {
                        target: rectangle1
                        property: "visible"
                        to: 0
                        duration: reserveFlash.delay
                    }
                    PropertyAnimation {
                        target: rectangle2
                        property: "visible"
                        to: 0
                        duration: reserveFlash.delay
                    }
                }
                ParallelAnimation {
                    PropertyAnimation {
                        target: rectangle1
                        property: "visible"
                        to: 1
                        duration: reserveFlash.delay
                    }
                    PropertyAnimation {
                        target: rectangle2
                        property: "visible"
                        to: 1
                        duration: reserveFlash.delay
                    }
                }
            }




            Rectangle {
                id: rectangle1
                x: 47
                y: -128
                width: 10
                height: item1.height
                visible: true
                color: "#ff0000"
                radius: 5
                border.width: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.horizontalCenterOffset: 0
                anchors.horizontalCenter: parent.horizontalCenter
                rotation: -15
            }

            Rectangle {
                id: rectangle2
                x: 47
                y: -128
                width: 10
                height: item1.height
                visible: true
                color: "#ff0000"
                radius: 5
                border.width: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                rotation: 15
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: 0
            }
            Text {
                id: text1
                y: 109
                height: 137
                color: fuelBorder.border.color
                text: (fuelQty.height/fuelBorder.height*10).toFixed(0).toString()
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                font.pixelSize: 100
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                fontSizeMode: Text.Fit
                font.family: "BN Elements"
                anchors.bottomMargin: 20
            }
        }

        Text {
            id: label
            width: 100
            height: 25
            color: fuelBorder.border.color
            text: qsTr("FUEL")
            anchors.bottom: parent.bottom
            font.pixelSize: 25
            horizontalAlignment: Text.AlignHCenter
            anchors.bottomMargin: 5
            font.family: "BN Elements"
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
    states: [
        State {
            when: item1.state  == "full"
            name: "full"
            PropertyChanges {target: rectangle1; visible: false}
            PropertyChanges {target: rectangle2; visible: false}
            PropertyChanges {target: fuelQty; color: "#00ff00"}
            PropertyChanges {target: reserveFlash; running: false}
        },
        State {
            name: "mid"
            when: item1.state  == "mid"
            PropertyChanges {target: rectangle1; visible: false}
            PropertyChanges {target: rectangle2; visible: false}
            PropertyChanges {target: fuelQty; color: "#ffff00"}
            PropertyChanges {target: reserveFlash; running: false}
        },
        State {
            name: "reserve"
            when: item1.state  == "reserve"
            PropertyChanges {target: rectangle1; visible: true}
            PropertyChanges {target: rectangle2; visible: true}
            PropertyChanges {target: fuelQty; color: "#ffaa00"}
            PropertyChanges {target: reserveFlash; running: true}
            PropertyChanges {target: reserveFlash; delay:fuelQty.height*400/65}
        },
        State {
            name: "empty"
            when: item1.state  == "empty"
            PropertyChanges {target: rectangle1; visible: true}
            PropertyChanges {target: rectangle2; visible: true}
            PropertyChanges {target: fuelQty; color: "#ff0000"}
            PropertyChanges {target: reserveFlash; running: true}
            PropertyChanges {target: reserveFlash; delay:fuelQty.height*400/65}
        }
    ]

}
