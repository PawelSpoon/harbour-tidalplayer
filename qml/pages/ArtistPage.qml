import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.6
import Sailfish.Media 1.0

import "widgets"


Page {
    id: artistPage
    property int track_id

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {

        width: parent.width
        anchors {
            fill: parent
            bottomMargin: minPlayerPanel.margin
        }
        PullDownMenu {
            MenuItem {
                text: qsTr("Show Playlist")
                onClicked:
                {
                    onClicked: pageStack.push(Qt.resolvedUrl("PlaylistPage.qml"))
                }
            }
            MenuItem {
                text: minPlayerPanel.open ? "Hide player" : "Show player"
                onClicked: minPlayerPanel.open = !minPlayerPanel.open
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Column {
            id: infoCoulumn
            PageHeader {
                id: header
                title:  qsTr("Artist Info")
            }
            spacing: 10 // Abstand zwischen den Elementen in der Column
            width: parent.width // Die Column nimmt die volle Breite des Eltern-Elements (Item) ein

            Image {
                id: coverImage
                anchors {
                    top: header.bottom
                    horizontalCenter: albumPage.isPortrait ? parent.horizontalCenter : undefined
                }

                sourceSize.width: {
                    var maxImageWidth = Screen.width
                    var leftMargin = Theme.horizontalPageMargin
                    var rightMargin = artistPage.isPortrait ? Theme.horizontalPageMargin : 0
                    return (maxImageWidth - leftMargin - rightMargin)*3/2
                }

                fillMode: Image.PreserveAspectFit
            }
            Label
            {
                id: artistName
                anchors {
                    top : coverImage.bottom
                }
                truncationMode: TruncationMode.Fade
                color: Theme.highlightColor
            }
        }
            TrackList {
                id: topTracks
                title :  "Popular Tracks"

                anchors {
                     top: infoCoulumn.bottom// Anker oben an den unteren Rand der Column
                     topMargin: 650 // Abstand zwischen der Column und dem ListView
                     left: parent.left // Anker links am linken Rand des Eltern-Elements (Page)
                     right: parent.right // Anker rechts am rechten Rand des Eltern-Elements (Page)
                     leftMargin: Theme.horizontalPageMargin
                     rightMargin: Theme.horizontalPageMargin
                     //bottom: parent.bottom// Anker unten am unteren Rand des Eltern-Elements (Page)
                 }
                height: 600
                start_on_top : true
            }

        }

    Connections {
        target: pythonApi

        onArtistChanged:
        {
            header.title = name
            coverImage.source = img
        }
        onTrackAdded:
        {
            topTracks.addTrack(title, artist, album, id, duration)
        }

    }
}
