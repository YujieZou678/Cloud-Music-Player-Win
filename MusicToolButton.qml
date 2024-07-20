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
    property bool ifNeedToolTip: true  //是否需要tooltip
    property bool ifNeedClickBac: true  //是否需要点击背景

    property string iconClickColor: "#00000000"  //点击icon它的颜色
    property string iconColor: "#eeeeee"  //没点击icon它的颜色

    id: self

    icon.source: iconSource
    icon.height: 22
    icon.width: 22

    //提示是否可见
    //ToolTip.visible: hovered
    //提示内容
    //ToolTip.text: toolTip
    MusicToolTip {
        visible: ifNeedToolTip ? parent.hovered:false
        text: toolTip
        parentX: parent.x
        parentY: parent.y
    }

    //默认为鼠标悬浮背景变白
    background: Rectangle {
        visible: ifNeedClickBac
        color: self.down || (isCheckable && self.isChecked) ? "#eeeeee" : "#00000000"
    }
    icon.color: self.down ? iconClickColor : iconColor

    //是否可检测
    checkable: isCheckable
    //如果可检测，则在点击或有焦点空格后转换true或false
    checked: isChecked
}
