/*
author: zouyujie
date: 2023.11.18
function: 播放历史列表视图。
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {

    property alias historyListView: historyListView
    property bool ifNeedRefreshList: false
    function refreshList() {
        historyListView.musicList = historyListView.musicList
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
            text: qsTr("播放历史")
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
//            btnText: "自动搜索(非全盘)"
//            btnHeight: 50
//            btnWidth: 200
//            onClicked: {
//            }
//        }
//        MusicTextButton {
//            btnText: "刷新历史记录"
//            btnHeight: 50
//            btnWidth: 200
//            onClicked: {
//                historyListView.musicList = []
//                mainHistoryList = []  //触发改变信号就可
//            }
//        }
        MusicTextButton {
            btnText: "清空缓存"
            btnHeight: 50
            btnWidth: 200
            onClicked: {
                clearHistoryCache()
                //刷新
                historyListView.musicList = []
                mainHistoryList = []  //触发改变信号就可
                mainHistoryListCopy = []
            }
        }
    }

    MusicListView {
        id: historyListView
        modelName: "DetailHistoryPageView"  //列表视图额外的属性
    }

    Component.onCompleted: {
        historyListView.musicList = mainHistoryList.reverse()  //副本颠倒
        historyListView.songCount = mainHistoryList.length
    }
}
