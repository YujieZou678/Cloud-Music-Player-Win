//LoadingView.qml

import QtQuick
import QtQuick.Controls

Item {

    property alias image: imageLoading

    Image {
        id: imageLoading
        source: "qrc:/images/loading.png"
        width: 30; height: 30;
        visible: true
        anchors.centerIn: parent
    }

    RotationAnimation {
        target: imageLoading
        from: 0
        to: 360
        duration: 2000
        running: true
        loops: Animation.Infinite
    }
}
