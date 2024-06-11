require 'mp3info'
# This Class is for Albums data defining, tracks is linked to the "Tracks" Class
class Albums
    attr_accessor :title, :artist, :genre, :year, :total_tracks, :images, :tracks
    def initialize(title, artist, genre, year, total_tracks, images, tracks)
        @title = title
        @artist = artist
        @genre = genre
        @year = year
        @total_tracks = total_tracks
        @images = images
        @tracks = tracks
    end
end
# This Class is for Tracks data defining, features is linked to the "Audio_Features" Class
class Tracks
    attr_accessor :name, :location, :artist, :genre, :year, :length, :album, :features
    def initialize(name, location, artist, genre, year, length, album, features)
        @name = name
        @location = location
        @artist = artist
        @genre = genre
        @year = year
        @length = length
        @album = album
        @features = features
    end
end
# This Class is for Tracks Audio Features data defining (Popularity, Acousticness, Valence, Energy, Danceability, Speechiness, Tempo)
class Audio_Features
    attr_accessor :popularity, :acousticness, :valence, :energy, :danceability, :speechiness, :tempo
    def initialize()
        @popularity = nil
        @acousticness = nil
        @valence = nil
        @energy = nil
        @danceability = nil
        @speechiness = nil
        @tempo = nil
    end
end

# Note: The parameter is the path to the file, not the name
# This functions will read the metadata of the track
def load_track(track_file)
    track_location = track_file
    track_name = nil
    track_year = nil
    track_album = nil
    track_artist = nil
    track_genre = nil
    track_length = nil
    # Loading mp3 metadata information
    Mp3Info.open(track_file) do |track_info|
        track_name = track_info.tag.title
        track_year = track_info.tag.year
        track_album = track_info.tag.album
        track_artist = track_info.tag.artist
        track_genre = track_info.tag.genre_s
        track_length = track_info.length
    end
    features = Audio_Features.new()
    return Tracks.new(track_name, track_location, track_artist, track_genre, track_year, track_length, track_album, features)
end
# Note: The parameter is the array consisting of file paths, not the name
# This functions will iterate through each mp3 file found
def detect_and_load_tracks(track_files)
    # Iterate through each mp3 file
    tracks = Array.new()
    track_files.each do |track_file|
        tracks << load_track(track_file)
    end
    return tracks
end
# Note: The parameter is the array consisting of file paths, not the name
# This functions fill find all informations related to that album folder by looking at directories folder (mp3 files, album name, album artist, album genre, ...)
def load_album(album_folder)
    # Automatically detect mp3 files in each folder directory
    track_files = Dir.glob(File.join(album_folder, '*.mp3'))
    #Load tracks information
    tracks = detect_and_load_tracks(track_files)
    # Load album information from track metadata info
    album_title = tracks[0].album
    album_artist = tracks[0].artist
    album_genre = tracks[0].genre
    album_year = tracks[0].year
    album_images = nil
    album_images_temp = nil
    # Check for available cover in different extensions
    if Dir.glob(File.join(album_folder, '*.bmp')).any?
        album_images_temp = Dir.glob(File.join(album_folder, '*.bmp'))
    elsif Dir.glob(File.join(album_folder, '*.png')).any?
        album_images_temp = Dir.glob(File.join(album_folder, '*.png'))
    elsif Dir.glob(File.join(album_folder, '*.jpg')).any?
        album_images_temp = Dir.glob(File.join(album_folder, '*.jpg'))
    end
    if (album_images_temp != nil)
        # The result is an array so it need to access the first array index
        album_images = album_images_temp[0]
    end
    total_tracks = track_files.length()
    return Albums.new(album_title, album_artist, album_genre, album_year, total_tracks, album_images, tracks)
end
# This functions fill iterate all albums folder by looking at directories folder
def detect_and_load_albums()
    # Automatically detect folders in music directory
    albums = Array.new()
    album_folders = Dir.glob('music/*')
    album_folders.each do |album_folder|
        albums << load_album(album_folder)
    end
    return albums
end
# Print albums array to terminal
def display_detected_albums(albums)
    albums.each do |album|
        puts album.title
        puts album.artist
        puts album.total_tracks
        puts album.images
        puts album.genre
        puts album.year
        album.tracks.each do |track|
            puts track.name
            puts track.location
            puts track.length
            puts "-----------------------------"
        end
        puts "-----------------------------"
    end
end
