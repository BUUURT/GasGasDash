import QtQuick 2.2
import QtQuick.Window 2.1
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.4
import QtQuick.Controls.Universal 2.0

//gasdash todo

//[] pit message logic
//[x]ignition mapping
//[x]race data
//[]top speed visual
//[]gear pos movement

Window {
    id: root
    visible: true
    color: "#d8d9d8"
    //property alias rectangleWidth: rectangle.width
    width:1280
    height:800
    visibility: Window.Maximized

    property color fontColor: "black"
    property color fontBcolor: "gray"
    property bool darkMode: false
    //property string engineTemp: "0"
    property string gear: "N"
    property int engTemp: 220
    property int ignitionMapSetting: 1

    onDarkModeChanged: {
        if(root.darkMode==true){
            image.source= "backgroundMask_dark.png"
            root.fontColor="white"
        }
        if(root.darkMode==false){
            image.source= "backgroundMask_light.png"
            root.fontColor="black"
        }
    }
    onEngTempChanged: {
        const thresholds = [130, 160, 190, 220, 250]; // temp values(f) for blue, teal, green, yellow, red
        let colorIndex = thresholds.findIndex(i => root.engTemp < i);
        const lowerThreshold = thresholds[colorIndex-1];
        const upperThreshold = thresholds[colorIndex];
        const colorRatio = (root.engTemp-lowerThreshold)/(upperThreshold-lowerThreshold);

        let rgb = [0,0,0,0]
        switch (colorIndex){
        case 0:
            rgb=[0,0,1,1]
            break;
        case 1:
            rgb=[0,colorRatio,1,1]
            break;
        case 2:
            rgb=[0,1,colorRatio,1]
            break;
        case 3:
            rgb=[colorRatio,1,0,1]
            break;
        case 4:
            rgb = rgb=[1,colorRatio,0,1]
            break;
        case -1:
            rgb=[1,0,0,1]
            //TODO: flashing alarm light
            break;
        }
        engineTemp.rectangleColor = Qt.rgba(...rgb)
    }
//    Timer {
//        interval: 16
//        running: true
//        repeat: true
//        onTriggered: {
//            var sensorDict = con.sensorRefresh()
//            root.rpm = parseInt(sensorDict['rpm'])
//            speed.text = parseInt(sensorDict['speed'])
//        }
//    }
    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            sessionTimer.boxValueText=con.sessionTime()
            console.log(con.sessionTime())
            
        }
     
    }


    Rectangle {
        id: rpmBar
        width: 498
        color: "#010073"
        border.width: 0
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.top
        anchors.bottomMargin: -450
        anchors.topMargin: 80
        anchors.leftMargin: 0
    }

    Image {
        id: image
        visible: true
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        smooth: false
        source: "backgroundMask_light.png"
        sourceSize.height: 801
        sourceSize.width: 1281
        anchors.rightMargin: 0
        anchors.leftMargin: 0
        anchors.bottomMargin: 0
        anchors.topMargin: 0
        fillMode: Image.Stretch
        Item {
            id: bikeData
            x: 27
            y: 533
            width: 761
            height: 254



            ValueBox {
                id: ignitionMap
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.left
                anchors.bottom: parent.bottom
                anchors.rightMargin: -250
                anchors.bottomMargin: 15
                anchors.leftMargin: 50
                boxValueColor: root.fontColor
                boxValueText: {root.ignitionMapSetting.toString()}
                labelText: "IGN MAP"
                rectangleColor: "#00ffffff"

                MouseArea {
                    id: mouseArea2
                    width: ignitionMap.width
                    height: ignitionMap.height
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    onPressed: {
                        (root.ignitionMapSetting<4)? root.ignitionMapSetting +=1 : root.ignitionMapSetting = 1
                    }
                }
            }

            ValueBox {
                id: engineTemp
                x: 197
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: ignitionMap.right
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 15
                anchors.verticalCenterOffset: 0
                anchors.rightMargin: 261
                anchors.leftMargin: 50
                boxValueColor: root.fontColor
                boxValueText: {root.engTemp.toString()}
                labelText: "ENG TEMP"
                rectangleColor: "#00ffffff"

            }
        }

        ValueBox {
            id: gearPos
            width: 159
            height: 151
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 5
            anchors.topMargin: 5
            boxValueColor: "black"//root.fontColor
            boxValueText: root.gear
            labelText: "GEAR"
            rectangleColor: "#00ff00"

            MouseArea {
                id: mouseArea
                width: gearPos.width
                height: gearPos.height
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                layer.enabled: true
                cursorShape: Qt.BlankCursor
                acceptedButtons: Qt.AllButtons
                //anchors.horizontalCenter: parent.horizontalCenter
                onPressed: {
                    root.darkMode = !root.darkMode
                }
            }
        }

        Item {
            id: raceData
            x: 631
            y: 341
            width: 625
            height: 446

            ValueBox {
                id: sessionTimer
                x: 59
                width: 450
                height: 200
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: 10
                anchors.topMargin: 15
                labelText: "Session Timer"
                rectangleColor: "#00ffffff"
                boxValueColor: root.fontColor
                boxValueText: "29:54"
                boxValueFontfamily: "Arial"


            }

            ValueBox {
                id: position
                y: 234
                width: 186
                height: 200
                anchors.left: sessionTimer.left
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 15
                anchors.leftMargin: 0
                labelText: "Position"
                rectangleColor: "#00ffffff"
                boxValueColor: root.fontColor
                boxValueText: "15"
                boxValueFontfamily:"Arial"
            }

            ValueBox {
                id: lapCount
                y: 234
                height: 200
                anchors.left: position.right
                anchors.right: sessionTimer.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: 10
                anchors.bottomMargin: 15
                anchors.rightMargin: 0
                labelText: "Lap"
                rectangleColor: "#00ffffff"
                boxValueColor: root.fontColor
                boxValueText: "650"
                boxValueFontfamily: "Arial"


            }

            FuelLevel {
                id: fuelBar
                x: 26
                y: 106
                anchors.right: position.left
                anchors.bottom: position.bottom
                //fuelBorderColor: root.fontColor
                anchors.rightMargin: 10
                anchors.bottomMargin: 0
            }
        }

        PitMsg {
            id: pitMsg
            x: 184
            width: 1100
            height: 100
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 0
            anchors.topMargin: 0
        }

        Speed {
            id: speed
            x: 132
            y: 302
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: 130
            anchors.bottomMargin: 250
            speedLabelColor: root.fontBcolor
            speedTextText: "28"
            speedTextColor: root.fontColor
            visible: true


        }


    }

    Dial {
        id: dial
        x: 258
        y: 0
        stepSize: 1
        bottomPadding: 1
        from: 1280
        value:1
        onValueChanged: {
            //root.engTemp = value
            //rpmBar.width = value
            fuelBar.fuelQtyHeight = value
        }

    }

}









