import QtQuick 2.0

Item {
    id: item1
    width: 100
    height: 325
    property alias fuelQtyHeight: fuelQty.height
    property alias fuelBorderColor: fuelBorder.border.color

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
            height: 197
            color: "#ecff00"
            radius: 10
            border.color: fuelBorder.border.color
            border.width: 3
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            anchors.bottomMargin: 0

            Text {
                id: text1
                y: 109
                width: 100
                height: 137
                color: fuelBorder.border.color
                text: (fuelQty.height/fuelBorder.height*10).toFixed(0).toString()
                anchors.bottom: parent.bottom
                font.pixelSize: 100
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.horizontalCenterOffset: 5
                font.family: "BN Elements"
                anchors.bottomMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
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

}
