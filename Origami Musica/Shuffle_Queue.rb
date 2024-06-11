# Produce a shuffle queue of tracks (albums, playlists)
def shuffle_produce()
    shuffle_array = Array.new()
    index = 0
    while(index < @current_playing_album_or_playlist.total_tracks)
        if(index != @current_track_index)
            shuffle_array << index
        end
        index += 1
    end
    shuffle_array = shuffle_array.shuffle
    @selected_track_index_array = Array.new()
    @selected_track_index_array << @current_track_index
    shuffle_array.each do |index|
        @selected_track_index_array << index
    end
    @current_track_array_index = 0
end
# Produce a default queue of tracks (albums, playlists)
def default_array()
    @current_track_array_index = @selected_track_index_array[@current_track_array_index]
    @selected_track_index_array = Array.new()
    index = 0
    while(index < @current_playing_album_or_playlist.total_tracks)
        @selected_track_index_array << index
        index += 1
    end
end
# Produce the queue depends on the current state of shuffle button
def shuffle_list(shuffle_check)
    if(shuffle_check == true)
        shuffle_produce()
    else
        default_array()
    end
end
