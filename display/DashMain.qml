import QtQuick 2.2
import QtQuick.Window 2.1
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.4
import QtQuick.Controls.Universal 2.0

//TODO
//[x]ignition mapping send to bike signal
//[x]top speed visual
//[x]gear pos animation
//[x]fix session time animation
//[x] rpm shift light
//[x]low fuel visual alarm
//[x] alarm on session time
//[] pit message two way logic
//[] menu for pit
//[] launch control
// - exit button
// - fix scale
// - button animation
// - disable with speed


Window {
    id: root
    visible: true
    color: "#cbcbcb"
    //property alias rectangleWidth: rectangle.width
    width: 1280
    height: 800
    visibility: Window.Maximized
    
    property color fontColor: "black"
    property color fontBcolor: "gray"
    property color fontColorOp: "black"
    property color blueHighlight: "#0050ff"
    property color rpmColor: "#010073"
    property color rpmColorYellow: "#dfff00"
    property color rpmColorShift: "#ff3000"
    property bool darkMode: false
    property string imageSource: "backgroundMask_light.png"
    property string gear: "N"
    property int engTemp: 0
    property int ignitionMapSetting: 1
    property int speed: 0
    property int oldSpeed1: 0
    property int oldSpeed2: 0
    property int speedPause: 0
    property int rpm: 0
    //    property int delay: 250
    property int fuelLevel: 100
    
    //launch control
    property int rpmBar: 4000
    property int step: 250
    
    onDarkModeChanged: {
        if (root.darkMode == true) {
            //            image.source = "backgroundMask_dark.png"
            root.imageSource = "backgroundMask_dark.png"
            root.fontColor = "white"
            root.fontColorOp = "black"
        }
        if (root.darkMode == false) {
            //            image.source = "backgroundMask_light.png"
            root.imageSource = "backgroundMask_light.png"
            root.fontColor = "black"
            root.fontColorOp = "black"
        }
    }
    onEngTempChanged: {
        const thresholds = [130, 160, 190, 220, 250]
        // temp values(f) for blue, teal, green, yellow, red
        let colorIndex = thresholds.findIndex(i => root.engTemp < i)
        const lowerThreshold = thresholds[colorIndex - 1]
        const upperThreshold = thresholds[colorIndex]
        const colorRatio = (root.engTemp - lowerThreshold) / (upperThreshold - lowerThreshold)
        
        let rgb = [0, 0, 0, 0]
        switch (colorIndex) {
        case 0:
            rgb = [0, 0, 1, 1]
            engineTemp_hot.running = false
            engineTemp.visible = true
            break
        case 1:
            rgb = [0, colorRatio, 1, 1]
            engineTemp_hot.running = false
            engineTemp.visible = true
            break
        case 2:
            rgb = [0, 1, 1 - colorRatio, 1]
            engineTemp_hot.running = false
            engineTemp.visible = true
            break
        case 3:
            rgb = [colorRatio, 1, 0, 1]
            engineTemp_hot.running = false
            engineTemp.visible = true
            break
        case 4:
            rgb = rgb = [1, 1 - colorRatio, 0, 1]
            engineTemp_hot.running = false
            engineTemp.visible = true
            break
        case -1:
            rgb = [1, 0, 0, 1]
            engineTemp_hot.running = true
            break
        }
        engineTemp.rectangleColor = Qt.rgba(...rgb)
    }
    
    onSpeedChanged: {
        if (root.speedPause == 0) {
            speed.speedTextText = root.speed.toString() //Update label
            if (root.speed < root.oldSpeed1
                    && root.oldSpeed1 >= root.oldSpeed2) {
                //max speed dropping
                maxSpeedFlash.running = true
                maxSpeed.text = root.oldSpeed1.toString()
            }
            root.oldSpeed2 = root.oldSpeed1
            root.oldSpeed1 = root.speed
        } else {
            speed.speedTextText = maxSpeed.text
        }
    }

    onGearChanged: {
        gearDial.state = root.gear
    }
    
    onRpmChanged: {
        rpmBar.width = root.rpm*1253/12000
        if(root.rpm<10000){
            rpmBar.state = "normal"}
        if(root.rpm>10000){
            rpmBar.state = "yellow"}
        if(root.rpm>10750){
            rpmBar.state = "shift"}
    }
    
    onFuelLevelChanged: {
        fuelBar.fuelQtyHeight = root.fuelLevel*325/100
        if(root.fuelLevel==100){fuelBar.state = "full"}
        else if(root.fuelLevel<10){fuelBar.state = "empty"}
        else if(root.fuelLevel<20){fuelBar.state = "reserve"}
        else if(root.fuelLevel<100){fuelBar.state = "mid"}
    }

    onRpmBarChanged: {
        launchBar.x = root.rpmBar*1280/12250
        limitDisplay.boxValueText = root.rpmBar
    }
    
    
    
    //TODO update sensor dict
    //    Timer {
    //        interval: 16
    //        running: true
    //        repeat: true
    //        onTriggered: {
    //            var sensorDict = con.sensorRefresh()
    //            root.rpm = parseInt(sensorDict['rpm'])
    //            speed.text = parseInt(sensorDict['speed'])
    // speed, rpm, air temp, gear
    
    //        }
    //    }
    //TODO raceData dictionary retrevial
    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            sessionTimer.boxValueText = con.sessionTime()
            if(sessionTimer.boxValueText[0]==="-"){overtimeFlasher.running=true}
            else {
                overtimeFlasher.running=false;
                sessionTimer.rectangleColor = "#00000000";
            }
        }
    }
    
    Rectangle {
        id: rpmBar
        width: 0
        color: root.rpmColor
        border.width: 0
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.top
        anchors.bottomMargin: -450
        anchors.topMargin: 80
        anchors.leftMargin: 0
        states: [
            State {
                name: "normal"
                PropertyChanges {target: shiftFlasherYellow; running: false}
                PropertyChanges {target: shiftFlasherRed; running: false}
                PropertyChanges {target: flasher; opacity: 0}
            },
            State {
                name: "yellow"
                PropertyChanges {target: shiftFlasherYellow; running: true}
                PropertyChanges {target: shiftFlasherRed; running: false}
                
                
            },
            State {
                name: "shift"
                PropertyChanges {target: shiftFlasherYellow; running: false}
                PropertyChanges {target: shiftFlasherRed; running: true}
            }
        ]
        SequentialAnimation {
            id: shiftFlasherRed
            loops: -1
            running: false
            PropertyAnimation {
                target: flasher
                property: "color"
                to: "#ff0000"
                duration:0
            }
            PropertyAnimation {
                target: flasher
                property: "opacity"
                to: 1
                duration: 100
                
            }
            PropertyAnimation {
                target: flasher
                property: "opacity"
                to: 0
                duration: 100
            }
        }
        SequentialAnimation {
            id: shiftFlasherYellow
            loops: -1
            running: false
            PropertyAnimation {
                target: flasher
                property: "color"
                to: "#ffff00"
                duration:0
            }
            PropertyAnimation {
                target: flasher
                property: "opacity"
                to: 1
                duration: 100
                
            }
            PropertyAnimation {
                target: flasher
                property: "opacity"
                to: 0
                duration: 100
            }
        }

        Rectangle {
            id: launchBar
            x: 348
            y: -321
            width: 10
            height: 200
            color: "#ff0000"
            anchors.top: parent.top
            anchors.topMargin: 0
        }
        
    }
    
    Image {
        id: image
        visible: true
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        smooth: false
        source: root.imageSource
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
                boxValueText: {
                    root.ignitionMapSetting.toString()
                }
                labelText: "IGN MAP"
                rectangleColor: "#00ffffff"
                boxValueStyleColor: root.fontColorOp
                
                MouseArea {
                    id: mouseArea2
                    width: ignitionMap.width
                    height: ignitionMap.height
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    onPressed: {
                        (root.ignitionMapSetting < 4) ? root.ignitionMapSetting
                                                        += 1 : root.ignitionMapSetting = 1
                        con.ignitionMapUpdate(root.ignitionMapSetting)
                    }
                }
            }
            
            ValueBox {
                id: engineTemp
                x: 197
                height: 224
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: ignitionMap.right
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 15
                anchors.verticalCenterOffset: 0
                anchors.rightMargin: 138
                anchors.leftMargin: 50
                boxValueColor: root.fontColor
                boxValueText: {
                    root.engTemp.toString()
                }
                labelText: "ENG TEMP"
                rectangleColor: "#00ffffff"
                visible: true
                boxValueStyleColor: root.fontColorOp
                SequentialAnimation {
                    id: engineTemp_hot
                    running: false
                    loops: Animation.Infinite
                    PropertyAnimation {
                        target: engineTemp
                        property: "visible"
                        to: false
                        duration: 150
                    }
                    PropertyAnimation {
                        target: engineTemp
                        property: "visible"
                        to: true
                        duration: 100
                    }
                }
            }
        }
        
        ValueBox {
            id: gearPos
            width: 159
            height: 151
            visible: true
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 5
            anchors.topMargin: 5
            boxValueColor: root.fontColor
            boxValueText: root.gear
            labelText: "GEAR"
            rectangleColor: "#00ff00"
            boxValueStyleColor: root.fontColorOp
        }
        
        Item {
            id: raceData
            x: 631
            y: 341
            width: 625
            height: 446
            ValueBox {
                id: position
                y: 234
                width: 186
                height: 200
                anchors.left: sessionTimer.left
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 15
                anchors.leftMargin: 0
                labelText: "POSITION"
                rectangleColor: "#00ffffff"
                boxValueColor: root.fontColor
                boxValueText: "X"
                boxValueFontfamily: "Arial"
                boxValueStyleColor: root.fontColorOp
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
                labelText: "LAP"
                rectangleColor: "#00ffffff"
                boxValueColor: root.fontColor
                boxValueText: "0"
                boxValueFontfamily: "Arial"
                boxValueStyleColor: root.fontColorOp
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
            ValueBox {
                id: sessionTimer
                x: 59
                width: 450
                height: 200
                anchors.right: parent.right
                anchors.top: parent.top
                rectangleColor: "#00ffffff"
                anchors.rightMargin: 10
                anchors.topMargin: 15
                labelText: "SESSION TIMER"
                boxValueColor: root.fontColor
                boxValueText: "29:54"
                boxValueFontfamily: "Arial"
                boxValueStyleColor: root.fontColorOp
                Rectangle {
                    id: resetBacklight
                    width: 0
                    height: 200
                    color: root.fontBcolor
                    radius: 10
                    border.width: 0
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                }
                SequentialAnimation {
                    id: resetFlash
                    running: false
                    ParallelAnimation {
                        PropertyAnimation {
                            target: sessionTimer
                            property: "scale"
                            to: .95
                            duration: 5
                        }
                    }
                    PropertyAnimation {
                        target: resetBacklight
                        property: "width"
                        to: 450
                        duration: 200
                    }
                    PropertyAnimation {
                        target: sessionTimer
                        property: "scale"
                        to: 1.1
                        duration: 50
                    }
                    PropertyAnimation {
                        target: resetBacklight
                        property: "width"
                        to: 0
                        duration: 0
                    }
                    PropertyAnimation {
                        target: sessionTimer
                        property: "scale"
                        to: 1
                        duration: 5
                    }
                }
                SequentialAnimation {
                    id: addTimeFlash
                    running: false
                    PropertyAnimation {
                        target: sessionTimer
                        property: "scale"
                        to: .95
                        duration: 5
                    }
                    PropertyAnimation {
                        target: sessionTimer
                        property: "scale"
                        to: 1.10
                        duration: 200
                    }
                    PropertyAnimation {
                        target: sessionTimer
                        property: "rectangleColor"
                        to: root.fontBcolor
                        duration: 100
                    }
                    PropertyAnimation {
                        target: sessionTimer
                        property: "scale"
                        to: 1
                        duration: 20
                    }
                    PropertyAnimation {
                        target: sessionTimer
                        property: "rectangleColor"
                        to: "#00ffffff"
                        duration: 20
                    }
                }
                SequentialAnimation {
                    id: overtimeFlasher
                    running: false
                    loops: -1
                    PropertyAnimation {
                        target: sessionTimer
                        property: "rectangleColor"
                        easing.bezierCurve: [0.2,0.2,0.8,0.8,1,1]
                        to: "#aaffff00"
                        duration: 500
                    }
                    PropertyAnimation {
                        target: sessionTimer
                        property: "rectangleColor"
                        easing.bezierCurve: [0.2,0.2,0.8,0.8,1,1]
                        to:"#00000000"
                        duration: 500
                    }
                }
                
                MouseArea {
                    id: mouseArea1
                    width: sessionTimer.width
                    height: sessionTimer.height
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    onPressAndHold: {
                        interval: 2000
                        con.sessionTime_Reset()
                        resetFlash.running = true
                    }
                    onClicked: {
                        con.sessionTime_plusFive()
                        addTimeFlash.running = true
                    }
                }
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
            speedTextColor: root.fontColor
            anchors.leftMargin: 130
            anchors.bottomMargin: 250
            speedLabelColor: root.fontBcolor
            speedTextText: "28"
            visible: true
            SequentialAnimation {
                id: maxSpeedFlash
                running: false
                ParallelAnimation {
                    PropertyAnimation {
                        target: root
                        property: "speedPause"
                        to: 1
                        duration: 0
                    }
                    PropertyAnimation {
                        target: speed
                        property: "scale"
                        to: 1.2
                        duration: 100
                    }
                }
                SequentialAnimation {
                    loops: 6
                    PropertyAnimation {
                        target: speed
                        property: "speedTextColor"
                        to: root.fontColor
                        duration: 50
                    }
                    PropertyAnimation {
                        target: speed
                        property: "speedTextColor"
                        to: "#ff00ff00"
                        duration: 100
                    }
                }
                PropertyAnimation {
                    target: root
                    property: "speedPause"
                    to: 0
                    duration: 0
                }
                PropertyAnimation {
                    target: speed
                    property: "speedTextColor"
                    to: root.fontColor
                    duration: 0
                }
                PropertyAnimation {
                    target: speed
                    property: "scale"
                    to: 1
                    duration: 0
                }
            }
            
            Text {
                id: maxSpeed
                width: 85
                height: 47
                color: root.fontColor
                text: qsTr("0")
                anchors.left: parent.right
                anchors.top: parent.top
                
                font.pixelSize: 75
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.leftMargin: -40
                anchors.topMargin: 20
                fontSizeMode: Text.Fit
                minimumPixelSize: 12
                font.family: "BN Elements"
                
                Text {
                    id: text1
                    width: 84
                    height: 28
                    color: root.fontColor
                    text: qsTr("MAX")
                    anchors.top: parent.bottom
                    font.pixelSize: 25
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: "BN Elements"
                    anchors.topMargin: -10
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
        
        Slider {
            id: slider
            x: 617
            y: 299
            width: 649
            height: 36
            stepSize: 1
            to: 300
            from: 1
            value: 0.5
            onValueChanged: {
                root.engTemp = value
            }
        }
        Slider {
            id: slider2
            x: 617
            y: 275
            width: 649
            height: 36
            stepSize: 1
            to: 100
            from: 0
            value: 0
            onValueChanged: {
                root.fuelLevel = value
            }
        }
        
        Slider {
            id: slider1
            x: 617
            y: 250
            width: 649
            height: 36
            value: 0
            stepSize: 1
            to: 100
            from: 0
            onValueChanged: {
                root.speed = value
            }
        }
        
        Slider {
            id: slider3
            x: 617
            y: 222
            width: 649
            height: 36
            value: 0
            stepSize: 1
            to: 4
            from: 0
            onValueChanged: {
                
                if (value == 0) {
                    root.gear = "N"
                } else {
                    root.gear = value.toString()
                }
            }
        }
        
        
        
        Slider {
            id: slider4
            x: 617
            y: 193
            width: 649
            height: 36
            value: 0
            stepSize: 1
            to: 12500
            from: 0
            onValueChanged: {
                root.rpm = value
            }
        }
        
        Rectangle {
            id: flasher
            y: 265
            width: root.width
            height: 100
            opacity: 0
            visible: true
            color: "#ff0000"
            anchors.top: parent.top
            anchors.horizontalCenterOffset: 0
            anchors.topMargin: 0
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Item {
            id: gearDial
            x: -486
            y: -556
            width: 800
            height: gearDial.width
            rotation: 0
            
            states: [
                State {
                    name: "N"
                    PropertyChanges {target: gearDial; rotation: 0}
                    PropertyChanges {target: gearDialCirc; color: "#00ff47"}
                },
                State {
                    name: "1"
                    PropertyChanges {target: gearDial; rotation: 72}
                    PropertyChanges {target: gearDialCirc; color: root.fontBcolor}
                },
                State {
                    name: "2"
                    PropertyChanges {target: gearDial; rotation: 144}
                    PropertyChanges {target: gearDialCirc; color: root.fontBcolor}
                },
                State {
                    name: "3"
                    PropertyChanges {target: gearDial; rotation: 216}
                    PropertyChanges {target: gearDialCirc; color: root.fontBcolor}
                },
                State {
                    name: "4"
                    PropertyChanges {target: gearDial; rotation: 288}
                    PropertyChanges {target: gearDialCirc; color: root.blueHighlight}
                }
            ]
            transitions: [
                Transition {
                    from: "*"
                    to: "*"
                    RotationAnimation {
                        target: gearDial
                        duration: 1000
                        easing.type: Easing.InOutQuad
                    }
                    
                    ColorAnimation {
                        target: gearDialCirc
                        easing.bezierCurve: [0.655,0.144,0.817,0.465,1,1]
                        duration: 300
                        //easing.type: Easing.InOutQuad
                    }
                }
                
            ]
            
            Rectangle {
                id: gearDialCirc
                width: gearDial.width
                height: gearDial.height
                color: "#6d6edf"
                radius: gearDial.width/2
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                
                MouseArea {
                    id: mouseArea
                    x: 0
                    y: 0
                    width: gearDial.width
                    height: gearDial.height
                    //                    anchors.verticalCenter: parent.verticalCenter
                    //                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.fill: parent
                    layer.enabled: true
                    cursorShape: Qt.BlankCursor
                    acceptedButtons: Qt.AllButtons
                    //anchors.horizontalCenter: parent.horizontalCenter
                    onPressed: {
                        root.darkMode = !root.darkMode
                    }
                }
            }
            Text {
                id: gearN
                color: root.fontColor
                style: Text.Outline
                styleColor: root.fontColorOp
                text: qsTr("N")
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                font.pixelSize: 200
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignBottom
                anchors.leftMargin: gearDial.width/2
                anchors.topMargin: gearDial.height/2
                transformOrigin: Item.TopLeft
                anchors.bottomMargin: 40
                anchors.rightMargin: 130
                font.family: "BN Elements"
            }
            
            Text {
                id: gear1
                color: root.fontColor
                style: Text.Outline
                styleColor: root.fontColorOp
                x: 4
                y: 4
                text: qsTr("1")
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                font.pixelSize: 200
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignBottom
                rotation: -72
                font.family: "BN Elements"
                anchors.leftMargin: gearDial.width/2
                transformOrigin: Item.TopLeft
                anchors.bottomMargin: 40
                anchors.rightMargin: 200
                anchors.topMargin: gearDial.height/2
            }
            
            Text {
                id: gear2
                color: root.fontColor
                style: Text.Outline
                styleColor: root.fontColorOp
                x: 1
                y: 1
                text: qsTr("2")
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                font.pixelSize: 200
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignBottom
                rotation: -144
                font.family: "BN Elements"
                anchors.leftMargin: gearDial.width/2
                transformOrigin: Item.TopLeft
                anchors.bottomMargin: 40
                anchors.rightMargin: 130
                anchors.topMargin: gearDial.height/2
            }
            
            Text {
                id: gear3
                color: root.fontColor
                style: Text.Outline
                styleColor: root.fontColorOp
                x: -1
                y: -1
                text: qsTr("3")
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                font.pixelSize: 200
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignBottom
                rotation: -216
                font.family: "BN Elements"
                anchors.leftMargin: gearDial.width/2
                transformOrigin: Item.TopLeft
                anchors.bottomMargin: 40
                anchors.rightMargin: 130
                anchors.topMargin: gearDial.height/2
            }
            
            Text {
                id: gear4
                color: root.fontColor
                style: Text.Outline
                styleColor: root.fontColorOp
                x: 4
                y: 4
                text: qsTr("4")
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                font.pixelSize: 200
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignBottom
                rotation: -288
                font.family: "BN Elements"
                anchors.leftMargin: gearDial.width/2
                transformOrigin: Item.TopLeft
                anchors.bottomMargin: 40
                anchors.rightMargin: 130
                anchors.topMargin: gearDial.height/2
            }
        }
    }

    MouseArea {
        id: launchButton
        x: 350
        width: 930
        height: 110
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 105
        anchors.rightMargin: 0
        onPressed: {
            if(root.speed<5){
                stateGroup.state = "launchControl"
            }
        }
    }

    Item {
        id: launchControl_group
        x: 668
        y: 345
        width: 480
        height: 445
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.rightMargin: 20
        
        ValueBox {
            id: limitDisplay
            height: 200
            boxValueColor: root.fontColor
            boxValueText: "5000"
            labelText: "LAUNCH CONTROL"
            rectangleColor: "#00ffffff"
            visible: true
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 0
            anchors.rightMargin: 15
            boxValueStyleColor: root.fontColorOp

        }

        Rectangle {
            id: twostepUp
            x: 101
            color: "#00000000"
            radius: 10
            border.color: root.fontBcolor
            border.width: 3
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: limitDisplay.top
            anchors.topMargin: 15
            anchors.bottomMargin: 15
            anchors.rightMargin: 15
            anchors.leftMargin: 0

            Text {
                id: up
                color: root.fontColor
                text: qsTr("UP")
                font.pixelSize: 200
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "BN Elements"
                fontSizeMode: Text.Fit
                anchors.fill: parent
            }

            MouseArea {
                id: mouseArea3
                width: 100
                height: 100
                anchors.fill: parent
                onPressed: {
                    root.rpmBar += root.step
                }
            }
        }

        Rectangle {
            id: twostepDown
            height: 93
            color: "#00000000"
            radius: 10
            border.color: root.fontBcolor
            border.width: 3
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: limitDisplay.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 15
            anchors.rightMargin: 15

            Text {
                id: down
                color: root.fontColor
                text: qsTr("DOWN")
                font.pixelSize: 200
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "BN Elements"
                fontSizeMode: Text.Fit
                anchors.fill: parent
            }

            MouseArea {
                id: mouseArea4
                width: 100
                height: 100
                anchors.fill: parent
                onPressed: {
                    root.rpmBar -= root.step
                }
            }
        }
    }
    
    StateGroup {
        id: stateGroup
        states: [
            State {
                name: "normal"
                PropertyChanges {target: bikeData; visible: true}
                PropertyChanges {target: raceData; visible: true}
                PropertyChanges {target: launchControl_group;visible: false}
                PropertyChanges {target: launchBar; visible: false}
            },
            State {
                name: "messages"
                PropertyChanges {target: bikeData; visible: false}
                PropertyChanges {target: raceData; visible: false}
                PropertyChanges {target: launchControl_group;visible: false}
                PropertyChanges {target: launchBar; visible: false}
            },
            State {
                name: "launchControl"
                PropertyChanges {target: bikeData; visible: true}
                PropertyChanges {target: raceData; visible: false}
                PropertyChanges {target: launchControl_group; visible: true}
                PropertyChanges {target: launchBar; visible: true}
                }

        ]
    }


}




