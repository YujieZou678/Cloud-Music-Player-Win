/*
author: zouyujie
date: 2023.11.18
function: 推荐内容窗口的banner视图
*/
import QtQuick
import QtQuick.Controls
import QtQml
import QtMultimedia
import "requestNetwork.js" as MyJs //命名首字母必须大写，否则编译失败

/*
 * Version Two: PathView动效版*/
Frame {
    property int current: 0
    property var bannerList: []

    background: Rectangle {
        color: "#00000000"
    }

    PathView {
        id: pathView
        width: parent.width
        height: parent.height
        model: bannerList
        //超出部分隐藏
        clip: true
        delegate: MusicRoundImage {
            id: musicImage
            width: pathView.width*0.7
            height: pathView.height
            z: PathView.z ? PathView.z : 0
            scale: PathView.scale ? PathView.scale : 1
            imgSrc: modelData.picUrl
            imageLoading.width: 30
            imageLoading.height: 30
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (pathView.currentIndex == index) {
                        var item = bannerList[index]
                        var targetId = item.id+""
                        var targetType = item.type+""
                        console.log(targetId, targetType, " 正在点击banner")

                        switch(targetType) {
                        case "1":
                            //跟历史列表做替换
                            mainHistoryList.forEach(temp=>{
                                                        if (temp.id === item.id) {
                                                            item = temp
                                                            return
                                                        }
                                                    })
                            //跟我喜欢列表做替换
                            mainFavoriteList.forEach(temp=>{
                                                        if (temp.id === item.id) {
                                                            item = temp
                                                            return
                                                        }
                                                    })
                            var name = item.name
                            var picUrl = item.picUrl
                            //给主窗口播放列表赋值
                            mainAllMusicList = []
                            mainAllMusicList.push(item)
                            //mainAllMusicListCopy = JSON.parse(JSON.stringify(mainAllMusicList))  //赋值副本
                            mainAllMusicListIndex = 0
                            MyJs.playMusic(targetId,name,"",picUrl)
                            MyJs.changeAndSaveHistoryList(item)
                            break;
                        case "10":
                            //打开专辑
                            pageHomeView.showPlayList(targetId, targetType)
                            break;
                        case "1000":
                            //打开歌单列表
                            pageHomeView.showPlayList(targetId, targetType)
                            break;
                        }

                    } else pathView.currentIndex = index
                }
                hoverEnabled: true
                onEntered: { timer.stop() }
                onExited: { timer.start() }
            }
        }

        //该视图可见组件个数
        pathItemCount: 3
        path: path;

        //currentItem的highlight范围,让当前组件位于中间路线
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
    }
    Path {
        id: path
        //x,y对应组件的中心
        startX: 0
        startY: pathView.height/2-10
        //路径属性，是一一对应关系
        PathAttribute { name: "z"; value: 0 }
        //坐标不会随缩放而改变，从而有坐标偏差
        PathAttribute { name: "scale"; value: 0.6 }

        //中间路线，此时只是存在该路线(会路过它)，但是组件并不是默认位于该路线
        PathLine {
            x: pathView.width/2
            y: pathView.height/2-10
        }
        PathAttribute { name: "z"; value: 2 }
        PathAttribute { name: "scale"; value: 0.85 }

        PathLine {
            x: pathView.width
            y: pathView.height/2-10
        }
        PathAttribute { name: "z"; value: 0 }
        PathAttribute { name: "scale"; value: 0.6 }
    }

    //轮播图下方索引
    PageIndicator {
        id: pageIndicator
        count: bannerList.length
        anchors {
            top: pathView.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: -15
        }
        currentIndex: pathView.currentIndex
        delegate: Rectangle {
            width: 20; height: 5
            radius: 5
            color: pageIndicator.currentIndex===index ? "white" : "#55ffffff"
            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    pathView.currentIndex = index
                    timer.stop()
                }
                onExited: {
                    timer.start()
                }
                cursorShape: Qt.PointingHandCursor
            }
        }
    }  //end PageIndicator

    //设置轮播时间
    Timer {
        id: timer
        interval: 3000
        repeat: true
        onTriggered: {
            if (bannerList.length > 0)
                //pathView.count是model的个数
                pathView.currentIndex = (pathView.currentIndex + 1) % pathView.count
        }
        running: true
    }
}

  /*
   * Version one: 简易版，固定图片位置，改变Url*/
