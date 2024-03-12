/*
author: zouyujie
date: 2024.1.21
function: 本地音乐需要用的一个按钮。
*/
import QtQuick
import QtQuick.Controls

Button {
    property alias btnText: name.text

    property alias isCheckable: self.checkable
    property alias isChecked: self.checked
    
    property alias btnHeight: self.height
    property alias btnWidth: self.width

    id: self


    Text {
        id: name
        text: "Button"
        color: self.down || (isCheckable && isChecked) ? "#ee000000" : "#eeffffff"
        anchors.centerIn: parent
        font.family: window.mFONT_FAMILY
        font.pointSize: 14
    }

    background: Rectangle {
        implicitHeight: self.height
        implicitWidth: self.width
        color: self.down || (isCheckable && isChecked) ? "#e2f0f8" : "#66e9f4ff"
        radius: 3
    }

    width: 50
    height: 50
    //是否可检测
    checkable: false
    //如果可检测，则在点击或有焦点空格后转换true或false
    checked: false
}
