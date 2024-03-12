import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {

    id: lyricView

    property alias lyrics: list.model
    property alias current: list.currentIndex

    Layout.preferredHeight: parent.height*0.8
    Layout.alignment: Qt.AlignHCenter

    clip: true

    color: "#00000000"

    ListView {
        id: list
        anchors.fill: parent
        model: ["暂无歌词","云坠入雾里","云坠入雾里"]
        delegate: listDelegate
//        highlight: Rectangle {
//            color: "#2073a7db"
//        }
        highlightMoveDuration: 0
        highlightResizeDuration: 0
        currentIndex: 0
        preferredHighlightBegin: parent.height/2-50
        preferredHighlightEnd: parent.height/2
        highlightRangeMode: ListView.StrictlyEnforceRange
    }

    Component {
        id: listDelegate
        Item {
            id: delegateItem
            width: lyricView.width
            height: 50
            Text {
                text: modelData
                anchors.centerIn: parent
                color: index===list.currentIndex?"#eeffffff":"#aaffffff"
                font {
                    family: mFONT_FAMILY
                    pointSize: 16
                }
            }
            states: State {
                when: delegateItem.ListView.isCurrentItem
                PropertyChanges {
                    target: delegateItem
                    scale: 1.2
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: list.currentIndex = index
            }
        }
    }
}
