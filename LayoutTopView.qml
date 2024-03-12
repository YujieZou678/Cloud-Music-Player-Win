/*
author: zouyujie
date: 2023.11.18
function: 最上面那层部件，最小化，关闭......
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

ToolBar {

    property bool isSmallWindow: false

    width: parent.width
    Layout.fillWidth: true
    //ToolBar背景颜色
    background: Rectangle { color: "#00000000" }

    RowLayout {
        anchors.fill: parent
        TapHandler {
            onTapped: if (tapCount === 2) toggleMaximized()
            gesturePolicy: TapHandler.DragThreshold
        }
        DragHandler {  //跟随移动
            grabPermissions: PointerHandler.CanTakeOverFromAnything
            onActiveChanged: if (active) { window.startSystemMove() }
        }

        MusicToolButton {
            iconSource: "qrc:/images/music"
            toolTip: "关于"
            onClicked: {
                aboutPop.open()
            }
        }
        MusicToolButton {
            iconSource: "qrc:/images/about"
            toolTip: "博客"
            onClicked: {
                Qt.openUrlExternally("https://www.hyz.cool")
            }
        }
        MusicToolButton {
            id: smallWindow
            iconSource: "qrc:/images/small-window"
            toolTip: "小窗播放"
            onClicked: {
                setWindowSize(650, 330)
                visible = false
                exitSmallWindow.visible = true
                maxWindow.visible = true
                exitMaxWindow.visible = false

                isSmallWindow = true
                pageHomeView.visible = false
                pageDetailView.visible = true

                mainBackground.switchView(true)  //背景到歌词界面
            }
        }
        MusicToolButton {
            id: exitSmallWindow
            iconSource: "qrc:/images/exit-small-window"
            toolTip: "退出小窗播放"
            visible: false
            onClicked: {
                setWindowSize()
                visible = false
                smallWindow.visible = true

                isSmallWindow = false
            }
        }
        Item {
            Layout.fillWidth: true; height: 32
            Text {
                anchors.centerIn: parent
                text: qsTr("云坠入雾里")
                font.family: window.mFONT_FAMILY
                font.pixelSize: 16
                color: "#ffffff"
            }
        }
        MusicToolButton {
            iconSource: "qrc:/images/minimize-screen"
            toolTip: "最小化"
            onClicked: {
                window.showMinimized()
            }
        }
        MusicToolButton {
            id: maxWindow
            iconSource: "qrc:/images/full-screen"
            //icon.name: "view-fullscreen"
            toolTip: "全屏播放"
            onClicked: {
                window.visibility = Window.Maximized
                maxWindow.visible = false
                exitMaxWindow.visible = true
                smallWindow.visible = true
                exitSmallWindow.visible = false

                isSmallWindow = false
            }
        }
        MusicToolButton {
            id: exitMaxWindow
            iconSource: "qrc:/images/small-screen"
            toolTip: "退出全屏播放"
            visible: false
            onClicked: {
                setWindowSize()
                exitMaxWindow.visible = false
                maxWindow.visible = true
            }
        }
        MusicToolButton {
            iconSource: "qrc:/images/power"
            toolTip: "退出"
            onClicked: {
                Qt.quit()
            }
        }
    }  //end RowLayout

    //设置主窗口大小及位置(有默认数值)
    function setWindowSize(height = window.mWINDOW_HEIGHT, width = window.mWINDOW_WIDTH) {
        window.height = height
        window.width = width
        //恢复正常窗口后主窗口居中
        window.x = (Screen.desktopAvailableWidth - window.width)/2
        window.y = (Screen.desktopAvailableHeight - window.height)/2
    }
    //“关于”的弹窗
    Popup{
            id:aboutPop
            topInset: 0
            leftInset: -2
            rightInset: 0
            bottomInset: 0

            //该组件下面的那个组件
            parent: Overlay.overlay
            x:(parent.width-width)/2
            y:(parent.height-height)/2

            width: 250
            height: 230

            background: Rectangle{
                color:"#e9f4ff"
                radius: 5
                border.color: "#2273a7ab"
            }

            contentItem: ColumnLayout{
                width: parent.width
                height: parent.height
                Layout.alignment: Qt.AlignHCenter

                Image{
                    Layout.preferredHeight: 60
                    source: "qrc:/images/music"
                    Layout.fillWidth:true
                    fillMode: Image.PreserveAspectFit

                }

                Text {
                    text: qsTr("续加仪")
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 18
                    color: "#8573a7ab"
                    font.family: window.mFONT_FAMILY
                    font.bold: true
                }
                Text {
                    text: qsTr("这是我的Cloud Music Player")
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 16
                    color: "#8573a7ab"
                    font.family:  window.mFONT_FAMILY
                    font.bold: true
                }
                Text {
                    text: qsTr("www.hyz.cool")
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 16
                    color: "#8573a7ab"
                    font.family:  window.mFONT_FAMILY
                    font.bold: true
                }
            }
    }

    function toggleMaximized() {  //切换最大化
        if (window.visibility === Window.Maximized) {
            setWindowSize()
            exitMaxWindow.visible = false
            maxWindow.visible = true
        } else {
            window.visibility = Window.Maximized
            maxWindow.visible = false
            exitMaxWindow.visible = true
            smallWindow.visible = true
            exitSmallWindow.visible = false

            isSmallWindow = false
        }
    }
}  //end ToolBar
