import QtQuick

Item {
    id: item1
    width: 525
    height: 250
    property alias speedTextColor: speedText.color
    property alias speedTextText: speedText.text
    property alias speedLabelColor: speedLabel.color

    Text {
        id: speedText
        width: item1.width
        height: item1.height
        text: qsTr("128")
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 300
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: "BN Elements"

        Text {
            id: speedLabel
            width: 88
            text: qsTr("MPH")
            anchors.top: parent.bottom
            font.pixelSize: 30
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.topMargin: -40
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: "BN Elements"
        }
    }

}
