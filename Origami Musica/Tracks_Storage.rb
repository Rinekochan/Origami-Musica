# Reading track audio features to store with tracks name, artist, genre
def read_tracks_audio_features(file_data, track)
    track.features.popularity = file_data.gets().chomp
    track.features.acousticness = file_data.gets().chomp
    track.features.valence = file_data.gets().chomp
    track.features.energy = file_data.gets().chomp
    track.features.danceability = file_data.gets().chomp
    track.features.speechiness = file_data.gets().chomp
    track.features.tempo = file_data.gets().chomp
end
LOCAL_API_FILE_NAME = "config/LocalAPIStorage.txt"
# Reading all tracks to store in @tracks_storage from albums
def read_tracks_to_store(albums)
    tracks_array = Array.new()
    file_data = File.new(LOCAL_API_FILE_NAME, "r")
    lines = file_data.gets()
    correct_track = true
    current_location = nil
    albums.each do |album|
        album.tracks.each do |track|
            if(correct_track == true)
                current_location = file_data.gets().chomp
            end
            if(track.location == current_location)
                read_tracks_audio_features(file_data, track)
                correct_track = true
            else
                correct_track = false
            end

            tracks_array << track
        end
    end
    file_data.close()
    return tracks_array
end
# Display all tracks procedure
def display_all_tracks(tracks_storage)
    tracks_storage.each do |track|
        puts "Track Name: #{track.name}"
        puts "Track Artist: #{track.artist}"
        puts "Popularity: #{track.features.popularity}"
        puts "Acousticness: #{track.features.acousticness}"
        puts "Valence: #{track.features.valence}"
        puts "Energy: #{track.features.energy}"
        puts "Danceability: #{track.features.danceability}"
        puts "Speechiness: #{track.features.speechiness}"
        puts "Tempo: #{track.features.tempo}"
    end
end
