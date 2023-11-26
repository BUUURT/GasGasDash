import QtQuick 2.2

Item {

    id: item1
    Rectangle {
        id: rectangle
        x: 194
        y: 140
        width: 200
        height: 200
        color: "blue"
    }
    states: [
        State {
            name: "State1"
            PropertyChanges {target: rectangle; color: "green"}
        },
        State {
            name: "State2"
            PropertyChanges {target: rectangle; color: "red"}
        }
    ]

}
