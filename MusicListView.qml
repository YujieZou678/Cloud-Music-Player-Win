/*
author: zouyujie
date: 2023.11.18
function: 歌曲列表，反复使用的模板视图
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import QtMultimedia
import "requestNetwork.js" as MyJs //命名首字母必须大写，否则编译失败

Frame {

    //需要赋值
    property var musicList: []
    property int songCount: 0
    property int currentPage: 0
    property int pageSize: 60

    //得到当前是哪个模块加载列表，PlayList或者Search或者Local或者history或者favorite
    property string modelName: ""
    //得到当前playList的id
    property string currentPlayListId: ""
    //得到当前正在播放的playList的id
    property string isPlayingPlayListId: ""
    onIsPlayingPlayListIdChanged: {
        if (modelName === "DetailPlayListPageView") {
            pageHomeView.ifPlaying = (pageHomeView.ifPlaying+2+1)%2
        }
    }
    //是否点击了该列表，用于解决搜索界面光标的问题，点击了即值就变了
    property int ifClick: -1

    //暴露接口
    property alias scrollBar: scrollBar
    property alias listView: listView

    //视觉逻辑
    property alias imageLoadingVisible: imageLoading.visible
    property alias listViewVisible: listView.visible
    property alias pageButtonVisible: pageButton.visible

    //信号，切换页数
    signal switchPage(int offset)

    //一开始会默认赋值一次
    onMusicListChanged: {
        imageLoading.visible = false
        listView.visible = true
        pageButton.visible = true

        listViewModel.clear()
        musicList.forEach(item=>{
                              listViewModel.append(item)
                          })
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

    Layout.fillHeight: true
    Layout.fillWidth: true
    //超出部分隐藏
    clip: true
    padding: 0
    background: Rectangle {
        color: "#00000000"
    }

    ListView {
        id: listView
        visible: false
        anchors.fill: parent
        anchors.bottomMargin: 58
        model: ListModel {
            id: listViewModel
        }
        delegate: listViewDelegate
        ScrollBar.vertical: ScrollBar {
            id: scrollBar
            policy: ScrollBar.AlwaysOff
            anchors.right: parent.right
        }
        header: listViewHeader
        highlight: Rectangle {
            color: "#20f0f0f0"
        }
        highlightMoveDuration: 0
        highlightResizeDuration: 0
    }

    //音乐数据列表
    Component {
        id: listViewDelegate
        Rectangle {
            id: listViewDelegateItem
            height: 45
            width: listView.width
            //将颜色置为无色，方便显示第二层hightlight的颜色
            color: "#00000000"

            //画边框
            Shape {
                id: shape
                anchors.fill: parent
                ShapePath {
                    strokeWidth: 0
                    strokeColor: "#50ffffff"
                    strokeStyle: ShapePath.SolidLine
                    startX: 0
                    startY: listViewDelegateItem.height
                    PathLine {
                        x:0; y:listViewDelegateItem.height
                    }
                    PathLine {
                        x:shape.width; y:listViewDelegateItem.height
                    }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    color = "#20f0f0f0"
                }
                onExited: {
                    color = "#00000000"
                }
                onClicked: {
                    listView.currentIndex = index
                    ifClick = (ifClick+2+1)%2
                }
                //双击播放音乐
                onDoubleClicked: {
                    //播放单曲
                    var targetId = id
                    var picUrl_ = picUrl
                    //给主窗口播放列表赋值
                    //mainAllMusicListCopy = JSON.parse(JSON.stringify(musicList))  //赋值副本
                    mainAllMusicList = musicList
                    mainAllMusicListIndex = index
                    MyJs.playMusic(targetId,name,artist,picUrl_,ifIsFavorite)
                    MyJs.changeAndSaveHistoryList(musicList[index])  //需要放到index后面，否则会有bug
                    mainModelName = modelName
                    //当前正在播放的歌单/专辑id赋值
                    isPlayingPlayListId = currentPlayListId
                }

                //内容
                RowLayout {
                    width: parent.width; height: parent.height
                    spacing: 15
                    x: 5
                    //序号
                    Text {
                        id: indexNumber
                        text: index+1 + pageSize*currentPage
                        horizontalAlignment: Text.AlignHCenter
                        Layout.preferredWidth: parent.width*0.05
                        font.family: window.mFONT_FAMILY
                        font.pointSize: 13
                        color: "#eeffffff"
                        elide: Qt.ElideRight
                    }
                    //最后加载index
    //                    Component.onCompleted: {
    //                        indexNumber.text = index+1 + pageSize*currentPage
    //                    }

                    Text {
                        text: name
                        //horizontalAlignment: Text.AlignHCenter
                        Layout.preferredWidth: parent.width*0.4
                        font.family: window.mFONT_FAMILY
                        font.pointSize: 13
                        color: "#eeffffff"
                        elide: Qt.ElideRight
                    }
                    Text {
                        text: artist
                        horizontalAlignment: Text.AlignHCenter
                        Layout.preferredWidth: parent.width*0.15
                        font.family: window.mFONT_FAMILY
                        font.pointSize: 13
                        color: "#eeffffff"
                        elide: Qt.ElideRight
                    }
                    Text {
                        text: album
                        horizontalAlignment: Text.AlignHCenter
                        Layout.preferredWidth: parent.width*0.15
                        font.family: window.mFONT_FAMILY
                        font.pointSize: 13
                        color: "#eeffffff"
                        elide: Qt.ElideRight
                    }

                    Item {
                        Layout.preferredWidth: parent.width*0.15
                        Layout.fillHeight: true
                        RowLayout {
                            anchors.centerIn: parent
                            Item {
                                Layout.preferredHeight: 16
                                Layout.preferredWidth: 16
                            }
                            MusicIconButton {
                                iconSource: "qrc:/images/video-white.png"
                                iconWidth: 16; iconHeight: 16
                                toolTip: "MV"
                                visible: mv==="0" ? false:true  //如果有mv
                                onClicked: {
                                    mediaPlayer.pause()
                                    layoutBottomView.playStateSource = "qrc:/images/play_ing.png"
                                    pageDetailView.cover.isRotating = false
                                    console.log("歌曲已暂停")
                                    pageHomeView.showMvView(mv)
                                }
                            }
                            Item {
                                Layout.preferredHeight: 24
                                Layout.preferredWidth: 24
                                visible: mv==="0" ? true:false  //如果没有mv
                            }

                            MusicIconButton {
                                iconSource: "qrc:/images/play_ing.png"
                                iconWidth: 16; iconHeight: 16
                                toolTip: "播放"
                                onClicked: {
                                    listView.currentIndex = index
                                    //播放单曲
                                    var targetId = id
                                    var picUrl_ = picUrl
                                    //给主窗口播放列表赋值
                                    //mainAllMusicListCopy = JSON.parse(JSON.stringify(musicList))  //赋值副本
                                    mainAllMusicList = musicList
                                    mainAllMusicListIndex = index
                                    MyJs.playMusic(targetId,name,artist,picUrl_)
                                    MyJs.changeAndSaveHistoryList(musicList[index])  //需要放到index后面，否则会有bug
                                    mainModelName = modelName
                                    //当前正在播放的歌单/专辑id赋值
                                    isPlayingPlayListId = currentPlayListId
                                }
                            }
                            MusicIconButton {
                                iconSource: "qrc:/images/favorite.png"
                                iconWidth: 16; iconHeight: 16
                                toolTip: "喜欢"
                                ifFavorite: ifIsFavorite
                                onClicked: {
                                    ifIsFavorite = !ifIsFavorite  //可以同步当前列表
                                    musicList[index].ifIsFavorite = !musicList[index].ifIsFavorite

                                    MyJs.changeAndSaveFavoriteList(!musicList[index].ifIsFavorite, musicList[index])
                                    layoutBottomView.refreshBottomFavorite()
                                }
                            }
                            Item {
                                Layout.preferredHeight: 16
                                Layout.preferredWidth: 16
                            }
                        }
                    }  //end Item

                }  //end RowLayout
            }  //end MouseArea
        }  //end Rectangle
    }

    //header
    Component {
        id: listViewHeader
        Rectangle {
            color: "#3000AAAA"
            height: 45
            width: listView.width
            RowLayout {
                width: parent.width; height: parent.height
                spacing: 15
                x: 5
                Text {
                    text: "序号"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: parent.width*0.05
                    font.family: window.mFONT_FAMILY
                    font.pointSize: 13
                    color: "#eeffffff"
                    elide: Qt.ElideRight
                }
                Text {
                    text: "歌名"
                    //horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: parent.width*0.4
                    font.family: window.mFONT_FAMILY
                    font.pointSize: 13
                    color: "#eeffffff"
                    elide: Qt.ElideRight
                }
                Text {
                    text: "歌手"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: parent.width*0.15
                    font.family: window.mFONT_FAMILY
                    font.pointSize: 13
                    color: "#eeffffff"
                    elide: Qt.ElideRight
                }
                Text {
                    text: "专辑"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: parent.width*0.15
                    font.family: window.mFONT_FAMILY
                    font.pointSize: 13
                    color: "#eeffffff"
                    elide: Qt.ElideRight
                }
                Text {
                    text: "操作"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: parent.width*0.15
                    font.family: window.mFONT_FAMILY
                    font.pointSize: 13
                    color: "#eeffffff"
                    elide: Qt.ElideRight
                }
            }
        }
    }  //end header

    //pageButton
    Item {
        id: pageButton
        //如果列表长度为0,则没有pageButton
        visible: false
        //visible: musicList.length===0 ? false:true
        height: 40; width: parent.width
        anchors {
            top: listView.bottom
            topMargin: 20
        }

        ButtonGroup {
            //定义一系列按钮的逻辑
            buttons: buttons.children
        }

        RowLayout {
            id: buttons
            //让以下组件居中
            anchors.centerIn: parent
            Repeater {
                id: repeater
                model: songCount/pageSize>9 ? 9: songCount/pageSize
                Button {
                    Text {
                        anchors.fill: parent
                        text: modelData+1
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font {
                            family: window.mFONT_FAMILY
                            pointSize: 14
                        }
                        color: checked ? "#497563":"eeffffff"
                    }
                    background: Rectangle {
                        implicitHeight: 30; implicitWidth: 30
                        color: checked ? "#e2f0f8":"#20e9f4ff"
                        radius: 3
                    }
                    checkable: true
                    checked: index === currentPage
                    onClicked: {
                        //换页
                        if (currentPage===index) return
                        imageLoading.visible = true
                        listView.visible = false
                        currentPage = index
                        //切换页数之后视图自动到顶部
                        scrollBar.position = 0
                        switchPage(index*pageSize)
                    }
                }
            }
        }
    }
}