//Frame {
//    property int current: 0
//    property var songList: []

//    background: Rectangle {
//        color: "#00000000"
//    }

//    MouseArea {
//        anchors.fill: parent
//        cursorShape: Qt.PointingHandCursor
//        hoverEnabled: true
//        onEntered: {
//            timer.stop()
//        }
//        onExited: {
//            timer.start()
//        }
//    }

//    //左方图片
//    MusicRoundImage {
//        id: leftImage
//        width: parent.width*0.6
//        height: parent.height*0.8
//        anchors {
//            left: parent.left
//            bottom: parent.bottom
//            bottomMargin: 20
//        }

//        imgSrc: getLeftImgSrc()

//        MouseArea {
//            anchors.fill: parent
//            onClicked: {
//                if (songList.length > 0)
//                    current = current==0 ? songList.length-1 : current-1
//             }
//            cursorShape: Qt.PointingHandCursor
//        }

//        onImgSrcChanged: {
//            leftImageAnimation.start()
//        }

//        NumberAnimation {
//            id: leftImageAnimation
//            target: leftImage
//            property: "scale"
//            from: 0.7
//            to: 1.0
//            duration: 200
//        }
//    }

//    //中间图片
//    MusicRoundImage {
//        id: centerImage
//        width: parent.width*0.6
//        height: parent.height
//        z: 2
//        anchors.centerIn: parent
//        imgSrc: getCenterImgSrc()

//        MouseArea {
//            anchors.fill: parent
//            cursorShape: Qt.PointingHandCursor
//        }

//        onImgSrcChanged: {
//            centerImageAnimation.start()
//        }
//        NumberAnimation {
//            id: centerImageAnimation
//            target: centerImage
//            property: "scale"
//            from: 0.7
//            to: 1.0
//            duration: 200
//        }
//    }

//    //右方图片
//    MusicRoundImage {
//        id: rightImage
//        width: parent.width*0.6
//        height: parent.height*0.8
//        anchors {
//            right: parent.right
//            bottom: parent.bottom
//            bottomMargin: 20
//        }

//        imgSrc: getRightImgSrc()

//        MouseArea {
//            anchors.fill: parent
//            onClicked: {
//                if (songList.length > 0)
//                    current = current==songList.length-1 ? 0 : current+1
//             }
//            cursorShape: Qt.PointingHandCursor
//        }

//        onImgSrcChanged: {
//            rightImageAnimation.start()
//        }
//        NumberAnimation {
//            id: rightImageAnimation
//            target: rightImage
//            property: "scale"
//            from: 0.7
//            to: 1.0
//            duration: 200
//        }
//    }

//    //轮播图下方的指示器
//    PageIndicator {
//        id: pageIndicator
//        anchors {
//            top: centerImage.bottom
//            horizontalCenter: parent.horizontalCenter
//        }
//        count: 5
//        //自动更改索引
//        interactive: true
//        //索引改变时
//        onCurrentIndexChanged: {
//            current = currentIndex
//        }
//        delegate: Rectangle {
//            width: 20; height: 5
//            radius: 5
//            color: current===index ? "black" : "gray"

//            MouseArea {
//                anchors.fill: parent
//                cursorShape: Qt.PointingHandCursor
//                hoverEnabled: true
//                onEntered: {
//                    current = index
//                    timer.stop()
//                }
//                onExited: {
//                    timer.start()
//                }
//            }
//        }
//    }

//    //计时器，实现自动切换（轮播图片）
//    Timer {
//        id: timer
//        interval: 3000
//        repeat: true
//        onTriggered: {
//            if (songList.length > 0)
//                current = current==songList.length-1 ? 0 : current+1
//        }
//        running: true
//    }

//    //分别得到三张轮播图的Url
//    function getLeftImgSrc() {
//        return songList.length ? songList[(current-1+songList.length)%songList.length].artists[0].img1v1Url : ""
//    }
//    function getCenterImgSrc() {
//        return songList.length ? songList[current].artists[0].img1v1Url : ""
//    }
//    function getRightImgSrc() {
//        return songList.length ? songList[(current+1+songList.length)%songList.length].artists[0].img1v1Url : ""
//    }
//}  //end Frame
