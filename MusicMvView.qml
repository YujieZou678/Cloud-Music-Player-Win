/*
author: zouyujie
date: 2024.4.9
function: MV视图。
*/
import QtQuick
import QtQuick.Layouts
import QtMultimedia
import QtQuick.Controls
import "requestNetwork.js" as MyJs //命名首字母必须大写，否则编译失败

Item {
    id: self
    anchors.fill: parent

    property alias mvMediaPlayer: mvMediaPlayer
    property bool needStop: false  //timer是否需要暂停

    property string mvSource: ""  //mv播放地址
    property int itemIndex: 0
    property string mvId: ""  //mvId
    onMvIdChanged: {
        //网络请求
        MyJs.postRequest("/mv/detail?mvid="+mvId, handleData1)
        MyJs.postRequest("/mv/url?id="+mvId, handleData2)
    }
    function handleData1(data) {
        var result = JSON.parse(data)
        var mvData = result.data

        mvName.text = mvData.name  //mv名
        mvArtist.text = mvData.artistName  //作者名
        mvPlayCount.text = mvData.playCount  //播放次数
        mvPublishTime.text = mvData.publishTime  //发布时间
    }
    function handleData2(data) {
        var result = JSON.parse(data)
        var mvData = result.data

        mvSource = mvData.url  //播放地址
        mvMediaPlayer.play()
    }

    function enterLoadingView() {  //进入mv加载视图
        imageLoading.visible = true
        mvCenter.visible = false
    }
    function exitLoadingView() {  //推出mv加载视图
        mvCenter.visible = true
        imageLoading.visible = false
    }

    //缓冲画面
    Image {
        id: imageLoading
        visible: true
        source: "qrc:/images/loading.png"
        width: 35; height: 35
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

    Timer {  //判断隐藏menuBar
        id: timer
        interval: 5000
        repeat: false
        running: false
        onTriggered: {
            showMenuBar(false)
        }
    }

    Timer {
        id: m_timer
        interval: 200
        repeat: false

        //单击后200ms没其他单击 判断为单击
        onTriggered: {
            //console.log("我单击了")
            switch (mvMediaPlayer.playbackState) {
            case MediaPlayer.PlayingState:
                mvMediaPlayer.pause()
                break;
            case MediaPlayer.PausedState:
                mvMediaPlayer.play()
                break;
            }
        }
    }

    function showMenuBar(visible) {
        if (visible) {
            progressBar.visible = true
            mouseArea.cursorShape = Qt.ArrowCursor
        }
        else {
            progressBar.visible = false
            mouseArea.cursorShape = Qt.BlankCursor
        }
    }

    ColumnLayout {
        id: mvCenter
        visible: false
        anchors.fill: parent
        spacing: 0

        Rectangle {  //上
            id: upperLayer
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "black"
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onPositionChanged: {
                    timer.restart()
                    showMenuBar(true)
                }
                onHoveredChanged: {
                    if (needStop) { timer.stop(); needStop = false; }
                    else needStop = true
                }
                onReleased: {  //释放鼠标 判断单击或者双击
                    if (m_timer.running) {
                        //console.log("我双击了")
                        switch (window.visibility) {
                        case Window.FullScreen:
                            videoOutPut.fillMode = Image.PreserveAspectCrop  //恢复缩放模式
                            pageHomeView.showOtherModule()
                            window.showTopModule()
                            layoutBottomView.visible = true
                            downLayer.visible = true
                            window.showNormal()
                            window.restoreWindowSize()
                            break
                        case Window.Windowed:
                            videoOutPut.fillMode = Image.PreserveAspectFit  //全屏更换缩放模式
                            /* 隐藏4个其他模块 */
                            pageHomeView.hideOtherModule()
                            window.hideTopModule()
                            layoutBottomView.visible = false
                            downLayer.visible = false
                            window.showFullScreen()
                            break
                        }
                        m_timer.stop()
                    } else m_timer.restart()
                }
            }

            ColumnLayout {  //进度条栏
                z: 10
                anchors.fill: parent
                spacing: 0

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80

                    RowLayout {  //进度条栏
                        id: progressBar
                        anchors.fill: parent
                        spacing: 0

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width*0.93

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 0

                                Item {  //进度条
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: parent.height*0.3

                                    Slider {
                                        id: slider
                                        anchors.centerIn: parent
                                        width: parent.width*0.98
                                        height: 10
                                        handle: Rectangle { visible: false }
                                        value: mvMediaPlayer.duration > 0 ? mvMediaPlayer.position / mvMediaPlayer.duration : 0
                                        onMoved: {
                                            mvMediaPlayer.position = mvMediaPlayer.duration * slider.position
                                        }
                                        background: Rectangle {
                                            x: slider.leftPadding
                                            y: slider.topPadding + (slider.availableHeight - height)/2
                                            width: slider.availableWidth
                                            height: 4
                                            radius: 2
                                            color: "#e9f4ff"
                                            Rectangle {
                                                width: slider.visualPosition*parent.width; height: parent.height
                                                radius: 2
                                                color: "#8cecf3"
                                            }
                                        }
                                    }
                                }
                                Item {  //进度条下方的组件
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: parent.height*0.7

                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 0

                                        Item {  //暂停/播放
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: 60
                                            MusicToolButton {
                                                anchors.fill: parent
                                                iconSource: mvMediaPlayer.playbackState===1 ? "qrc:/images/pause.png":"qrc:/images/play_ing.png"
                                                icon.height: 38
                                                icon.width: 38
                                                ifNeedToolTip: false
                                                ifNeedClickBac: false
                                                onClicked: {
                                                    switch (mvMediaPlayer.playbackState) {
                                                    case MediaPlayer.PlayingState:
                                                        mvMediaPlayer.pause()
                                                        break;
                                                    case MediaPlayer.PausedState:
                                                        mvMediaPlayer.play()
                                                        break;
                                                    }
                                                }
                                            }
                                        }
                                        Item {  //时间
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: 100
                                            Text {
                                                anchors.centerIn: parent
                                                text: getTime(mvMediaPlayer.position/1000)+"/"+getTime(mvMediaPlayer.duration/1000)
                                                color: "#eeffffff"
                                                font {
                                                    family: mFONT_FAMILY
                                                    pointSize: 12
                                                    bold: true
                                                }
                                            }
                                        }
                                        Item {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                        }
                                        Item {  //全屏
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: 40
                                            MusicToolButton {
                                                anchors.fill: parent
                                                iconSource: "qrc:/images/全屏.png"
                                                icon.height: 30
                                                icon.width: 30
                                                ifNeedToolTip: false
                                                ifNeedClickBac: false
                                                onClicked: {
                                                    switch (window.visibility) {
                                                    case Window.FullScreen:
                                                        videoOutPut.fillMode = Image.PreserveAspectCrop  //恢复缩放模式
                                                        pageHomeView.showOtherModule()
                                                        window.showTopModule()
                                                        layoutBottomView.visible = true
                                                        downLayer.visible = true
                                                        window.showNormal()
                                                        window.restoreWindowSize()
                                                        break
                                                    case Window.Windowed:
                                                        videoOutPut.fillMode = Image.PreserveAspectFit  //全屏更换缩放模式
                                                        /* 隐藏4个其他模块 */
                                                        pageHomeView.hideOtherModule()
                                                        window.hideTopModule()
                                                        layoutBottomView.visible = false
                                                        downLayer.visible = false
                                                        window.showFullScreen()
                                                        break
                                                    }
                                                }
                                            }
                                        }  //end 全屏
                                    }
                                }
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }
                }
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

//                Item {
//                    Layout.fillWidth: true
//                    Layout.fillHeight: true
//                }
                Item {  //播放窗口
//                    Layout.preferredWidth: parent.height/3*4
//                    Layout.preferredHeight: parent.height
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    MediaPlayer {
                        id: mvMediaPlayer
                        audioOutput: audioOutPut
                        videoOutput: videoOutPut
                        source: mvSource
                        onMediaStatusChanged: {
                            switch(mvMediaPlayer.mediaStatus) {
                            case MediaPlayer.LoadingMedia:
                                //正在加载媒体,正在播放
                                console.log("开始加载mv")
                                break;
                            case MediaPlayer.BufferingMedia:
                                //数据正在缓冲
                                console.log("BufferingMedia......")
                                break;
                            case MediaPlayer.BufferedMedia:
                                //数据缓冲完成
                                mvCenter.visible = true
                                imageLoading.visible = false
                                console.log("开始播放mv")
                                break;
                            case MediaPlayer.StalledMedia:
                                //缓冲数据被打断
                                console.log(5)
                                break;
                            case MediaPlayer.InvalidMedia:
                                console.log("The media cannot be played")
                                break;
                            }
                        }
                    }
                    AudioOutput {
                        id: audioOutPut
                    }
                    VideoOutput {
                        id: videoOutPut
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop  //均匀缩放填充
                    }
                }
//                Item {
//                    Layout.fillWidth: true
//                    Layout.fillHeight: true
//                }
            }
        }

        Item {  //下
            id: downLayer
            Layout.fillWidth: true
            Layout.preferredHeight: window.height*0.2

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Item {  //第一排信息
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    RowLayout {
                        anchors.fill: parent
                        spacing: 0

                        Item {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 60
                        }
                        Text {
                            id: mvName
                            text: "送你一朵小红花（《送你一朵小红花》电影主题曲）"
                            color: "#eeffffff"
                            font {
                                pointSize: 12
                                family: mFONT_FAMILY
                                bold: true
                            }
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 5
                }
                Item {  //第二排信息
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    RowLayout {
                        anchors.fill: parent
                        spacing: 0

                        Item {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 60
                        }
                        Text {
                            text: "演唱："
                            color: "#eeffffff"
                            font {
                                pointSize: 12
                                family: mFONT_FAMILY
                            }
                            opacity: 0.5
                        }
                        Text {
                             id: mvArtist
                            text: "赵英俊"
                            color: "#eeffffff"
                            font {
                                pointSize: 12
                                family: mFONT_FAMILY
                            }
                        }
                        Item {
                            Layout.preferredWidth: 8
                        }
                        Text {
                            id: mvPlayCount
                            text: "1521.42万"
                            color: "#eeffffff"
                            font {
                                pointSize: 12
                                family: mFONT_FAMILY
                            }
                            opacity: 0.5
                        }
                        Text {
                            text: "次播放"
                            color: "#eeffffff"
                            font {
                                pointSize: 12
                                family: mFONT_FAMILY
                            }
                            opacity: 0.5
                        }
                        Item {
                            Layout.preferredWidth: 8
                        }
                        Text {
                            text: "发布时间："
                            color: "#eeffffff"
                            font {
                                pointSize: 12
                                family: mFONT_FAMILY
                            }
                            opacity: 0.5
                        }
                        Text {
                            id: mvPublishTime
                            text: "2020-12-15"
                            color: "#eeffffff"
                            font {
                                pointSize: 12
                                family: mFONT_FAMILY
                            }
                            opacity: 0.5
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                        }
                    }
                }
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
            }

//            ListView {
//                id: listView
//                anchors.fill: parent
//                model: 10
//                clip: true
//                header: Item {
//                    height: self.height-window.height*0.68
//                    width: 200
//                    Text {
//                        text: "推荐MV"
//                        font {
//                            pointSize: 18
//                            family: mFONT_FAMILY
//                            bold: true
//                        }
//                        anchors.centerIn: parent
//                        color: "#eeffffff"
//                    }
//                }

//                delegate: Image {
//                    height: self.height-window.height*0.68
//                    width: self.width/4
//                    source: "qrc:/images/12.png"
//                }
//                orientation: ListView.Horizontal
//                onContentXChanged: {
//                    if (contentX < -20-200) contentX = -200
//                    if (contentX > self.width/7*10+100) contentX = self.width/7*10+60
//                }
//                MouseArea {
//                    anchors.fill: parent
//                    onWheel: function (wheel) {
//                        if (wheel.angleDelta.y < 0) {
//                            listView.contentX += 200
//                        }
//                        else {
//                            listView.contentX -= 200
//                        }
//                    }
//                }
//                Behavior on contentX {
//                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
//                }

////                ScrollBar.horizontal: ScrollBar {
////                    id: scrollBar
////                    anchors.bottom: parent.bottom
////                }
//            }
        }
    }
}


