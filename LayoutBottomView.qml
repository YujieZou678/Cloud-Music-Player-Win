/*
author: zouyujie
date: 2023.11.18
function: 最下面那层部件，播放，切换歌曲，进度条......
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import "requestNetwork.js" as MyJs

Rectangle {

    property alias slider: slider
    property alias nameText: nameText.text
    property alias timeText: timeText.text
    property alias modePlay: playMode.toolTip  //播放模式
    property alias playStateSource: playIconButton.iconSource  //播放/暂停按钮
    property alias musicCoverSrc: musicCover.imgSrc  //图片信息

    property var playModeSwitch: [  //播放模式提示语的数组
        { name: "顺序播放", source: "qrc:/images/repeat.png"},
        { name: "随机播放", source: "qrc:/images/random.png"},
        { name: "循环播放", source: "qrc:/images/single-repeat.png"}
    ]
    property int indexPlayMode: 0

    function refreshBottomFavorite() {
        ifIsFavoriteButton.ifFavorite = mainAllMusicList[mainAllMusicListIndex].ifIsFavorite
    }

    Layout.fillWidth: true
    height: 60
    color: "#1500AAAA"

    //Layout布局(有些组件属性可能就没用)
    RowLayout {
        anchors.fill: parent
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width/10
        }
        MusicIconButton {
            Layout.preferredWidth: 50
            iconSource: "qrc:/images/previous.png"
            iconWidth: 32; iconHeight: 32
            toolTip: "上一曲"
            onClicked: {
                MyJs.switchSong(false, modePlay, false)
            }
        }
        MusicIconButton {
            id: playIconButton
            Layout.preferredWidth: 50
            iconSource: window.mediaPlayer.playbackState===1 ? "qrc:/images/pause.png":"qrc:/images/play_ing.png"
            iconWidth: 32; iconHeight: 32
            toolTip: window.mediaPlayer.playbackState===1 ? "暂停":"播放"
            onClicked: {
                switch (window.mediaPlayer.playbackState) {
                case MediaPlayer.PlayingState:
                    window.mediaPlayer.pause()
                    iconSource = "qrc:/images/play_ing.png"
                    pageDetailView.cover.isRotating = false
                    break;
                case MediaPlayer.PausedState:
                    window.mediaPlayer.play()
                    iconSource = "qrc:/images/pause.png"
                    pageDetailView.cover.isRotating = true
                    break;
                }
            }
        }
        MusicIconButton {
            Layout.preferredWidth: 50
            iconSource: "qrc:/images/next.png"
            iconWidth: 32; iconHeight: 32
            toolTip: "下一曲"
            onClicked: {
                MyJs.switchSong(true, modePlay, false)
            }
        }
        //不是具体组件，没有默认属性，宽高会伸缩
        Item {
            visible: !layoutTopView.isSmallWindow
            Layout.preferredWidth: parent.width/2
            //可伸缩属性
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 25

            Text {
                id: nameText
                text: qsTr("云坠入雾里")
                anchors.left: slider.left
                anchors.bottom: slider.top
                font.family: "微软雅黑"
                color: "#ffffff"
            }
            Text {
                id: timeText
                text: qsTr("00:00/05:30")
                anchors.right: slider.right
                anchors.bottom: slider.top
                font.family: "微软雅黑"
                color: "#ffffff"
            }

            //具体组件有默认属性，宽高不会伸缩
            Slider {
                id: slider
                width: parent.width
                //一定要给显式的高，默认宽高仅在默认滑块上有
                height: 20
                visible: !layoutTopView.isSmallWindow
                //MediaPlayer.position应该是0-duration，而slider.position是0-1
                value: mediaPlayer.duration > 0 ? mediaPlayer.position / mediaPlayer.duration : 0
                onMoved: {
                    mediaPlayer.position = mediaPlayer.duration * slider.position
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
                property alias handleRec: handleRec
                handle: Rectangle {
                    id: handleRec
                    x: slider.leftPadding + (slider.availableWidth - width)*slider.visualPosition
                    y: slider.topPadding + (slider.availableHeight - height)/2
                    width: 15; height: 15
                    radius: 10
                    color: "#f0f0f0"
                    border.color: "#73a7ab"
                    border.width: 0.5

                    property alias imageLoading: imageLoading
                    //缓冲画面
                    Image {
                        id: imageLoading
                        source: "qrc:/images/loading.png"
                        width: 12; height: 12
                        visible: false
                        anchors.centerIn: parent
                    }
                    RotationAnimation {
                        target: imageLoading
                        from: 0
                        to: 360
                        duration: 500
                        running: true
                        loops: Animation.Infinite
                    }
                }
            }
        }
        MusicBorderImage {
            id: musicCover
            width: 50; height: 50
            visible: !layoutTopView.isSmallWindow
            imgSrc: "qrc:/images/errorLoading.png"
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: {
                    musicCover.scale = 0.9
                }
                onReleased: {
                    musicCover.scale = 1
                }

                onClicked: {
                    //视图切换
                    pageDetailView.visible = ! pageDetailView.visible
                    pageHomeView.visible = ! pageHomeView.visible

                    //背景也随之切换
                    if (mainBackground.pageViewBGState) { mainBackground.switchView(true) }
                    else mainBackground.switchView(false)

                    //暂停歌词视图的timer
                    pageDetailView.timer.stop()
                }
            }
        }
        MusicIconButton {
            id: ifIsFavoriteButton
            Layout.preferredWidth: 50
            iconSource: "qrc:/images/favorite.png"
            iconWidth: 32; iconHeight: 32
            toolTip: "我喜欢"
            onClicked: {
                if (mainAllMusicList.length === 0) return

                ifFavorite = !ifFavorite  //可以同步当前列表
                if (mainModelName === "DetailHistoryPageView") {  //历史列表单独处理
                    mainAllMusicList[0].ifIsFavorite = !mainAllMusicList[0].ifIsFavorite
                    var loader = pageHomeView.repeater.itemAt(3)
                    loader.item.refreshList()  //刷新
                    MyJs.changeAndSaveFavoriteList(!mainAllMusicList[0].ifIsFavorite, mainAllMusicList[0])
                    return
                }

                mainAllMusicList[mainAllMusicListIndex].ifIsFavorite = !mainAllMusicList[mainAllMusicListIndex].ifIsFavorite
                //当前正在播放歌曲的页面需要立刻刷新，历史页面一定需要刷新
                switch (mainModelName) {
                case "DetailSearchPageView":
                    var loader = pageHomeView.repeater.itemAt(1)
                    loader.item.refreshList()  //刷新
                    break;
                case "DetailPlayListPageView":
                    var loader = []
                    if (pageHomeView.ifPlaying === 0) { loader = pageHomeView.repeater.itemAt(5) }
                    else if (pageHomeView.ifPlaying === 1) { loader = pageHomeView.repeater.itemAt(6) }
                    loader.item.refreshList()  //刷新
                    break;
                case "DetailLocalPageView":
                    var loader = pageHomeView.repeater.itemAt(2)
                    loader.item.refreshList()  //刷新
                    break;
                }

                MyJs.changeAndSaveFavoriteList(!mainAllMusicList[mainAllMusicListIndex].ifIsFavorite, mainAllMusicList[mainAllMusicListIndex])

                //历史列表一定要刷新
                var loader = pageHomeView.repeater.itemAt(3)
                loader.item.refreshList()  //刷新
            }
        }
        MusicIconButton {
            id: playMode
            Layout.preferredWidth: 50
            iconSource: playModeSwitch[indexPlayMode].source
            iconWidth: 32; iconHeight: 32
            toolTip: playModeSwitch[indexPlayMode].name
            onClicked: {
                indexPlayMode = (indexPlayMode+3+1)%3
            }
        }
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width/10
        }
    }  //end RowLayout
}  //end Rectangle
