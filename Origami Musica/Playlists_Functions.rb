require_relative 'Albums_Read.rb'

def add_playlist(playlists, playlist_name)
    playlists << Playlist.new(playlist_name, 0, nil, Array.new())
    return playlists
end
def delete_playlist(playlists, playlist_index)
    playlists.delete_at(playlist_index)
    return playlists
end
def rename_playlist(playlists, playlist_index, name)
    playlists[playlist_index].title = name
    return playlists
end
def add_song_to_playlist(playlists, playlist_index, track)
    playlists[playlist_index].tracks << track
    playlists[playlist_index].total_tracks += 1
    return playlists
end
def delete_song_in_playlist(playlists, playlist_index, track_index)
    playlists[playlist_index].tracks.delete_at(track_index)
    playlists[playlist_index].total_tracks -= 1
    return playlists
end
