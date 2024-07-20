/*
author: zouyujie
date: 2023.11.18
function: 中间内容，区别于top和bottom。加载各种其他qml组件视图。
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml

RowLayout {

    property int defaultIndex: 0
    property alias repeater: repeater

    //判断列表视图是否播放音乐,0:对应qmlList[5]独立 1:对应qmlList[6]独立
    property int ifPlaying: -1

    property var qmlList: [
        {icon:"recommend-white",value:"推荐内容",qml:"DetailRecommendPageView",menu:true},
        {icon:"cloud-white",value:"搜索音乐",qml:"DetailSearchPageView",menu:true},
        {icon:"local-white",value:"本地音乐",qml:"DetailLocalPageView",menu:true},
        {icon:"history-white",value:"播放历史",qml:"DetailHistoryPageView",menu:true},
        {icon:"favorite-big-white",value:"我喜欢的",qml:"DetailFavoritePageView",menu:true},
        {icon:"",value:"",qml:"DetailPlayListPageView",menu:false},
        {icon:"",value:"",qml:"DetailPlayListPageView",menu:false},
        {icon:"",value:"",qml:"MusicMvView",menu:false}
    ]

    function hideOtherModule() {  //用于全屏播放mv
        t1.visible = false
        menuBar.visible = false
        t2.visible = false
    }
    function showOtherModule() {
        t1.visible = true
        menuBar.visible = true
        t2.visible = true
    }

    spacing: 0

    Item {
        id: t1
        width: 1.5
    }
    Rectangle {
        id: menuBar
        //Layout.preferredWidth: 200
        Layout.preferredWidth: window.width/6 - 5
        Layout.fillHeight: true
        color: "#1000AAAA"
        // padding: 0
        // background: Rectangle {
        //     color: "#1000AAAA"
        // }

        ColumnLayout{
            anchors.fill: parent

            Item{
                Layout.fillWidth: true
                Layout.preferredHeight: window.height/16*3
                //见MusicRoundImage.qml
                MusicBorderImage{
                        anchors.centerIn:parent
                        height: window.height/8
                        width: window.height/8
                        borderRadius: 100
                        imgSrc: "qrc:/images/12.png"
                    }
                }

            ListView{
                id:menuView
                Layout.fillHeight: true
                Layout.fillWidth: true
                model: ListModel{
                    id:menuViewModel
                }
                delegate: menuViewDelegate
                highlight:Rectangle{
                    color: "#5073a7ab"
                }
            }

            Component{
                id:menuViewDelegate
                Rectangle{
                    id:menuViewDelegateItem
                    height: 50
                    width: window.width/6-5
                    color: "#00000000"
                    RowLayout{
                        anchors.fill: parent
                        anchors.centerIn: parent
                        spacing:15
                        Item{
                            width: 10
                            Layout.fillWidth: true
                        }

                        Image{
                            source: "qrc:/images/"+icon
                            Layout.preferredHeight: 20
                            Layout.preferredWidth: 20
                        }

                        Text{
                            text:value
                            //Layout.fillWidth: true
                            height: 50
                            font.family: window.mFONT_FAMILY
                            font.pointSize: 12
                            color: "#eeffffff"
                        }
                        Item {
                            width: 10
                            Layout.fillWidth: true
                        }
                    }  //end RowLayout

                    MouseArea {
                        anchors.fill: parent
                        //启动鼠标悬浮功能
                        hoverEnabled: true
                        onEntered: {
                            color="#aa73a7ab"
                        }
                        onExited: {
                            color="#00000000"
                        }

                        onClicked:{
                            //只要点击菜单，第5和第6个.qml就不可见
                            repeater.itemAt(5).visible = false
                            repeater.itemAt(6).visible = false
                            /* 单独处理mv视图 */
                            repeater.itemAt(7).visible = false
                            repeater.itemAt(7).item.mvMediaPlayer.pause()  //暂停mv
                            repeater.itemAt(7).item.enterLoadingView()  //进入加载界面

                            //item.ListView.view = 该item对应的ListView
                            repeater.itemAt(menuViewDelegateItem.ListView.view.currentIndex).visible =false
                            //改变当前项索引
                            menuViewDelegateItem.ListView.view.currentIndex = index
                            var loader = repeater.itemAt(menuViewDelegateItem.ListView.view.currentIndex)
                            loader.visible=true
                            loader.source = qmlList[index].qml+".qml"
                            if (loader.item.ifNeedRefreshList) {  //检查是否需要刷新
                                loader.item.refreshList()
                                console.log("已经刷新")
                                loader.item.ifNeedRefreshList = false
                            }
                        }
                    }
                }
            }  //end Component
            //默认显示第一个，即“推荐内容“
            Component.onCompleted: {
                menuViewModel.append(qmlList.filter(item=>item.menu))
                //第一个Loader
                var loader = repeater.itemAt(defaultIndex)
                loader.visible=true
                loader.source = qmlList[defaultIndex].qml+".qml"
                //索引
                menuView.currentIndex = defaultIndex

                //后台自动加载
                repeater.itemAt(1).source = qmlList[1].qml+".qml"
                repeater.itemAt(2).source = qmlList[2].qml+".qml"
                repeater.itemAt(3).source = qmlList[3].qml+".qml"
                repeater.itemAt(4).source = qmlList[4].qml+".qml"
                repeater.itemAt(5).source = qmlList[5].qml+".qml"
                repeater.itemAt(6).source = qmlList[6].qml+".qml"
                repeater.itemAt(7).source = qmlList[7].qml+".qml"
            }
        }  //end ColumnLayout
    }  //end Frame

    Repeater{
        id:repeater
        model: qmlList.length
        //加载一个qml组件
        Loader{
            visible: false
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
    Item {
        id: t2
        width: 1.5
    }

    //加载PlayList视图，并赋值给视图
    function showPlayList(targetId="", targetType="10") {
        if (ifPlaying === 0) {
            /* 0:对应qmlList[5]独立 */

            //得到当前正在播放的歌单的id
            var playingId = repeater.itemAt(5).item.playingPlayListId
            //判断id是不是独立的视图id
            if (targetId === playingId) {
                repeater.itemAt(menuView.currentIndex).visible =false
                repeater.itemAt(6).visible = false
                var loader = repeater.itemAt(5)
                if (loader.item.ifNeedRefreshList) {  //刷新列表
                    loader.item.refreshList();
                    loader.item.ifNeedRefreshList = false
                }
                loader.visible=true
            } else { handle(6, targetId, targetType) }
        }
        else if (ifPlaying === 1) {
            /* 1:对应qmlList[6]独立 */

            //得到当前正在播放的歌单的id
            var playingId = repeater.itemAt(6).item.playingPlayListId
            //判断id是不是独立的视图id
            if (targetId === playingId) {
                repeater.itemAt(menuView.currentIndex).visible =false
                repeater.itemAt(5).visible = false
                var loader = repeater.itemAt(6)
                if (loader.item.ifNeedRefreshList) {  //刷新列表
                    loader.item.refreshList()
                    loader.item.ifNeedRefreshList = false
                }
                loader.visible=true
            } else { handle(5, targetId, targetType) }
        }
        else {
            /* 没有播放歌单的情况(第一次点的情况) */
            handle(5, targetId, targetType)
        }
    }

    function handle(index, targetId, targetType) {
        //item.ListView.view = 该item对应的ListView
        repeater.itemAt(menuView.currentIndex).visible =false
        var loader = repeater.itemAt(index)
        loader.visible=true
        if (loader.item.targetId === targetId) {  //连续两次点同一个专辑/歌单的情况(targetID没变，不会网络请求，可能有bug)
            if (loader.item.ifNeedRefreshList) {  //刷新列表
                loader.item.refreshList()
                console.log("已经刷新")
                loader.item.ifNeedRefreshList = false
            }
            return
        }
        loader.item.ifNeedRefreshList = false  //handle意味着该视图已经会刷新一次
        //靠loader为其加载的qml组件里面的赋值
        loader.item.targetType = targetType
        loader.item.targetId = targetId
    }

    //显示并播放mv视图
    function showMvView(mv) {
        repeater.itemAt(5).visible = false
        repeater.itemAt(6).visible = false
        repeater.itemAt(menuView.currentIndex).visible = false

        var loader = repeater.itemAt(7)
        loader.visible=true
        if (mv === loader.item.mvId) {  //连续点击同一个mv
            loader.item.exitLoadingView()
            loader.item.mvMediaPlayer.play()
            return
        }
        loader.item.mvId = mv  //赋值
    }
}
