/*
author: zouyujie
date: 2024.3.4
function: 重写toolTip。
*/
import QtQuick

Rectangle {

    property alias text: content.text
    property int margin: 0
    property int parentX: 0
    property int parentY: 0

    property bool isTop: true  //默认为top

    id: self

    color: "white"
    radius: 4
    width: content.width + 20
    height: content.height + 20

    anchors {
        top: isTop ? parent.bottom:undefined
        bottom: isTop ? undefined:parent.top
    }
    x: {
        var w = width - parent.width
        if (w >= 0) {
            if (parentX-w/2 < 5) return 5
            else {
                //17 = 12 + 5, 有间隙
                if (parentX-w/2+width > window.width-17) return -(width-(parent.width-5))
                return -w/2
            }
        }
        else return -w/2
    }

    Text {
        id: content
        text: "这是一段提示文字!"
        lineHeight: 1.2
        anchors.centerIn: parent
        font.family: window.mFONT_FAMILY
    }

    function getGlobalPosition(target = parent) {
        var targetX = 0
        var targetY = 0
        while (target !== null) {
            targetX += targetX
            targetY += targetY
            target = target.parent
        }
        return {
            x: targetX,
            y: targetY
        }
    }
}
