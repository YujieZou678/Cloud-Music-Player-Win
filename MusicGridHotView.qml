/*
author: zouyujie
date: 2023.11.18
function: 推荐内容窗口的热门歌单视图
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {

    property var hotList: []

    Grid {
        id: gridLayOut
        anchors.fill: parent
        columns: 5

        Repeater {
            id: gridRepeater
            model: hotList
            Frame {
                padding: 5
                width: parent.width*0.2
                height: parent.width*0.2 + 30
                background: Rectangle {
                    id: background
                    color: "#00000000"
                }
                clip: true

                MusicBorderImage {
                    id: img
                    width: parent.width
                    height: parent.height - 30
                    imgSrc: modelData.coverImgUrl
                    imageLoading.width: 25
                    imageLoading.height: 25
                }

                //歌单下的评语
                Text {
                    height: 30
                    width: parent.width
                    anchors {
                        top: img.bottom
                        topMargin: 5
                        horizontalCenter: parent.horizontalCenter
                    }
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData.name
                    font {
                        family: window.mFONT_FAMILY
                        pointSize: 11
                    }
                    elide: Qt.ElideMiddle
                    color: "#eeffffff"
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        background.color = "#50ffffff"
                    }
                    onExited: {
                        background.color = "#00000000"
                    }
                    onClicked: {
                        var id = modelData.id+""
                        pageHomeView.showPlayList(id, "1000")
                    }
                }
            }  //end Frame

        }
    }
}
