/*
author: zouyujie
date: 2023.11.18
function: 图片视图
*/
import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Item {
    property string imgSrc: ""
    property int borderRadius: 5
    property alias imageLoading: imageLoading

    Image{
        id:image
        anchors.centerIn: parent
        source: imgSrc
        smooth: true
        visible: false
        width: parent.width
        height: parent.height
        fillMode: Image.PreserveAspectCrop
        antialiasing: true
        cache: true  //缓存
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
                loadingProgress.visible = true
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
        visible: false
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
    }

    OpacityMask{
        anchors.fill:image
        source: image
        maskSource: mask
        visible: true
        antialiasing: true
    }
}

