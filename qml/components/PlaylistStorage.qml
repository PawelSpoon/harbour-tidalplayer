import QtQuick 2.0
import QtQuick.LocalStorage 2.0

Item {
    id: root
    property string playlistTitle: "_current"
    Timer {
        id: updateTimer
        interval: 1000  // 100ms Verzögerung
        repeat: false
        onTriggered: {
            saveCurrentPlaylistState()
        }
    }
    // Signale für Playlist-Events
    signal playlistSaved(string name, var trackIds)
    signal playlistLoaded(string name, var trackIds, int position)
    signal playlistsChanged()
    signal playlistDeleted(string name)

    // Initialisiere Datenbank
    function getDatabase() {
        return LocalStorage.openDatabaseSync(
            "TidalPlayerDB",
            "1.0",
            "Tidal Player Playlist Storage",
            1000000
        );
    }

    // Erstelle Tabellen
    function initDatabase() {
        var db = getDatabase();
        db.transaction(function(tx) {
            // Erweiterte Tabelle mit Position und Timestamp
            tx.executeSql('CREATE TABLE IF NOT EXISTS playlists(
                name TEXT PRIMARY KEY,
                tracks TEXT,
                position INTEGER DEFAULT 0,
                last_played TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )');
        });
    }

    // Speichere Playlist mit Position
    function savePlaylist(name, trackIds, position) {
    console.log("Save database", name, trackIds, position)
        var db = getDatabase();
        var tracksJson = JSON.stringify(trackIds);

        db.transaction(function(tx) {
            tx.executeSql('INSERT OR REPLACE INTO playlists (name, tracks, position, last_played) VALUES(?, ?, ?, CURRENT_TIMESTAMP)',
                         [name, tracksJson, position]);
        });

        playlistSaved(name, trackIds);
        playlistsChanged();
    }

    // Lade Playlist mit Position
    function loadPlaylist(name) {
        playlistTitle = name
        var db = getDatabase();
        var result;

        db.transaction(function(tx) {
            result = tx.executeSql('SELECT tracks, position FROM playlists WHERE name = ?', [name]);
            if (result.rows.length > 0) {
                var trackIds = JSON.parse(result.rows.item(0).tracks);
                var position = result.rows.item(0).position;

                // Aktualisiere last_played
                tx.executeSql('UPDATE playlists SET last_played = CURRENT_TIMESTAMP WHERE name = ?', [name]);

                playlistLoaded(name, trackIds, position);
            }
        });
    }

    // Update Position einer Playlist
    function updatePosition(name, position) {
        var db = getDatabase();

        db.transaction(function(tx) {
            tx.executeSql('UPDATE playlists SET position = ?, last_played = CURRENT_TIMESTAMP WHERE name = ?',
                         [position, name]);
        });
    }

    // Lösche Playlist
    function deletePlaylist(name) {
        var db = getDatabase();

        db.transaction(function(tx) {
            tx.executeSql('DELETE FROM playlists WHERE name = ?', [name]);
        });

        playlistDeleted(name);
        playlistsChanged();
    }

    // Hole alle Playlist-Namen mit Zusatzinformationen
    function getPlaylistInfo() {
        var db = getDatabase();
        var playlists = [];

        db.transaction(function(tx) {
            var result = tx.executeSql('SELECT name, position, tracks, last_played FROM playlists ORDER BY last_played DESC');
            for (var i = 0; i < result.rows.length; i++) {
                var item = result.rows.item(i);
                var tracks = JSON.parse(item.tracks);
                if (tracks == undefined) return playlists;
                playlists.push({
                    name: item.name,
                    position: item.position,
                    trackCount: tracks.length,
                    lastPlayed: item.last_played
                });
            }
        });

        return playlists;
    }

    // In PlaylistManager.qml oder wo der PlaylistStorage verwendet wird
    function saveCurrentPlaylistState() {
        var trackIds = []
        if(playlistManager.size === 0)
            return
        for(var i = 0; i < playlistManager.size; i++) {
            var id = playlistManager.requestPlaylistItem(i)
            trackIds.push(id)
        }
        // Speichere als spezielle Playlist "_current"
        playlistStorage.savePlaylist("_current", trackIds, playlistManager.currentIndex)
    }

    function clearCurrentPlaylist() {            //playlistStorage.loadCurrentPlaylistState()

        // Speichere als spezielle Playlist "_current"
        playlistStorage.savePlaylist("_current", "", playlistManager.currentIndex)
    }


    // Beim Laden
    function loadCurrentPlaylistState() {
        // Check if auto-load is enabled
        console.log("loadCurrentPlaylistState called, auto_load_playlist:", applicationWindow.settings.auto_load_playlist, "resume_playback:", applicationWindow.settings.resume_playback)
        if (!applicationWindow.settings.auto_load_playlist) {
            console.log("Auto-load playlist disabled, skipping")
            return
        }

        playlistTitle = "_current"
        var db = getDatabase();
        var currentPlaylist;
        var trackIds;
        var position;
        db.transaction(function(tx) {
            currentPlaylist = tx.executeSql('SELECT tracks, position FROM playlists WHERE name = ?', [playlistTitle]);
            if (currentPlaylist.rows.length > 0) {
                trackIds = JSON.parse(currentPlaylist.rows.item(0).tracks);
                position = currentPlaylist.rows.item(0).position;

                // Aktualisiere last_played
                tx.executeSql('UPDATE playlists SET last_played = CURRENT_TIMESTAMP WHERE name = ?', [playlistTitle]);
            }
        });

        console.log("Loading current playlist, tracks:", trackIds ? trackIds.length : 0, "position:", position)

        if (trackIds === undefined || trackIds.length === 0) return;

        // OPTIMIZED: Use batch loading instead of one-by-one
        playlistManager.clearPlayList()
        playlistManager.appendTracksBatch(trackIds)
        
        // Position wiederherstellen
        playlistManager.currentIndex = position
        console.log("Setting currentIndex to:", position, "resume_playback:", applicationWindow.settings.resume_playback)
        if(applicationWindow.settings.resume_playback) {
            console.log("Resuming playback at position:", position)
            //playlistManager.playPosition(position);
        }
    }
    Component.onCompleted: {
        initDatabase();
    }
    // Bei App-Beendigung
    Component.onDestruction: {
        console.log("Save current playlist")
        saveCurrentPlaylistState()
    }

    // Optional: Bei wichtigen Playlist-Änderungen
    Connections {
        target: playlistManager
        onListChanged: {
            //saveCurrentPlaylistState()
            if(updateTimer.running)
                updateTimer.restart()
            else
                updateTimer.start()
        }
        onCurrentIndexChanged: {
            //saveCurrentPlaylistState()
            updatePosition(playlistTitle, playlistManager.currentIndex)
        }
        onClearList:
        {
            if(playlistTitle === "_current")
                clearCurrentPlaylist()
        }
    }
}
