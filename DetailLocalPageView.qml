/*
author: zouyujie
date: 2024.1.22
function: 播放本地音乐。
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform
import "requestNetwork.js" as MyJs

ColumnLayout {

    property alias localListView: localListView
    property var localMusicList: []  //本地音乐列表
    property var autoMusicList: []  //自动搜索得到的列表
    property var handMusicList: []  //手动添加得到的列表

    property bool ifNeedRefreshList: false
    function refreshList() {
        localListView.musicList = localListView.musicList
    }

    Rectangle {
        Layout.fillWidth: true
        width: parent.width
        height: 60
        color: "#00000000"

        Text {
            x: 10
            //文本与底部对齐
            verticalAlignment: Text.AlignBottom
            text: qsTr("本地音乐")
            font.family: window.mFONT_FAMILY
            font.pointSize: 25
            color: "#eeffffff"
        }
    }

    RowLayout {
        height: 80

        Item {
            width: 10
        }

        MusicTextButton {
            btnText: "手动添加"
            btnHeight: 50
            btnWidth: 200
            onClicked: {
                fileDialog.open()
            }
        }
        MusicTextButton {
            btnText: "自动搜索(非全盘)"
            btnHeight: 50
            btnWidth: 200
            onClicked: {
                autoMusicList = []  //清除记录
                //加载界面
                localListView.imageLoadingVisible = true
                localListView.listViewVisible = false
                localListView.pageButtonVisible = false

                localListView.currentPage = 0;
                localListView.scrollBar.position = 0;

                //开始处理本地音乐
                var oneFolder = "C:/Users"
                var oneFolderList = getCurrentFolderList(oneFolder)
                oneFolderList = oneFolderList.filter(item=>!isNaN(item))
                oneFolderList = oneFolderList.map(item=>{
                                                      return "C:/Users/"+item+"/Music"
                                                  })
                var folderList = oneFolderList //需要遍历的文件夹
                getSongsFF_AtSub1Thread(folderList)  //子线程执行查找

                function onReply(songsList) {
                    for (var i in songsList) {
                        var id = ""+songsList[i]
                        if (localMusicList.filter(item=>item.id===id).length<1) {  //遍历本地音乐列表，没找到重复的则加入
                            //处理每一首歌，songsList为它们的地址
                            var songNameAbsoArr = songsList[i].split("/")
                            var songNameArr = songNameAbsoArr[songNameAbsoArr.length-1].split(".")
                            songNameArr.pop()  //去掉后缀
                            var songName = songNameArr.join(".")  //考虑歌名部分为A.B.C的情况
                            var songArr = songName.split("-")  //分离 歌手-歌名

                            var artist = songArr.length>1 ? songArr[0]:"未知"
                            var song = songArr.length>1 ? songArr[1]: songArr[0]

                            autoMusicList.push({
                                               id: id,
                                               name: song,
                                               artist: artist,
                                               album: "本地音乐",
                                               picUrl: "qrc:/images/errorLoading.png",
                                               ifIsFavorite: MyJs.checkIsFavorite(id)===-1 ? false: true
                                           })
                            console.log(id)
                        }
                    }
                    //赋值
                    localMusicList = localMusicList.concat(autoMusicList)  //合并
                    localListView.songCount = localMusicList.length
                    localListView.musicList = localMusicList
                    console.log("本地音乐 自动搜索歌曲数目："+autoMusicList.length)
                    saveLocalCache(localMusicList)  //保存缓存

                    onGetSongsFFEnd_Signal.disconnect(onReply)  //断开连接
                }

                onGetSongsFFEnd_Signal.connect(onReply)
            }
        }
//        MusicTextButton {
//            btnText: "刷新缓存"
//            btnHeight: 50
//            btnWidth: 200
//            onClicked: {
//                localMusicList = getLocalCache()
//                localListView.songCount = localMusicList.length
//                localListView.musicList = localMusicList
//            }
//        }
        MusicTextButton {
            btnText: "清空缓存"
            btnHeight: 50
            btnWidth: 200
            onClicked: {
                clearLocalCache()
                //刷新
                localMusicList = getLocalCache()
                localListView.songCount = localMusicList.length
                localListView.musicList = localMusicList
            }
        }
    }

    MusicListView {
        id: localListView
        modelName: "DetailLocalPageView"  //列表视图额外的属性
    }

    Component.onCompleted: {
        localMusicList = getLocalCache()
        replaceList1()  //跟播放历史做比较替换
        replaceList2()  //跟我喜欢列表做比较替换
        localListView.songCount = localMusicList.length
        localListView.musicList = localMusicList
    }

    function replaceList1() {  //跟播放历史做比较替换
        for (var i in localMusicList) {
            var index = MyJs.checkIsHistory(localMusicList[i].id)
            if (index !== -1) {
                localMusicList[i] = mainHistoryList[index]
            }
        }
    }

    function replaceList2() {  //跟我喜欢做比较替换
        for (var i in localMusicList) {
            var index = MyJs.checkIsFavorite(localMusicList[i].id)
            if (index !== -1) {
                localMusicList[i] = mainFavoriteList[index]  //如果是收藏了的，就替换保证是同一个对象
            }
        }
    }

    FileDialog {
        id: fileDialog
        fileMode: FileDialog.OpenFiles
        nameFilters: ["MP3 Music Files(*.mp3)", "FLAC Music Files(*.flac)"]
        folder: StandardPaths.standardLocations(StandardPaths.MusicLocation)[0]  //该属性目前没用
        acceptLabel: "确定"
        rejectLabel: "取消"

        onAccepted: {
            handMusicList = []  //清除之前的值
            var songsList = files  //url格式

            for (var i in songsList) {
                var path = songsList[i]+""  //url转字符串
                var id = path.replace("file:///","")  //id
                if (localMusicList.filter(item=>item.id===id).length<1) {  //遍历本地音乐列表，没找到重复的则加入
                    //处理每一首歌，songsList为它们的地址
                    var songNameAbsoArr = path.split("/")
                    var songNameArr = songNameAbsoArr[songNameAbsoArr.length-1].split(".")
                    songNameArr.pop()  //去掉后缀
                    var songName = songNameArr.join(".")  //考虑歌名部分为A.B.C的情况
                    var songArr = songName.split("-")  //分离 歌手-歌名

                    var artist = songArr.length>1 ? songArr[0]:"未知"
                    var song = songArr.length>1 ? songArr[1]: songArr[0]

                    handMusicList.push({
                                       id: id,
                                       name: song,
                                       artist: artist,
                                       album: "本地音乐",
                                       picUrl: "qrc:/images/errorLoading.png",
                                       ifIsFavorite: MyJs.checkIsFavorite(id)===-1 ? false: true
                                   })
                    console.log(songsList[i])
                }
            }
            //赋值
            localMusicList = localMusicList.concat(handMusicList)  //合并
            localListView.songCount = localMusicList.length
            localListView.musicList = localMusicList
            console.log("本地音乐 手动添加歌曲数目："+handMusicList.length)
            saveLocalCache(localMusicList)  //保存缓存
        }
    }
}




