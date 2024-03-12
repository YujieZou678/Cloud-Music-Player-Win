/*
author: zouyujie
date: 2023.11.18
function: 图片视图
*/
import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Rectangle {
    property string imgSrc: ""
    property int borderRadius: 5
    property bool isRotating: false
    property real rotationAngle: 0.0
    property alias imageLoading: imageLoading
    property alias loadingProgress: loadingProgress

    radius: borderRadius

    gradient: Gradient {  //渐变
        GradientStop {
            position: 0.0
            color: "#101010"
        }
        GradientStop {
            position: 0.5
            color: "#a0a0a0"
        }
        GradientStop {
            position: 1.0
            color: "#505050"
        }
    }

    Image{
        id:image
        anchors.centerIn: parent
        source: imgSrc
        smooth: true
        visible: false
        width: parent.width*0.9
        height: parent.height*0.9
        fillMode: Image.PreserveAspectCrop
        antialiasing: true  //抗锯齿
        cache: true
        //当状态改变时
        onStatusChanged: {
            switch (image.status) {
            case Image.Ready:
                imageLoading.visible = false
                loadingProgress.visible = false
                break;
            case Image.Loading:
                //加载缓冲的画面，可能一直loading
                imageLoading.visible = true
                break;
            case Image.Error:
                console.log("图片加载错误......")
                image.source = "qrc:/images/errorLoading.png"
                break;
            }
        }
    }

    //缓冲画面
    Image {
        id: imageLoading
        source: "qrc:/images/loading.png"
        width: 20; height: 20
        visible: false
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
    Text {
        id: loadingProgress
        //向下取整
        text: Math.floor(image.progress*100)+"%"
        font.pixelSize: 15
        anchors.top: imageLoading.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 15
    }

    Rectangle{
        id:mask
        color: "black"
        anchors.fill: parent
        radius: borderRadius
        visible: false
        smooth: true
        antialiasing: true
        border.width: 20
        border.color: "#ffffff"
    }

    OpacityMask{  //mask,处理图片可视范围
        id: realImage
        anchors.fill:image
        source: image
        maskSource: mask
        visible: true  //我们看到的图片，对image进行处理后的，image本身是不可见的
        antialiasing: true  //抗锯齿
    }

    NumberAnimation {
        running: isRotating
        loops: Animation.Infinite
        target: realImage
        from: rotationAngle
        to: rotationAngle+360
        property: "rotation"  //旋转
        duration: 10000
        onStopped: {
            rotationAngle = realImage.rotation
        }
    }
}

