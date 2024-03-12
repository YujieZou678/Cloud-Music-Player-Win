/*
author: zouyujie
date: 2023.11.18
function: 最上面那层部件所用的按钮
*/
import QtQuick
import QtQuick.Controls

ToolButton {
    property string iconSource: ""

    property string toolTip: "提示"

    property bool isCheckable: false
    property bool isChecked: false

    id: self

    icon.source: iconSource
    icon.height: 22
    icon.width: 22

    //提示是否可见
    //ToolTip.visible: hovered
    //提示内容
    //ToolTip.text: toolTip
    MusicToolTip {
        visible: parent.hovered
        text: toolTip
        parentX: parent.x
        parentY: parent.y
    }

    //默认为鼠标悬浮背景变白
    background: Rectangle {
        color: self.down || (isCheckable && self.isChecked) ? "#eeeeee" : "#00000000"
    }
    icon.color: self.down ? "#00000000" : "#eeeeee"

    //是否可检测
    checkable: isCheckable
    //如果可检测，则在点击或有焦点空格后转换true或false
    checked: isChecked
}
