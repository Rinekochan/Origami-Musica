require 'mp3info'

class Playlist
    attr_accessor :title, :total_tracks, :cover, :tracks
    def initialize(title, total_tracks, cover, tracks)
        @title = title
        @total_tracks = total_tracks
        @cover = cover
        @tracks = tracks
    end
end

PLAYLISTS_FILE_NAME = "config/playlists.txt"

#Load Playlist from Playlists
def load_playlist(playlist)
    playlist_name = playlist.gets().chomp()
    playlist_total_tracks = playlist.gets().to_i
    playlist_tracks = Array.new()
    index = 0
    while (index < playlist_total_tracks)
        playlist_track_location = playlist.gets().chomp()
        #This function is in Albums_Read.rb
        playlist_tracks << load_track(playlist_track_location)
        index += 1
    end
    return Playlist.new(playlist_name, playlist_total_tracks, nil, playlist_tracks)
end
#Load playlists.txt file
def load_playlists(playlists_file)
    index = 0
    playlists = Array.new()
    number_of_playlist = playlists_file.gets().to_i
    while (index < number_of_playlist)
        playlists << load_playlist(playlists_file)
        index += 1
    end
    return playlists
end
#Open playlists.txt file
def read_playlists()
    if(Dir.glob(PLAYLISTS_FILE_NAME).any? == true)
        playlists_file = File.open(PLAYLISTS_FILE_NAME, "r")
        playlists = load_playlists(playlists_file)
    else
        playlists_file = File.new(PLAYLISTS_FILE_NAME, "w")
        playlists_file.puts(0)
        playlists_file.close()
        return Array.new()
    end
    playlists_file.close()
    return playlists
end

# This function create and modify playlists.txt file
def playlists_file_create_and_modify(playlists_data)
    file_data = File.new(PLAYLISTS_FILE_NAME, "w")
    file_data.puts(playlists_data.length)
    index = 0
    while (index < playlists_data.length)
        file_data.puts(playlists_data[index].title)
        file_data.puts(playlists_data[index].total_tracks)
        if(playlists_data[index].tracks != nil)
            playlists_data[index].tracks.each do |track|
                file_data.puts(track.location)
            end
        end
        index += 1
    end
    file_data.close()
end

# Print playlists array to terminal
def print_playlists(playlists)
    playlists.each do |playlist|
        puts playlist.title
        puts "------------------"
        playlist.tracks.each do |track|
            puts track.name
            puts track.artist
            puts track.location
            puts track.year
            puts track.length
            puts "------------------"
        end
        puts "++++++++++++++++++"
    end
end
