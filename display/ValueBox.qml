import QtQuick

Item {
    id: item1
    width: 200
    height: 200
    property alias boxValueStyleColor: boxValue.styleColor
    property alias rectangleBordercolor: rectangle.border.color
    property alias boxValueFontfamily: boxValue.font.family
    property alias rectangleColor: rectangle.color
    property alias boxValueColor: boxValue.color
    property alias boxValueText: boxValue.text
    property alias labelText: label.text

    Rectangle {
        id: rectangle
        width: item1.width
        height: item1.height
        color: "#ffffff"
        radius: 10
        border.color: "#818181"
        border.width: 3
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            id: boxValue
            width: item1.width*.90
            height: item1.height
            color: "#000000"
            text: "222"
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            style: Text.Outline
            font.pointSize: 125
            font.bold: true
            fontSizeMode: Text.Fit
            font.family: "BN Elements"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            id: label
            y: 168
            width: item1.width
            color: rectangle.border.color
            text: qsTr("Label")
            anchors.bottom: parent.bottom
            font.pixelSize: item1.height*0.1
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "BN Elements"
            anchors.bottomMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

}
