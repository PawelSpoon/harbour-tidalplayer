import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.6
import Sailfish.Media 1.0

import "widgets"


Page {
    id: playlistPage
    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        width: parent.width
        anchors.fill: parent
        PullDownMenu {
            MenuItem {
                text: minPlayerPanel.open ? "Hide player" : "Show player"
                onClicked: minPlayerPanel.open = !minPlayerPanel.open
                anchors.horizontalCenter: parent.horizontalCenter
            }

            MenuItem {
                text: qsTr("Clear")
                onClicked:
                {
                    playlistManager.clearPlayList()
                    pLtrackList.clear();
                }
            }
        }

            TrackList {
                id: pLtrackList
                title :  "Current Playlist"
                allow_add: false
                start_on_tap : true
                allow_play: false
                anchors {
                    top : parent.bottom
                    fill: parent
                    horizontalCenter: parent.horizontalCenter
                }
            }

   }

    Connections
    {
        target: playlistManager
        onCurrentTrack:
        {
            pLtrackList.highlight_index = position
        }

        onClearList:
        {
            //trackList.clear();
        }

    }
    Connections {
        target: pythonApi
        onTrackChanged:
        {
            pLtrackList.addTrack(title, artist, album, id, duration)
        }
    }

}
