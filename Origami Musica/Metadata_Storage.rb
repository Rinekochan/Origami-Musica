require 'set'
# Set is used to add unique items in an average of O(1) Time Complexity.
def read_artists_to_store(albums)
    #Add Artist to the set
    artists = Set.new()
    albums.each do |album|
        #Duplicate Checking Time Complexity: O(1)
        artists.add(album.artist)
    end
    # Convert the set to array to get the index of stored artists
    artists_array = artists.to_a
    # Sort the array to easier to look
    artists_array.sort!
    return artists_array
end

def display_stored_artists(artists)
    artists.each do |artist|
        puts artist
    end
end

def read_decades_to_store(albums)
    #Add Decades to the set
    decades_sorted_array = Array.new()
    decades_unsorted_array = Array.new()
    decades = Set.new()
    albums.each do |album|
        decade = album.year / 10 * 10
        #Duplicate Checking Time Complexity: O(1)
        decades.add(decade)
    end
    # Convert the set to array to get the index of stored decades
    decades_unsorted_array = decades.to_a
    # Sort the array to easier to look
    decades_unsorted_array.sort!
    decades_unsorted_array.each do |decade|
        decades_sorted_array << decade.to_s + "s"
    end
    return decades_sorted_array
end

def display_stored_decades(decades)
    decades.each do |decade|
        puts decade
    end
end

def read_genres_to_store(albums)
    # Add Genres to the set
    genres = Set.new()
    albums.each do |album|
        #Duplicate Checking Time Complexity: O(1)
        genres.add(album.genre)
    end
    # Convert the set to array to get the index of stored genres
    genres_array = genres.to_a
    # Sort the array to easier to look
    genres_array.sort!
    return genres_array
end

def display_stored_genres(genres)
    genres.each do |genre|
        puts genre
    end
end
