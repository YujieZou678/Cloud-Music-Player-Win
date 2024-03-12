/*
author: zouyujie
date: 2024.2.18
function: 背景。
*/
import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    //逻辑：两张图片切换，实现无缝衔接。
    property alias backgroundImageSrc1: backgroundImage1.source
    property alias backgroundImageSrc2: backgroundImage2.source

    property bool selectImage: true  //判断选哪个image,true为1,false为2
    property string originalImageSrc: "qrc:/images/player"  //原始的背景图片
    property alias pageViewBGState: realBackgroundImage3.visible  //主页背景状态
    function switchView(needLyricView = true) {  //切换背景，参数:是否需要歌词界面
        if (!selectImage) {
            if (needLyricView) {
                realBackgroundImage1.visible = true
                realBackgroundImage3.visible = false
            } else {
                realBackgroundImage3.visible = true
                realBackgroundImage1.visible = false
            }
        }
        else {
            if (needLyricView) {
                realBackgroundImage2.visible = true
                realBackgroundImage3.visible = false
            } else {
                realBackgroundImage3.visible = true
                realBackgroundImage2.visible = false
            }
        }
    }

    Image {
        id: backgroundImage1
        source: originalImageSrc
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        cache: true
        visible: false  //不是真正的对象
        onStatusChanged: {
            switch (status) {
            case Image.Ready:
                realBackgroundImage1.visible = true
                realBackgroundImage2.visible = false
                break;
            case Image.Loading:
                realBackgroundImage2.visible = true
                realBackgroundImage1.visible = false
                break;
            case Image.Error:
                console.log("背景图片加载错误......")
                break;
            }
        }
    }

    Image {
        id: backgroundImage2
        source: originalImageSrc
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        cache: true
        visible: false  //不是真正的对象
        onStatusChanged: {
            switch (status) {
            case Image.Ready:
                realBackgroundImage2.visible = true
                realBackgroundImage1.visible = false
                break;
            case Image.Loading:
                realBackgroundImage1.visible = true
                realBackgroundImage2.visible = false
                break;
            case Image.Error:
                console.log("背景图片加载错误......")
                break;
            }
        }
    }

    Image {
        id: backgroundImage3  //原始背景
        source: originalImageSrc
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        cache: true
        visible: false  //不是真正的对象
    }

    ColorOverlay {  //颜色滤镜
        id: backgroundImageOverlay1
        anchors.fill: backgroundImage1
        source: backgroundImage1
        color: "#35000000"
        visible: false
    }

    FastBlur {  //模糊，真正的对象
        id: realBackgroundImage1
        anchors.fill: backgroundImageOverlay1
        source: backgroundImageOverlay1
        radius: 80
        visible: false
    }

    ColorOverlay {
        id: backgroundImageOverlay2
        anchors.fill: backgroundImage2
        source: backgroundImage2
        color: "#35000000"
        visible: false
    }

    FastBlur {
        id: realBackgroundImage2
        anchors.fill: backgroundImageOverlay2
        source: backgroundImageOverlay2
        radius: 80
        visible: false
    }

    ColorOverlay {
        id: backgroundImageOverlay3
        anchors.fill: backgroundImage3
        source: backgroundImage3
        color: "#35000000"
        visible: false
    }

    FastBlur {
        id: realBackgroundImage3
        anchors.fill: backgroundImageOverlay3
        source: backgroundImageOverlay3
        radius: 80
        visible: true
    }
}
