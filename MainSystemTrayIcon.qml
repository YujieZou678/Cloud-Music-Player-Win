/*
author: zouyujie
date: 2024..3.2
function: 该软件的系统托盘图标。
*/
import Qt.labs.platform
import QtQuick
import QtMultimedia
import "requestNetwork.js" as MyJs

SystemTrayIcon {
    id: systemTray
    visible: true
    icon.source: "qrc:/images/music"
    onActivated: {
        window.x = (Screen.desktopAvailableWidth-width)/2
        window.y = (Screen.desktopAvailableHeight-height)/2
        window.show()
        window.raise()
        window.requestActivate()
    }
    menu: Menu {
        id: menu
        MenuItem {
            text: "上一曲"
            onTriggered: { MyJs.switchSong(false, layoutBottomView.modePlay, false) }
            icon.source: "qrc:/images/previous.png"
        }
        MenuItem {
            text: window.mediaPlayer.playbackState===1 ? "暂停":"播放"
            onTriggered: {
                switch (window.mediaPlayer.playbackState) {
                case MediaPlayer.PlayingState:
                    window.mediaPlayer.pause()
                    layoutBottomView.playStateSource = "qrc:/images/stop.png"
                    pageDetailView.cover.isRotating = false
                    break;
                case MediaPlayer.PausedState:
                    window.mediaPlayer.play()
                    layoutBottomView.playStateSource = "qrc:/images/pause.png"
                    pageDetailView.cover.isRotating = true
                    break;
                }
            }
            icon.source: window.mediaPlayer.playbackState===1 ? "qrc:/images/stop.png":"qrc:/images/pause.png"
        }
        MenuItem {
            text: "下一曲"
            onTriggered: { MyJs.switchSong(true, layoutBottomView.modePlay, false) }
            icon.source: "qrc:/images/next.png"
        }
        MenuSeparator {}
        MenuItem {
            text: "显示"
            onTriggered: {
                window.x = (Screen.desktopAvailableWidth-width)/2
                window.y = (Screen.desktopAvailableHeight-height)/2
                window.show()
                window.raise()
                window.requestActivate()
            }
            icon.source: "qrc:/images/music.png"
        }
        MenuItem {
            text: "退出"
            onTriggered: { Qt.quit() }
            icon.source: "qrc:/images/clear.png"
        }
    }
}
