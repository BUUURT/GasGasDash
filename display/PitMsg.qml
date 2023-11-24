import QtQuick 2.0

Item {
    id: item1
    height: 80
    property alias text1Color: text1.color
    property alias rectangleColor: rectangle.color

    Rectangle {
        id: rectangle
        width: 640
        height: 80
        color: "#00ffffff"
        radius: 10
        border.color: "#00ffffff"
        anchors.verticalCenter: parent.verticalCenter
        state: ""
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            id: text1
            width: item1.width
            height: item1.height
            text: qsTr("PIT MESSAGE")
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 90
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "Arial"
            fontSizeMode: Text.Fit
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

}
