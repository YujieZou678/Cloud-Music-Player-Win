/*
author: zouyujie
date: 2023.11.18
function: qml主函数
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import "requestNetwork.js" as MyJs

ApplicationWindow {
    id: window
    visibility: "Hidden"
    Component.onCompleted: {
        visibility = Window.Windowed
    }

    property int mWINDOW_WIDTH: Screen.width/1707*1200
    property int mWINDOW_HEIGHT: Screen.height/1067*800
    function restoreWindowSize() {  //还原窗口大小
        window.width = mWINDOW_WIDTH
        window.height = mWINDOW_HEIGHT
    }
    property string mFONT_FAMILY: "微软雅黑"

    /* 实际上主函数不需要声明，会自动加载到全部应用里 */
    property alias mediaPlayer: mediaPlayer
    property alias mainBackground: mainBackground
    property alias layoutBottomView: layoutBottomView
    property alias pageHomeView: pageHomeView
    property alias pageDetailView: pageDetailView

    //用于列表播放后，切歌
    property var mainHistoryList: []   //播放历史列表
    property var mainHistoryListCopy: []  //副本
    property bool loadCacheCause1: true  //是否是加载缓存导致
    onMainHistoryListChanged: {  //一开始自动会执行一次
        if (mainHistoryList.length === 0) {
            var dataCache = getHistoryCache()
            if (dataCache.length < 1) {
                console.log("播放历史缓存数据为空。")
                loadCacheCause1 = false
            } else {
                mainHistoryList = dataCache  //加载缓存
                mainHistoryListCopy = JSON.parse(JSON.stringify(mainHistoryList))  //副本
                replaceHistoryList()  //跟我喜欢列表做比较替换
            }
        }
        else {
            if (loadCacheCause1) { loadCacheCause1 = false; return }
            var loader = pageHomeView.repeater.itemAt(3).item.historyListView  //每播放一首歌就需要改变历史视图
            loader.musicList = mainHistoryList.reverse()  //颠倒
            loader.songCount = mainHistoryList.length
        }
    }
    function replaceHistoryList() {
        for (var i in mainHistoryList) {
            var index = MyJs.checkIsFavorite(mainHistoryList[i].id)
            if (index !== -1) {
                mainHistoryList[i] = mainFavoriteList[index]  //如果是收藏了的，就替换保证是同一个对象
            }
        }
    }

    property var mainAllMusicList: []  //当前歌单/专辑列表
    onMainAllMusicListChanged: {
        //清空随机历史列表和index
        mainRandomHistoryList = []
        mainRandomHistoryListIndex = -1
    }
    //property var mainAllMusicListCopy: []  //当前歌单/专辑列表副本
    property int mainAllMusicListIndex: -1  //当前歌单/专辑列表的index
    property string mainModelName: ""  //播放模式
    property var mainRandomHistoryList: []  //随机模式下的历史列表
    property int mainRandomHistoryListIndex: -1  //随机模式下的历史列表的index

    property var mainFavoriteList: []  //我喜欢列表
    property bool loadCacheCause2: true  //是否是加载缓存导致
    property bool ifloadCache: false  //是否加载缓存
    onMainFavoriteListChanged: {  //所有列表视图都应重新加载
        if (mainFavoriteList.length === 0) {
            if (!ifloadCache) {
                ifloadCache = true
                var dataCache = getFavoriteCache()  //获取缓存数据
                if (dataCache.length === 0) {
                    console.log("我喜欢缓存数据为空。")
                    loadCacheCause2 = false
                } else {
                    mainFavoriteList = dataCache
                }
            } else {
                //减少到0的情况
                var loader = pageHomeView.repeater.itemAt(4).item.favoriteListView  //每播放一首歌就需要改变我喜欢视图
                loader.musicList = mainFavoriteList.reverse()  //颠倒
                loader.songCount = mainFavoriteList.length

                sendSignalRefreshList()
            }
        }
        else {
            if (loadCacheCause2) { loadCacheCause2 = false; return }
            var loader = pageHomeView.repeater.itemAt(4).item.favoriteListView  //每播放一首歌就需要改变历史视图
            loader.musicList = mainFavoriteList.reverse()  //颠倒
            loader.songCount = mainFavoriteList.length

            sendSignalRefreshList()
        }
    }
    function sendSignalRefreshList() {
        pageHomeView.repeater.itemAt(1).item.ifNeedRefreshList = true  //搜索音乐
        pageHomeView.repeater.itemAt(2).item.ifNeedRefreshList = true  //本地音乐
        pageHomeView.repeater.itemAt(3).item.ifNeedRefreshList = true  //播放历史
        pageHomeView.repeater.itemAt(5).item.ifNeedRefreshList = true  //专辑/歌单
        pageHomeView.repeater.itemAt(6).item.ifNeedRefreshList = true  //专辑/歌单
    }

    width: mWINDOW_WIDTH
    height: mWINDOW_HEIGHT
    visible: true
    title: qsTr("Cloud Music Player")

    background: Background {  //背景
        id: mainBackground
    }

    MainSystemTrayIcon {  //托盘图标
        id: mainSystemTrayIcon
    }

    flags: Qt.Window|Qt.FramelessWindowHint
    property int bw: 3
    onYChanged: {
        if (y > Screen.desktopAvailableHeight - 30) {
            window.showMinimized()
        }
    }
    onVisibilityChanged: {
        if (window.visibility === Window.Windowed) {
            window.x = (Screen.desktopAvailableWidth-width)/2
            window.y = (Screen.desktopAvailableHeight-height)/2
        }
    }
    // The mouse area is just for setting the right cursor shape
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: {
            const p = Qt.point(mouseX, mouseY);
            const b = bw + 10; // Increase the corner size slightly
            if (p.x < b && p.y < b) return Qt.SizeFDiagCursor;
            if (p.x >= width - b && p.y >= height - b) return Qt.SizeFDiagCursor;
            if (p.x >= width - b && p.y < b) return Qt.SizeBDiagCursor;
            if (p.x < b && p.y >= height - b) return Qt.SizeBDiagCursor;
            if (p.x < b || p.x >= width - b) return Qt.SizeHorCursor;
            if (p.y < b || p.y >= height - b) return Qt.SizeVerCursor;
        }
        acceptedButtons: Qt.NoButton // don't handle actual events
    }
    DragHandler {
        id: resizeHandler
        grabPermissions: TapHandler.TakeOverForbidden
        target: null
        onActiveChanged: if (active) {
                             const p = resizeHandler.centroid.position;
                             const b = bw + 10; // Increase the corner size slightly
                             let e = 0;
                             if (p.x < b) { e = Qt.LeftEdge }
                             if (p.x >= width - b) { e = Qt.RightEdge }
                             if (p.y < b) { e = Qt.TopEdge }
                             if (p.y >= height - b) { e = Qt.BottomEdge }
                             window.startSystemResize(e);
                         }
    }

    ColumnLayout {
        anchors.fill: parent
        //组件之间的边距
        spacing: 0
        Item {
            id: top1
            height: 2
        }
        LayoutTopView {
            id: layoutTopView
            z: 1000
        }
       Item {  //占用top的空间，top隐藏不让鼠标坐标改变
           id: topItem
           height: layoutTopView.height
           visible: false
       }

        //中间内容
        PageHomeView {
            id: pageHomeView
        }
        //歌曲的细节视图。唱片旋转，歌词。
        PageDetailView {
            id: pageDetailView
            visible: false
        }

        //底部工具栏
        LayoutBottomView {
            id: layoutBottomView
        }
        Item {  //同topItem
            id: bottomItem
            height: layoutBottomView.height
            visible: false
        }
    }
    function hideTopModule() {
        top1.visible = false
        layoutTopView.visible = false
    }
    function showTopModule() {
        top1.visible = true
        layoutTopView.visible = true
    }

    MediaPlayer {
        id: mediaPlayer
        property var times: []  //歌词的各个时间段
        audioOutput: audioOutPut
        //拖动，有延迟，应该是内部position赋值之后继续计时，但是没有实时传出数据
        onPositionChanged: {
            layoutBottomView.timeText = getTime(mediaPlayer.position/1000)+"/"+getTime(mediaPlayer.duration/1000)

            if (times.length>0) {
                var count = times.filter(time=>time<mediaPlayer.position).length  //对数据进行筛选
                pageDetailView.current = (count===0) ? 0: count-1
            }
        }

        onMediaStatusChanged: {
            switch(mediaPlayer.mediaStatus) {
            case MediaPlayer.LoadingMedia:
                //正在加载媒体,正在播放
                console.log("加载动画")
                break;
            case MediaPlayer.LoadedMedia:
                //媒体加载完成，播放完成
                console.log("上一首播放完毕")
                break;
            case MediaPlayer.BufferingMedia:
                //数据正在缓冲
                console.log("BufferingMedia......")
                break;
            case MediaPlayer.BufferedMedia:
                //数据缓冲完成
                layoutBottomView.slider.handleRec.imageLoading.visible = false
                pageDetailView.cover.isRotating = true
                console.log("结束加载动画，开始播放")
                break;
            case MediaPlayer.StalledMedia:
                //缓冲数据被打断
                console.log(5)
                break;
            case MediaPlayer.EndOfMedia:
                //当前歌曲结束
                console.log("自动播放下一首")
                MyJs.switchSong(true, layoutBottomView.modePlay, true)
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

    //添加主窗口快捷键，空格暂停
    Shortcut {
        context: Qt.WindowShortcut
        sequence: "space"
        onActivated: {
            /* 先判断mv视图是否显示 */
            var loader = pageHomeView.repeater.itemAt(7)
            if (loader.visible) {
                switch (loader.item.mvMediaPlayer.playbackState) {
                case MediaPlayer.PlayingState:
                    loader.item.mvMediaPlayer.pause()
                    break;
                case MediaPlayer.PausedState:
                    loader.item.mvMediaPlayer.play()
                    break;
                }
            } else {
                /* mv视图没有显示 */
                switch(mediaPlayer.playbackState) {
                case MediaPlayer.PlayingState:
                    mediaPlayer.pause()
                    layoutBottomView.playStateSource = "qrc:/images/play_ing.png"
                    pageDetailView.cover.isRotating = false
                    console.log("歌曲已暂停")
                    break;
                case MediaPlayer.PausedState:
                    mediaPlayer.play()
                    console.log("歌曲继续播放")
                    layoutBottomView.playStateSource = "qrc:/images/pause.png"
                    pageDetailView.cover.isRotating = true
                    break;
                }
            }
        }
    }
    //添加主窗口快捷键，上一首
    Shortcut {
        context: Qt.WindowShortcut
        sequence: "Ctrl+Alt+left"
        onActivated: {
            MyJs.switchSong(false, layoutBottomView.modePlay, false)
        }
    }
    //添加主窗口快捷键，下一首
    Shortcut {
        context: Qt.WindowShortcut
        sequence: "Ctrl+Alt+Right"
        onActivated: {
            MyJs.switchSong(true, layoutBottomView.modePlay, false)
        }
    }
}
