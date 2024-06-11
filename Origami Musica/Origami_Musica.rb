require 'rubygems'
require 'gosu'

require_relative 'Relative_Files.rb'

module ZOrder
    BACKGROUND, LAYOUT, CONTAINER, HIGHLIGHT, CURRENT_HIGHLIGHT, DISPLAY, TEXT, ICON, PLACEHOLDER, PROMPT = *1..10
end

class ArtWork
	attr_accessor :file
	def initialize (file)
		@file = Gosu::Image.new(file)
	end
end
# Color used in Origami Musica Player
BACKGROUND_COLOR = Gosu::Color.new(0xFF180101)
LAYOUT_COLOR = Gosu::Color.new(0xFF1C1B1B)
PLAY_BACK_COLOR = Gosu::Color.new(0xFF210202)
SECONDARY_COLOR = Gosu::Color.new(0xFF262626)
THIRD_COLOR = Gosu::Color.new(0xFF323131)
FOURTH_COLOR = Gosu::Color.new(0xFF4D4D4D)
PRIMARY_TEXT_COLOR = Gosu::Color::WHITE
STATUS_TEXT_COLOR = Gosu::Color.new(255, 64, 64)
SEARCH_BAR_COLOR = Gosu::Color::WHITE
SECONDARY_TEXT_COLOR = Gosu::Color.new(0xFFADACAC)
THIRD_TEXT_COLOR = Gosu::Color.new(0xFF969696)
class OrigamiMusica < Gosu::Window
    def initialize
        super(1440, 820)
        self.caption = "Origami Musica"
        #Load Albums from directories
        @albums_storage = detect_and_load_albums()
        @albums = @albums_storage
        #Store Available Genres
        @genres_storage = read_genres_to_store(@albums_storage)
        #Store Avaliable Artists
        @artists_storage = read_artists_to_store(@albums_storage)
        #Store Available Decades
        @decades_storage = read_decades_to_store(@albums_storage)
        #Store Available Tracks
        @tracks_storage = read_tracks_to_store(@albums_storage)
        # display_all_tracks(@tracks_storage)
        # searching_query("Fall Down", @tracks_storage)
        #Load Playlists (as an array)
        @playlists_storage = read_playlists()
        @playlists = @playlists_storage
        # ----------------------------------
        # ----------------------------------
        # ----------------------------------
        # Position Setting
        @margin_top = 15
        @margin_left = 5
        @margin_right = 5
        @margin_album_top = 380
        # Layout Position
        @playback_height = 100
        # Menu Bar Position
        @right_bar_x = 1120
        # The left-most x of the main layout
        @main_display_width = @right_bar_x - @margin_right
        @main_display_height = height - @playback_height
        # ----------------------------------
        # ----------------------------------
        # ----------------------------------
        # Default Music Player Values
        @current_playing_album_or_playlist = nil
        @align_left_contents = @main_display_width / 4 - 183
        @action_notification_1 = ""
        @action_notification_2 = ""
        @action_notify_check = false
        @notify_duration = 0
        @shuffle_check = false
        @loop_check = false
        @blinking_effect = false
        @blinking_duration = 0
        @current_player_page = 1
        @current_volume = 0.5
        if(@tracks_storage.length != 0)
            #Default values of Search Page
            @search_bar_typing = false
            @search_bar_searching_text = ""
            @found_similar_tracks = Array.new()
            @similarity_toggle_check = false
        end
        #Default page of selected albums
        @first_current_page_album_index = 0
        #Default page of tracks
        @first_current_page_tracks_index = 0
        #Default Each Category Page
        @first_category_page_index = 0
        # The Maximum Albums Per Page is 4
        @maximum_albums_per_page = @albums.length > 4 ? 4 : @albums.length
        # The Maximum displayed Genres Per Page is 4
        @maximum_items_per_category_page = 4
        #Selected Tracks List
        @selected_tracks_list_x = @align_left_contents - 30 + 390
        @selected_tracks_list_y = @margin_top + 50
        # Default Album Values
        @selected_album_index = 0
        @current_track_index = nil
        @selected_album_check = false
        @current_playing_album = false
        @help_page_check = false
        # Default Values of Toggled Play/Pause Area
        @playing_area_check = false
        @playing_area_check_selected_page = false
        #Default Tracks Value
        @current_track = nil
        @current_song_seconds = 0
        @pause_time = 0
        #Default Values of Categories
        @category_storage = nil
        @current_category_page = 0
        @required_category_item = nil
        @category_index = ['Null', 'Genres', 'Artists', 'Decades']
        @filter_status = false
        @active_category_page = nil
        @active_category_item = nil
        #Generated Random Colors for Album Cover in Selected Album Page
        @displayed_background_color_1 = random_color_generated()
        @displayed_background_color_2 = random_color_generated()
        #Default home page values
        @header = nil
        # Playlists Default Values
        @first_current_page_playlist_index = 0
        @first_current_page_adding_playlist_index = 0
        @maximum_playlists_per_page = @playlists.length > 6 ? 6 : @playlists.length
        @maximum_adding_playlists_per_page = @playlists.length > 6 ? 6 : @playlists.length
        @playlists_name_typing = false
        @playlists_add_prompt = ""
        @rename_playlist_add_prompt = ""
        @playlist_rename_typing = false
        @playlists_index_y = Array.new()
        @select_playlist_to_add_y = Array.new()
        @selected_playlist_index = nil
        @selected_playlist_check = false
        @add_track_to_playlist_index = nil
        @delete_track_to_playlist_index = nil
        @added_playlists_check = Array.new(@playlists.length, false)
        @available_track_in_playlist = Array.new(@playlists.length, false)
        @current_playing_playlist = false
        if(@tracks_storage.length != 0)
            #Playlists Generation Default Values
            @selected_generated_playlist_index = nil
            @selected_generated_playlist_check = false
            @current_playing_generated_playlist = false
            @playlists_add_name_typing = false
            @generated_playlist = Array.new()
            @generated_playlist_names = ["Mega Hit Mix", "", "", "", "", "Discovery Mix", "Exploration Mix", "Personalized Mix"]
            @generated_playlist_covers = ["generated cover/Mega Hit Mix.png", "generated cover/Genre Playlist 1.png", "generated cover/Genre Playlist 2.png", "generated cover/Artist Mix.png", "generated cover/Decade Mix.png", "generated cover/Mix 1.png", "generated cover/Mix 2.png", "generated cover/Mix 3.png"]
            index = 0
            while(index < @generated_playlist_names.length)
                @generated_playlist << Playlist.new(@generated_playlist_names[index], 0, Array.new(), @generated_playlist_covers[index])
                index += 1
            end
            ######################
            ## The first 5 mixes is based on random selection of genres, artists and decades
            @total_distance_generated_playlist = Array.new(@generated_playlist_names.length){Array.new(2)}
            @audio_features_toggle_check = false
            @genres_generated_check = Array.new(@genres_storage.length, false) # Check if that genres has been used for playlist generation
            @artists_generated_check = Array.new(@artists_storage.length, false) # Check if that artists has been used for playlist generation
            @decades_generated_check = Array.new(@decades_storage.length, false) # Check if that decades has been used for playlist generation
            # Perform intial playlist generation for random mixes
            generation_type = ["All", "Genre", "Genre", "Artist", "Decade"]
            index = 0
            while(index < 5)
                # Don't randomize second genre if there is only one genre
                if(index == 2 && @genres_storage.length < 2)
                    index += 1
                    next
                end
                generated_check = nil
                storage_type = nil
                case generation_type[index]
                when "All" # Generated Playlist based on popularity
                    generated_check = nil
                    storage_type = nil
                when "Genre" # Generated Playlist based on popularity with certain Genre
                    generated_check = @genres_generated_check
                    storage_type = @genres_storage
                when "Artist" # Generated Playlist based on popularity with certain Artist
                    generated_check = @artists_generated_check
                    storage_type = @artists_storage
                when "Decade" # Generated Playlist based on popularity with certain Decade
                    generated_check = @decades_generated_check
                    storage_type = @decades_storage
                end
                # Generate Playlist with Random Criteria (All, Genre, Artist, Decade)
                temp_generated_playlist = playlist_generation_based_on_random_criteria(generation_type[index], [50, @tracks_storage.length].min, generated_check, storage_type, @tracks_storage)
                @generated_playlist[index].tracks = temp_generated_playlist[1][0]
                @generated_playlist[index].total_tracks = @generated_playlist[index].tracks.length
                @total_distance_generated_playlist[index][0] = temp_generated_playlist[1][1].round(3)
                @total_distance_generated_playlist[index][1] = temp_generated_playlist[1][2].round(3)
                if(temp_generated_playlist[0] != nil)
                    storage_index = temp_generated_playlist[0]
                end
                case generation_type[index]
                when "Genre" # Naming the Playlist based on randomized Genre
                    @genres_generated_check[storage_index] = true
                    @generated_playlist[index].title = "#{@genres_storage[storage_index]} Mix"
                when "Artist" # Naming the Playlist based on randomized Artist
                    @artists_generated_check[storage_index] = true
                    @generated_playlist[index].title = "#{@artists_storage[storage_index]} Mix"
                when "Decade" # Naming the Playlist based on randomized Decade
                    @decades_generated_check[storage_index] = true
                    @generated_playlist[index].title = "#{@decades_storage[storage_index]} Mix"
                end
                index += 1
            end
            # Only display the options if there are history of user interaction
            if (Dir.glob(INTERACTION_HISTORY_FILE_NAME).any? == true)
                ######################
                ## The last 3 mixes is based on users interaction history / custom choices
                @playlist_generation_option_check = false
                @custom_playlist_generation_check = false
                @previous_custom_playlist_generation_check = @custom_playlist_generation_check
                @custom_playlist_generation_options = [[nil], [nil], [false, false, false], [false, false, false], [false, false, false]]
                @previous_custom_playlist_generation_options = @custom_playlist_generation_options.clone
                @generated_playlist_add_prompt = ""
                # Intialize Preferences Array for User Interaction Tracking and Calculation
                preferences_array = calculate_user_interactions_history_from_files(@artists_storage, @genres_storage, @decades_storage, @tracks_storage)
                @artist_preferences = preferences_array[0].clone
                @genres_preferences = preferences_array[1].clone
                @decades_preferences = preferences_array[2].clone
                # Audio Features Array User Interaction Counting: 0, 0.05, 0.1, 0.15, ... , 1 for Acousticness, Valence, Energy and Danceability
                @acousticness_preferences = preferences_array[3].clone
                @valence_preferences = preferences_array[4].clone
                @energy_preferences = preferences_array[5].clone
                @danceability_preferences = preferences_array[6].clone
                # Audio Features Array User Interaction Counting: 0, 0.02, 0.04, 0.06, ... , 0.4 for Speechiness
                @speechiness_prefererences = preferences_array[7].clone
                # Audio Features Array User Interaction Counting: 0, 10, 20, 30, ... , 200 for Tempo
                @tempo_preferences = preferences_array[8].clone
            end
        end
        # playlist_generation(@tracks_storage)
        #Text Input Default Values
        @backspace_pressed = false
        @backspace_duration = 0
        # ----------------------------------
        # ----------------------------------
        # ----------------------------------
        # Icons Drawing
        @search_bar_icon = ArtWork.new("media/Search_Bar.png")
        @search_icon = ArtWork.new("media/Search.png")
        @search_inactive_icon = ArtWork.new("media/Search_Inactive.png")
        @home_icon = ArtWork.new("media/Home.png")
        @home_inactive_icon = ArtWork.new("media/Home_Inactive.png")
        @recommended_icon = ArtWork.new("media/Recommend.png")
        @help_icon = ArtWork.new("media/Help.png")
        @recommended_inactive_icon = ArtWork.new("media/Recommend_Inactive.png")
        @history_icon = ArtWork.new("media/History.png")
        @playlist_icon = ArtWork.new("media/List.png")
        @play_icon = ArtWork.new("media/Play.png")
        @stop_icon = ArtWork.new("media/Stop.png")
        @back_icon = ArtWork.new("media/Back.png")
        @skip_icon = ArtWork.new("media/Skip.png")
        @repeat_icon = ArtWork.new("media/Repeat.png")
        @shuffle_icon = ArtWork.new("media/Shuffle.png")
        @volume_up_icon = ArtWork.new("media/Volume_Up.png")
        @volume_down_icon = ArtWork.new("media/Volume_Down.png")
        @play_album_icon = ArtWork.new("media/PlayAlbum.png")
        @pause_album_icon = ArtWork.new("media/PauseAlbum.png")
        @previous_page_icon = ArtWork.new("media/Previous.png")
        @next_page_icon = ArtWork.new("media/Next.png")
        @upper_page_icon = ArtWork.new("media/Previous_Up.png")
        @lower_page_icon = ArtWork.new("media/Next_Down.png")
        @close_icon = ArtWork.new("media/Close.png")
        @unchecked_box_icon = ArtWork.new("media/Unchecked_Box.png")
        @checked_box_icon = ArtWork.new("media/Checked_Box.png")
        # ----------------------------------
        # ----------------------------------
        # ----------------------------------
        # Text Font
        @bar_font = Gosu::Font.new(22, name: "Tahoma", bold: true)
        @search_bar_font = Gosu::Font.new(24, name: "Arial", bold: true)
        @notify_duration_font = Gosu::Font.new(18, name: "Tahoma", bold: true)
        @categories_font = Gosu::Font.new(32, name: "Tahoma", bold: true)
        @header_font = Gosu::Font.new(48, name: "Helvetica", bold: true)
        @header_2_font = Gosu::Font.new(36, name: "Helvetica", bold: true)
        @albums_or_playlist_name_font = Gosu::Font.new(22, name: "Arial", bold: true)
        @albums_name_font_2 = Gosu::Font.new(16, name: "Arial", bold: true)
        @selected_page_name_font = Gosu::Font.new(36, name: "Arial", bold: true)
        @artist_font = Gosu::Font.new(18, name: "Arial")
        @selected_albums_information_font = Gosu::Font.new(20, name: "Arial", bold: true)
        @paragraph_font = Gosu::Font.new(24, name: "Arial")
        @duration_font = Gosu::Font.new(17, name: "Arial", bold: true)
        @shortcut_font = Gosu::Font.new(27, name: "Arial", bold: true)
        # Auto Generated Font For Non-Cover Album
        @album_auto_generated_font = Gosu::Font.new(24, name: "Tahoma", bold: true)
        @selected_album_auto_generated_font = Gosu::Font.new(40, name: "Tahoma", bold: true)
    end
    # Draw gradient color rectangle using Top-left and Bottom-right point
    def draw_rect_gradient(x1, y1, x2, y2, color1, color2, z)
        draw_quad(x1, y1, color1, x2, y1, color1, x1, y2, color2, x2, y2, color2, z, mode=:default)
    end
    # Draw rectangle using Top-left and Bottom-right point
    def draw_rectangle(x1, y1, x2, y2, color, z)
        draw_quad(x1, y1, color, x2, y1, color, x1, y2, color, x2, y2, color, z, mode=:default)
    end
    # Draw horizontal line
    def draw_line_horizontal(x, y, width, line_size, color, z)
        Gosu.draw_rect(x, y, width, line_size, color, z)
    end
    # Draw vertical line
    def draw_line_vertical(x, y, line_size, height, color, z)
        Gosu.draw_rect(x, y, line_size, height, color, z)
    end
    # Cropping text function if the text is too long
    def crop_text(font, text, required_width)
        #Crop Text if the song name is too long
        name = text.split(" ")
        cropped_texts = ""
        index = 0
        while(index < name.length)
            if (font.text_width(cropped_texts + name[index] + " ") > required_width)
                return cropped_texts + "..."
            end
            cropped_texts += name[index]
            if(index != name.length - 1)
                cropped_texts += " "
            end
            index += 1
        end
        return cropped_texts
    end
    # Returns the x position that styles the text center of a box
    def center_text_horizontal(font, text, last_pos, box_width)
        # Formula to calculate the horizontal center of the text:
        # 1. Set the value to the right-most x.
        # 2. Then subtract the gap between right border of box and text width ((box width - text width ) / 2).
        # 3. Then subtract the text-width.
        return (last_pos - (box_width - font.text_width(text)) / 2 - font.text_width(text))
    end
    # Hover Areas check
    def cursor_hover?(x_min, y_min, x_max, y_max)
        if ((mouse_x > x_min && mouse_x < x_max) && (mouse_y > y_min && mouse_y < y_max))
            return true
        else
            return false
        end
    end
    #Play track with track location
    def playTrack(track)
        @song = Gosu::Song.new(track.location)
        @song.play(false)
        @song.volume = @current_volume
    end
    #Draw Background
    def draw_background()
        draw_rectangle(0, 0, width, height, BACKGROUND_COLOR, ZOrder::BACKGROUND)
    end
    ##################################
    #####-----Navigation Bar-----#####
    #Draw Navigation Layout
    def draw_navigation_layout()
        draw_rectangle(@right_bar_x, @margin_top, width - 5, height / 14 * 4, LAYOUT_COLOR, ZOrder::LAYOUT)
    end
    # Draw Navigation Icon
    def draw_navigation_icon()
        case @current_player_page
        when 0
            @search_icon.file.draw(@right_bar_x + 40, @margin_top + 40, ZOrder::ICON, 0.28, 0.28)
            if(cursor_hover?(@right_bar_x + 30, @margin_top + 88, @right_bar_x + 285, @margin_top + 145))
                @home_icon.file.draw(@right_bar_x + 38, @margin_top + 100, ZOrder::ICON, 0.28, 0.28)
            else
                @home_inactive_icon.file.draw(@right_bar_x + 38, @margin_top + 100, ZOrder::ICON, 0.28, 0.28)
            end
            if(cursor_hover?(@right_bar_x + 30, @margin_top + 148, @right_bar_x + 285, @margin_top + 205))
                @recommended_icon.file.draw(@right_bar_x + 40, @margin_top + 160, ZOrder::ICON, 0.28, 0.28)
            else
                @recommended_inactive_icon.file.draw(@right_bar_x + 40, @margin_top + 160, ZOrder::ICON, 0.28, 0.28)
            end
        when 1
            if(cursor_hover?(@right_bar_x + 30, @margin_top + 26, @right_bar_x + 285, @margin_top + 81))
                @search_icon.file.draw(@right_bar_x + 40, @margin_top + 40, ZOrder::ICON, 0.28, 0.28)
            else
                @search_inactive_icon.file.draw(@right_bar_x + 40, @margin_top + 40, ZOrder::ICON, 0.28, 0.28)
            end
            @home_icon.file.draw(@right_bar_x + 38, @margin_top + 100, ZOrder::ICON, 0.28, 0.28)
            if(cursor_hover?(@right_bar_x + 30, @margin_top + 148, @right_bar_x + 285, @margin_top + 205))
                @recommended_icon.file.draw(@right_bar_x + 40, @margin_top + 160, ZOrder::ICON, 0.28, 0.28)
            else
                @recommended_inactive_icon.file.draw(@right_bar_x + 40, @margin_top + 160, ZOrder::ICON, 0.28, 0.28)
            end
        when 2
            if(cursor_hover?(@right_bar_x + 30, @margin_top + 26, @right_bar_x + 285, @margin_top + 81))
                @search_icon.file.draw(@right_bar_x + 40, @margin_top + 40, ZOrder::ICON, 0.28, 0.28)
            else
                @search_inactive_icon.file.draw(@right_bar_x + 40, @margin_top + 40, ZOrder::ICON, 0.28, 0.28)
            end
            if(cursor_hover?(@right_bar_x + 30, @margin_top + 88, @right_bar_x + 285, @margin_top + 145))
                @home_icon.file.draw(@right_bar_x + 38, @margin_top + 100, ZOrder::ICON, 0.28, 0.28)
            else
                @home_inactive_icon.file.draw(@right_bar_x + 38, @margin_top + 100, ZOrder::ICON, 0.28, 0.28)
            end
            @recommended_icon.file.draw(@right_bar_x + 40, @margin_top + 160, ZOrder::ICON, 0.28, 0.28)
        end

    end
    #Draw Navigation Text
    def draw_navigation_text()
        case @current_player_page
        when 0
            search_text_color =  PRIMARY_TEXT_COLOR
            home_text_color =  THIRD_TEXT_COLOR
            recommended_text_color =  THIRD_TEXT_COLOR
        when 1
            search_text_color =  THIRD_TEXT_COLOR
            home_text_color =  PRIMARY_TEXT_COLOR
            recommended_text_color =  THIRD_TEXT_COLOR
        when 2
            search_text_color =  THIRD_TEXT_COLOR
            home_text_color =  THIRD_TEXT_COLOR
            recommended_text_color =  PRIMARY_TEXT_COLOR
        end
        # Search Text Color Status
        if(cursor_hover?(@right_bar_x + 30, @margin_top + 26, @right_bar_x + 285, @margin_top + 81))
            draw_rectangle(@right_bar_x + 30, @margin_top + 26, @right_bar_x + 285, @margin_top + 81, SECONDARY_COLOR, ZOrder::HIGHLIGHT)
            search_text_color = PRIMARY_TEXT_COLOR
        end
        @bar_font.draw_text("Search", @right_bar_x + 90, @margin_top + 42, ZOrder::TEXT, 1.05, 1.05, search_text_color)
        # Home Text Color Status
        if(cursor_hover?(@right_bar_x + 30, @margin_top + 88, @right_bar_x + 285, @margin_top + 145))
            draw_rectangle(@right_bar_x + 30, @margin_top + 88, @right_bar_x + 285, @margin_top + 145, SECONDARY_COLOR, ZOrder::HIGHLIGHT)
            home_text_color = PRIMARY_TEXT_COLOR
        end
        @bar_font.draw_text("Home", @right_bar_x + 90, @margin_top + 104, ZOrder::TEXT, 1.05, 1.05, home_text_color)
        # Recommended Text Color Status
        if(cursor_hover?(@right_bar_x + 30, @margin_top + 148, @right_bar_x + 285, @margin_top + 205))
            draw_rectangle(@right_bar_x + 30, @margin_top + 148, @right_bar_x + 285, @margin_top + 205, SECONDARY_COLOR, ZOrder::HIGHLIGHT)
            recommended_text_color = PRIMARY_TEXT_COLOR
        end
        @bar_font.draw_text("Generation", @right_bar_x + 90, @margin_top + 164, ZOrder::TEXT, 1.05, 1.05, recommended_text_color)
    end
    # Draw Navigation Bar
    def draw_navigation_bar()
        draw_navigation_layout()
        draw_navigation_icon()
        draw_navigation_text()
    end
    #################################
    #####-----Playlist Bar-----#####
    #Draw Playlist Bar Layout
    def draw_playlist_layout()
        draw_rectangle(@right_bar_x, height / 14 * 4 + 5, width - @margin_right, @main_display_height, LAYOUT_COLOR, ZOrder::LAYOUT)
        draw_line_horizontal(@right_bar_x + 20, height / 14 * 4 + 60, 280, 3, Gosu::Color::WHITE, ZOrder::TEXT)
        draw_line_horizontal(@right_bar_x + 20, height / 14 * 4 + 426, 280, 3, Gosu::Color::WHITE, ZOrder::TEXT)
    end
    # Draw Playlist Bar Icon
    def draw_playlist_icon()
        @playlist_icon.file.draw(@right_bar_x + 40, height / 14 * 4 + 25, ZOrder::ICON, 0.25, 0.25)
    end
    # Draw Playlist Bar Header
    def draw_playlist_text()
        @bar_font.draw_text("Playlist", @right_bar_x + 90, height / 14 * 4 + 26, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
        @bar_font.draw_text("+", @right_bar_x + 280, height / 14 * 4 + 26, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
        if(cursor_hover?(@right_bar_x + 275, height / 14 * 4 + 21, @right_bar_x + 300, height / 14 * 4 + 52))
            draw_rectangle(@right_bar_x + 275, height / 14 * 4 + 21, @right_bar_x + 300, height / 14 * 4 + 52, FOURTH_COLOR, ZOrder::HIGHLIGHT)
        end
    end
    # Draw Existed Playlist
    def draw_displayed_playlist()
        if (@playlists_name_typing == true)
            draw_rectangle(@right_bar_x + 20, height / 14 * 4 + 22, width - @margin_right - 15, height / 14 * 4 + 56, SEARCH_BAR_COLOR, ZOrder::PLACEHOLDER)
            if(@playlists_add_prompt == '')
                @albums_or_playlist_name_font.draw_text("Enter a name (< 16 chars)", @right_bar_x + 25, height / 14 * 4 + 30, ZOrder::PLACEHOLDER, 1, 1, SECONDARY_TEXT_COLOR)
            end
            @albums_or_playlist_name_font.draw_text(@playlists_add_prompt, @right_bar_x + 25, height / 14 * 4 + 30, ZOrder::PROMPT, 1, 1, Gosu::Color::BLACK)
            if(@blinking_effect == true && @blinking_duration > 0 && @blinking_duration < 500 && @playlists_add_prompt != " ")
                @albums_or_playlist_name_font.draw_text("|", @right_bar_x + 25 + @albums_or_playlist_name_font.text_width(@playlists_add_prompt), height / 14 * 4 + 27, ZOrder::PROMPT, 1, 1, Gosu::Color::BLACK)
            end
        end
        @playlists_index_y = Array.new()
        first_playlists_y = height / 14 * 4 + 75
        playlists_x =  @right_bar_x + 30
        #Index is the first album index of the current page
        index = @first_current_page_playlist_index
        text_position_adjust = 0
        while(index < @first_current_page_playlist_index + @maximum_playlists_per_page)
            @playlists_index_y << first_playlists_y
            if(cursor_hover?(playlists_x - 10, first_playlists_y - 10, playlists_x + 270, first_playlists_y + 50))
                draw_rectangle(playlists_x - 10, first_playlists_y - 10, playlists_x + 270, first_playlists_y + 50, THIRD_COLOR, ZOrder::HIGHLIGHT)
            end
            text_position_adjust = 12 * ((index + 1) / 10)
            if(@current_playing_album_or_playlist!= nil && @playlists[index] == @current_playing_album_or_playlist)
                draw_rectangle(playlists_x - 10, first_playlists_y - 10, playlists_x + 270, first_playlists_y + 50, FOURTH_COLOR, ZOrder::HIGHLIGHT)
                @albums_or_playlist_name_font.draw_text("#{index + 1} - #{@playlists[index].title}", playlists_x + 10 - text_position_adjust, first_playlists_y, ZOrder::TEXT, 0.9, 0.9, STATUS_TEXT_COLOR)
                @artist_font.draw_text("#{@playlists[index].total_tracks.to_s} Songs", playlists_x + 10 + @albums_or_playlist_name_font.text_width("#{index + 1} - ") - text_position_adjust, first_playlists_y + 25, ZOrder::TEXT, 1, 1, STATUS_TEXT_COLOR)
            else
                @albums_or_playlist_name_font.draw_text("#{index + 1} - #{@playlists[index].title}", playlists_x + 10 - text_position_adjust, first_playlists_y, ZOrder::TEXT, 0.9, 0.9, PRIMARY_TEXT_COLOR)
                @artist_font.draw_text("#{@playlists[index].total_tracks.to_s} Songs", playlists_x + 10 + @albums_or_playlist_name_font.text_width("#{index + 1} - ") - text_position_adjust, first_playlists_y + 25, ZOrder::TEXT, 1, 1, SECONDARY_TEXT_COLOR)
            end
            first_playlists_y += 60
            index += 1
        end
    end
    # Draw pagination of playlist
    def draw_page_of_playlist()
        current_page = @first_current_page_playlist_index / 6 + (@playlists.length != 0 ? 1 : 0)
        maximum_page = (@playlists.length - 1) / 6 + 1
        page = "Page #{current_page.to_s} / #{maximum_page.to_s}"
        @bar_font.draw_text(page, @right_bar_x + 40, @main_display_height - 40, ZOrder::TEXT, 1.0, 1.0, PRIMARY_TEXT_COLOR)
        change_page_button_x = width - @margin_right - 50
        change_page_button_y = @main_display_height - 40
        if (@maximum_playlists_per_page < @playlists.length - @first_current_page_playlist_index)
            draw_rectangle(change_page_button_x - 5, change_page_button_y - 5, change_page_button_x + 30, change_page_button_y + 30, THIRD_COLOR, ZOrder::HIGHLIGHT)
            draw_lower_icon_box(change_page_button_x, change_page_button_y, 0.25)
            if (cursor_hover?(change_page_button_x - 5, change_page_button_y - 5, change_page_button_x + 30, change_page_button_y + 30))
                draw_rectangle(change_page_button_x - 5, change_page_button_y - 5, change_page_button_x + 30, change_page_button_y + 30, FOURTH_COLOR, ZOrder::CURRENT_HIGHLIGHT)
            end
        end
        if (@first_current_page_playlist_index != 0)
            draw_upper_icon_box(change_page_button_x - 40, change_page_button_y, 0.25)
            draw_rectangle(change_page_button_x - 45, change_page_button_y - 5, change_page_button_x - 10, change_page_button_y + 30, THIRD_COLOR, ZOrder::HIGHLIGHT)
            if (cursor_hover?(change_page_button_x - 45, change_page_button_y - 5, change_page_button_x - 10, change_page_button_y + 30))
                draw_rectangle(change_page_button_x - 45, change_page_button_y - 5, change_page_button_x - 10, change_page_button_y + 30, FOURTH_COLOR, ZOrder::CURRENT_HIGHLIGHT)
            end
        end
    end
    # Draw Playlist Bar
    def draw_playlist_bar()
        draw_playlist_layout()
        draw_playlist_icon()
        draw_displayed_playlist()
        draw_playlist_text()
        draw_page_of_playlist()
    end
    # --------------------------------------------------
    #Draw Playback Bar
    def draw_playback_layout()
        draw_rectangle(0, @main_display_height, width, height, PLAY_BACK_COLOR, ZOrder::LAYOUT)
    end
    # Minute calculation function
    def minute_calc(seconds)
        minutes = '%02d' % (seconds / 60)
        return minutes.to_s
    end
    # Second calculation function
    def seconds_calc(seconds)
        seconds = '%02d' % (seconds % 60)
        return seconds.to_s
    end
    # Draw volume bar
    def draw_volume_bar()
        @volume_up_icon.file.draw(width - 60, @main_display_height + 39, ZOrder::ICON, 0.27, 0.27)
        @volume_down_icon.file.draw(width - 220, @main_display_height + 39, ZOrder::ICON, 0.27, 0.27)
        draw_line_horizontal(width - 178, @main_display_height + 50, 100, 4, FOURTH_COLOR, ZOrder::ICON)
        line_length = @current_volume.round(1) * 100
        draw_line_horizontal(width - 178, @main_display_height + 50, line_length, 4, PRIMARY_TEXT_COLOR, ZOrder::ICON)
        volume_num = (@current_volume.round(1) * 10).round(0)
        volume_num_pos = width - 183 + line_length
        if(volume_num == 10)
            volume_num_pos = width - 187 + line_length
        end
        @duration_font.draw_text(volume_num, volume_num_pos, @main_display_height + 30, ZOrder::TEXT, 1, 1, STATUS_TEXT_COLOR)
    end
    # Draw Scrubber bar
    def draw_scrubber_icon()
        scrubber_icon_space = 80
        center = width / 2 - 20
        if (@current_track != nil)
            #Displaying Song Current Seconds
            current_minutes_and_seconds = minute_calc(@current_song_seconds) + ":" + seconds_calc(@current_song_seconds)
            duration_minutes_and_seconds = minute_calc(@current_track.length) + ":" + seconds_calc(@current_track.length)
            @duration_font.draw_text(current_minutes_and_seconds, center - 250, @main_display_height + 20, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
            @duration_font.draw_text(duration_minutes_and_seconds, center + 260, @main_display_height + 20, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
            slider_length = 450
            draw_line_horizontal(center - 200, @main_display_height + 27, slider_length, 4, FOURTH_COLOR, ZOrder::ICON)
            line_length = slider_length * (@current_song_seconds / @current_track.length)
            draw_line_horizontal(center - 200, @main_display_height + 27, line_length, 4, PRIMARY_TEXT_COLOR, ZOrder::ICON)
        end
        if (@song && @song.playing?)
            @stop_icon.file.draw(center, @main_display_height + 45, ZOrder::ICON, 0.4, 0.4)
        elsif (@current_track == nil || @song && !@song.playing?)
            @play_icon.file.draw(center, @main_display_height + 45, ZOrder::ICON, 0.4, 0.4)
        end
        @skip_icon.file.draw(center + scrubber_icon_space - 2, @main_display_height + 57, ZOrder::ICON, 0.18, 0.18)
        @back_icon.file.draw(center - scrubber_icon_space + 22, @main_display_height + 57, ZOrder::ICON, 0.18, 0.18)
        @repeat_icon.file.draw(center + scrubber_icon_space * 2 - 17, @main_display_height + 55, ZOrder::ICON, 0.2, 0.2)
        @shuffle_icon.file.draw(center - scrubber_icon_space * 2 + 36, @main_display_height + 57, ZOrder::ICON, 0.18, 0.18)
        if(@shuffle_check == true)
            draw_line_horizontal(center - scrubber_icon_space * 2 + 33, @main_display_height + 80, 28, 4, STATUS_TEXT_COLOR, ZOrder::ICON)
        end
        if(@loop_check == true)
            draw_line_horizontal(center + scrubber_icon_space * 2 - 20, @main_display_height + 80, 28, 4, STATUS_TEXT_COLOR, ZOrder::ICON)
        end
        draw_volume_bar()

    end
    # Draw auto generated album cover in the playback bar if there is no existed cover
    def draw_generated_thumbnail_current_display(name, x, y, scale)
        initial_width = 303
        initial_height = 303
        required_width = initial_width * scale
        required_height = initial_height * scale
        color = Gosu::Color.new(233, 20, 41)
        if(name == "Playlist")
            color = Gosu::Color.new(20, 138, 8)
        elsif(name == "Track")
            color = Gosu::Color.new(45, 70, 185)
        end
        draw_rectangle(x, y, x + required_width, y + required_height, color, ZOrder::DISPLAY)
        center_x = center_text_horizontal(@albums_name_font_2, name, x + required_width, required_width)
        @albums_name_font_2.draw_text(name, center_x, y + 28, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
    end
    # Draw current playing song
    def draw_current_song_information()
        #Draw only the album/playlist/tracks information currently playing
        if(@current_playing_album == true)
            @current_album_image = @current_playing_album_or_playlist.images
            if (@current_album_image != nil)
                thumbnail = ArtWork.new(@current_album_image)
                draw_thumbnail(@margin_left + 10, @main_display_height + 15, thumbnail, 0.23)
            else
                draw_generated_thumbnail_current_display("Album", @margin_left + 10, @main_display_height + 15, 0.23)
            end
        elsif(@current_playing_playlist == true)
            draw_generated_thumbnail_current_display("Playlist", @margin_left + 10, @main_display_height + 15, 0.23)
        elsif(@current_playing_generated_playlist == true)
            @current_album_image = @current_playing_album_or_playlist.cover
            thumbnail = ArtWork.new(@current_album_image)
            draw_thumbnail(@margin_left + 10, @main_display_height + 15, thumbnail, 0.27)
        else
            draw_generated_thumbnail_current_display("Track", @margin_left + 10, @main_display_height + 15, 0.23)
        end
        if (@paragraph_font.text_width(@current_track.name) < 300)
            @paragraph_font.draw_text(@current_track.name, @margin_left + 100, @main_display_height + 25, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
        else
            cropped_texts = crop_text(@paragraph_font, @current_track.name, 300)
            @paragraph_font.draw_text(cropped_texts, @margin_left + 100, @main_display_height + 25, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
        end
        addictional_information = @current_track.artist + " - " + @current_track.album
        @artist_font.draw_text(addictional_information, @margin_left + 100, @main_display_height + 55, ZOrder::TEXT, 1, 1, SECONDARY_TEXT_COLOR)
        if(cursor_hover?(@margin_left + 10, @main_display_height + 15, @margin_left + 490, @main_display_height + 15 + 70) && @current_playing_album_or_playlist != nil)
            @artist_font.draw_text(addictional_information, @margin_left + 100, @main_display_height + 55, ZOrder::TEXT, 1, 1, STATUS_TEXT_COLOR)
            draw_line_horizontal(@margin_left + 99, @main_display_height + 75, @artist_font.text_width(addictional_information) + 3, 2, STATUS_TEXT_COLOR, ZOrder::ICON)
        end
    end
    def draw_playback_bar()
        draw_playback_layout()
        draw_scrubber_icon()
        #Show current playing track & album
        if (@current_track != nil)
            draw_current_song_information()
        end
    end
    #Draw layout of the Music Player
    def draw_layout()
        # Draw Main Layout
        draw_rectangle(@margin_left, @margin_top, @main_display_width, @main_display_height, LAYOUT_COLOR, ZOrder::LAYOUT)
        # Draw Menu Bar
        draw_navigation_bar()
        # Draw Playlist Bar
        draw_playlist_bar()
        # Draw playback Bar
        draw_playback_bar()
    end
    #############################
    #############################
    #####-----Search Page----######
    # Draw Search Page
    def draw_search_page()
        if(@selected_album_check == false && @selected_playlist_check == false)
            draw_search_bar()
            if(@found_similar_tracks != [])
                draw_search_header()
                draw_search_found()
            end
        end
    end
    # Draw Search Bar
    def draw_search_bar()
        search_bar_x = @margin_left + 220
        search_bar_y = @margin_top + 20
        @search_bar_icon.file.draw(search_bar_x, search_bar_y, ZOrder::ICON, 0.75, 0.75)
        if(@search_bar_searching_text == "" && @search_bar_typing == false)
            @search_bar_font.draw_text("What song do you want to listen to?", @margin_left + 290, @margin_top + 34, ZOrder::PROMPT, 1, 1, SECONDARY_TEXT_COLOR)
        else
            @search_bar_font.draw_text(@search_bar_searching_text, @margin_left + 290, @margin_top + 34, ZOrder::PROMPT, 1, 1, Gosu::Color::BLACK)
            if(@blinking_effect == true && @blinking_duration > 0 && @blinking_duration < 500 && @search_bar_typing == true)
                @search_bar_font.draw_text("|", @margin_left + 290 + @search_bar_font.text_width(@search_bar_searching_text), @margin_top + 31, ZOrder::PROMPT, 1, 1, Gosu::Color::BLACK)
            end
        end
    end
    # Draw Search Page Text Header
    def draw_search_header()
        @results_position_x = @margin_left + 125
        @results_position_y = @margin_top + 115
        @similar_toggle_position_x = @margin_left + 670
        @similar_toggle_position_y = @margin_top + 115
        @search_bar_font.draw_text("Top Results", @results_position_x, @results_position_y, ZOrder::TEXT, 1.25, 1.25, PRIMARY_TEXT_COLOR)
        if(@similarity_toggle_check == false)
            @unchecked_box_icon.file.draw(@similar_toggle_position_x + 285, @similar_toggle_position_y, ZOrder::ICON, 0.28, 0.28)
        else
            @checked_box_icon.file.draw(@similar_toggle_position_x + 285, @similar_toggle_position_y, ZOrder::ICON, 0.28, 0.28)
        end
        @search_bar_font.draw_text("Visualize Similarity %", @similar_toggle_position_x, @similar_toggle_position_y, ZOrder::TEXT, 1.25, 1.25, PRIMARY_TEXT_COLOR)
        draw_line_horizontal(@margin_left + 105, @margin_top + 155, 900, 3, PRIMARY_TEXT_COLOR, ZOrder::ICON)
        draw_rectangle(@margin_left + 90, @results_position_y - 20, @margin_left + 90 + 925, @margin_top + 158 + 515, SECONDARY_COLOR, ZOrder::CONTAINER)
    end
    # Draw Search Page found tracks based on user query
    def draw_search_found()
        @top_track_results_position_x = @margin_left + 125
        @top_track_results_position_y = @margin_top + 170
        @top_track_results_pos_y_array = Array.new()
        @tracks_pos_y = Array.new()
        index = 0
        while(index < @found_similar_tracks.length)
            @tracks_pos_y << @top_track_results_position_y
            track_index = @found_similar_tracks[index][0]
            @top_track_results_pos_y_array << @top_track_results_position_y
            @paragraph_font.draw_text(@tracks_storage[track_index].name, @top_track_results_position_x, @top_track_results_position_y, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
            @artist_font.draw_text(@tracks_storage[track_index].artist, @top_track_results_position_x, @top_track_results_position_y + 30, ZOrder::TEXT, 1, 1, SECONDARY_TEXT_COLOR)
            if(@similarity_toggle_check == true)
                @paragraph_font.draw_text("#{@found_similar_tracks[index][1]}%", @top_track_results_position_x + 750, @top_track_results_position_y, ZOrder::TEXT, 1.1, 1.1, STATUS_TEXT_COLOR)
            end
            if(cursor_hover?(@top_track_results_position_x - 20, @top_track_results_position_y - 10, @top_track_results_position_x + 880, @top_track_results_position_y + 60))
                draw_rectangle(@top_track_results_position_x - 20, @top_track_results_position_y - 10, @top_track_results_position_x + 880, @top_track_results_position_y + 60, THIRD_COLOR, ZOrder::HIGHLIGHT)
                @artist_font.draw_text("Add to Playlist", @top_track_results_position_x + 725, @top_track_results_position_y + 30, ZOrder::TEXT, 1, 1, SECONDARY_TEXT_COLOR)
                if(cursor_hover?(@top_track_results_position_x + 725, @top_track_results_position_y + 30, @top_track_results_position_x + 830, @top_track_results_position_y + 45))
                    draw_line_horizontal(@top_track_results_position_x + 725, @top_track_results_position_y + 48, 105, 2, SECONDARY_TEXT_COLOR, ZOrder::TEXT)
                end
            end
            @top_track_results_position_y += 70
            index += 1
        end
    end
    #############################
    #############################
    #####-----Home Page----######
    #Draw header of the page in Home Page
    def draw_header()
        center_x = center_text_horizontal(@header_font, @header, @margin_left + @right_bar_x - @margin_right, @right_bar_x - @margin_right)
        @header_font.draw_text(@header, center_x, @margin_album_top - 100, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
    end
    # Draw auto generated album cover if there is no existed cover
    def draw_auto_generated_thumbnail(album_name, x, y, scale)
        initial_width = 303
        initial_height = 303
        required_width = initial_width * scale
        required_height = initial_height * scale
        draw_rectangle(x, y, x + required_width, y + required_height, Gosu::Color.new(233, 20, 41), ZOrder::DISPLAY)
        center_x = center_text_horizontal(@album_auto_generated_font, album_name, x + required_width, required_width)
        @album_auto_generated_font.draw_text(album_name, center_x, y + 77, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
    end
    # Draw album cover
    def draw_thumbnail(x, y, thumbnail, scale)
        thumbnail.file.draw(x, y, ZOrder::DISPLAY, scale, scale)
    end
    # Draw a box containing title and artist of album
    def draw_album_box(album, x, y, color)
        draw_rectangle(x - 20, y - 20, x + 200, y + 300, SECONDARY_COLOR, ZOrder::CONTAINER)
        if (cursor_hover?(x - 20, y - 20, x + 200, y + 300))
            draw_rectangle(x - 20, y - 20, x + 200, y + 300, THIRD_COLOR, ZOrder::HIGHLIGHT)
            if (!@song || @song && (@current_playing_album_or_playlist != album))
                @play_album_icon.file.draw(x + 60, y + 60, ZOrder::ICON, 0.6, 0.6)
            end
        end

        if(@song && (@current_playing_album_or_playlist == album))
            color = STATUS_TEXT_COLOR
            draw_rectangle(x - 20, y - 20, x + 200, y + 300, FOURTH_COLOR, ZOrder::CURRENT_HIGHLIGHT)
        end
        album_name = album.title

        if (@albums_or_playlist_name_font.text_width(album.title) < 180)
            album_name = album.title
        else
            #Crop Text if the song name is too long
            album_name = crop_text(@albums_or_playlist_name_font, album_name, 180)
        end

        album_artist = album.artist
        center_x_name = center_text_horizontal(@albums_or_playlist_name_font, album_name, x + 200, 220)
        @albums_or_playlist_name_font.draw_text(album_name, center_x_name, y + 205, ZOrder::TEXT, 1, 1, color)
        center_x_artist = center_text_horizontal(@artist_font, album_artist, x + 200, 220)
        @artist_font.draw_text(album_artist, center_x_artist, y + 235, ZOrder::TEXT, 1, 1, SECONDARY_TEXT_COLOR)
        # Display Current Playing Text on the playing Album box
    end
    # Draw next icon by position and scale
    def draw_next_icon_box(x, y, scale)
        @next_page_icon.file.draw(x, y, ZOrder::ICON, scale, scale)
    end
    # Draw back icon by position and scale
    def draw_previous_icon_box(x, y, scale)
        @previous_page_icon.file.draw(x, y, ZOrder::ICON, scale, scale)
    end
    # Draw up (previous) icon by position and scale
    def draw_upper_icon_box(x, y, scale)
        @upper_page_icon.file.draw(x, y, ZOrder::ICON, scale, scale)
    end
    # Draw down (next) icon by position and scale
    def draw_lower_icon_box(x, y, scale)
        @lower_page_icon.file.draw(x, y, ZOrder::ICON, scale, scale)
    end
    # Draw back and next icon of pagination of albums display
    def draw_previous_and_next_album_icon(x, y)
        # Display if there are more albums in next page
        next_icon_position_x = x - 85
        next_icon_position_y = y - 90
        previous_icon_position_x = next_icon_position_x - 50
        previous_icon_position_y = next_icon_position_y
        if (@albums.length - @first_current_page_album_index > 4)
            draw_next_icon_box(next_icon_position_x, next_icon_position_y, 0.25)
            draw_rectangle(next_icon_position_x - 10, next_icon_position_y - 10, next_icon_position_x + 35,next_icon_position_y + 35, SECONDARY_COLOR, ZOrder::CONTAINER)
            if (cursor_hover?(next_icon_position_x - 10, next_icon_position_y - 10, next_icon_position_x + 35, next_icon_position_y + 35))
                draw_rectangle(next_icon_position_x - 10, next_icon_position_y - 10, next_icon_position_x + 35,next_icon_position_y + 35, THIRD_COLOR, ZOrder::HIGHLIGHT)
            end
        end
        # Display if there are more albums in previous page
        if (@first_current_page_album_index != 0)
            draw_previous_icon_box(previous_icon_position_x, previous_icon_position_y, 0.25)
            draw_rectangle(previous_icon_position_x - 10, previous_icon_position_y - 10, previous_icon_position_x + 35,previous_icon_position_y + 35, SECONDARY_COLOR, ZOrder::CONTAINER)
            if (cursor_hover?(previous_icon_position_x - 10, previous_icon_position_y - 10, previous_icon_position_x + 35, previous_icon_position_y + 35))
                draw_rectangle(previous_icon_position_x - 10, previous_icon_position_y - 10, previous_icon_position_x + 35 ,previous_icon_position_y + 35, THIRD_COLOR, ZOrder::HIGHLIGHT)
            end
        end
    end
    #Draw required albums (the default state is the initial @albums file)
    def draw_required_albums()
        #Left-most x
        first_album_position = @align_left_contents
        #Right-most x
        last_album_position = first_album_position + 250 * 4
        # Conditions to display next and/or previous button
        draw_previous_and_next_album_icon(last_album_position, @margin_album_top)
        current_page = @first_current_page_album_index / 4 + 1
        maximum_page = (@albums.length - 1) / 4 + 1
        page = "#{current_page.to_s} / #{maximum_page.to_s}"
        @bar_font.draw_text(page, last_album_position - 120, @margin_album_top - 50, ZOrder::TEXT, 1.0, 1.0, PRIMARY_TEXT_COLOR)
        #Index is the first album index of the current page
        index = @first_current_page_album_index
        # Display albums cover with title
        while (index < @first_current_page_album_index + @maximum_albums_per_page)
            if (@albums[index].images != nil)
                # Draw available album cover
                album_thumbnail = ArtWork.new(@albums[index].images)
                draw_thumbnail(first_album_position, @margin_album_top, album_thumbnail, 0.6)
            else
                # Draw auto-generated album cover in case of non-existed cover
                draw_auto_generated_thumbnail("Album", first_album_position, @margin_album_top, 0.6)
            end
            # Draw a box containing title and artist of album
            draw_album_box(@albums[index], first_album_position, @margin_album_top, PRIMARY_TEXT_COLOR)
            first_album_position += 250
            index += 1
        end
    end
    # Draw the categories the users want to filter on the default page
    def draw_default_categories()
        color = Array.new(4)
        color[0] = Gosu::Color.new(233, 20, 41)
        color[1] = Gosu::Color.new(225, 51, 0)
        color[2] = Gosu::Color.new(20, 138, 8)
        color[3] = Gosu::Color.new(45, 70, 185)
        categories = ["All", "Genres", "Artists", "Decades"]
        first_categories_x = @align_left_contents
        index = 0
        while (index < 4)
            draw_rectangle(first_categories_x - 20, @margin_top + 50, first_categories_x + 200, @margin_top + 190, color[index], ZOrder::CONTAINER)
            text_color = Gosu::Color.new(255,215,0)
            # Formula to calculate the horizontal center of the text:
            # 1. Set the value to the right-most x.
            # 2. Then subtract the gap between right border of box and text width ((box width - text width ) / 2).
            # 3. Then subtract the text-width.
            if (@active_category_page != nil && @category_index[@active_category_page] == categories[index])
                center_x_item = center_text_horizontal(@categories_font, @active_category_item, first_categories_x + 200, 220)
                @categories_font.draw_text(@active_category_item, center_x_item, @margin_top + 105, ZOrder::TEXT, 1, 1, text_color)
                draw_line_horizontal(center_x_item, @margin_top + 138, @categories_font.text_width(@active_category_item), 5, text_color, ZOrder::HIGHLIGHT)
            else
                center_x = center_text_horizontal(@categories_font, categories[index], first_categories_x + 200, 220)
                #Highlighting All Status
                if (index == 0 && @active_category_page == nil && @active_category_item == nil && @filter_status == false)
                    @categories_font.draw_text(categories[0], center_x, @margin_top + 105, ZOrder::TEXT, 1, 1, text_color)
                    draw_line_horizontal(center_x, @margin_top + 138, @categories_font.text_width(categories[0]), 5, text_color, ZOrder::HIGHLIGHT)
                else
                    @categories_font.draw_text(categories[index], center_x, @margin_top + 105, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
                end
            end
            first_categories_x += 250
            index += 1
        end
    end
    # Display if there are more albums in next page
    def draw_previous_and_next_category_icon(first, last, y)
        previous_icon_position_x = first - 50
        previous_icon_position_y = y + 10
        next_icon_position_x = last - 30
        next_icon_position_y = previous_icon_position_y
        if (@category_storage.length - @first_category_page_index > 4)
            draw_next_icon_box(next_icon_position_x - 8, next_icon_position_y, 0.25)
            draw_rectangle(next_icon_position_x - 10, next_icon_position_y - 10, next_icon_position_x + 20, next_icon_position_y + 35, SECONDARY_COLOR, ZOrder::CONTAINER)
            if (cursor_hover?(next_icon_position_x - 10 , next_icon_position_y - 10, next_icon_position_x + 20, next_icon_position_y + 35))
                draw_rectangle(next_icon_position_x - 10, next_icon_position_y - 10, next_icon_position_x + 20, next_icon_position_y + 35, THIRD_COLOR, ZOrder::HIGHLIGHT)
            end
        end
        # Display if there are more albums in previous page
        if (@first_category_page_index != 0)
            draw_previous_icon_box(previous_icon_position_x - 8, previous_icon_position_y, 0.25)
            draw_rectangle(previous_icon_position_x - 10, previous_icon_position_y - 10, previous_icon_position_x + 20, previous_icon_position_y + 35, SECONDARY_COLOR, ZOrder::CONTAINER)
            if (cursor_hover?(previous_icon_position_x - 10,  previous_icon_position_y - 10, previous_icon_position_x + 20, previous_icon_position_y + 35))
                draw_rectangle(previous_icon_position_x - 10, previous_icon_position_y - 10, previous_icon_position_x + 20, previous_icon_position_y + 35, THIRD_COLOR, ZOrder::HIGHLIGHT)
            end
        end
    end
    # Draw the available genres/artist/decades for users to choose
    def draw_available_items_in_category(category)
        case category
        when 1
            background_color = Gosu::Color.new(225, 51, 0)
        when 2
            background_color = Gosu::Color.new(20, 138, 8)
        when 3
            background_color = Gosu::Color.new(45, 70, 185)
        end
        @maximum_items_per_category_page = @category_storage.length() - @first_category_page_index > 4 ? 4 : @category_storage.length() - @first_category_page_index
        first_item_x = @align_left_contents
        last_item_x = first_item_x + 250 * 4
        index = @first_category_page_index
        draw_previous_and_next_category_icon(first_item_x, last_item_x, @margin_top + 100)
        @close_icon.file.draw(first_item_x - 60, @margin_top + 50, ZOrder::ICON, 0.8, 0.8)
        # Display albums cover with title
        while (index < @first_category_page_index + @maximum_items_per_category_page)
            draw_rectangle(first_item_x - 20, @margin_top + 50, first_item_x + 200, @margin_top + 190, background_color, ZOrder::CONTAINER)
            center_x = center_text_horizontal(@categories_font, @category_storage[index], first_item_x + 200, 220)
            if (@active_category_item == @category_storage[index])
                text_color = Gosu::Color.new(255,215,0)
                draw_line_horizontal(center_x, @margin_top + 138, @categories_font.text_width(@category_storage[index]), 5, text_color, ZOrder::HIGHLIGHT)
            else
                text_color = PRIMARY_TEXT_COLOR
            end
            @categories_font.draw_text(@category_storage[index], center_x, @margin_top + 105, ZOrder::TEXT, 1, 1, text_color)
            first_item_x += 250
            index += 1
        end
    end
    #Draw the home page of the Music Player
    def draw_home_page()
        if(@selected_album_check == false && @selected_playlist_check == false && @albums.length > 0)
            draw_line_horizontal(@margin_left + 20, @margin_album_top - 147, @right_bar_x - @margin_right - (@margin_left + 20) * 2, 3, PRIMARY_TEXT_COLOR, ZOrder::TEXT)
            # Draw Header indicates the default page
            draw_header()
            # Draw Albums Cover & Information of on the default page
            draw_required_albums()
            if(@current_category_page == 0)
                draw_default_categories()
            else
                draw_available_items_in_category(@current_category_page)
            end

            if(!@active_category_page)
                @header = "All Albums"
            else
                @header = "#{@active_category_item} Albums"
            end
            @help_icon.file.draw(@margin_left + 20, @margin_album_top - 100, ZOrder::ICON, 0.4, 0.4)
        end
    end
    #############################
    #####-----Help Page----######
    # Draw Help Page Header
    def draw_help_page_header()
        header = "Shortcuts"
        center_x = center_text_horizontal(@header_font, header, @margin_left + @right_bar_x - @margin_right, @right_bar_x - @margin_right)
        @header_font.draw_text(header, center_x, @shortcut_section_y, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
    end
    # Draw Shortcuts and functions of that shortcut in the Help Page
    def draw_shortcuts_and_functions(shortcut, purpose, y)
        @shortcut_font.draw_text(shortcut, @help_page_content_x, y, ZOrder::TEXT, 1, 1, STATUS_TEXT_COLOR)
        @paragraph_font.draw_text(purpose, @help_page_content_x + 350, y, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
    end
    # Draw the help page in home page of the Music Player
    def draw_help_page_shortcut()
        @help_page_content_x = @margin_left + 200
        shortcuts = [
            ["ESC", "Close selected album/playlist/help pages"],
            ["SPACE", "Play/Pause the song"],
            ["LEFT ARROW", "Move to previous song"],
            ["RIGHT ARROW", "Move to next song"],
            ["S", "Shuffle mode on/off"],
            ["L", "Loop mode on/off"],
            ["1", "Decrease volume"],
            ["2", "Increase volume"],
        ]
        index = 0
        shortcut_y = @shortcut_section_y + 150
        draw_line_horizontal(@help_page_content_x - 50, shortcut_y - 15, @right_bar_x - @margin_right - (@help_page_content_x - 50) * 2, 3, SECONDARY_TEXT_COLOR, ZOrder::TEXT)
        while(index < shortcuts.length)
            draw_shortcuts_and_functions(shortcuts[index][0], shortcuts[index][1], shortcut_y)
            draw_line_horizontal(@help_page_content_x - 50, shortcut_y + 35, @right_bar_x - @margin_right - (@help_page_content_x - 50) * 2, 3, SECONDARY_TEXT_COLOR, ZOrder::TEXT)
            index += 1
            shortcut_y += 50
        end
        draw_line_vertical(@help_page_content_x - 50, @shortcut_section_y + 150 - 15, 3, shortcut_y - 15 - (@shortcut_section_y + 150 - 15), SECONDARY_TEXT_COLOR, ZOrder::TEXT)
        draw_line_vertical(@right_bar_x - @margin_right - (@help_page_content_x - 50), @shortcut_section_y + 150 - 15, 3, shortcut_y - 15 - (@shortcut_section_y + 150 - 15) + 3, SECONDARY_TEXT_COLOR, ZOrder::TEXT)
    end
    # Draw Help Page with the above components
    def draw_help_page()
        #Help Page Close Button
        @help_page_close_x = @margin_left + 50
        @help_page_close_y = @margin_top + 50
        @close_icon.file.draw(@help_page_close_x, @help_page_close_y, ZOrder::ICON, 0.8, 0.8)
        #Help Page Contents
        @shortcut_section_y = @margin_top + 50
        draw_help_page_header()
        draw_line_horizontal(@margin_left + 20, @shortcut_section_y + 60, @right_bar_x - @margin_right - 50, 3, PRIMARY_TEXT_COLOR, ZOrder::TEXT)
        draw_help_page_shortcut()
    end
    #######################################
    #######-----Generation Page-----#######
    # Draw generated playlist box
    def draw_generated_playlist_box(box_x, box_y, cover, text, info)
        draw_rectangle(box_x - 15, box_y - 15, box_x + 175, box_y + 245, SECONDARY_COLOR, ZOrder::CONTAINER)
        if (cursor_hover?(box_x - 15, box_y - 20, box_x + 175, box_y + 245))
            draw_rectangle(box_x - 15, box_y - 20, box_x + 175, box_y + 245, THIRD_COLOR, ZOrder::CONTAINER)
        end
        cover.file.draw(box_x, box_y, ZOrder::DISPLAY, 0.64, 0.64)
        center_x_name = center_text_horizontal(@albums_or_playlist_name_font, text, box_x + 175, 190)
        @albums_or_playlist_name_font.draw_text(text, center_x_name, box_y + 180, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
        center_x_add_info = center_text_horizontal(@artist_font, info, box_x + 175, 190)
        @artist_font.draw_text(info, center_x_add_info, box_y + 210, ZOrder::TEXT, 1, 1, SECONDARY_TEXT_COLOR)
    end
    # Draw 5 initial generated mixes graphically
    def draw_mixes(first_mix_x, first_mix_y)
        index = 0
        @generated_playlists_x = Array.new()
        while(index < 5)
            name = @generated_playlist[index].title
            cover =  ArtWork.new(@generated_playlist[index].cover)
            draw_generated_playlist_box(first_mix_x + 15, first_mix_y, cover, name, "Ready for Best Hits")
            @generated_playlists_x << first_mix_x + 15
            first_mix_x += 215
            index += 1
        end
    end
    # Draw actions button in playlist generation page
    def draw_generation_button(box_x, box_y)
        color_0 = Gosu::Color.new(45, 70, 185)
        text = "Generate"
        @albums_or_playlist_name_font.draw_text(text, box_x + 20, box_y + 15, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
        draw_rectangle(box_x, box_y, box_x + 125, box_y + 50, color_0, ZOrder::CONTAINER)
        color_1 = Gosu::Color.new(20, 138, 8)
        text = "Options"
        @albums_or_playlist_name_font.draw_text(text, box_x + 170, box_y + 15, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
        draw_rectangle(box_x + 150, box_y, box_x + 265, box_y + 50, color_1, ZOrder::CONTAINER)
    end
    # Draw generation mix
    def draw_generation_mix(first_mix_x, first_mix_y)
        index = 5
        @personalized_playlists_x = Array.new()
        mix_description = ["Discovery Mix", "Exploration Mix", "Personalized Mix"]
        while(index < @generated_playlist.length)
            name = @generated_playlist[index].title
            cover =  ArtWork.new(@generated_playlist[index].cover)
            draw_generated_playlist_box(first_mix_x + 15, first_mix_y, cover, name, mix_description[index - 5])
            @personalized_playlists_x << first_mix_x + 15
            first_mix_x += 215
            index += 1
        end
    end
    # Draw playlist generation page
    def draw_generation_page()
        # If total tracks is above 0, I will try to provide the most suitable tracks :D
        if(@tracks_storage.length > 0 && @selected_generated_playlist_check == false && @selected_playlist_check == false)
            first_header_x = @align_left_contents - 60
            first_header_y = @margin_top + 30
            @header_2_font.draw_text("Top Mixes", first_header_x, first_header_y, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
            draw_mixes(first_header_x, first_header_y + 70)
            second_header_x = @align_left_contents - 60
            second_header_y = @margin_top + 370
            @header_2_font.draw_text("Made For You", second_header_x, second_header_y, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
            draw_generation_mix(second_header_x, second_header_y + 70)
            third_header_x = @align_left_contents + 585
            third_header_y = @margin_top + 370
            @header_2_font.draw_text("Playlist Generation", third_header_x, third_header_y, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
            # Only display the options if there are history of user interaction
            if (Dir.glob(INTERACTION_HISTORY_FILE_NAME).any? == true)
                draw_generation_button(third_header_x, third_header_y + 55)
            end
        end
    end
    # Draw interaction buttons when users is in option page
    def draw_playlist_generation_interaction_button()
        header_x = @margin_left + 100
        header_y  = @margin_top + 75
        auto_button_x = @margin_left + 425
        custom_button_x = @margin_left + 525
        cancel_button_x = @margin_left + 775
        confirm_button_x = @margin_left + 895
        button_y = @margin_top + 70
        color = Array.new()
        color[0] = Gosu::Color.new(233, 20, 41)
        color[1] = Gosu::Color.new(225, 51, 0)
        color[2] = Gosu::Color.new(20, 138, 8)
        color[3] = Gosu::Color.new(45, 70, 185)

        @header_2_font.draw_text("Generation Options", header_x, header_y, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)

        text_color = Gosu::Color.new(255,215,0)
        # Auto Button
        draw_rectangle(auto_button_x, button_y, auto_button_x + 80, button_y + 50, color[3], ZOrder::CONTAINER)
        if(@custom_playlist_generation_check == false)
            @albums_or_playlist_name_font.draw_text("Auto", auto_button_x + 12, button_y + 13, ZOrder::TEXT, 1.2, 1.2, text_color)
            draw_line_horizontal(auto_button_x + 10, button_y + 40, 60, 4, text_color, ZOrder::HIGHLIGHT)
        else
            @albums_or_playlist_name_font.draw_text("Auto", auto_button_x + 12, button_y + 13, ZOrder::TEXT, 1.2, 1.2, PRIMARY_TEXT_COLOR)
        end
        # Custom Button
        draw_rectangle(custom_button_x, button_y, custom_button_x + 112, button_y + 50, color[1], ZOrder::CONTAINER)
        if(@custom_playlist_generation_check == true)
            @albums_or_playlist_name_font.draw_text("Custom", custom_button_x + 12, button_y + 13, ZOrder::TEXT, 1.2, 1.2, text_color)
            draw_line_horizontal(custom_button_x + 10, button_y + 40, 92, 4, text_color, ZOrder::HIGHLIGHT)
        else
            @albums_or_playlist_name_font.draw_text("Custom", custom_button_x + 12, button_y + 13, ZOrder::TEXT, 1.2, 1.2, PRIMARY_TEXT_COLOR)
        end
        # Cancel Button
        draw_rectangle(cancel_button_x, button_y, cancel_button_x + 102, button_y + 50, color[0], ZOrder::CONTAINER)
        @albums_or_playlist_name_font.draw_text("Cancel", cancel_button_x + 12, button_y + 13, ZOrder::TEXT, 1.2, 1.2, PRIMARY_TEXT_COLOR)
        # Confirm Button
        draw_rectangle(confirm_button_x, button_y, confirm_button_x + 115, button_y + 50, color[2], ZOrder::CONTAINER)
        @albums_or_playlist_name_font.draw_text("Confirm", confirm_button_x + 12, button_y + 13, ZOrder::TEXT, 1.2, 1.2, PRIMARY_TEXT_COLOR)
    end
    # Draw categories of options in custom playlist generation
    def draw_custom_playlist_generation_categories()
        custom_categories_header_x = @margin_left + 50
        custom_categories_header_y = @margin_top + 200
        custom_option_header = ["Artists", "Genres", "Happiness", "Energy", "Danceability"]
        options_array = [[@artists_storage[@custom_playlist_generation_options[0][0]]], [@genres_storage[@custom_playlist_generation_options[1][0]]], ["Sad", "Neutral", "Happy"], ["Calm", "Neutral", "Energetic"], ["Relax", "Neutral", "Dance"]]
        index = 0
        while(index < custom_option_header.length)
            center_x_categories = center_text_horizontal(@categories_font, custom_option_header[index], custom_categories_header_x + 220, 220)
            @categories_font.draw_text(custom_option_header[index], center_x_categories, custom_categories_header_y, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
            draw_custom_playlist_generation_each_option(custom_categories_header_x, index, options_array[index])
            custom_categories_header_x += 200
            index += 1
        end
    end
    # Draw each option in custom playlist generation options
    def draw_custom_playlist_generation_each_option(custom_option_x, option_index, options)
        option_x = custom_option_x
        option_y = @margin_top + 270
        option_box_width = 150
        pseudo_string_length = ""
        while(@categories_font.text_width(pseudo_string_length) < option_box_width)
            pseudo_string_length += "I"
        end
        index = 0
        text_color = PRIMARY_TEXT_COLOR
        box_color = THIRD_COLOR
        while(index < options.length)
            if(option_index >= 2)
                if(@custom_playlist_generation_options[option_index][index] == true)
                    text_color = Gosu::Color.new(255,215,0)
                    box_color = Gosu::Color.new(45, 70, 185)
                else
                    text_color = PRIMARY_TEXT_COLOR
                    box_color = THIRD_COLOR
                end
            else
                text_color = Gosu::Color.new(255,215,0)
                box_color = Gosu::Color.new(45, 70, 185)
            end
            center_x_option_box = center_text_horizontal(@categories_font, pseudo_string_length, option_x + 220, 220)
            draw_rectangle(center_x_option_box, option_y, center_x_option_box + option_box_width, option_y + 50, box_color, ZOrder::CONTAINER)
            draw_line_horizontal(center_x_option_box, option_y, option_box_width, 2, SECONDARY_TEXT_COLOR, ZOrder::HIGHLIGHT)
            draw_line_horizontal(center_x_option_box, option_y + 50, option_box_width, 2, SECONDARY_TEXT_COLOR, ZOrder::HIGHLIGHT)
            draw_line_vertical(center_x_option_box, option_y, 2, 50, SECONDARY_TEXT_COLOR, ZOrder::HIGHLIGHT)
            draw_line_vertical(center_x_option_box + option_box_width, option_y, 2, 52, SECONDARY_TEXT_COLOR, ZOrder::HIGHLIGHT)
            center_x_option = center_text_horizontal(@albums_or_playlist_name_font, options[index], center_x_option_box + option_box_width, option_box_width)
            @albums_or_playlist_name_font.draw_text(options[index], center_x_option, option_y + 17, ZOrder::TEXT, 1, 1, text_color)
            @options_position_array << [option_index, index, center_x_option_box, option_y]
            if(option_index < 2)
                text = "Click to change"
                center_x_genre_guide = center_text_horizontal(@albums_or_playlist_name_font, text, center_x_option_box + option_box_width, option_box_width)
                @albums_or_playlist_name_font.draw_text(text, center_x_genre_guide, option_y + 67, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
            end
            option_y += 50
            index += 1
        end
    end
    # Draw target preferences if the users want to auto generate the playlist
    def draw_current_target_preferences()
        auto_preference_x = @margin_left + 380
        auto_preference_y = @margin_top + 200
        compressed_preferences = [@artist_preferences, @genres_preferences, @decades_preferences, @acousticness_preferences, @valence_preferences, @energy_preferences, @danceability_preferences, @speechiness_prefererences, @tempo_preferences].clone
        target_preferences = calculation_target_preferences_based_on_history(compressed_preferences, @artists_storage, @genres_storage, @decades_storage, @tracks_storage)
        index = 0
        @categories_font.draw_text("Current Preferences", @margin_left + 100, auto_preference_y, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
        # Only display the necessary information
        displayed_preferences = [target_preferences.artist, target_preferences.genre, target_preferences.decade]
        while(index < displayed_preferences.length)
            center_x_preferences = center_text_horizontal(@albums_or_playlist_name_font, displayed_preferences[index], auto_preference_x + 220, 220)
            @albums_or_playlist_name_font.draw_text(displayed_preferences[index], center_x_preferences, auto_preference_y + 10, ZOrder::TEXT, 1, 1, Gosu::Color.new(255,215,0))
            draw_rectangle(center_x_preferences - 15, auto_preference_y - 5, center_x_preferences + @albums_or_playlist_name_font.text_width(displayed_preferences[index]) + 15, auto_preference_y + 45, Gosu::Color.new(45, 70, 185), ZOrder::CONTAINER)
            auto_preference_x += 150
            index += 1
        end
    end
    # Draw option page if user clicks on options button in playlist generation page
    def draw_playlist_generation_option_page()
        draw_playlist_generation_interaction_button()
        # Provide options for users if the users want custom generation
        if(@custom_playlist_generation_check == true)
            @options_position_array = Array.new()
            draw_custom_playlist_generation_categories()
        else
            draw_current_target_preferences()
        end
    end
    #####################################################################################
    #####################################################################################
    #####-----Display Tracks (from Albums/ Playlists/ Generated Playlists) Page----######
    def draw_playlists_action(x, y, text)
        center_x = center_text_horizontal(@albums_or_playlist_name_font, text, x + 303, 303)
        draw_rectangle(x + 50, y + 400, x + 255, y + 440, SECONDARY_COLOR, ZOrder::CONTAINER)
        @albums_or_playlist_name_font.draw_text(text, center_x, y + 410, ZOrder::TEXT, 1, 1, Gosu::Color::RED)
        if(cursor_hover?(x + 50, y + 400, x + 255, y + 440))
            draw_rectangle(x + 50, y + 400, x + 255, y + 440, THIRD_COLOR, ZOrder::CONTAINER)
            draw_line_horizontal(x + 62, y + 430, 175, 3, Gosu::Color::RED, ZOrder::CURRENT_HIGHLIGHT)
        end
    end
    # Draw Albums/Playlists/Generated Playlists Informations
    def draw_selected_album_or_playlist_info(info, x, y)
        album_or_playlist_x = @align_left_contents - 30
        album_or_playlist_y = y + 320
        if (@selected_page_name_font.text_width(info.title) < 375)
            center_x_name = center_text_horizontal(@selected_page_name_font, info.title, x + 303, 303)
            @selected_page_name_font.draw_text(info.title, center_x_name, album_or_playlist_y, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
        else
            cropped_texts = crop_text(@selected_page_name_font, info.title, 375)
            center_x_name = center_text_horizontal(@selected_page_name_font, cropped_texts, x + 303, 303)
            @selected_page_name_font.draw_text(cropped_texts, center_x_name, album_or_playlist_y, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
        end
        if(@selected_album_check == true)
            displayed_album_information = info.artist + " • " + info.genre + " • " + "#{info.total_tracks.to_s} Songs"
            center_x_information = center_text_horizontal(@selected_albums_information_font, displayed_album_information, x + 303, 303)
            @selected_albums_information_font.draw_text(displayed_album_information, center_x_information, y + 370, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
            center_x_year = center_text_horizontal(@albums_or_playlist_name_font, info.year, x + 303, 303)
            @albums_or_playlist_name_font.draw_text(info.year, center_x_year, y + 400, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
        elsif(@selected_playlist_check == true)
            # Draw rename box
            rename_text = "RENAME PLAYLIST"
            center_x = center_text_horizontal(@albums_or_playlist_name_font, rename_text, x + 303, 303)
            draw_rectangle(x + 50, y - 50, x + 255, y - 10, SECONDARY_COLOR, ZOrder::CONTAINER)
            @albums_or_playlist_name_font.draw_text(rename_text, center_x, y - 40, ZOrder::TEXT, 1, 1, Gosu::Color::RED)
            if(cursor_hover?(x + 50, y - 50, x + 255, y - 10))
                draw_rectangle(x + 50, y - 50, x + 255, y - 10, THIRD_COLOR, ZOrder::CONTAINER)
                draw_line_horizontal(x + 58, y - 20, 185, 3, Gosu::Color::RED, ZOrder::CURRENT_HIGHLIGHT)
            end
            if(@playlist_rename_typing == true)
                draw_rectangle(album_or_playlist_x, album_or_playlist_y - 5, album_or_playlist_x + 303, album_or_playlist_y + 40, PRIMARY_TEXT_COLOR, ZOrder::PLACEHOLDER)
                if(@rename_playlist_add_prompt == '')
                    @shortcut_font.draw_text("Name (< 16 chars)", album_or_playlist_x + 10, album_or_playlist_y + 5, ZOrder::PLACEHOLDER, 1, 1, SECONDARY_TEXT_COLOR)
                end
                @shortcut_font.draw_text(@rename_playlist_add_prompt, album_or_playlist_x + 10, album_or_playlist_y + 5, ZOrder::PROMPT, 1, 1, Gosu::Color::BLACK)
                if(@blinking_effect == true && @blinking_duration > 0 && @blinking_duration < 500 && @rename_playlist_add_prompt != " ")
                    @shortcut_font.draw_text("|", album_or_playlist_x + 10 + @shortcut_font.text_width(@rename_playlist_add_prompt), album_or_playlist_y + 3, ZOrder::PROMPT, 1, 1, Gosu::Color::BLACK)
                end
            end
            displayed_album_information = "#{info.total_tracks.to_s} Songs"
            center_x_information = center_text_horizontal(@selected_albums_information_font, displayed_album_information, x + 303, 303)
            @selected_albums_information_font.draw_text(displayed_album_information, center_x_information, y + 365, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
            draw_playlists_action(x, y, "DELETE PLAYLIST")
        elsif(@selected_generated_playlist_check == true)
            displayed_album_information = "#{info.total_tracks.to_s} Songs"
            center_x_information = center_text_horizontal(@selected_albums_information_font, displayed_album_information, x + 303, 303)
            @selected_albums_information_font.draw_text(displayed_album_information, center_x_information, y + 365, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
            draw_playlists_action(x, y, "SAVE to PLAYLIST")
        end
        if((info != @current_playing_album_or_playlist || (@song && !@song.playing?)) && info.total_tracks != 0)
            @play_album_icon.file.draw(x + 115, y + 475, ZOrder::ICON, 0.7, 0.7)
        elsif(info == @current_playing_album_or_playlist && @song && @song.playing? && info.total_tracks != 0)
            @pause_album_icon.file.draw(x + 115, y + 475, ZOrder::ICON, 0.7, 0.7)
        end
    end
    # Draw Track Name and Artist
    def draw_track(index, track, x, y, color)
        if(index < 9)
		    @paragraph_font.draw_text((index + 1).to_s + ". " + track.name, x + 2, y, ZOrder::DISPLAY, 1.0, 1.0, color)
		else
            @paragraph_font.draw_text((index + 1).to_s + ". " + track.name, x - 10, y, ZOrder::DISPLAY, 1.0, 1.0, color)
        end
        if(@audio_features_toggle_check == true && @selected_generated_playlist_index != nil)
            @artist_font.draw_text(track.features.popularity.to_s, x + 210, y + 30, ZOrder::DISPLAY, 1.0, 1.0, STATUS_TEXT_COLOR)
            @artist_font.draw_text(track.features.valence.to_s, x + 280, y + 30, ZOrder::DISPLAY, 1.0, 1.0, color)
            @artist_font.draw_text(track.features.energy.to_s, x + 345, y + 30, ZOrder::DISPLAY, 1.0, 1.0, color)
            @artist_font.draw_text(track.features.danceability.to_s, x + 400, y + 30, ZOrder::DISPLAY, 1.0, 1.0, color)
        end
        @artist_font.draw_text(track.artist, x + 27, y + 30, ZOrder::DISPLAY, 1.0, 1.0, SECONDARY_TEXT_COLOR)
        # duration_minutes_and_seconds = minute_calc(track.length) + ":" + seconds_calc(track.length)
		# @artist_font.draw_text(duration_minutes_and_seconds, x + 580, y + 10, ZOrder::DISPLAY, 1.0, 1.0, PRIMARY_TEXT_COLOR)
	end
    # Draw List of Tracks in Album/Playlist
    def draw_tracks(tracks_list, tracks_x, tracks_y)
        #Drawling Tracks Display Layout
        draw_rectangle(tracks_x - 20, tracks_y - 20, @main_display_width - 20, @main_display_height - 20, SECONDARY_COLOR, ZOrder::CONTAINER)
        draw_line_horizontal(@align_left_contents + 340, @margin_top + 85, 660, 2, PRIMARY_TEXT_COLOR, ZOrder::TEXT)
        current_page = @first_current_page_tracks_index / 8 + (tracks_list.total_tracks != 0 ? 1 : 0)
        maximum_page = (tracks_list.total_tracks - 1) / 8 + 1
        page = "Page #{current_page.to_s} / #{maximum_page.to_s}"
        @bar_font.draw_text(page, tracks_x, tracks_y - 4, ZOrder::TEXT, 1.0, 1.0, PRIMARY_TEXT_COLOR)
        if(@selected_generated_playlist_index != nil)
            if(@audio_features_toggle_check == false)
                @unchecked_box_icon.file.draw(tracks_x + 150, tracks_y - 5, ZOrder::ICON, 0.25, 0.25)
            else
                @checked_box_icon.file.draw(tracks_x + 150, tracks_y - 5, ZOrder::ICON, 0.25, 0.25)
                @bar_font.draw_text(@total_distance_generated_playlist[@selected_generated_playlist_index][0].to_s, tracks_x + 300, tracks_y - 5, ZOrder::TEXT, 1.1, 1.1, STATUS_TEXT_COLOR)
                @bar_font.draw_text("---->", tracks_x + 385, tracks_y - 5, ZOrder::TEXT, 1.1, 1.1, PRIMARY_TEXT_COLOR)
                @bar_font.draw_text(@total_distance_generated_playlist[@selected_generated_playlist_index][1].to_s, tracks_x + 450, tracks_y - 5, ZOrder::TEXT, 1.1, 1.1, STATUS_TEXT_COLOR)
            end
            @bar_font.draw_text("Visualize", tracks_x + 180, tracks_y - 5, ZOrder::TEXT, 1.1, 1.1, PRIMARY_TEXT_COLOR)
        end
        #Drawing Available Tracks
        @tracks_pos_y = Array.new()
        current_track_pos_y = tracks_y + 50
        current_tracks = tracks_list.tracks
        track_color = PRIMARY_TEXT_COLOR
        index = @first_current_page_tracks_index
        # The Maximum Tracks Per Page is 8
        @maximum_tracks_per_page = tracks_list.total_tracks - @first_current_page_tracks_index > 8 ? 8 : tracks_list.total_tracks - @first_current_page_tracks_index
		while (index < @first_current_page_tracks_index + @maximum_tracks_per_page)
            if (cursor_hover?(tracks_x - 20, current_track_pos_y - 15, tracks_x + 640, current_track_pos_y + 60))
                draw_rectangle(tracks_x - 20, current_track_pos_y - 15, tracks_x + 640, current_track_pos_y + 60, THIRD_COLOR, ZOrder::HIGHLIGHT)
                if((@selected_album_index != nil && tracks_list == @albums[@selected_album_index]) || (@selected_generated_playlist_index != nil && tracks_list == @generated_playlist[@selected_generated_playlist_index]))
                    @artist_font.draw_text("Add to Playlist", tracks_x + 500, current_track_pos_y + 30, ZOrder::DISPLAY, 1.0, 1.0, SECONDARY_TEXT_COLOR)
                    if(cursor_hover?(tracks_x + 500, current_track_pos_y + 30, tracks_x + 604, current_track_pos_y + 50))
                        draw_line_horizontal(tracks_x + 500, current_track_pos_y + 47, 104, 2, SECONDARY_TEXT_COLOR, ZOrder::DISPLAY)
                    end
                elsif(@selected_playlist_index != nil && tracks_list == @playlists[@selected_playlist_index])
                    @artist_font.draw_text("Delete Track", tracks_x + 505, current_track_pos_y + 30, ZOrder::DISPLAY, 1.0, 1.0, SECONDARY_TEXT_COLOR)
                    if(cursor_hover?(tracks_x + 505, current_track_pos_y + 30, tracks_x + 600, current_track_pos_y + 50))
                        draw_line_horizontal(tracks_x + 505, current_track_pos_y + 47, 93, 2, SECONDARY_TEXT_COLOR, ZOrder::DISPLAY)
                    end
                end
            end
			@tracks_pos_y << current_track_pos_y
            if (@song && current_tracks[index] == @current_track && ((@selected_album_index != nil && @current_playing_album_or_playlist == @albums[@selected_album_index]) ||  (@selected_playlist_index != nil && @current_playing_album_or_playlist == @playlists[@selected_playlist_index]) || (@selected_generated_playlist_index != nil && tracks_list == @generated_playlist[@selected_generated_playlist_index])))
                draw_rectangle(tracks_x - 20, current_track_pos_y - 15, tracks_x + 640, current_track_pos_y + 60, FOURTH_COLOR, ZOrder::CURRENT_HIGHLIGHT)
                track_color = STATUS_TEXT_COLOR
            else
                track_color = PRIMARY_TEXT_COLOR
            end
			draw_track(index, current_tracks[index], tracks_x, current_track_pos_y, track_color)
			current_track_pos_y += 75
			# Gosu.draw_rect(TrackLeftX - 10, @tracks_pos_y[index] + 55, 480, 2, Gosu::Color::WHITE, ZOrder::BACKGROUND_DISPLAY, mode=:default)
			index += 1
		end
        if (@maximum_tracks_per_page < tracks_list.total_tracks - @first_current_page_tracks_index)
            draw_lower_icon_box(@main_display_width - 62, tracks_y - 3, 0.25)
            if (cursor_hover?(@main_display_width - 65, tracks_y - 7, @main_display_width - 33, tracks_y + 24))
                draw_rectangle(@main_display_width - 65, tracks_y - 7, @main_display_width - 33, tracks_y + 24, FOURTH_COLOR, ZOrder::HIGHLIGHT)
            end
        end
        if (@first_current_page_tracks_index != 0)
            draw_upper_icon_box(@main_display_width - 102, tracks_y - 3, 0.25)
            if (cursor_hover?(@main_display_width - 105, tracks_y - 7, @main_display_width - 73, tracks_y + 24))
                draw_rectangle(@main_display_width - 105, tracks_y - 7, @main_display_width - 73, tracks_y + 24, FOURTH_COLOR, ZOrder::HIGHLIGHT)
            end
        end
	end
    # Draw Playlists Selection to Add Track to selected Playlists
    #Random Album Background Color each time the album is loaded
    def random_color_generated()
        red = rand(192)
        green = rand(96)
        blue = rand(128)
        return Gosu::Color.new(red, green, blue)
    end
    # Draw auto generated cover for album and playlist if there is no existed cover
    def draw_generated_thumbnail_selected_albums_and_playlists(name, x, y, scale)
        initial_width = 303
        initial_height = 303
        required_width = initial_width * scale
        required_height = initial_height * scale
        color = Gosu::Color.new(233, 20, 41)
        if(name == "Playlist")
            color = Gosu::Color.new(20, 138, 8)
        end
        draw_rectangle(x, y, x + required_width, y + required_height, color, ZOrder::DISPLAY)
        center_x = center_text_horizontal(@selected_album_auto_generated_font, name, x + required_width, required_width)
        @selected_album_auto_generated_font.draw_text(name, center_x, y + 127, ZOrder::TEXT, 1, 1, PRIMARY_TEXT_COLOR)
    end
    # Draw Albums/Playlists/Generated Playlists cover
    def selected_album_or_playlist_background_cover(x, y)
        draw_rect_gradient(x - 43, y - 60, x + 350, y + 595, @displayed_background_color_1, @displayed_background_color_2, ZOrder::CONTAINER)
    end
    # Draw page when an album is selected
    def selected_album_page()
        selected_album_cover_x = @align_left_contents - 30
        selected_album_cover_y = @margin_top + 90
        @selected_album = @albums[@selected_album_index]
        if (@albums[@selected_album_index].images != nil)
            # Draw available album cover
            album_thumbnail = ArtWork.new(@selected_album.images)
            draw_thumbnail(selected_album_cover_x, selected_album_cover_y, album_thumbnail, 1)
        else
            # Draw auto-generated album cover in case of non-existed cover
            draw_generated_thumbnail_selected_albums_and_playlists("Album", selected_album_cover_x, selected_album_cover_y, 1)
        end
        @close_icon.file.draw(selected_album_cover_x - 30, selected_album_cover_y - 45, ZOrder::ICON, 0.8, 0.8)
        selected_album_or_playlist_background_cover(selected_album_cover_x, selected_album_cover_y)
        draw_selected_album_or_playlist_info(@selected_album, selected_album_cover_x, selected_album_cover_y)
        draw_tracks(@selected_album, @selected_tracks_list_x, @selected_tracks_list_y)
    end
    #######################################
    ####--"Adding track to playlists"--####
    #######################################
    # Draw page when users click on "Adding track to playlists"
    def draw_playlists_for_adding_tracks(playlists_x, playlists_y)
        @select_playlist_to_add_y = Array.new()
        index = @first_current_page_adding_playlist_index
        while(index < @first_current_page_adding_playlist_index + @maximum_adding_playlists_per_page)
            @select_playlist_to_add_y << playlists_y
            if(@added_playlists_check[index] == false)
                @unchecked_box_icon.file.draw(playlists_x, playlists_y + 2, ZOrder::ICON, 0.2, 0.2)
                draw_rectangle(playlists_x - 10, playlists_y - 10, playlists_x + 740, playlists_y + 35, THIRD_COLOR, ZOrder::HIGHLIGHT)
                if(cursor_hover?(playlists_x - 10, playlists_y - 10, playlists_x + 740, playlists_y + 35))
                    draw_rectangle(playlists_x - 10, playlists_y - 10, playlists_x + 740, playlists_y + 35, FOURTH_COLOR, ZOrder::HIGHLIGHT)
                end
            else
                @checked_box_icon.file.draw(playlists_x, playlists_y + 2, ZOrder::ICON, 0.2, 0.2)
                draw_rectangle(playlists_x - 10, playlists_y - 10, playlists_x + 740, playlists_y + 35, FOURTH_COLOR, ZOrder::HIGHLIGHT)
            end
            @albums_or_playlist_name_font.draw_text("#{index + 1} - #{@playlists[index].title}", playlists_x + 30, playlists_y, ZOrder::TEXT, 1.2, 1.2, PRIMARY_TEXT_COLOR)
            if(@available_track_in_playlist[index] == true)
                @albums_or_playlist_name_font.draw_text("Already Existed", playlists_x + 500, playlists_y, ZOrder::TEXT, 1.2, 1.2, STATUS_TEXT_COLOR)
            end
            playlists_y += 60
            index += 1
        end
    end
    # Draw ADD and CANCEL button on "Adding track to playlists"
    def draw_confirm_and_cancel_button(button_x, button_y)
        color_1 = Gosu::Color.new(200, 20, 41)
        color_2 = Gosu::Color.new(20, 138, 8)
        # color[1] = Gosu::Color.new(225, 51, 0)
        # color[2] = Gosu::Color.new(20, 138, 8)
        # color[3] = Gosu::Color.new(45, 70, 185)
        action_text = "CANCEL"
        center_action_text = (button_x + 180 - (180 - @bar_font.text_width(action_text)) / 2 - @bar_font.text_width(action_text))
        @bar_font.draw_text(action_text, center_action_text, button_y + 25, ZOrder::TEXT, 1.1, 1.1, PRIMARY_TEXT_COLOR)
        draw_rectangle(button_x, button_y, button_x + 180, button_y + 70, color_1, ZOrder::DISPLAY)
        action_text = "ADD"
        center_action_text = (button_x + 200 + 180 - (180 - @bar_font.text_width(action_text)) / 2 - @bar_font.text_width(action_text))
        @bar_font.draw_text(action_text, center_action_text, button_y + 25, ZOrder::TEXT, 1.1, 1.1, PRIMARY_TEXT_COLOR)
        draw_rectangle(button_x + 200, button_y, button_x + 380, button_y + 70, color_2, ZOrder::DISPLAY)
    end
    # Draw page when users click on "Adding track to playlists"
    def add_track_to_playlist_page(tracks_list)
        page_color = Gosu::Color.rgba(0, 0, 0, 128)
        draw_rectangle(@margin_left, @margin_top, @main_display_width, @main_display_height, page_color, ZOrder::CONTAINER)
        draw_rectangle(@margin_left + 150, @margin_top + 50, @main_display_width - 150, @main_display_height - 50, SECONDARY_COLOR, ZOrder::CONTAINER)
        cropped_text = crop_text(@bar_font, tracks_list[@add_track_to_playlist_index].name, 300)
        @bar_font.draw_text("Adding \"#{cropped_text} - #{tracks_list[@add_track_to_playlist_index].artist}\" to playlists:", @margin_left + 190, @margin_top + 75, ZOrder::TEXT, 1.0, 1.0, PRIMARY_TEXT_COLOR)
        draw_line_horizontal(@margin_left + 180, @margin_top + 110, 750, 2, PRIMARY_TEXT_COLOR, ZOrder::TEXT)
        draw_playlists_for_adding_tracks(@margin_left + 190, @margin_top + 140)
        if (@maximum_adding_playlists_per_page < @playlists.length - @first_current_page_adding_playlist_index)
            draw_lower_icon_box(@main_display_width - 210, @main_display_height - 215, 0.25)
            draw_rectangle(@main_display_width - 215, @main_display_height - 220, @main_display_width - 180, @main_display_height - 185, THIRD_COLOR, ZOrder::HIGHLIGHT)
            if (cursor_hover?(@main_display_width - 215, @main_display_height - 220, @main_display_width - 180, @main_display_height - 185))
                draw_rectangle(@main_display_width - 215, @main_display_height - 220, @main_display_width - 180, @main_display_height - 185, FOURTH_COLOR, ZOrder::CURRENT_HIGHLIGHT)
            end
        end
        if (@first_current_page_adding_playlist_index != 0)
            draw_upper_icon_box(@main_display_width - 255, @main_display_height - 215, 0.25)
            draw_rectangle(@main_display_width - 260, @main_display_height - 220, @main_display_width - 225, @main_display_height - 185, THIRD_COLOR, ZOrder::HIGHLIGHT)
            if (cursor_hover?(@main_display_width - 260, @main_display_height - 220, @main_display_width - 225, @main_display_height - 185))
                draw_rectangle(@main_display_width - 260, @main_display_height - 220, @main_display_width - 225, @main_display_height - 185, FOURTH_COLOR, ZOrder::CURRENT_HIGHLIGHT)
            end
        end
        draw_confirm_and_cancel_button(@main_display_width - 560, @main_display_height - 145)
        draw_line_horizontal(@margin_left + 180, @main_display_height - 175, 750, 2, PRIMARY_TEXT_COLOR, ZOrder::TEXT)
    end
    ##########################################################
    ###--Drawing components that may be used in all pages--###
    # Draw naming box when the user is naming a new playlist before added the track inside it
    def draw_playlists_naming_box(box_x, box_y)
        draw_rectangle(box_x, box_y - 5, box_x + 303, box_y + 40, PRIMARY_TEXT_COLOR, ZOrder::PLACEHOLDER)
        if(@generated_playlist_add_prompt == '')
            @shortcut_font.draw_text("Name (< 16 chars)", box_x + 10, box_y + 5, ZOrder::PLACEHOLDER, 1, 1, SECONDARY_TEXT_COLOR)
        end
        @shortcut_font.draw_text(@generated_playlist_add_prompt, box_x + 10, box_y + 5, ZOrder::PROMPT, 1, 1, Gosu::Color::BLACK)
        if(@blinking_effect == true && @blinking_duration > 0 && @blinking_duration < 500 && @generated_playlist_add_prompt != " ")
            @shortcut_font.draw_text("|", box_x + 10 + @shortcut_font.text_width(@generated_playlist_add_prompt), box_y + 3, ZOrder::PROMPT, 1, 1, Gosu::Color::BLACK)
        end
    end
    # Draw page when an playlist is selected
    def selected_playlist_page(playlists, index)
        selected_playlist_cover_x = @align_left_contents - 30
        selected_playlist_cover_y = @margin_top + 90
        selected_playlist = playlists[index]
        @close_icon.file.draw(selected_playlist_cover_x - 30, selected_playlist_cover_y - 45, ZOrder::ICON, 0.8, 0.8)
        if(selected_playlist.cover != nil)
            playlist_thumbnail = ArtWork.new(selected_playlist.cover)
            draw_thumbnail(selected_playlist_cover_x, selected_playlist_cover_y, playlist_thumbnail, 1.2)
        else
            draw_generated_thumbnail_selected_albums_and_playlists("Playlist", selected_playlist_cover_x, selected_playlist_cover_y, 1)
        end
        selected_album_or_playlist_background_cover(selected_playlist_cover_x, selected_playlist_cover_y)
        draw_selected_album_or_playlist_info(selected_playlist, selected_playlist_cover_x, selected_playlist_cover_y)
        draw_tracks(selected_playlist, @selected_tracks_list_x, @selected_tracks_list_y)
        if(@playlists_add_name_typing == true)
            draw_playlists_naming_box(selected_playlist_cover_x, selected_playlist_cover_y + 320)
        end
    end
    # Draw notification box with text when there is a need of notification specify in the code
    def draw_notification_box()
        draw_rectangle(@margin_left + 17, height - @margin_top - @playback_height - 150, @margin_left + 410, height - @margin_top - @playback_height - 5, Gosu::Color::RED, ZOrder::PLACEHOLDER)
        draw_rectangle(@margin_left + 20, height - @margin_top - @playback_height - 147, @margin_left + 407, height - @margin_top - @playback_height - 8, FOURTH_COLOR, ZOrder::PROMPT)

        center_x = center_text_horizontal(@bar_font, @action_notification_1, @margin_left + 410, 383)
        @bar_font.draw_text(@action_notification_1, center_x, height - @margin_top - @playback_height - 110, ZOrder::PROMPT, 1, 1, Gosu::Color::RED)

        center_x = center_text_horizontal(@bar_font, @action_notification_2, @margin_left + 410, 383)
        @bar_font.draw_text(@action_notification_2, center_x, height - @margin_top - @playback_height - 80, ZOrder::PROMPT, 1, 1, Gosu::Color::RED)
        remaining_time = "(Automatically close in #{(5 - @notify_duration / 1000).round(0)})"

        center_x = center_text_horizontal(@notify_duration_font, remaining_time, @margin_left + 410, 383)
        @notify_duration_font.draw_text(remaining_time, center_x, height - @margin_top - @playback_height - 50, ZOrder::PROMPT, 1, 1, PRIMARY_TEXT_COLOR)
    end
    #####################################################################################################################
    #######-------------- Draw all pages depends on @current_player_page (music player page) ---------------------#######
    # Since currently playing albums/playlists/generated playlists can be accessed by clicking track current information, it can be drawed in all pages
    def draw_pages()
        case @current_player_page
        when 0
            if(@add_track_to_playlist_index != nil)
                add_track_to_playlist_page(@tracks_storage)
            else
                draw_search_page()
            end
        when 1
            if(@help_page_check == false)
                draw_home_page()
            else
                draw_help_page()
            end
        when 2
            if(@playlist_generation_option_check == false)
                draw_generation_page()
            end
        end

        if(@selected_playlist_check == true)
            selected_playlist_page(@playlists, @selected_playlist_index)
        end
        if(@selected_album_check == true)
            if(@add_track_to_playlist_index != nil)
                add_track_to_playlist_page(@selected_album.tracks)
            else
                selected_album_page()
            end
        end
        if(@selected_generated_playlist_check == true)
            if(@add_track_to_playlist_index != nil)
                add_track_to_playlist_page(@generated_playlist[@selected_generated_playlist_index].tracks)
            else
                selected_playlist_page(@generated_playlist, @selected_generated_playlist_index)
            end
        end
        if(@playlist_generation_option_check == true)
            draw_playlist_generation_option_page()
        end
        if(@action_notify_check == true)
            draw_notification_box()
        end
    end
    def draw
        draw_background()
        draw_layout()
        draw_pages()
    end
    ####################################################################################################################
    ####################################################################################################################
    ##########-----------------Start of Music Player Interaction Logic Manipulation---------------------################
    #Check if user want to change music player pages
    def music_player_pages_area(current_x, current_y)
        # Search Page
        if(current_x > @right_bar_x + 30 && current_x < @right_bar_x + 285 && current_y > @margin_top + 26 && current_y < @margin_top + 81)
            return 0
        elsif(current_x > @right_bar_x + 30 && current_x < @right_bar_x + 285 && current_y > @margin_top + 88 && current_y < @margin_top + 145)
            return 1
        elsif(current_x > @right_bar_x + 30 && current_x < @right_bar_x + 285 && current_y > @margin_top + 148 && current_y < @margin_top + 205)
            return 2
        end
        return nil
    end
    # Check if user want to search a track
    def check_search_bar_area(current_x, current_y)
        search_bar_x = @margin_left + 220
        search_bar_y = @margin_top + 20
        if(current_x > search_bar_x && current_x < search_bar_x + 675 && current_y > search_bar_y && current_y < search_bar_y + 48)
            return true
        end
        return false
    end
    # Check if user want to toggle Visual Similarity Display
    def similar_toggle_check_area(current_x, current_y)
        if(current_x >= @similar_toggle_position_x && current_x <= @similar_toggle_position_x + 315 && current_y >= @similar_toggle_position_y && current_y <= @similar_toggle_position_y + 25)
            return true
        end
        return false
    end
    # Check if user want to play a track in search page
    def search_tracks_area(current_x, current_y)
        index = 0
        while(index < @tracks_pos_y.length)
            if(current_x >= @top_track_results_position_x - 20 && current_x <= @top_track_results_position_x + 880 && current_y >= @tracks_pos_y[index] - 10 && current_y <= @tracks_pos_y[index] + 60)
                return index
            end
            index += 1
        end
        return nil
    end
    # Check if user want to add a track to a playlist in search page
    def search_track_to_add_to_playlist(current_x, current_y)
        index = 0
        while(index < @tracks_pos_y.length)
            if(current_x >= @top_track_results_position_x + 725 && current_x <= @top_track_results_position_x + 830 && current_y >= @tracks_pos_y[index] + 30 && current_y <= @tracks_pos_y[index] + 45)
                return index
            end
            index += 1
        end
        return nil
    end
    #Check for each category item area
    def check_category_item_area(x, y, check_x, check_y)
        if (x > check_x - 20 && x < check_x + 200 && y > check_y + 50 && y < check_y + 190)
            return true
        end
        return false
    end
    # Output: Index of genres/artist/decades areas
    def selected_required_items_category_area(current_x, current_y)
        first_item_x = @align_left_contents
        item_y = @margin_top
        index = @first_category_page_index
        # Display albums cover with title
        while (index < @first_category_page_index + @maximum_items_per_category_page)
            if (check_category_item_area(current_x, current_y, first_item_x, item_y))
                return index
            end
            first_item_x += 250
            index += 1
        end
    end
    # Check if user click on close button
    def close_button_categories_area(current_x, current_y)
        close_button_x = @align_left_contents - 60
        close_button_y = @margin_top + 50
        if(current_x > close_button_x && current_x < close_button_x + 33 && current_y > close_button_y && current_y < close_button_y + 33)
            return true
        end
        return false
    end
    # Check if user want to change page of categories
    def previous_and_next_category_page(current_x, current_y)
        previous_icon_position_x = @align_left_contents - 50
        previous_icon_position_y = @margin_top + 100 + 10
        next_icon_position_x = @align_left_contents + 250 * 4 - 30
        next_icon_position_y = previous_icon_position_y
        if (current_x > previous_icon_position_x - 10 && current_x < previous_icon_position_x + 20 && current_y > previous_icon_position_y - 10 && current_y < previous_icon_position_y + 35)
            return 1
        elsif (current_x > next_icon_position_x - 10 && current_x < next_icon_position_x + 20 && current_y > next_icon_position_y - 10 && current_y < next_icon_position_y + 35)
            return 2
        end
    end
    # Check four categories Areas
    def check_category_area(x, y, check_x, check_y)
        if (x >= check_x && x <= check_x + 220 && y >= check_y && y <= check_y + 140)
            return true
        end
        return false
    end
    # Output: Index of selected category
    def selected_categories_areas(current_x, current_y)
        first_categories_x = @align_left_contents - 20
        categories_y = @margin_top + 50
        index = 0
        while (index < 4)
            if (check_category_area(current_x, current_y, first_categories_x, categories_y))
                return index
            end
            first_categories_x += 250
            index += 1
        end
        return nil
    end
    # Check if user has clicked on help button
    def help_icon_area(current_x, current_y)
        if(current_x >= @margin_left + 20 && current_x <= @margin_left + 60 && current_y >= @margin_album_top - 100 && current_y <= @margin_album_top - 60)
            return true
        end
        return false
    end
    #Close help page area
    def close_help_page_area(current_x, current_y)
        if(current_x >= @help_page_close_x && current_x <= @help_page_close_x + 30 && current_y >= @help_page_close_y && current_y <= @help_page_close_y + 30)
            return true
        end
        return false
    end
    # Check Previous/Next Button in Display Albums page
    def previous_and_next_album_page(current_x, current_y)
        # Next Icon Clicking Area
        next_icon_area_position_x = @align_left_contents + 250 * 4 - 85
        next_icon_area_position_y = @margin_album_top - 90
        # Previous Icon Clicking Area
        previous_icon_area_position_x = next_icon_area_position_x - 50
        previous_icon_area_position_y = next_icon_area_position_y
        # Checking Areas
        if (current_x > previous_icon_area_position_x - 10 && current_x < previous_icon_area_position_x + 35 && current_y > previous_icon_area_position_y - 10 && current_y < previous_icon_area_position_y + 35)
            return 1
        elsif (current_x > next_icon_area_position_x  - 10 && current_x < next_icon_area_position_x + 35 && current_y > next_icon_area_position_y - 10 && current_y < next_icon_area_position_y + 35)
            return 2
        end
        return nil
    end
    # Check an album area
    def checked_album_area(x, y, x_check, y_check)
        if (x >= x_check && x <= x_check + 220 && y >= y_check && y <= y_check + 320)
            return true
        end
        return false
    end
    # Output: Index of selected album
    def selected_albums_area(current_x, current_y)
        first_album_area_x = @align_left_contents
        index = @first_current_page_album_index
        # albums area per page to check
        while (index < @first_current_page_album_index + @maximum_albums_per_page)
            if (checked_album_area(current_x, current_y, first_album_area_x - 20, @margin_album_top - 20))
                return index
            end
            first_album_area_x += 250
            index += 1
        end
        return nil
    end
    # Check the Play Button Area when selecting albums
    def selected_playing_albums_area(current_x, current_y)
        play_position_x = @align_left_contents + 60
        play_position_y = @margin_album_top + 60
        index = @first_current_page_album_index
        while (index <= @first_current_page_album_index + @maximum_albums_per_page)
            if (current_x > play_position_x && current_x < play_position_x + 60 && current_y > play_position_y && current_y < play_position_y + 60)
                return true
            end
            play_position_x += 250
            index += 1
        end
        return false
    end
    # Check a playlist area for selected_playlists_area function
    def check_playlist_area(x, y, check_x, check_y)
        if(x >= check_x - 10 && x <= check_x + 270 && y >= check_y - 10 && y <= check_y + 50)
            return true
        end
        return false
    end
    #Output: Index of selected playlists
    def selected_playlists_area(current_x, current_y)
        playlists_x =  @right_bar_x + 30
        index = 0
        while(index < @playlists_index_y.length)
            if(check_playlist_area(current_x, current_y, playlists_x, @playlists_index_y[index]))
                return index + @first_current_page_playlist_index
            end
            index += 1
        end
        return nil
    end
    # Check if users want to see the next or previous page of displayed playlists
    def next_and_previous_page_displayed_playlists(current_x, current_y)
            change_page_button_x = width - @margin_right - 50
            change_page_button_y = @main_display_height - 40
            #Next Page Button
            if(current_x >= change_page_button_x - 5 && current_x <= change_page_button_x + 30 && current_y >= change_page_button_y - 5 && current_y <= change_page_button_y + 30)
                return 1
            #Previous Page Button
            elsif (current_x >= change_page_button_x - 45 && current_x <= change_page_button_x - 10 && current_y >= change_page_button_y - 5 && current_y <= change_page_button_y + 30)
                return 2
            end
        return nil
    end
    # Check the Play Button Area when the users are in the selected albums/playlists page
    def playing_selected_page_area(current_x, current_y)
        play_position_x = @align_left_contents + 85
        play_position_y = @margin_top + 565
        if (current_x >= play_position_x && current_x <= play_position_x + 70 && current_y >= play_position_y && current_y <= play_position_y + 70)
            return true
        end
        return false
    end
    # This is to check if the users want to add the song to the playlist
    def album_track_to_add_to_playlist(current_x, current_y)
        index = 0
        tracks_index_y = @tracks_pos_y
		while (index < tracks_index_y.length)
            if(current_x >= @selected_tracks_list_x + 500 && current_x <= @selected_tracks_list_x + 604 && current_y >= tracks_index_y[index] + 30 && current_y <= tracks_index_y[index] + 50)
                return index + @first_current_page_tracks_index
			end
			index += 1
		end
        return nil
    end
    # Return the index of the playlist that user want to add the track to
    def add_track_to_playlist_area(current_x, current_y)
        playlists_x = @margin_left + 190
        playlists_y = @select_playlist_to_add_y
        index = 0
        while(index < playlists_y.length)
            if(current_x >= playlists_x - 10 && current_x <= playlists_x + 740 && current_y >= playlists_y[index] - 10 && current_y <= playlists_y[index] + 35)
                return index + @first_current_page_adding_playlist_index
            end
            index += 1
        end
        return nil
    end
    # Change page area in the "Add Track To Playlist" page
    def change_page_add_track_to_playlist(current_x, current_y)
        next_page_position_x = @main_display_width - 260
        previous_page_position_x = @main_display_width - 215
        next_page_position_y = @main_display_height - 220
        previous_page_position_y = next_page_position_y
        if(current_x >= next_page_position_x && current_x <= next_page_position_x + 35 && current_y >= next_page_position_y && current_y <= next_page_position_y + 35)
            return 1
        elsif(current_x >= previous_page_position_x && current_x <= previous_page_position_x + 35 && current_y >= previous_page_position_y && current_y <= previous_page_position_y + 35)
            return 2
        end
        return nil
    end
    # This is to check for the areas of CANCEL and ADD button in add to playlist page
    def cancel_and_add_playlist_area(current_x, current_y)
        button_x = @main_display_width - 560
        button_y = @main_display_height - 145
        if(current_x >= button_x && current_x <= button_x + 180 && current_y >= button_y && current_y <= button_y + 70)
            return 1
        elsif (current_x >= button_x + 200 && current_x <= button_x + 380 && current_y >= button_y && current_y <= button_y + 70 )
            return 2
        end
        return nil
    end
    # Output: Index of selected track
    def tracks_area(current_x, current_y)
		index = 0
        tracks_index_y = @tracks_pos_y
		while (index < tracks_index_y.length)
			if (current_x >= @selected_tracks_list_x - 20 && current_x <= @selected_tracks_list_x + 640 && current_y >= tracks_index_y[index] - 15 && current_y <= tracks_index_y[index] + 60)
				return index + @first_current_page_tracks_index
			end
			index += 1
		end
		return nil
	end
    # Check Previous/Next Button for tracks in Selected Albums page
    def previous_and_next_tracks_page(current_x, current_y)
        # Previous Icon Clicking Area
        previous_icon_area_position_x = @main_display_width - 105
        previous_icon_area_position_y = @margin_top + 43
        # Next Icon Clicking Area
        next_icon_area_position_x = @main_display_width - 65
        next_icon_area_position_y = @margin_top + 43
        if (current_x > previous_icon_area_position_x && current_x < previous_icon_area_position_x + 32 && current_y > previous_icon_area_position_y && current_y < previous_icon_area_position_y + 32)
            return 1
        elsif (current_x > next_icon_area_position_x && current_x < next_icon_area_position_x + 32 && current_y > next_icon_area_position_y && current_y < next_icon_area_position_y + 32)
            return 2
        end
        return nil
    end
    # Check for the index of each scrubber objects
    def scrubber_area(current_x, current_y)
        center = width / 2 - 20
        scrubber_icon_space = 80
        #Play Button Area
        if (current_x > center && current_x < center + 40 && current_y > @main_display_height + 45 && current_y < @main_display_height + 85)
            return 1
        #Skip Button Area
        elsif (current_x > center + scrubber_icon_space - 2 && current_x < center + scrubber_icon_space - 2 + 40 && current_y > @main_display_height + 52 && current_y < @main_display_height + 92)
            return 2
        #Previous Button Area
        elsif (current_x > center - scrubber_icon_space + 22 && current_x < center - scrubber_icon_space + 22 + 40 && current_y > @main_display_height + 52 && current_y < @main_display_height + 92)
            return 3
        #Shuffle Button Area
        elsif (current_x > center - scrubber_icon_space * 2 + 36 && current_x < center - scrubber_icon_space * 2 + 36 + 40 && current_y > @main_display_height + 52 && current_y < @main_display_height + 92)
            return 4
            #Loop Button Area
        elsif (current_x > center + scrubber_icon_space * 2 - 17 && current_x < center + scrubber_icon_space * 2 - 17 + 40 && current_y > @main_display_height + 52 && current_y < @main_display_height + 92)
            return 5
        end
        return nil
    end
    # Check for volume up and down areas
    def volume_area(current_x, current_y)
        if(current_x >= width - 220 && current_x <= width - 195 && current_y >= @main_display_height + 39 && current_y <= @main_display_height + 60)
            return 1
        elsif(current_x >= width - 60 && current_x <= width - 35 && current_y >= @main_display_height + 39 && current_y <= @main_display_height + 60)
            return 2
        end
        return nil
    end
    # The page is closed if the users click on Close Button
    def close_button_tracks_area(current_x, current_y)
        close_button_x = @align_left_contents - 60
        close_button_y = @margin_top + 45
        if (current_x > close_button_x && current_x < close_button_x + 32 && current_y > close_button_y && current_y < close_button_y + 32)
            return true
        end
        return false
    end
    # The prompt bar appears when the user click on "+" button
    def playlists_add_area(current_x, current_y)
        add_icon_x = @right_bar_x + 280
        add_icon_y = height / 14 * 4 + 26
        if (current_x > add_icon_x - 5 && current_x < add_icon_x + 20 && current_y > add_icon_y - 5 && current_y < add_icon_y + 26)
            return true
        end
        return false
    end
    # Area check for user if clicks on delete/add to playlist button
    def action_playlist_area(current_x, current_y)
        action_playlist_x = @align_left_contents - 30
        action_playlist_y = @margin_top + 90
        if(current_x >= action_playlist_x + 50 && current_x <= action_playlist_x + 255 && current_y >= action_playlist_y + 400 && current_y <= action_playlist_y + 440)
            return true
        end
        return false
    end
    # Area check for user if clicks on rename playlist button
    def rename_playlist_area(current_x, current_y)
        rename_playlist_x = @align_left_contents - 30
        rename_playlist_y = @margin_top + 90
        if(current_x >= rename_playlist_x + 50 && current_x <= rename_playlist_x + 255 && current_y >= rename_playlist_y - 50 && current_y <= rename_playlist_y - 10)
            return true
        end
        return false
    end
    # Returns index of track that user want to delete
    def track_to_delete_playlist(current_x, current_y)
        index = 0
        tracks_index_y = @tracks_pos_y
		while (index < tracks_index_y.length)
            if(current_x > @selected_tracks_list_x + 505 && current_x < @selected_tracks_list_x + 600 && current_y > tracks_index_y[index] + 30 && current_y < tracks_index_y[index] + 50)
                return index + @first_current_page_tracks_index
			end
			index += 1
		end
        return nil
    end
    # Returns index of generated playlists
    def selected_generated_playlist_area(current_x, current_y)
        box_x = @generated_playlists_x
        box_y = @margin_top + 100
        index = 0
        while(index < @generated_playlists_x.length)
            if(current_x >= box_x[index] - 15 && current_x <= box_x[index] + 175 && current_y >= box_y - 20 && current_y <= box_y + 245)
                return index
            end
            index += 1
        end
        box_x = @personalized_playlists_x
        box_y = @margin_top + 440
        while(index < @generated_playlists_x.length + @personalized_playlists_x.length)
            if(current_x >= box_x[index - @generated_playlists_x.length] - 15 && current_x <= box_x[index - @generated_playlists_x.length] + 175 && current_y >= box_y - 20 && current_y <= box_y + 245)
                return index
            end
            index += 1
        end
        return nil
    end
    # Check if user want to generate personalized playist
    def personalized_playlist_generation_area(current_x, current_y)
        button_x = @align_left_contents + 585
        button_y = @margin_top + 425
        color_0 = Gosu::Color.new(45, 70, 185)
        if(current_x >= button_x && current_x <= button_x + 125 && current_y >= button_y && current_y <= button_y + 50)
            return true
        end
        return false
    end
    # Check if user want to choose their personal option for playlist generation
    def playlist_generation_option_area(current_x, current_y)
        button_x = @align_left_contents + 585 + 150
        button_y = @margin_top + 425
        if(current_x >= button_x && current_x <= button_x + 115 && current_y >= button_y && current_y <= button_y + 50)
            return true
        end
        return false
    end
    # Check if user want to select auto playlist generation
    def auto_playlist_generation_area(current_x, current_y)
        auto_button_x = @margin_left + 425
        auto_button_y = @margin_top + 70
        if (current_x >= auto_button_x && current_x <= auto_button_x + 80 && current_y >= auto_button_y && current_y <= auto_button_y + 50)
            return true
        end
        return false
    end
    # Check if user want to select custom playlist generation
    def custom_playlist_generation_area(current_x, current_y)
        custom_button_x = @margin_left + 525
        custom_button_y = @margin_top + 70
        if (current_x >= custom_button_x && current_x <= custom_button_x + 112 && current_y >= custom_button_y && current_y <= custom_button_y + 50)
            return true
        end
        return false
    end
    # Check if user want to cancel playlist generation option
    def cancel_playlist_generation_area(current_x, current_y)
        cancel_button_x = @margin_left + 775
        cancel_button_y = @margin_top + 70
        if(current_x >= cancel_button_x && current_x <= cancel_button_x + 102 && current_y >= cancel_button_y && current_y <= cancel_button_y + 50)
            return true
        end
        return false
    end
    # Check if user want to confirm playlist generation option
    def confirm_playlist_generation_option_area(current_x, current_y)
        confirm_button_x = @margin_left + 895
        confirm_button_y = @margin_top + 70
        if(current_x >= confirm_button_x && current_x <= confirm_button_x + 112 && current_y >= confirm_button_y && current_y <= confirm_button_y + 50)
            return true
        end
        return false
    end
    # Check if user want to select an option in the custom playlist generation options
    def custom_option_playlist_generation_area(current_x, current_y)
        index = 0
        while(index < @options_position_array.length)
            option_x = @options_position_array[index][2]
            option_y = @options_position_array[index][3]
            if(current_x >= option_x && current_x <= option_x + 150 && current_y >= option_y && current_y <= option_y + 50)
                return [@options_position_array[index][0], @options_position_array[index][1]]
            end
            index += 1
        end
        return nil
    end
    # Check if user want to visualize audio features of smooth-transition list
    def visualize_audio_features_toggle_area(current_x, current_y)
        visualize_box_x = @selected_tracks_list_x
        visualize_box_y = @selected_tracks_list_y
        if(current_x >= visualize_box_x + 150 && current_x <= visualize_box_x + 175 && current_y >= visualize_box_y - 5 && current_y <= visualize_box_y + 20)
            return true
        end
        return false
        if(@audio_features_toggle_check == false)
            @unchecked_box_icon.file.draw(tracks_x + 150, tracks_y - 5, ZOrder::ICON, 0.25, 0.25)
        else
            @checked_box_icon.file.draw(tracks_x + 150, tracks_y - 5, ZOrder::ICON, 0.25, 0.25)
        end
    end
    # Check if user want to access current albums/playlist
    def albums_or_playlist_current_information_area(current_x, current_y)
        current_information_x = @margin_left + 10
        current_information_y = @main_display_height + 15
        if(current_x > current_information_x && current_x < current_information_x + 480 && current_y > current_information_y && current_y < current_information_y + 70)
            return true
        end
        return false
    end
    # Interactions in Albums/Playlists Page that display tracks
    def tracks_in_albums_or_playlists_page(type, list, selected_index)
        playing_area_check = playing_selected_page_area(mouse_x, mouse_y)
        # Toggle between Play and Pause state
        if (list[selected_index] == @current_playing_album_or_playlist)
            if(@song && playing_selected_page_area(mouse_x, mouse_y))
                if(@song.playing?)
                    @song.pause
                else
                    @song.play
                end
            end
        end
        #The Album is play when the users click on the play button (in the Selected Page)
        if (playing_area_check == true && (@current_playing_album_or_playlist == nil || (@current_playing_album_or_playlist != list[selected_index])) && list[selected_index].total_tracks != 0)
            @current_track_index = 0
            @current_track_array_index = 0
            @selected_track_index_array = Array.new()
            @shuffle_check = false
            @loop_check = false
            index = 0
            while(index < list[selected_index].total_tracks)
                @selected_track_index_array << index
                index += 1
            end
            @current_playing_album_or_playlist = list[selected_index]
            @current_track = @current_playing_album_or_playlist.tracks[@current_track_index]
            copy_track = @current_track.clone
            recalculate_preferences_counting(copy_track, 0.25) # Playing tracks by playing an album will make up a score of 0.25 preferences
            if (type == "Album")
                @current_playing_album = true
                @current_playing_playlist = false
                @current_playing_generated_playlist = false
            elsif (type == "Playlist")
                @current_playing_album = false
                @current_playing_playlist = true
                @current_playing_generated_playlist = false
            elsif (type == "Generated Playlist")
                @current_playing_album = false
                @current_playing_playlist = false
                @current_playing_generated_playlist = true
            end
            @current_song_seconds = 0
            @pause_time = 0
            @last_update_time = Gosu.milliseconds
            playTrack(@current_track)
        end
        #-----------------------------------------
        # Selecting Tracks Area to play in Selected Album Page
        selected_track_areas = tracks_area(mouse_x, mouse_y)
        if (selected_track_areas != nil)
            @current_track_index = selected_track_areas
            @current_track_array_index = @current_track_index
            @shuffle_check = false
            @loop_check = false
            @selected_track_index_array = Array.new()
            index = 0
            while(index < list[selected_index].total_tracks)
                @selected_track_index_array << index
                index += 1
            end
            @current_playing_album_or_playlist = list[selected_index]
            @current_track = @current_playing_album_or_playlist.tracks[@current_track_index]
            copy_track = @current_track.clone
            recalculate_preferences_counting(copy_track, 0.5) # Directly clicking a track will make up a score of 0.5 preferences
            if (type == "Album")
                @current_playing_album = true
                @current_playing_playlist = false
                @current_playing_generated_playlist = false
            elsif (type == "Playlist")
                @current_playing_album = false
                @current_playing_playlist = true
                @current_playing_generated_playlist = false
            elsif (type == "Generated Playlist")
                @current_playing_album = false
                @current_playing_playlist = false
                @current_playing_generated_playlist = true
            end
            @current_song_seconds = 0
            @pause_time = 0
            @last_update_time = Gosu.milliseconds
            playTrack(@current_track)
        end
        #-----------------------------------------
        # The page is closed if the users click on Close Button
        if (close_button_tracks_area(mouse_x, mouse_y))
            if (type == "Album")
                @selected_album_check = false
            elsif (type == "Playlist")
                @selected_playlist_check = false
            elsif (type == "Generated Playlist")
                @selected_generated_playlist_check = false
            end
            selected_index = nil
            @first_current_page_tracks_index = 0
            playing_area_check = false
            @current_category_page = 0
            @first_category_page_index = 0
            @playlists_add_name_typing = false
            @generated_playlist_add_prompt = ""
        end
        case previous_and_next_tracks_page(mouse_x, mouse_y)
        when 1
            if (@first_current_page_tracks_index != 0)
                @first_current_page_tracks_index -= 8
                @maximum_tracks_per_page = 8
            end
        when 2
            if (@first_current_page_tracks_index + @maximum_tracks_per_page < list[selected_index].total_tracks)
                @first_current_page_tracks_index += 8
                @maximum_tracks_per_page = list[selected_index].total_tracks - @first_current_page_tracks_index > 8 ? 8 : list[selected_index].total_tracks - @first_current_page_tracks_index
            end
        end
    end
    # Add track to playlist depends on where it is being added from (albums & generated playlist or search page)
    def add_track_to_playlist_sub(tracks_list, tracks_list_type)
        if(@add_track_to_playlist_index == nil)
            if(tracks_list_type == "List")
                @add_track_to_playlist_index = album_track_to_add_to_playlist(mouse_x, mouse_y)
            elsif(tracks_list_type == "Search")
                selected_track_index = search_track_to_add_to_playlist(mouse_x, mouse_y)
                if(selected_track_index != nil)
                    @add_track_to_playlist_index = @found_similar_tracks[selected_track_index][0]
                end
            end
            @maximum_adding_playlists_per_page = @playlists.length - @first_current_page_adding_playlist_index > 6 ? 6 : @playlists.length - @first_current_page_adding_playlist_index
            if(@add_track_to_playlist_index != nil)
                @available_track_in_playlist = Array.new(@playlists.length(), false)
                index = 0
                while(index < @playlists.length)
                    @playlists[index].tracks.each do |track|
                        if(track.location == tracks_list[@add_track_to_playlist_index].location)
                            @available_track_in_playlist[index] = true
                        end
                    end
                    index += 1
                end
            end
        else
            if(add_track_to_playlist_area(mouse_x, mouse_y) != nil)
                if(!@available_track_in_playlist[add_track_to_playlist_area(mouse_x, mouse_y)])
                    if(@added_playlists_check[add_track_to_playlist_area(mouse_x, mouse_y)] != true)
                        @added_playlists_check[add_track_to_playlist_area(mouse_x, mouse_y)] = true
                    else
                        @added_playlists_check[add_track_to_playlist_area(mouse_x, mouse_y)] = false
                    end
                end
            end
        end
    end
    # Add track to selected playlist interaction in add tracks to playlist page
    def adding_track_to_playlist_page_func(adding_track)
        #Changing pages in "add tracks to playlist" page
        case change_page_add_track_to_playlist(mouse_x, mouse_y)
        when 1
            if (@first_current_page_adding_playlist_index != 0)
                @first_current_page_adding_playlist_index -= 6
                @maximum_adding_playlists_per_page = 6
            end
        when 2
            if (@first_current_page_adding_playlist_index + @maximum_adding_playlists_per_page < @playlists.length)
                @first_current_page_adding_playlist_index += 6
                @maximum_adding_playlists_per_page = @playlists.length - @first_current_page_adding_playlist_index > 6 ? 6 : @playlists.length - @first_current_page_adding_playlist_index
            end
        end
        #This will cancel or add the tracks to the selected playlists
        case cancel_and_add_playlist_area(mouse_x, mouse_y)
        when 1
            @add_track_to_playlist_index = nil
            @first_current_page_adding_playlist_index = 0
            @maximum_adding_playlists_per_page = @playlists.length - @first_current_page_adding_playlist_index > 6 ? 6 : @playlists.length - @first_current_page_adding_playlist_index
            @added_playlists_check = Array.new(@playlists.length, false)
        when 2
            index = 0
            add_playlists_amount_check = 0
            while(index < @playlists.length)
                if(@added_playlists_check[index] == true)
                    recalculate_preferences_counting(adding_track, 0.5) # Adding track to each playlist has the score of 0.5 preference
                    @playlists = add_song_to_playlist(@playlists, index, adding_track)
                    add_playlists_amount_check += 1
                end
                index += 1
            end
            temp_string = ""
            index = 0
            count_text = 0
            while(index < @added_playlists_check.length)
                if(@added_playlists_check[index] == true)
                    temp_string += "#" + (index + 1).to_s.chomp()
                    if(count_text == 5)
                        temp_string += "..."
                        break
                    end
                    if (count_text < add_playlists_amount_check - 1)
                        temp_string += ", "
                    else
                        temp_string += "."
                    end
                    count_text += 1
                end
                index += 1
            end
            cropped_text = crop_text(@bar_font, adding_track.name, 300)
            @action_notification_1 = "Add \"#{cropped_text}\""
            @action_notification_2 = "To Playlists #{temp_string}"
            if(@current_playing_playlist == true)
                @shuffle_check = false
                @loop_check = false
                if(@song)
                    shuffle_list(@shuffle_check)
                end
            end
            @action_notify_check = true
            @notify_duration = 0
            @first_current_page_adding_playlist_index = 0
            @maximum_adding_playlists_per_page = @playlists.length - @first_current_page_adding_playlist_index > 6 ? 6 : @playlists.length - @first_current_page_adding_playlist_index
            @add_track_to_playlist_index = nil
            @added_playlists_check = Array.new(@playlists.length, false)
            playlists_file_create_and_modify(@playlists)
        end
    end
    # Recalculating history preferences for auto playlist generation by accessing the file and modify it
    def recalculate_preferences_counting(track, score)
        # Initialize options since there have been interaction
        if (Dir.glob(INTERACTION_HISTORY_FILE_NAME).any? == false)
            ######################
            ## The last 3 mixes is based on users interaction history / custom choices
            @playlist_generation_option_check = false
            @custom_playlist_generation_check = false
            @previous_custom_playlist_generation_check = @custom_playlist_generation_check
            @custom_playlist_generation_options = [[nil], [nil], [false, false, false], [false, false, false], [false, false, false]]
            @previous_custom_playlist_generation_options = @custom_playlist_generation_options.clone
            @generated_playlist_add_prompt = ""
            # Intialize Preferences Array for User Interaction Tracking and Calculation
            preferences_array = calculate_user_interactions_history_from_files(@artists_storage, @genres_storage, @decades_storage, @tracks_storage)
            @artist_preferences = preferences_array[0].clone
            @genres_preferences = preferences_array[1].clone
            @decades_preferences = preferences_array[2].clone
            # Audio Features Array User Interaction Counting: 0, 0.05, 0.1, 0.15, ... , 1 for Acousticness, Valence, Energy and Danceability
            @acousticness_preferences = preferences_array[3].clone
            @valence_preferences = preferences_array[4].clone
            @energy_preferences = preferences_array[5].clone
            @danceability_preferences = preferences_array[6].clone
            # Audio Features Array User Interaction Counting: 0, 0.02, 0.04, 0.06, ... , 0.4 for Speechiness
            @speechiness_prefererences = preferences_array[7].clone
            # Audio Features Array User Interaction Counting: 0, 10, 20, 30, ... , 200 for Tempo
            @tempo_preferences = preferences_array[8].clone
        end
        creating_and_modify_user_interaction_history_file(track.location, score)
        preferences = calculate_user_interactions_history_from_files(@artists_storage, @genres_storage, @decades_storage, @tracks_storage)
        @artist_preferences = preferences[0].clone
        @genres_preferences = preferences[1].clone
        @decades_preferences = preferences[2].clone
        @acousticness_preferences = preferences[3].clone
        @valence_preferences = preferences[4].clone
        @energy_preferences = preferences[5].clone
        @danceability_preferences = preferences[6].clone
        @speechiness_prefererences = preferences[7].clone
        @tempo_preferences = preferences[8].clone
    end
    # Returns lowercase or uppercase letter when user press SHIFT when entering
    def input_char(id, prompt, max_char_limit)
        # Check if it's an uppercase letter
        if(prompt.length < max_char_limit)
            if Gosu.button_down?(Gosu::KB_LEFT_SHIFT) || Gosu.button_down?(Gosu::KB_RIGHT_SHIFT)
                # This will results in the ASCII value of the capital letter
                capital_letter = (id - Gosu::KB_A + 'A'.ord).chr
                prompt += capital_letter
            else
                prompt += Gosu.button_id_to_char(id)
            end
        end
        return prompt
    end
    # Returns special sign when user press SHIFT when entering
    def input_special_sign(id, prompt, max_char_limit)
        #Hash Map for Sign when pressing SHIFT
        key_to_char = {
            Gosu::KB_1 => "!",
            Gosu::KB_2 => "@",
            Gosu::KB_3 => "#",
            Gosu::KB_4 => "$",
            Gosu::KB_5 => "%",
            Gosu::KB_6 => "^",
            Gosu::KB_7 => "&",
            Gosu::KB_8 => "*",
            Gosu::KB_9 => "(",
            Gosu::KB_0 => ")",
            Gosu::KB_SLASH  => "?",
            Gosu::KB_COMMA  => "<",
            Gosu::KB_PERIOD  => ">",
            Gosu::KB_SEMICOLON  => ":",
            Gosu::KB_BACKTICK  => "~"
        }
        if(prompt.length < max_char_limit)
            if key_to_char.key?(id) && (Gosu.button_down?(Gosu::KB_LEFT_SHIFT) || Gosu.button_down?(Gosu::KB_RIGHT_SHIFT))
                prompt += key_to_char[id]
            else
                prompt += Gosu.button_id_to_char(id)
            end
        end
        return prompt
    end
    # Returns playlists name and interaction logics based on type of input (Name of Playlist when adding, Name of Playlist when renaming, Name of Playlist when Save to Playlist in Generation Playlist)
    def playlists_name_input(id, status, prompt, add_tracks, rename, rename_index, original_name)
        # This will handle users input for playlist name
        if (status == true)
            #Set a limti for the number of input characters
            max_char_limit = 16
            case id
            when Gosu::KB_BACKSPACE
                if(@backspace_pressed == false)
                    prompt.chop!
                    @backspace_pressed = true
                    @backspace_duration = 0
                end
            when Gosu::KB_ESCAPE
                prompt = ''
                status = false
            when Gosu::KB_RETURN
                if(rename == false)
                    if (prompt != '')
                        @playlists = add_playlist(@playlists, prompt)
                        @action_notification_1 = "Add \"#{prompt}\""
                        @action_notification_2 = "As a Playlist"
                        @action_notify_check = true
                        @notify_duration = 0
                        prompt = ''
                        playlists_file_create_and_modify(@playlists)
                        @first_current_page_playlist_index = ((@playlists.length() - 1) / 6) * 6
                        @maximum_playlists_per_page = @playlists.length - @first_current_page_playlist_index > 6 ? 6 : @playlists.length - @first_current_page_playlist_index
                        @maximum_adding_playlists_per_page = @playlists.length - @first_current_page_adding_playlist_index > 6 ? 6 : @playlists.length - @first_current_page_adding_playlist_index
                        @added_playlists_check << false
                        # This will Add Every Tracks to the created playlist -> Save Generated Playlist As A Playlist
                        if(add_tracks != nil)
                            add_tracks.each do |track|
                                add_song_to_playlist(@playlists, @playlists.length - 1, track)
                                playlists_file_create_and_modify(@playlists)
                            end
                        end
                    end
                else
                    if (prompt != '')
                        if(rename_index != nil)
                            @playlists = rename_playlist(@playlists, rename_index, prompt)
                        end
                        @action_notification_1 = "Rename \"#{original_name}\""
                        @action_notification_2 = "to \"#{prompt}\""
                        @action_notify_check = true
                        @notify_duration = 0
                        prompt = ''
                        playlists_file_create_and_modify(@playlists)
                        if(rename_index > 0)
                            @first_current_page_playlist_index = ((rename_index - 1) / 6) * 6
                        end
                        @maximum_playlists_per_page = @playlists.length - @first_current_page_playlist_index > 6 ? 6 : @playlists.length - @first_current_page_playlist_index
                    end
                end
                status = false
            when Gosu::KB_A..Gosu::KB_Z
            # This will returns Uppercase or Lowercase characters whether users press SHIFT or not
                prompt = input_char(id, prompt, max_char_limit)
            else
                prompt = input_special_sign(id, prompt, max_char_limit)
            end
        end
        return [prompt, status]
    end
    def button_down(id)
        # The album/playlist/help page is closed if the users type ESCAPE
        if(id == Gosu::KB_ESCAPE)
            if(@playlists_name_typing == false && @search_bar_typing == false && @playlists_add_name_typing == false && @playlist_rename_typing == false)
                if (@selected_album_check == true)
                    @selected_album_check = false
                    @selected_album_index = nil
                    @first_current_page_tracks_index = 0
                    @playing_area_check = false
                    @current_category_page = 0
                    @first_category_page_index = 0
                elsif(@selected_playlist_check == true)
                    @selected_playlist_check = false
                    @selected_playlist_index = nil
                    @first_current_page_tracks_index = 0
                    @current_category_page = 0
                    @first_category_page_index = 0
                elsif(@help_page_check == true)
                    @help_page_check = false
                end
            end
        end
        # This will handle users input for searching query in Search Page
        if(@search_bar_typing == true)
            max_char_limit = 36
            case id
            when Gosu::KB_BACKSPACE
                if(@backspace_pressed == false)
                    @search_bar_searching_text.chop!
                    @backspace_pressed = true
                    @backspace_duration = 0
                end
            when Gosu::KB_ESCAPE
                @search_bar_typing = false
            when Gosu::KB_RETURN
                if (@search_bar_searching_text != "")
                    @found_similar_tracks = searching_query(@search_bar_searching_text, @tracks_storage)
                end
                @search_bar_typing = false
            when Gosu::KB_A..Gosu::KB_Z
                # This will returns Uppercase or Lowercase characters whether users press SHIFT or not
                @search_bar_searching_text = input_char(id, @search_bar_searching_text, max_char_limit)
            else
                # This will returns Special Sign whether users press SHIFT or not
                @search_bar_searching_text = input_special_sign(id, @search_bar_searching_text, max_char_limit)
            end
        end
        # This is for creating playlsit with a name
        temp = playlists_name_input(id, @playlists_name_typing, @playlists_add_prompt, nil, false, nil, nil)
		@playlists_add_prompt = temp[0]
        @playlists_name_typing = temp[1]
        # This is for Saving Generated Playlist Using A Name
        if(@selected_generated_playlist_index != nil)
            clone_playlist = @generated_playlist[@selected_generated_playlist_index].clone
            temp = playlists_name_input(id, @playlists_add_name_typing, @generated_playlist_add_prompt, clone_playlist.tracks, false, nil, nil)
            @generated_playlist_add_prompt = temp[0]
            @playlists_add_name_typing = temp[1]
        end
        # This is for renaming the playlist
        if(@playlist_rename_typing == true && @selected_playlist_index != nil)
            temp = playlists_name_input(id, @playlist_rename_typing, @rename_playlist_add_prompt, nil, true, @selected_playlist_index, @playlists[@selected_playlist_index].title)
            @rename_playlist_add_prompt = temp[0]
            @playlist_rename_typing = temp[1]
        end
        case id
		when Gosu::MsLeft
            if(@help_page_check == true)
                if(close_help_page_area(mouse_x, mouse_y))
                    @help_page_check = false
                end
            end
            # Album Tracks Page Interaction Logic
            if(@selected_album_check == true)
                #Check if the users want to add track to playlist
                add_track_to_playlist_sub(@selected_album.tracks, "List")
                if(@add_track_to_playlist_index == nil)
                    #-----------------------------------------
                    # Check if users want to play album/song
                    tracks_in_albums_or_playlists_page("Album", @albums, @selected_album_index)
                else
                    # Adding Track To Playlist Page
                    adding_track_to_playlist_page_func(@selected_album.tracks[@add_track_to_playlist_index])
                end
            end
            # Generated Playlist Page (display track) Interaction Logic
            if(@selected_generated_playlist_check == true)
                if(visualize_audio_features_toggle_area(mouse_x, mouse_y) == true)
                    @audio_features_toggle_check = @audio_features_toggle_check == false ? true : false
                end
                if(action_playlist_area(mouse_x, mouse_y) == true)
                    @playlists_add_name_typing = true
                else
                    @playlists_add_name_typing = false
                    @generated_playlist_add_prompt = ""
                end
                #Check if the users want to add track to playlist
                add_track_to_playlist_sub(@generated_playlist[@selected_generated_playlist_index].tracks, "List")
                if(@add_track_to_playlist_index == nil)
                    #-----------------------------------------
                    # Check if users want to play album/song
                    tracks_in_albums_or_playlists_page("Generated Playlist", @generated_playlist, @selected_generated_playlist_index)
                else
                    # Adding Track To Playlist Page
                    adding_track_to_playlist_page_func(@generated_playlist[@selected_generated_playlist_index].tracks[@add_track_to_playlist_index])
                end
            end
            #-----------------------------------------
            #-----------------------------------------
            #-----------------------------------------
            # Users can click on current tracks information to access tracks in albums/playlists
            if(@current_playing_album_or_playlist != nil && @add_track_to_playlist_index == nil && @playlist_generation_option_check == false)
                if(albums_or_playlist_current_information_area(mouse_x, mouse_y))
                    #Reset Categories Page to Default
                    @albums = @albums_storage
                    @maximum_albums_per_page = @albums.length > 4 ? 4 : @albums.length
                    @first_current_page_album_index = 0
                    @filter_status = false
                    @active_category_page = nil
                    @active_category_item = nil
                    index = 0
                    while (index < @albums.length)
                        if(@current_playing_album_or_playlist == @albums[index])
                            @selected_album_check = true
                            @selected_playlist_check = false
                            @selected_generated_playlist_check = false
                            @selected_playlist_index = nil
                            @selected_album_index = index
                            @selected_generated_playlist_index = nil
                            @first_current_page_tracks_index = (@current_track_index / 8) * 8
                        end
                        index += 1
                    end
                    index = 0
                    while (index < @playlists.length)
                        if(@current_playing_album_or_playlist == @playlists[index])
                            @selected_album_check = false
                            @selected_playlist_check = true
                            @selected_generated_playlist_check = false
                            @selected_playlist_index = index
                            @selected_album_index = nil
                            @selected_generated_playlist_index = nil
                            @first_current_page_tracks_index = (@current_track_index / 8) * 8
                        end
                        index += 1
                    end
                    index = 0
                    while (index < @generated_playlist.length)
                        if(@current_playing_album_or_playlist == @generated_playlist[index])
                            @selected_album_check = false
                            @selected_playlist_check = false
                            @selected_generated_playlist_check = true
                            @selected_playlist_index = nil
                            @selected_album_index = nil
                            @selected_generated_playlist_index = index
                            @first_current_page_tracks_index = (@current_track_index / 8) * 8
                        end
                        index += 1
                    end
                end
            end
            #-----------------------------------------
            #-----------------------------------------
            #-----------------------------------------
            if (@selected_album_check == false && @selected_playlist_check == false && @selected_generated_playlist_check == false && @help_page_check == false)
                case @current_player_page
                # Search Page Interaction Logic
                when 0
                    if(@tracks_storage.length != 0)
                        if(check_search_bar_area(mouse_x, mouse_y))
                            @playlists_name_typing = false
                            @search_bar_typing = true
                        else
                            @search_bar_typing = false
                        end
                        if(@found_similar_tracks != [])
                            #Check if the users want to add track to playlist
                            add_track_to_playlist_sub(@tracks_storage, "Search")
                            if(@add_track_to_playlist_index == nil)
                                if(similar_toggle_check_area(mouse_x, mouse_y))
                                    if(@similarity_toggle_check == false)
                                        @similarity_toggle_check = true
                                    else
                                        @similarity_toggle_check = false
                                    end
                                end
                                selected_track_areas = search_tracks_area(mouse_x, mouse_y)
                                if (selected_track_areas != nil)
                                    @current_track_index = selected_track_areas
                                    @current_track_array_index = @current_track_index
                                    @shuffle_check = false
                                    @loop_check = false
                                    track_index = @found_similar_tracks[selected_track_areas][0]
                                    @current_track = @tracks_storage[track_index]
                                    @current_playing_album = false
                                    @current_playing_playlist = false
                                    @current_playing_album_or_playlist = nil
                                    @current_song_seconds = 0
                                    @pause_time = 0
                                    @last_update_time = Gosu.milliseconds
                                    playTrack(@current_track)
                                end
                            else
                                adding_track_to_playlist_page_func(@tracks_storage[@add_track_to_playlist_index])
                            end
                        end
                    end
                # Home Page Interaction Logic
                when 1
                    #Check user click on help button
                    if(help_icon_area(mouse_x, mouse_y) == true)
                        @help_page_check = true
                    end
                    #Choose between All, Genres, Artist and Decades
                    if (@current_category_page == 0)
                        case selected_categories_areas(mouse_x, mouse_y)
                        when nil
                            @current_category_page = @current_category_page
                        when 0
                            #Reset to Default
                            @albums = @albums_storage
                            @maximum_albums_per_page = @albums.length > 4 ? 4 : @albums.length
                            @first_current_page_album_index = 0
                            @filter_status = false
                            @active_category_page = nil
                            @active_category_item = nil
                        when 1
                            #Change to Genres Page
                            @current_category_page = 1
                            @category_storage = @genres_storage
                        when 2
                            #Change to Artists Page
                            @current_category_page = 2
                            @category_storage = @artists_storage
                        when 3
                            #Change to Decades Page
                            @current_category_page = 3
                            @category_storage = @decades_storage
                        end
                    else
                        if (close_button_categories_area(mouse_x, mouse_y))
                            # Set to default values when closing
                            @current_category_page = 0
                            @first_category_page_index = 0
                            @maximum_items_per_category_page = 4
                        end
                        case previous_and_next_category_page(mouse_x, mouse_y)
                        when 1
                            if (@first_category_page_index != 0)
                                @first_category_page_index -= 4
                                @maximum_items_per_category_page = 4
                            end
                        when 2
                            if (@first_category_page_index + @maximum_items_per_category_page < @category_storage.length)
                                @first_category_page_index += 4
                                @maximum_items_per_category_page = @category_storage.length - @first_category_page_index > 4 ? 4 : @category_storage.length - @first_category_page_index
                            end
                        end
                        @required_category_item = selected_required_items_category_area(mouse_x, mouse_y)
                        if(@required_category_item != nil)
                            @active_category_page = @current_category_page
                            @active_category_item = @category_storage[@required_category_item]
                            @albums = filter_by_category(@albums_storage, @category_index[@current_category_page], @category_storage[@required_category_item])
                            @maximum_albums_per_page = @albums.length > 4 ? 4 : @albums.length
                            @first_current_page_album_index = 0
                        end
                    end
                    #-----------------------------------------
                    #-----------------------------------------
                    #-----------------------------------------
                    #Choose Previous or Next Page Button
                    case previous_and_next_album_page(mouse_x, mouse_y)
                    when 1
                        if (@first_current_page_album_index != 0)
                            @first_current_page_album_index -= 4
                            @maximum_albums_per_page = 4
                        end
                    when 2
                        if (@first_current_page_album_index + @maximum_albums_per_page < @albums.length)
                            @first_current_page_album_index += 4
                            @maximum_albums_per_page = @first_current_page_album_index + 4 < @albums.length ? 4 : @albums.length - @first_current_page_album_index
                        end
                    end
                    #-----------------------------------------
                    #-----------------------------------------
                    #-----------------------------------------
                    #Check if the user is selecting an album
                    @selected_album_index = selected_albums_area(mouse_x, mouse_y)
                    @playing_area_check = selected_playing_albums_area(mouse_x, mouse_y)
                    if (@selected_album_index != nil)
                        #Generated different background colors
                        @displayed_background_color_1 = random_color_generated()
                        @displayed_background_color_2 = random_color_generated()
                        @selected_album_check = true
                        @selected_playlist_index = nil
                        @selected_playlist_check = false
                        @first_current_page_tracks_index = 0
                        if(@song && @current_playing_album_or_playlist == @albums[@selected_album_index])
                            @first_current_page_tracks_index = (@current_track_index / 8) * 8
                        end
                        # The Album is if the users click on the play button (in the Albums page)
                        if (@playing_area_check == true && (@current_playing_album_or_playlist == nil || (@current_playing_album_or_playlist != @albums[@selected_album_index])))
                            @current_song_seconds = 0
                            @last_update_time = Gosu.milliseconds
                            @current_track_index = 0
                            @current_track_array_index = 0
                            index = 0
                            @shuffle_check = false
                            @loop_check = false
                            @selected_track_index_array = Array.new()
                            while(index < @albums[@selected_album_index].total_tracks)
                                @selected_track_index_array << index
                                index += 1
                            end
                            @current_playing_album_or_playlist = @albums[@selected_album_index]
                            @current_playing_album = true
                            @current_playing_playlist = false
                            @current_track = @current_playing_album_or_playlist.tracks[@current_track_index]
                            copy_track = @current_track.clone
                            recalculate_preferences_counting(copy_track, 0.25) # Playing song by playing an album will make up a score of 0.25 of preference
                            playTrack(@current_track)
                        end
                        @playing_area_check = false
                    end
                # Recommended Page Interaction Logic
                when 2
                    if(@playlist_generation_option_check == false)
                        if(@tracks_storage.length > 0)
                            @selected_generated_playlist_index = selected_generated_playlist_area(mouse_x, mouse_y)
                            if(@selected_generated_playlist_index != nil)
                                #Generated different background colors
                                @displayed_background_color_1 = random_color_generated()
                                @displayed_background_color_2 = random_color_generated()
                                @selected_generated_playlist_check = true
                                @selected_playlist_index = nil
                                @selected_playlist_check = false
                                @first_current_page_tracks_index = 0
                                if(@song && @current_playing_album_or_playlist == @generated_playlist[@selected_generated_playlist_index])
                                    @first_current_page_tracks_index = (@current_track_index / 8) * 8
                                end
                            else
                                # Only usable when there is history of user interactions
                                if (Dir.glob(INTERACTION_HISTORY_FILE_NAME).any? == true)
                                    if(personalized_playlist_generation_area(mouse_x, mouse_y) == true)
                                        if(@current_playing_generated_playlist == true)
                                            @song = nil
                                            @current_playing_generated_playlist = false
                                            @current_playing_album_or_playlist = nil
                                            @current_track = nil
                                        end
                                        requirement = Array.new(3){Array.new(2)}
                                        ####################################
                                        #### Discovery Mix Generation -> no need to be popular, no same genres required.
                                        requirement[0] = [false, false]
                                        #####################################
                                        #### Exploration Mix Generation -> need to have popularity over 70 and subtract down if there is not enough songs in the playlist, no same genres required.
                                        requirement[1] = [true, false]
                                        ####################################
                                        #### Personalized Mix Generation -> need to have popularity over 70 and subtract down if there is not enough songs in the playlist, same genres required
                                        requirement[2] = [true, true]
                                        compressed_preferences = [@artist_preferences, @genres_preferences, @decades_preferences, @acousticness_preferences, @valence_preferences, @energy_preferences, @danceability_preferences, @speechiness_prefererences, @tempo_preferences].clone
                                        target_preferences = calculation_target_preferences_based_on_history(compressed_preferences, @artists_storage, @genres_storage, @decades_storage, @tracks_storage)
                                        if(@custom_playlist_generation_check == false)
                                            # Generating Personalized Playlist based on user interaction history
                                            index = 5
                                            while(index < @generated_playlist.length)
                                                generated_playlist = playlist_generation_based_on_history(@tracks_storage, target_preferences, requirement[index - 5][0], requirement[index - 5][1])
                                                @generated_playlist[index].tracks = generated_playlist[0]
                                                @generated_playlist[index].total_tracks = @generated_playlist[index].tracks.length
                                                @total_distance_generated_playlist[index][0] = generated_playlist[1].round(4) # Non smooth-transition total distance
                                                @total_distance_generated_playlist[index][1] = generated_playlist[2].round(4) # Smooth-transition total distance
                                                index += 1
                                            end
                                        else
                                            # Generating Personalized Playlist based on custom choices
                                            index = 5
                                            while(index < @generated_playlist.length)
                                                # We still need to use history preferences due to lack of decade choice, tempo ...
                                                compressed_preferences = [@artist_preferences, @genres_preferences, @decades_preferences, @acousticness_preferences, @valence_preferences, @energy_preferences, @danceability_preferences, @speechiness_prefererences, @tempo_preferences].clone
                                                generated_playlist = playlist_generation_based_on_custom_preferences(@tracks_storage, @artists_storage, @genres_storage, @custom_playlist_generation_options, target_preferences, requirement[index - 5][0], requirement[index - 5][1])
                                                @generated_playlist[index].tracks = generated_playlist[0]
                                                @generated_playlist[index].total_tracks = @generated_playlist[index].tracks.length
                                                @total_distance_generated_playlist[index][0] = generated_playlist[1].round(4) # Non smooth-transition total distance
                                                @total_distance_generated_playlist[index][1] = generated_playlist[2].round(4) # Smooth-transition total distance
                                                index += 1
                                            end
                                        end
                                        @action_notification_1 = "Playlist Generation Completed"
                                        @action_notification_2 = "For Mix 1, Mix 2, Mix 3"
                                        @action_notify_check = true
                                        @notify_duration = 0
                                    end
                                    # Only usable when there is history of user interactions
                                    if(playlist_generation_option_area(mouse_x, mouse_y) == true)
                                        @playlist_generation_option_check = true
                                    end
                                end
                            end
                        end
                    else
                        #Playlist Generation Option Interaction Logic
                        if(@custom_playlist_generation_check == true)
                            option_index = custom_option_playlist_generation_area(mouse_x, mouse_y)
                            if(option_index != nil)
                                if(option_index[0] != 0 && option_index[0] != 1)
                                    @custom_playlist_generation_options[option_index[0]] = [false, false, false]
                                    @custom_playlist_generation_options[option_index[0]][option_index[1]] = true
                                else
                                    case option_index[0]
                                    when 0
                                        artist_index = @custom_playlist_generation_options[0][0] + 1
                                        if(artist_index == @artists_storage.length - 1)
                                            artist_index = 0
                                        end
                                        @custom_playlist_generation_options[0][0] = artist_index
                                    when 1
                                        genre_index = @custom_playlist_generation_options[1][0] + 1
                                        if(genre_index == @genres_storage.length - 1)
                                            genre_index = 0
                                        end
                                        @custom_playlist_generation_options[1][0] = genre_index
                                    end
                                end
                            end
                        end
                        if(auto_playlist_generation_area(mouse_x, mouse_y) == true)
                            @custom_playlist_generation_options = [[nil], [nil], [false, false, false], [false, false, false], [false, false, false]]
                            @custom_playlist_generation_check = false
                        end
                        if(custom_playlist_generation_area(mouse_x, mouse_y) == true)
                            @custom_playlist_generation_options = [[0], [0], [false, true, false], [false, true, false], [false, true, false]]
                            @custom_playlist_generation_check = true
                        end
                        if(cancel_playlist_generation_area(mouse_x, mouse_y) == true)
                            # Returns to previous state if users click cancel button
                            @custom_playlist_generation_options = @previous_custom_playlist_generation_options.clone
                            @custom_playlist_generation_check = @previous_custom_playlist_generation_check.clone
                            @playlist_generation_option_check = false
                        end
                        if(confirm_playlist_generation_option_area(mouse_x, mouse_y) == true)
                            # Store previous state so as it will returns to previous state if users click cancel button
                            @previous_custom_playlist_generation_check = @custom_playlist_generation_check.clone
                            @previous_custom_playlist_generation_options = @custom_playlist_generation_options.clone
                            @playlist_generation_option_check = false
                        end
                    end
                end
            end
            # Switch between pages: Search Page, Home Page, Recommended Page
            if(music_player_pages_area(mouse_x, mouse_y) != nil)
                @current_player_page = music_player_pages_area(mouse_x, mouse_y)
                @selected_album_check = false
                @selected_playlist_check = false
                @selected_generated_playlist_check = false
                @help_page_check = false
                @first_current_page_tracks_index = 0
                @current_category_page = 0
                @search_bar_typing = false
                @search_bar_searching_text = ""
                @found_similar_tracks = Array.new()
                @similarity_toggle_check = false
                @first_current_page_album_index  = 0
                @maximum_albums_per_page = @first_current_page_album_index + 4 < @albums.length ? 4 : @albums.length - @first_current_page_album_index
                @playlist_generation_option_check = false
            end
            #The playlists can be accessed anywhere in all pages except in "add tracks to playlist" and "playlist generation option" page
            if(@add_track_to_playlist_index == nil && @playlist_generation_option_check == false)
                case next_and_previous_page_displayed_playlists(mouse_x, mouse_y)
                when 1
                    if(@first_current_page_playlist_index < @playlists.length - @maximum_playlists_per_page)
                        @first_current_page_playlist_index += 6
                        @maximum_playlists_per_page = @playlists.length - @first_current_page_playlist_index > 6 ? 6 : @playlists.length - @first_current_page_playlist_index
                    end
                when 2
                    if(@first_current_page_playlist_index != 0)
                        @first_current_page_playlist_index -= 6
                        @maximum_playlists_per_page = 6
                    end
                end
                if(selected_playlists_area(mouse_x, mouse_y) != nil)
                    @help_page_check = false
                    @selected_playlist_index = selected_playlists_area(mouse_x, mouse_y)
                    #Generated different background colors when selected an playlist
                    @displayed_background_color_1 = random_color_generated()
                    @displayed_background_color_2 = random_color_generated()
                    @selected_album_check = false
                    @selected_album_index = nil
                    @selected_generated_playlist_check = false
                    @selected_generated_playlist_index = nil
                    @selected_playlist_check = true
                    @first_current_page_tracks_index = 0
                    if(@song && @current_playing_album_or_playlist == @playlists[@selected_playlist_index])
                        @first_current_page_tracks_index = (@current_track_index / 8) * 8
                    end
                # Playlist Interaction
                elsif(@selected_playlist_check == true && @selected_playlist_index != nil)
                    #This will check if users want to rename the playlist
                    if(rename_playlist_area(mouse_x, mouse_y) == true)
                        @playlist_rename_typing = true
                    else
                        @playlist_rename_typing = false
                        @rename_playlist_add_prompt = ""
                    end
                    if(@delete_track_to_playlist_index == nil)
                        # This will delete selected tracks from selected playlist
                        @delete_track_to_playlist_index = track_to_delete_playlist(mouse_x, mouse_y)
                        if(@delete_track_to_playlist_index != nil)
                            cropped_text = crop_text(@bar_font, @playlists[@selected_playlist_index].tracks[@delete_track_to_playlist_index].name, 275)
                            @action_notification_1 = "Delete \"#{cropped_text}\""
                            @action_notification_2 = "From \"#{@playlists[@selected_playlist_index].title}\""
                            @action_notify_check = true
                            @notify_duration = 0
                            if(@song && @current_track == @playlists[@selected_playlist_index].tracks[@delete_track_to_playlist_index])
                                @song.pause
                                @song = nil
                                @current_track = nil
                                @current_playing_album_or_playlist = nil
                            end
                            @shuffle_check = false
                            #Reduce the current track index if the delete index is before the current track
                            if(@song && @current_playing_album_or_playlist == @playlists[@selected_playlist_index])
                                @current_track_array_index = @selected_track_index_array[@current_track_array_index]
                                if(@current_track_array_index > @delete_track_to_playlist_index)
                                    @current_track_array_index -= 1
                                end
                            end
                            index = 0
                            @selected_track_index_array = Array.new()
                            while(index < @playlists[@selected_playlist_index].total_tracks)
                                @selected_track_index_array << index
                                index += 1
                            end
                            @playlists = delete_song_in_playlist(@playlists, @selected_playlist_index, @delete_track_to_playlist_index)
                            playlists_file_create_and_modify(@playlists)
                            if(@playlists[@selected_playlist_index].total_tracks - @first_current_page_tracks_index == 0 && @first_current_page_tracks_index > 0)
                                @first_current_page_tracks_index -= 8
                            end
                        end
                    end
                    if(@delete_track_to_playlist_index == nil)
                        # Check if users want to play playlist/song
                        tracks_in_albums_or_playlists_page("Playlist", @playlists, @selected_playlist_index)
                    else
                        @delete_track_to_playlist_index = nil
                    end
                    # This will delete selected playlist when the area is clicked
                    if(action_playlist_area(mouse_x, mouse_y) == true)
                        @action_notification_1 = "Delete \"#{@playlists[@selected_playlist_index].title}\""
                        @action_notification_2 = "As a playlist"
                        @action_notify_check = true
                        @notify_duration = 0
                        if(@song && @current_playing_album_or_playlist == @playlists[@selected_playlist_index])
                            @song.pause
                            @song = nil
                            @current_track = nil
                            @current_playing_album_or_playlist = nil
                        end
                        @playlists = delete_playlist(@playlists, @selected_playlist_index)
                        playlists_file_create_and_modify(@playlists)
                        @first_current_page_playlist_index = ((@playlists.length() - 1) / 6) * 6
                        @maximum_playlists_per_page = @playlists.length - @first_current_page_playlist_index > 6 ? 6 : @playlists.length - @first_current_page_playlist_index
                        @maximum_adding_playlists_per_page = @playlists.length - @first_current_page_adding_playlist_index > 6 ? 6 : @playlists.length - @first_current_page_adding_playlist_index
                        @selected_playlist_check = false
                        @selected_playlist_index = nil
                        @first_current_page_tracks_index = 0
                        @shuffle_check = false
                        @loop_check = false
                    end
                end
            end
            #Users click on add playlist button to add playlist
            if(playlists_add_area(mouse_x, mouse_y))
                # This will enable user to typing a name
                @playlists_name_typing = true
            else
                @playlists_name_typing = false
                @playlists_add_prompt = ""
            end
            #-----------------------------------------
            #-----------------------------------------
            #-----------------------------------------
            # Scubber (Play, Stop, Skip, Previous, Shuffle, Loop)
            case scrubber_area(mouse_x, mouse_y)
            # Play / Pause
            when 1
                if(@song && @song.playing?)
                    @song.pause
                elsif (@current_track != nil)
                    @song.play
                end
            # Skip Song
            when 2
                if(@current_playing_album_or_playlist != nil && @current_track_array_index < @current_playing_album_or_playlist.total_tracks - 1)
                    @current_track_array_index += 1
                    @current_track_index = @selected_track_index_array[@current_track_array_index]
                    #This is to check if the track is playing at the next page, it will direct to that page the track is in.
                    @first_current_page_tracks_index = (@current_track_index / 8) * 8
                    @current_track = @current_playing_album_or_playlist.tracks[@current_track_index]
                    copy_track = @current_track.clone
                    recalculate_preferences_counting(copy_track, 0.25) # Skip to next song will make up a score of 0.25 of preferences (of the next song)
                    @current_song_seconds = 0
                    @pause_time = 0
                    @last_update_time = Gosu.milliseconds
                    playTrack(@current_track)
                else
                    #Reset to default value if the album reached the end
                    if(@loop_check == false)
                        if (@song)
                            @song.pause
                        end
                        @song = nil
                        @current_track_index = nil
                        @current_playing_album_or_playlist = nil
                        @current_track = nil
                        @shuffle_check = false
                    else
                        # Return index to 0 if loop mode is enabled
                        @current_track_array_index = 0
                        @current_track_index = @selected_track_index_array[@current_track_array_index]
                        @current_track = @current_playing_album_or_playlist.tracks[@current_track_index]
                        copy_track = @current_track.clone
                        recalculate_preferences_counting(copy_track, 0.25) # Skip to next song will make up a score of 0.25 of preferences (of the next song)
                        @first_current_page_tracks_index = (@current_track_index / 8) * 8
                        @current_song_seconds = 0
                        @pause_time = 0
                        @last_update_time = Gosu.milliseconds
                        playTrack(@current_track)
                    end
                end
            # Back to Previous Song
            when 3
                if(@current_playing_album_or_playlist != nil)
                    if(@current_track_array_index > 0)
                        @current_track_array_index -= 1
                        @current_track_index = @selected_track_index_array[@current_track_array_index]
                        @current_track = @current_playing_album_or_playlist.tracks[@current_track_index]
                        copy_track = @current_track.clone
                        recalculate_preferences_counting(copy_track, 0.25) # Go back to previous song will make up a score of 0.25 of preferences (of the previous song)
                        #This is to check if the track is playing at the next page, it will direct to that page the track is in.
                        @first_current_page_tracks_index = (@current_track_index / 8) * 8
                        @current_song_seconds = 0
                        @pause_time = 0
                        @last_update_time = Gosu.milliseconds
                        playTrack(@current_track)
                    else
                        @current_song_seconds = 0
                        @pause_time = 0
                        @last_update_time = Gosu.milliseconds
                        playTrack(@current_track)
                    end
                end
            #Shuffle Button
            when 4
                if(@current_playing_album_or_playlist != nil)
                    if(!@shuffle_check)
                        @shuffle_check = true
                        shuffle_list(@shuffle_check)
                    else
                        @shuffle_check = false
                        shuffle_list(@shuffle_check)
                    end
                end
            #Loop Button
            when 5
                if(@current_playing_album_or_playlist != nil)
                    if (!@loop_check)
                        @loop_check = true
                    else
                        @loop_check = false
                    end
                end
            end
            #Users click on volume button to change volume up or down
            case volume_area(mouse_x, mouse_y)
            when 1
                if(@current_volume.round(1) > 0.0)
                    @current_volume -= 0.1
                    if(@song)
                        @song.volume = @current_volume
                    end
                end
            when 2
                if(@current_volume.round(1) < 10.0)
                    @current_volume += 0.1
                    if(@song)
                        @song.volume = @current_volume
                    end
                end
            end
        end
        #-----------------------------------------
        #-----------------------------------------
        #-----------------------------------------
        # Press Space to Play / Stop Song
        if(@playlists_name_typing == false && @search_bar_typing == false && @playlists_add_name_typing == false && @playlist_rename_typing == false)
            case id
            when Gosu::KB_SPACE
                if(@song && @song.playing?)
                    @song.pause
                elsif (@current_track != nil)
                    @song.play
                end
            # Press Left Arrow to Previous Song
            when Gosu::KB_LEFT
                if(@current_playing_album_or_playlist != nil)
                    if(@current_track_array_index > 0)
                        @current_track_array_index -= 1
                        @current_track_index = @selected_track_index_array[@current_track_array_index]
                        @current_track = @current_playing_album_or_playlist.tracks[@current_track_index]
                        copy_track = @current_track.clone
                        recalculate_preferences_counting(copy_track, 0.25) # Go back to previous song will make up a score of 0.25 of preferences (of the previous song)
                        #This is to check if the track is playing at the next page, it will direct to that page the track is in.
                        @first_current_page_tracks_index = (@current_track_index / 8) * 8
                        @current_song_seconds = 0
                        @pause_time = 0
                        @last_update_time = Gosu.milliseconds
                        playTrack(@current_track)
                    else
                        @current_song_seconds = 0
                        @pause_time = 0
                        @last_update_time = Gosu.milliseconds
                        playTrack(@current_track)
                    end
                end
            # Press Right Arrow to Skip
            when Gosu::KB_RIGHT
                # Skip
                if(@current_playing_album_or_playlist != nil && @current_track_array_index < @current_playing_album_or_playlist.total_tracks - 1)
                    @current_track_array_index += 1
                    @current_track_index = @selected_track_index_array[@current_track_array_index]
                    #This is to check if the track is playing at the next page, it will direct to that page the track is in.
                    @first_current_page_tracks_index = (@current_track_index / 8) * 8
                    @current_track = @current_playing_album_or_playlist.tracks[@current_track_index]
                    copy_track = @current_track.clone
                    recalculate_preferences_counting(copy_track, 0.25) # Skip to next song will make up a score of 0.25 of preferences (of the next song)
                    @current_song_seconds = 0
                    @pause_time = 0
                    @last_update_time = Gosu.milliseconds
                    playTrack(@current_track)
                else
                    #Reset to default value if the album reached the end
                    if(@loop_check == false)
                        if (@song)
                            @song.pause
                        end
                        @song = nil
                        @current_track_index = nil
                        @current_playing_album_or_playlist = nil
                        @current_track = nil
                        @shuffle_check = false
                    else
                        # Return index to 0 if loop mode is enabled
                        @current_track_array_index = 0
                        @current_track_index = @selected_track_index_array[@current_track_array_index]
                        @current_track = @current_playing_album_or_playlist.tracks[@current_track_index]
                        copy_track = @current_track.clone
                        recalculate_preferences_counting(copy_track, 0.25) # Skip to next song will make up a score of 0.25 of preferences (of the next song)
                        @first_current_page_tracks_index = (@current_track_index / 8) * 8
                        @current_song_seconds = 0
                        @pause_time = 0
                        @last_update_time = Gosu.milliseconds
                        playTrack(@current_track)
                    end
                end
            #Shortcut for Shuffle Mode
            when Gosu::KB_S
                if(@current_playing_album_or_playlist != nil)
                    if(!@shuffle_check)
                        @shuffle_check = true
                        shuffle_list(@shuffle_check)
                    else
                        @shuffle_check = false
                        shuffle_list(@shuffle_check)
                    end
                end
            # Shortcut for Loop mode
            when Gosu::KB_L
                if(@current_playing_album_or_playlist != nil)
                    if (!@loop_check)
                        @loop_check = true
                    else
                        @loop_check = false
                    end
                end
            # Shortcut to Decrease Volume
            when Gosu::KB_1
                if(@current_volume.round(1) > 0.0)
                    @current_volume -= 0.1
                    if(@song)
                        @song.volume = @current_volume
                    end
                end
            # Shortcut to Increase Volume
            when Gosu::KB_2
                if(@current_volume.round(1) < 1.0)
                    @current_volume += 0.1
                    if(@song)
                        @song.volume = @current_volume
                    end
                end
            end
        end
    end
    def button_up(id)
        #Disable automatically deleting text when the escape button is up
        if(@playlists_name_typing == true)
            if (id == Gosu::KB_BACKSPACE)
                @backspace_pressed = false
            end
        end
        #Disable automatically deleting text when the escape button is up
        if(@playlists_add_name_typing == true)
            if (id == Gosu::KB_BACKSPACE)
                @backspace_pressed = false
            end
        end
        #Disable automatically deleting text when the escape button is up
        if(@search_bar_typing == true)
            if (id == Gosu::KB_BACKSPACE)
                @backspace_pressed = false
            end
        end
        #Disable automatically deleting text when the escape button is up
        if(@playlist_rename_typing == true)
            if (id == Gosu::KB_BACKSPACE)
                @backspace_pressed = false
            end
        end
    end
    #Automatically deleting text when the escape button is pressed
    def automatically_delete_text(prompt, check)
        if(check == true && @backspace_pressed == true && @backspace_duration > 250)
            prompt.chop!
            @backspace_duration = 0
        end
        return prompt
    end
    def update
        # This will automatically close notification box for 5 seconds
        if(@action_notify_check == true)
            @notify_duration += update_interval
            if(@notify_duration >= 5000)
                @action_notification_1  = ""
                @action_notification_2  = ""
                @action_notify_check = false
                @notify_duration = 0
            end
        end
        #This will add blinking effect
        if(@playlists_add_prompt != '' || @generated_playlist_add_prompt != '' || @search_bar_searching_text != nil)
            @blinking_effect = true
            @blinking_duration += update_interval
            if(@blinking_duration >= 750)
                @blinking_duration = 0
            end
        else
            @blinking_effect = false
            @blinking_duration = 0
        end
        # This will delete the input text every 300 milliseconds if the users is holding down the backspace button
        if(@backspace_pressed == true)
            @backspace_duration += update_interval
        end
        @playlists_add_prompt = automatically_delete_text(@playlists_add_prompt, @playlists_name_typing)
        @search_bar_searching_text = automatically_delete_text(@search_bar_searching_text, @search_bar_typing)
        @generated_playlist_add_prompt = automatically_delete_text(@generated_playlist_add_prompt, @playlists_add_name_typing)
        @rename_playlist_add_prompt = automatically_delete_text(@rename_playlist_add_prompt, @playlist_rename_typing)
        #-------------------------------
        #-------------------------------
        #-------------------------------
        # Update the song current second
        current_time = Gosu.milliseconds
        if(@song && @song.playing?)
            time_elapsed = current_time - @last_update_time - @pause_time
            @pause_time = 0
            # Update the current playback position
            @current_song_seconds += time_elapsed / 1000.0
            # Update the last update time
            @last_update_time = current_time
        end
        if(@song && !@song.playing?)
            # Subtract the time that is paused
            @pause_time = current_time - @last_update_time
        end
        # Buff seconds because of minor delay
        if(@song && !@song.playing? && @current_song_seconds > (@current_track.length - 1))
            @current_song_seconds = @current_track.length
        end
        if (@song && @current_song_seconds >= @current_track.length)
            if (@current_playing_album_or_playlist != nil && @current_track_array_index < @current_playing_album_or_playlist.total_tracks - 1)
                copy_track = @current_track.clone
                recalculate_preferences_counting(copy_track, 1) # Finishing a song will make up a score of 1 of preferences
                @current_track_array_index += 1
                @current_track_index = @selected_track_index_array[@current_track_array_index]
                @current_track = @current_playing_album_or_playlist.tracks[@current_track_index]
                copy_track = @current_track.clone
                recalculate_preferences_counting(copy_track, 0.25) # Auto playing next song will make up a score of 0.25 of preferences
                @first_current_page_tracks_index = (@current_track_index / 8) * 8
                playTrack(@current_track)
                @current_song_seconds = 0
                @pause_time = 0
                @last_update_time = Gosu.milliseconds
            else
                # Return to default values of tracks if the albums/playlists reached the end and @loop mode is not enabled
                if(@loop_check == false)
                    @song.pause
                    @song = nil
                    @current_track_index = nil
                    @current_playing_album_or_playlist = nil
                    @current_playing_album = false
                    @current_track = nil
                    @shuffle_check = false
                else
                    # Return index to 0 if loop mode is enabled
                    @current_track_array_index = 0
                    @current_track_index = @selected_track_index_array[@current_track_array_index]
                    @current_track = @current_playing_album_or_playlist.tracks[@current_track_index]
                    copy_track = @current_track.clone
                    recalculate_preferences_counting(copy_track, 0.25) # Auto playing next song will make up a score of 0.25 of preferences
                    @first_current_page_tracks_index = (@current_track_index / 8) * 8
                    @current_song_seconds = 0
                    @pause_time = 0
                    @last_update_time = Gosu.milliseconds
                    playTrack(@current_track)
                    copy_track = @current_track.clone
                end
            end
        end
	end
end

OrigamiMusica.new.show if __FILE__ == $0
