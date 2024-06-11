require 'rspotify'
require 'json'
# This file is used for retrieving track audio features from Spotify API and store it in the local file.
# This file is FOR REFERENCE & PROOF ONLY because it took 15 seconds to fetch a song -> 2 minutes for 1 album
class Credentials
    attr_accessor :id, :secret
    def initialize(id, secret)
        @id = id
        @secret = secret
    end
end
# This credential is used for educational purpose, please don't access and use it for malicious activities
def load_credential()
    # Open credentials configuration files
    config = JSON.parse(File.read('spotify credentials\credentials.json'))
    # Access the Spotify credentials
    spotify_config = config['spotify']
    return Credentials.new(spotify_config['client_id'], spotify_config['client_secret'])
end
client = load_credential()
RSpotify.authenticate(client.id, client.secret)
# This function will fetch track data from SPOTIFY API (FOR REFERENCE ONLY because it took 15 seconds to fetch a song -> 2 minutes for 1 album)
def fetch_track_data(track, tracks_storage, index)
    file_location = track.location
    name = track.name
    found_tracks = RSpotify::Track.search(name, limit: 5)
    found_tracks.each do |found_track|
        # Check if this is the correct song
        track_id = found_track.id
        track_id_find = RSpotify::Track.find(track_id)
        track_artist = track_id_find.artists[0].name
        track_popularity = track_id_find.popularity
        if(track_artist == tracks_storage[index].artist)
            return [file_location, found_track, track_popularity]
        else
            return nil
        end
    end
    return nil
end
# Read track audio features fetching from Spotify API and add to the LocalAPIStorage.txt file (FOR REFERENCE ONLY because it took 15 seconds to fetch a song -> 2 minutes for 1 album)
def read_track_audio_features(current_index, updated_index, tracks_storage)
    puts tracks_storage.length
    start_index = current_index
    index = start_index
    results = Array.new()
    while(index < updated_index)
        track = tracks_storage[index]
        result = fetch_track_data(track, tracks_storage, index)
        if(result != nil)
            results << result
        end
        index += 1
    end

    file_data = File.new(LOCAL_API_FILE_NAME, "a")
    results.each do |track_arr|
        track_location = track_arr[0]
        track = track_arr[1]
        track_popularity = track_arr[2]
        acousticness = track.audio_features.acousticness.round(2)
        valence = track.audio_features.valence.round(2)
        energy = track.audio_features.energy.round(2)
        danceability = track.audio_features.danceability.round(2)
        speechiness = track.audio_features.speechiness.round(2)
        tempo = track.audio_features.tempo.round(2)
        file_data.puts(track_location)
        file_data.puts(track_popularity)
        file_data.puts(acousticness)
        file_data.puts(valence)
        file_data.puts(energy)
        file_data.puts(danceability)
        file_data.puts(speechiness)
        file_data.puts(tempo)
        index += 1
    end
    file_data.close()
end
