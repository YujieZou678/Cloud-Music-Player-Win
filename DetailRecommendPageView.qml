/*
author: zouyujie
date: 2023.11.18
function: 推荐内容窗口
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "requestNetwork.js" as MyJs

//为了有滑轮，隐藏超出的视图
ScrollView {

    //如果网络请求没有数据
    signal noData(var modelName)
    //如果网络请求有数据
    signal yesData(var modelName)

    clip: true
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: ScrollBar.AlwaysOff

    ColumnLayout {
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            width: parent.width
            height: 50
            color: "#00000000"

            Text {
                x: 10
                //文本与底部对齐
                verticalAlignment: Text.AlignBottom
                text: qsTr("推荐内容")
                font.family: window.mFONT_FAMILY
                font.pointSize: 25
                color: "#eeffffff"
            }
        }

        //banner
        MusicBannerView {
            id: bannerView
            Layout.preferredWidth: window.width/6*5
            Layout.preferredHeight: window.width/6*5*0.3
            Layout.fillHeight: true
            Layout.fillWidth: true
            Component.onCompleted: {
                //手动给Json数组赋值
                var json = []
                var oneJsonData = {
                    "picUrl":"qrc:/images/errorLoading.png"
                }
                for (var i=0; i<5; i++) {
                    json.push(oneJsonData)
                }
                bannerView.bannerList = json
            }
        }

        Rectangle {
            Layout.fillWidth: true
            width: parent.width
            height: 50
            color: "#00000000"

            Text {
                x: 10
                //文本与底部对齐
                verticalAlignment: Text.AlignBottom
                text: qsTr("热门歌单")
                font.family: window.mFONT_FAMILY
                font.pointSize: 25
                color: "#eeffffff"
            }
        }

        //热门歌单网格布局
        MusicGridHotView {
            id: gridHotView
            Layout.preferredWidth: window.width/6*5
            Layout.preferredHeight: window.width/6*5/5*4 + 120
            Layout.fillHeight: true
            Layout.fillWidth: true
            Component.onCompleted: {
                //手动给Json数组赋值
                var json = []
                var oneJsonData = {
                    "id": "未知",
                    "coverImgUrl":"qrc:/images/errorLoading.png",
                    "name":"歌单"
                }
                for (var i=0; i<20; i++) {
                    json.push(oneJsonData)
                }
                gridHotView.hotList = json
            }
        }

        Rectangle {
            Layout.fillWidth: true
            width: parent.width
            height: 50
            color: "#00000000"

            Text {
                x: 10
                //文本与底部对齐
                verticalAlignment: Text.AlignBottom
                text: qsTr("新歌推荐")
                font.family: window.mFONT_FAMILY
                font.pointSize: 25
                color: "#eeffffff"
            }
        }

        //新歌推荐网格布局
        MusicGridLatestView {
            id: latestView
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: window.width/6*5
            Layout.preferredHeight: window.width/6*5*0.1*10
            Component.onCompleted: {
                //手动给Json数组赋值
                var json = []
                var oneJsonData = {
                    "id": "未知",
                    "picUrl":"qrc:/images/errorLoading.png",
                    "name": "歌名",
                    "artist": "作者"
                }
                for (var i=0; i<30; i++) {
                    json.push(oneJsonData)
                }
                latestView.latestList = json
            }
        }
    }

    Component.onCompleted: {
        //实现异步请求,并进行相应处理
        postRequest("/banner", getBannerList, "bannerList")
        postRequest("/top/playlist/highquality?limit=20", getHotList, "hotList")
        postRequest("/top/song", getLatestList, "latestList")
    }

    onNoData: function(modelName) {
        //判断是哪个模块发出的请求
        if (modelName === "bannerList") {
            bannerRepeatRequest.start()  //反复请求
        }
        else if (modelName === "hotList") {
            hotListRepeatRequest.start()  //反复请求
        }
        else if (modelName === "latestList") {
            latestRepeatRequest.start()  //反复请求
        }
    }
    onYesData: function(modelName){
        //判断是哪个模块发出的请求
        if (modelName === "bannerList") {
            bannerRepeatRequest.stop()  //停止反复请求
        }
        else if (modelName === "hotList") {
            hotListRepeatRequest.stop()  //停止反复请求
        }
        else if (modelName === "latestList") {
            latestRepeatRequest.stop()  //停止反复请求
        }
    }

    //网络请求失败的间断性反复请求
    Timer {
        id: bannerRepeatRequest
        interval: 1000
        repeat: true
        running: false
        onTriggered: { postRequest("/banner", getBannerList, "bannerList") }
    }
    Timer {
        id: hotListRepeatRequest
        interval: 1000
        repeat: true
        running: false
        onTriggered: { postRequest("/top/playlist/highquality?limit=20", getHotList, "hotList") }
    }
    Timer {
        id: latestRepeatRequest
        interval: 1000
        repeat: true
        running: false
        onTriggered: { postRequest("/top/song", getLatestList, "latestList") }
    }

    function getBannerList(data) {
        //在JS中string转JSON，得到Json数组
        var banners = JSON.parse(data).banners
        //赋值
        bannerView.bannerList = banners.map(item=>{
                                                return {
                                                        id: item.targetId+"",
                                                        name: item.typeTitle,
                                                        artist: "未知",
                                                        album: "未知",
                                                        picUrl: item.imageUrl,
                                                        type: item.targetType,
                                                        ifIsFavorite: false
                                                    }
                                            })
    }

    function getHotList(data) {
        //在JS中string转JSON，得到Json数组
        var playLists = JSON.parse(data).playlists
        //赋值
        gridHotView.hotList = playLists
    }

    function getLatestList(data) {
        //在JS中string转JSON，得到Json数组
        var latestLists = JSON.parse(data).data
        //先跟播放历史做比较替换
        var temp = latestLists.slice(0,30).map(item=>{
                                 var index = MyJs.checkIsHistory(item.id+"")
                                 if (index !== -1) {
                                     return mainHistoryList[index]
                                 }
                                 else {
                                     return {
                                         id: item.id+"",
                                         name: item.name,
                                         artist: item.artists[0].name,
                                         album: "未知",
                                         picUrl: item.album.picUrl,
                                         ifIsFavorite: false
                                     }
                                 }
                              })

        //再跟我喜欢做比较替换
        latestView.latestList = temp.map(item=>{
                                             var index = MyJs.checkIsFavorite(item.id+"")
                                             if (index !== -1) {
                                                 return mainFavoriteList[index]
                                             }
                                             else return item
                                         })
    }

    //网络请求模板函数的重载
    function postRequest(url="", handleData, moduleName) {
        //得到一个空闲的manager
        var manager = getFreeManager()

        function onReply(data) {
            //得到数据立马断开连接,重置状态
            switch(manager) {
            case 0:
                onReplySignal1.disconnect(onReply)
                reSetStatus(manager)
                break;
            case 1:
                onReplySignal2.disconnect(onReply)
                reSetStatus(manager)
                break;
            case 2:
                onReplySignal3.disconnect(onReply)
                reSetStatus(manager)
                break;
            }
            //如果传递的数据为空，则判断网络请求失败
            if (data==="") {
                console.log("Error: no data!")
                noData(moduleName)
                return;
            }
            yesData(moduleName)
            //处理数据
            handleData(data)
        }
        switch(manager) {
        case 0:
            onReplySignal1.connect(onReply)
            break;
        case 1:
            onReplySignal2.connect(onReply)
            break;
        case 2:
            onReplySignal3.connect(onReply)
            break;
        }

        //请求数据
        getData(url, manager)
    }
}
