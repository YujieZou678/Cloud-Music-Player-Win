/*
author: zouyujie
date: 2023.11.18
function: 我喜欢列表视图。
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {

    property alias favoriteListView: favoriteListView

    Rectangle {
        Layout.fillWidth: true
        width: parent.width
        height: 60
        color: "#00000000"

        Text {
            x: 10
            //文本与底部对齐
            verticalAlignment: Text.AlignBottom
            text: qsTr("我喜欢")
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

//        MusicTextButton {
//            btnText: "刷新记录"
//            btnHeight: 50
//            btnWidth: 200
//            onClicked: {
//                favoriteListView.musicList = []
//                mainFavoriteList = []  //触发改变信号就可
//            }
//        }
        MusicTextButton {
            btnText: "清空缓存"
            btnHeight: 50
            btnWidth: 200
            onClicked: {
                clearFavoriteCache()
                mainFavoriteList.forEach(item=>{  //把当前列表的是否收藏属性置为false
                                             item.ifIsFavorite = false
                                         })
                //刷新并将列表置为空
                favoriteListView.musicList = []
                mainFavoriteList = []  //触发改变信号就可
            }
        }
    }

    MusicListView {
        id: favoriteListView
        modelName: "DetailFavoritePageView"  //列表视图额外的属性
    }

    Component.onCompleted: {
        favoriteListView.musicList = mainFavoriteList.reverse()  //颠倒
        favoriteListView.songCount = mainFavoriteList.length
    }
}
