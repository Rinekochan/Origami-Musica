
def filter_by_category(albums, category, required_item)
    # This array will store all required albums
    stored_filter = Array.new()
    filter_condition = nil
    case category
    when "Decades"
        #Extracts the numberic part of the decade string
        required_decade = required_item[/\d+/].to_i
        albums.each do |album|
            if(album.year >= required_decade && album.year < required_decade + 10)
                stored_filter << album
            end
        end
    when "Artists"
        albums.each do |album|
            if(album.artist == required_item)
                stored_filter << album
            end
        end
    when "Genres"
        albums.each do |album|
            if(album.genre == required_item)
                stored_filter << album
            end
        end
    else
        return albums
    end
    return stored_filter
end
