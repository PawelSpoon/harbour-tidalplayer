import QtQuick 2.0
import io.thp.pyotherside 1.5

Item {
    id: root

    // Wichtige Login/Auth Signale
    signal authUrl(string url)
    signal oAuthSuccess(string type, string token, string rtoken, string date)
    signal oAuthRefresh(string token)

    signal loginSuccess()
    signal loginFailed()

    // Search Signale
    signal trackSearchFinished()
    signal artistSearchFinished()
    signal albumSearchFinished()
    signal searchFinished()

    // Item Signale
    signal trackAdded(int id, string title, string album, string artist, string image, int duration)
    signal albumAdded(int id, string title, string artist, string image, int duration)
    signal artistAdded(int id, string name, string image)

    signal playlistSearchAdded(int id, string name, string image, int duration, string uid)
    signal personalPlaylistAdded(string id, string title, string image, int num_tracks, string description, int duration)
    signal playlistAdded(string id, string title, string image, int num_tracks, string description, int duration)

    // Info Change Signale
    signal trackChanged(int id, string title, string album, string artist, string image, int duration)
    signal albumChanged(int id, string title, string artist, string image)
    signal artistChanged(int id, string name, string img)
    signal currentTrackInfo(string title, int track_num, string album, string artist, int duration, string album_image, string artist_image)

    /* new signals come here*/
    signal searchResults(var search_results)
    signal playurl(string url)
    signal currentPlayback(var trackinfo)
    signal cacheTrack(var track_info)
    signal cacheAlbum(var album_info)
    signal cacheArtist(var artist_info)
    signal albumofArtist(var album_info)
    signal topTracksofArtist(var track_info)
    signal similarArtist(var artist_info)

    signal foundTrack(var track_info)
    signal foundPlaylist(var playlist_info)
    signal foundAlbum(var album_info)
    signal foundArtist(var artist_info)
    signal foundVideo(var video_info)

    signal favTracks(var track_info)
    signal favAlbums(var album_info)
    signal favArtists(var artist_info)

    signal noSimilarArtists()

    signal playlistTrackAdded(var track_info)
    signal albumTrackAdded(var track_info)

    // Properties für die Suche
    property string artistsResults
    property string albumsResults
    property string tracksResults

    property bool albums: true
    property bool artists: true
    property bool tracks: true
    property bool playlists: true

    property bool loginTrue: false
    property bool loading: false

    property string playlist_track: ""
    property string playlist_artist: ""
    property string playlist_album: ""
    property string playlist_image: ""

    property string current_track_title : ""
    property string current_track_artist : ""
    property string current_track_album : ""
    property string current_track_image : ""

    property string quality: ""


    property int playlist_duration: 0
    property int playlist_track_id: 0

    Python {
        id: pythonTidal

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../'))

            // Login Handler
            setHandler('get_url', function(newvalue) {
                tidalApi.authUrl(newvalue)
            })
            setHandler('oauth_success', function() {
                tidalApi.loginSuccess()
            })
            setHandler('oauth_login_success', function() {
                tidalApi.loginSuccess()
            })
            setHandler('oauth_failed', function() {
                tidalApi.loginFailed()
            })
            setHandler('get_token', function(type, token, rtoken, date) {
                console.log("Got new token from session")
                console.log(type, token, rtoken, date)
                tidalApi.oAuthSuccess(type, token, rtoken, date)
            })

            setHandler('oauth_refresh', function(token) {
                console.log("Got new token from session")
                console.log(token)
                tidalApi.oAuthRefresh(token)
            })

            // Debug Handler
            setHandler('printConsole', function(string) {
                console.log("tidalApi::printConsole " + string)
            })

            // Search Handler
            //setHandler('cacheTrack', function(id, title, album, artist, image, duration) {
            //    tidalApi.cacheTrack(id, title, album, artist, image, duration)
            //})

            setHandler('cacheTrack', function(track_info) {
                tidalApi.cacheTrack(track_info)
            })

            setHandler('cacheArtist', function(artist_info) {
                tidalApi.cacheArtist(artist_info)
            })
            setHandler('cacheAlbum', function(album_info) {
                tidalApi.cacheAlbum(album_info)
            })

            setHandler('TopTrackofArtist', function(track_info) {
                tidalApi.topTracksofArtist(track_info)
            })

            setHandler('AlbumofArtist', function(album_info) {
                tidalApi.albumofArtist(album_info)
            })

            setHandler('SimilarArtist', function(artist_info) {
                //cacheManager.saveArtistToCache(artist_info)
                tidalApi.cacheArtist(artist_info)
                tidalApi.similarArtist(artist_info)
            })

            setHandler('noSimilarArtists', function() {
                tidalApi.noSimilarArtists()
            })

            setHandler('foundTrack', function(track_info) {
                tidalApi.foundTrack(track_info)
            })

            setHandler('foundAlbum', function(album_info) {
                tidalApi.foundAlbum(album_info)
            })

            setHandler('foundArtist', function(artist_info) {
                tidalApi.foundArtist(artist_info)
            })


            setHandler('foundPlaylist', function(playlist_info) {
                tidalApi.foundPlaylist(playlist_info)
            })


            setHandler('foundVideo', function(video_info) {
                tidalApi.foundVideo(video_info)
            })


            setHandler('FavAlbums', function(album_info) {
                tidalApi.favAlbums(album_info)
            })

            setHandler('FavTracks', function(track_info) {
                tidalApi.favTracks(track_info)
            })

            setHandler('FavArtist', function(artist_info) {
                tidalApi.favArtists(artist_info)
            })

            setHandler('foundPlaylist', function(playlist_info) {
                tidalApi.foundPlaylist(playlist_info)
            })

            // Search Handler
            setHandler('addTrack', function(id, title, album, artist, image, duration) {
                tidalApi.trackAdded(id, title, album, artist, image, duration)
            })
            setHandler('addArtist', function(id, name, image) {
                tidalApi.artistAdded(id, name, image)
            })
            setHandler('addAlbum', function(id, title, artist, image, duration) {
                tidalApi.albumAdded(id, title, artist, image, duration)
            })
            setHandler('addPlaylist', function(id, name, image, duration, uid) {
                tidalApi.playlistSearchAdded(id, name, image, duration, uid)
            })


            // Search Finished Handler
            setHandler('trackSearchFinished', function() {
                tidalApi.trackSearchFinished()
            })
            setHandler('artistsSearchFinished', function() {
                tidalApi.artistSearchFinished()
            })
            setHandler('albumsSearchFinished', function() {
                tidalApi.albumSearchFinished()
            })

            setHandler('fillStarted', function()
            {
                playlistManager.nextTrack();
            });

            setHandler('fillFinished', function()
            {
                playlistManager.generateList()
                //playlistManager.nextTrack();
            });

            // Info Handler
            setHandler('trackInfo', function(id, title, album, artist, image, duration) {
                tidalApi.trackChanged(id, title, album, artist, image, duration)
            })
            setHandler('albumInfo', function(id, title, artist, image) {
                tidalApi.albumChanged(id, title, artist, image)
            })
            setHandler('artistInfo', function(id, name, img) {
                tidalApi.artistChanged(id, name, img)
            })

            // Playlist Handler
            setHandler('addPersonalPlaylist', function(id, name, image, num_tracks, description, duration) {
                tidalApi.personalPlaylistAdded(id, name, image, num_tracks, description, duration)
            })
            setHandler('setPlaylist', function(id, title, image, num_tracks, description, duration) {
                tidalApi.playlistAdded(id, title, image, num_tracks, description, duration)
            })
            setHandler('currentTrackInfo', function(title, track_num, album, artist, duration, album_image, artist_image) {
                tidalApi.currentTrackInfo(title, track_num, album, artist, duration, album_image, artist_image)
            })

            setHandler('addTracktoPL', function(id)
            {
                console.log("appended to PL", id)
                playlistManager.appendTrack(id)
            });
             // URL Handler
            setHandler('playUrl', function(url) {
                mediaPlayer.source = url
                mediaPlayer.play()
            })

            /* new handler will be placed here */

            setHandler('search_results', function(search_result) {
                console.log(search_result)
                searchResults(search_result)
            })

            setHandler('playback_info', function(info) {
                mediaController.playUrl(info.url)
                currentPlayback(info.track)
                tidalApi.current_track_title = info.track.title
                tidalApi.current_track_artist = info.track.artist
                tidalApi.current_track_album = info.track.album
                tidalApi.current_track_image = info.track.image

            })

            setHandler('playlist_replace', function(playlist) {
                playlistManager.clearList()
                searchResults(playlist)
            })

            setHandler('loadingStarted', function() {
                root.loading = true
            })

            setHandler('loadingFinished', function() {
                root.loading = false
            })

            setHandler('playlistTrackAdded', function(track_info) {
                root.playlistTrackAdded(track_info)
            })

            setHandler('albumTrackAdded', function(track_info) {
                root.albumTrackAdded(track_info)
            })

            importModule('tidal', function() {
                console.log("Tidal module imported successfully")
            })
        }


        function getTrackInfo(id)
        {
            console.log("getTrackInfo ", id)
            var track = (call_sync("tidal.Tidaler.getTrackInfo", [id], function(track) {
                console.log(track)
            }));
            console.log(track)
            return track
        }


    }

    onOAuthSuccess: {
            console.log(type, token, rtoken, date)
            authManager.updateTokens(type, token, rtoken, date)
            loginSuccess()
        }

        onLoginSuccess: {
            loginTrue = true
        }

        onLoginFailed: {
            loginTrue = false
            if (authManager) {
                authManager.clearTokens()
            }
        }


    // Login Funktionen
    function getOAuth() {
        console.log("Request new login")
        pythonTidal.call('tidal.Tidaler.initialize', [quality])
        pythonTidal.call('tidal.Tidaler.request_oauth', [])
    }

    function loginIn(tokenType, accessToken, refreshToken, expiryTime) {
        console.log(accessToken)
        pythonTidal.call('tidal.Tidaler.initialize', [quality])
        pythonTidal.call('tidal.Tidaler.login',
            [tokenType, accessToken, refreshToken, expiryTime])
    }

    // Search Funktionen
    function genericSearch(text) {
        console.log("generic search", text)
        pythonTidal.call("tidal.Tidaler.genericSearch", [text])
    }

    function search(searchText) {
        if(tracks) {
            pythonTidal.call('tidal.Tidaler.search_track', [searchText])
        }
        if(artists) {
            pythonTidal.call('tidal.Tidaler.search_artist', [searchText])
        }
        if(albums) {
            pythonTidal.call('tidal.Tidaler.search_album', [searchText])
        }
        if(playlists) {
            pythonTidal.call('tidal.Tidaler.search_playlist', [searchText])
        }
    }

    // Track Funktionen
    function playTrackId(id) {
        console.log(id)
        pythonTidal.call("tidal.Tidaler.getTrackUrl", [id], function(name) {
            console.log(name.url)
            if(typeof name === 'undefined')
                console.log(typeof name)
            else
                console.log(typeof name)
        })
    }

    function getTrackInfo(id) {
        if (typeof id === 'string') {
            id = id.split('/').pop()
            id = id.replace(/[^0-9]/g, '')
        }
        console.log("JavaScript id after:", id, typeof id)

        var returnValue = null

        pythonTidal.call_sync("tidal.Tidaler.getTrackInfo", [id], function(result) {
            if (result) {
                // Properties aktualisieren
                playlist_track = result.title
                playlist_artist = result.artist
                playlist_album = result.album
                // playlist_image = result.image
                // Return-Wert setzen
                returnValue = result
            }
        })
        console.log(returnValue)
        return returnValue
    }

    // Album Funktionen
    function getAlbumTracks(id) {
        console.log("Get album tracks", id)
        pythonTidal.call("tidal.Tidaler.getAlbumTracks", [id])
    }

    function getAlbumInfo(id) {
        pythonTidal.call("tidal.Tidaler.getAlbumInfo", [id])
    }

    function playAlbumTracks(id) {
        pythonTidal.call("tidal.Tidaler.playAlbumTracks", [id])
    }

    function playAlbumFromTrack(id) {
        pythonTidal.call("tidal.Tidaler.playAlbumfromTrack", [id])
    }

    // Artist Funktionen
    function getArtistInfo(id) {
        pythonTidal.call("tidal.Tidaler.getArtistInfo", [id])
    }

    // Playlist Funktionen
    function getPersonalPlaylists() {
        pythonTidal.call('tidal.Tidaler.getPersonalPlaylists', [])
        pythonTidal.call('tidal.Tidaler.homepage', [])

    }

    function getPlaylistTracks(id) {
        pythonTidal.call('tidal.Tidaler.getPlaylistTracks', [id])
    }

    function playPlaylist(id) {
        pythonTidal.call("tidal.Tidaler.playPlaylist", [id])
    }

    function getFavorites() {
        pythonTidal.call('tidal.Tidaler.get_favorite_tracks', [])
    }

    function getAlbumsofArtist(artistid) {
        pythonTidal.call('tidal.Tidaler.getAlbumsofArtist', [artistid])
    }

    function getTopTracksofArtist(artistid) {
        pythonTidal.call('tidal.Tidaler.getTopTracksofArtist', [artistid])
    }

    function getSimiliarArtist(artistid) {
        pythonTidal.call('tidal.Tidaler.getSimiliarArtist', [artistid])
    }

    function getFavorits(artistid) {
        pythonTidal.call('tidal.Tidaler.getFavorits', [artistid])
    }
}


