require_relative "Tracks_Storage.rb"
require_relative "Albums_Read.rb"
# This Class defining Target Preferences based on History Preferences / Custom User Preferences for Playlist Generation
class Target
    attr_accessor :artist, :genre, :decade, :acousticness, :valence, :energy, :danceability, :speechiness, :tempo
    def initialize(artist, genre, decade, acousticness, valence, energy, danceability, speechiness, tempo)
        @artist = artist
        @genre = genre
        @decade = decade
        @acousticness = acousticness
        @valence = valence
        @energy = energy
        @danceability = danceability
        @speechiness = speechiness
        @tempo = tempo
    end
end

module NearestNeighbor
    RANDOM, REPEATED = *0..1
end
##########################################################
# Step 1: Choose the most similar song to user preferences
def most_similar_track_selection(tracks_storage, target, popularity_required, same_genres_required)
    min_popularity = 75
    similarity_sorted = Array.new(){Array.new(2)}
    while(similarity_sorted.length == 0)
        similarity_sorted = Array.new(){Array.new(2)}
        index = 0
        while(index < tracks_storage.length)
            track = tracks_storage[index]
            similarity = 0.0
            if (track.artist == target.artist)
                similarity += 0.1
            end
            if (track.genre == target.genre)
                similarity += 0.1
            end
            decade = track.year / 10 * 10
            similarity += [1 - (decade - target.decade).abs / 50, 0].max * 0.1 # Similarity in the 50 years margin
            similarity += (1 - (track.features.acousticness.to_f - target.acousticness).abs) * 0.05 # Similarity in the range of 0.0 to 1.0
            similarity += (1 - (track.features.valence.to_f - target.valence).abs) * 0.15 # Similarity in the range of 0.0 to 1.0
            similarity += (1 - (track.features.energy.to_f - target.energy).abs) * 0.15 # Similarity in the range of 0.0 to 1.0
            similarity += (1 - (track.features.danceability.to_f - target.danceability).abs) * 0.15 # Similarity in the range of 0.0 to 1.0
            similarity += (1 - (track.features.speechiness.to_f - target.speechiness).abs / 0.5) * 0.05 # Similarity in the range of 0.0 to 0.5
            similarity += (1 - (track.features.tempo.to_f - target.tempo).abs / 250) * 0.15 # Similarity in the range of 0.0 to 250.0
            if(popularity_required == true)
                if(track.features.popularity.to_f < min_popularity) # Not accepting tracks with popularity lower than minimum popularity start from 75
                    index += 1
                    next
                end
            end
            if(same_genres_required == true)
                if(track.genre != target.genre) # Not accepting tracks with not the same genre
                    index += 1
                    next
                end
            end
            similarity_sorted << [index, similarity]
            index += 1
        end
        if(similarity_sorted.length == 0)
            min_popularity -= 10
        end
    end
    # Sort the array by comparing the similarity value from highest to lowest
    similarity_sorted = similarity_sorted.sort {|a,b| a[1] <=> b[1]}.reverse
    return similarity_sorted[0][0]
end
def display_most_similar_track(similarity_sorted)
    index = 0
    while(index < 5)
        track = tracks_storage[similarity_sorted[index][0]]
        puts "Name: #{track.name}"
        puts "Artist: #{track.artist}"
        puts "Genre: #{track.genre}"
        puts "Year: #{track.year}"
        puts "Popularity: #{track.features.popularity}"
        puts "Acousticness: #{track.features.acousticness}"
        puts "Valence: #{track.features.valence}"
        puts "Energy: #{track.features.energy}"
        puts "Danceability: #{track.features.danceability}"
        puts "Speechiness: #{track.features.speechiness}"
        puts "Tempo: #{track.features.tempo}"
        puts "Similarity: #{similarity_sorted[index][1]}"
        puts "-----------------------------"
        index += 1
    end
end
##########################################################


##########################################################
# Step 2: Find the nearest neighbors of the chosen track based on playlist types
def neighbor_of_center_track(tracks_storage, center_track_index, target, popularity_required, same_genres_required)
    center_track = tracks_storage[center_track_index]
    similarity_sorted = Array.new(){Array.new(2)}
    min_popularity = 75
    while(similarity_sorted.length < 5)
        similarity_sorted = Array.new(){Array.new(2)}
        index = 0
        while(index < tracks_storage.length)
            current_track = tracks_storage[index]
            if(index == center_track_index)
                index += 1
                next
            end
            euclidean_distance = Math.sqrt((center_track.features.valence.to_f - current_track.features.valence.to_f)**2 +
                                        (center_track.features.energy.to_f - current_track.features.energy.to_f)**2 +
                                        (center_track.features.danceability.to_f - current_track.features.danceability.to_f)**2)
            if(popularity_required == true)
                if(current_track.features.popularity.to_f < min_popularity) # Not accepting tracks with popularity lower than minimum popularity start from 75
                    index += 1
                    next
                end
            end
            if(same_genres_required == true)
                if(current_track.genre != target.genre) # Not accepting tracks with not the same genre
                    index += 1
                    next
                end
            end
            similarity_sorted << [index, euclidean_distance]
            index += 1
        end
        if(similarity_sorted.length < 5)
            min_popularity -= 10
        end
    end

    # Sort the array by comparing the similarity value from lowest to highest
    similarity_sorted = similarity_sorted.sort {|a,b| a[1] <=> b[1]}
    playlist = Array.new()
    index = 0
    number_of_tracks = rand(15..30)
    while(index < [number_of_tracks, similarity_sorted.length].min)
        track = tracks_storage[similarity_sorted[index][0]]
        playlist << track
        index += 1
    end
    playlist << center_track
    return playlist
end
def euclidean_distance_calculation(track_1, track_2)
    return Math.sqrt((track_1.features.valence.to_f - track_2.features.valence.to_f)**2 +
            (track_1.features.energy.to_f - track_2.features.energy.to_f)**2 +
            (track_1.features.danceability.to_f - track_2.features.danceability.to_f)**2)
end
##########################################################

##########################################################
# Step 3: Solving Open Travelling Salesman Problem to create smooth-transition playlist
# Solving Open Travelling salesman problem with Brute Force (For Report Data Experiments Proof)
def brute_force(playlist)
    n = playlist.length
    final_playlist = playlist
    final_distance = 1e7
    playlist.permutation(n){
        |permutation|
        total_distance = 0
        index = 1
        while(index < n)
            euclidean_distance =  euclidean_distance_calculation(permutation[index], permutation[index - 1])
            total_distance += euclidean_distance
            index += 1
        end
        if(final_distance > total_distance)
            final_playlist = permutation
            final_distance = total_distance
        end
    }
    return [final_playlist, final_distance]
end
# Solving Open Travelling salesman problem with Random Nearest Neighbor Algorithm (For Report Data Experiments Proof) and Repeated Nearest Neighbor Algorithm
def nearest_neighbor_type(playlist, repeated_check)
    n = playlist.length
    final_playlist = playlist
    total_distance = 1e7
    all_nearest_neighbor_route = Array.new()
    if(repeated_check == 0)
        origin = rand(0...n - 1)
        result = nearest_neighbor_algorithm(playlist, origin)
        final_playlist = result[0]
        total_distance = result[1]
    else
        index = 0
        while(index < n)
            origin = index
            result = nearest_neighbor_algorithm(playlist, origin)
            all_nearest_neighbor_route << result[0]
            if(total_distance > result[1])
                final_playlist = result[0]
                total_distance = result[1]
            end
            index += 1
        end
    end
    return [final_playlist, total_distance, all_nearest_neighbor_route]
end
def nearest_neighbor_algorithm(playlist, start)
    n = playlist.length
    final_playlist = Array.new()
    child = Array.new(n - 1)
    next_distance = Array.new(n - 1)
    song_visited = Array.new(n - 1, false)
    current_point = start
    song_visited[current_point] = true
    current_track = playlist[current_point]
    final_playlist << current_track
    visited_songs = 1
    total_distance = 0
    while(visited_songs < n)
        index = 0
        distance = 1e7
        while(index < n)
            next_track = playlist[index]
            if(index == current_point || song_visited[index] == true)
                index += 1
                next
            end

            euclidean_distance = euclidean_distance_calculation(current_track, next_track)
            if(distance > euclidean_distance)
                distance = euclidean_distance
                child[current_point] = index
                next_distance[current_point] = distance
            end
            index += 1
        end
        visited_songs += 1
        total_distance += distance
        current_point = child[current_point]
        current_track = playlist[current_point]
        song_visited[current_point] = true
        final_playlist << current_track
    end
    return [final_playlist, total_distance]
end
# Using bitmask dynamic programming with top-down apporach
class Dynamic_Programming
    # Initialize DP array for memoization
    def initialize(playlist_length)
        @dp = Array.new(playlist_length){ Array.new(1 << playlist_length, 0)}
        @par = Array.new(playlist_length){ Array.new(1 << playlist_length, 0)}
    end
    # This function calculates euclidean distance in Dynamic_Programming class
    def euclidean(current_track, next_track)
        return Math.sqrt((current_track.features.valence.to_f - next_track.features.valence.to_f)**2 +
                        (current_track.features.energy.to_f - next_track.features.energy.to_f)**2 +
                        (current_track.features.danceability.to_f - next_track.features.danceability.to_f)**2)
    end
    # This function is for binary presentation of bitmask
    def binary_presentation(bitmask)
        str = ""
        while(bitmask > 0)
            str += bitmask % 2 == 1 ? "1" : "0"
            bitmask /= 2
        end
        if(str == "")
            return "0"
        end
        return str.reverse!
    end

    # This function is using memoization recursion approach (dynamic programming top-down) to solve "Open Traveling Salesman Problem" (OTSP)
    # Arguments: last is the index of the song being processed in the current stack
    # Subproblems:
    # If we want to calculate the path that song[last] is the last point,
    # we will iterate through an index and calculate the path that song[index] is the last point before adding the last song to the total distance,
    # and in song[index] we will again iterate through another index and the recursion will continue
    # until it returns a value when the number of bits are 2 or 1
    def OTSP(playlist, last, bitmask)
        if(@dp[last][bitmask] != 0)
            return @dp[last][bitmask]
        end
        n = playlist.length
        index = 0
        pair = Array.new()
        while(index < n)
            if(bitmask & (1 << index) != 0)
                pair << index
            end
            index += 1
        end
        # If the current route have two cities, returns the distance between these cities
        if(pair.length == 2)
            @dp[pair[0]][bitmask] = euclidean(playlist[pair[0]], playlist[pair[1]])
            @dp[pair[1]][bitmask] = @dp[pair[0]][bitmask]
            @par[last][bitmask] = last == pair[1] ? pair[0] : pair[1]
            return @dp[pair[0]][bitmask]
        # If the current route have one city, returns 0
        elsif(pair.length <= 1)
            @par[last][bitmask] = last
            @par[last][0] = last
            return 0
        end
        res = 1e7
        index = 0
        while(index < n)
            # This iterate each bit of the bitmask
            if(last != index && (bitmask & (1 << index)) != 0)
                total_distance = OTSP(playlist, index, bitmask & (~(1 << last))) + euclidean(playlist[last], playlist[index])
                if(res > total_distance)
                    res = total_distance
                    @par[last][bitmask] = index
                end
            end
            index += 1
        end
        @dp[last][bitmask] = res
        return res
    end

    def current_route(playlist, last, bitmask)
        n = playlist.length
        route = Array.new()
        visited = 0
        while(visited < n)
            route << playlist[last]
            temp = @par[last][bitmask]
            bitmask &= (~(1 << last))
            last = temp
            visited += 1
        end
        return route
    end
end
# Solving Open Travelling salesman problem with Dynamic Programming (For Report Data Experiments Proof)
def dynamic_programming_OTSP(playlist)
    n = playlist.length
    result = Dynamic_Programming.new(n)
    total_distance = 1e7
    route = Array.new()
    index = 0
    while(index < n)
        distance = result.OTSP(playlist, index, (1 << n) - 1)
        if(total_distance > distance)
            total_distance = [total_distance, distance].min
            route = result.current_route(playlist, index, (1 << n) - 1)
        end
        index += 1
    end
    return [route, total_distance]
end
# Calculating chrosome fitness of Genetic Algorithm
def genetic_fitness(candidate)
    index = 1
    total_distance = 0
    while(index < candidate.length)
        total_distance += euclidean_distance_calculation(candidate[index], candidate[index - 1])
        index += 1
    end
    return total_distance
end
# Perform selection for best parents
def genetic_selection(population, eliteSize, parentsSize)
    parents = Array.new()
    eliteParents = Array.new()
    # Ranking Selection with eliteSize
    fitness_pool = Array.new(){Array.new()}
    index = 0
    while(index < population.length)
        fitness_pool << [population[index], genetic_fitness(population[index])]
        index += 1
    end
    # Sort the fitness_pool by comparing the fitness value from lowest to highest
    ranking = fitness_pool.sort {|a,b| a[1] <=> b[1]}
    index = 0
    while(index < eliteSize)
        eliteParents << ranking[index][0]
        parents << ranking[index][0]
        index += 1
    end
    # current index will now 5
    # Tournament Selection for the remaining 5 parents
    visited = Array.new(population.length, 0)
    while(parents.length < parentsSize)
        select_1 = rand(index...population.length - 1)
        select_2 = rand(index...population.length - 1)
        while(select_2 == select_1)
            select_2 = rand(index...population.length - 1)
        end
        select_1_fitness = genetic_fitness(population[select_1])
        select_2_fitness = genetic_fitness(population[select_2])
        if(select_1_fitness < select_2_fitness && visited[select_1] == 0)
            parents << population[select_1]
            visited[select_1] = 1
        elsif(visited[select_2] == 0)
            parents << population[select_2]
            visited[select_2] = 1
        end
    end
    return [parents, eliteParents]
end
# Perform Genetic Algorithm Mutation with 20% chance
def genetic_mutation(offspring)
    rand_1 = rand(0..offspring.length - 1)
    rand_2 = rand(0..offspring.length - 1)
    while(rand_1 == rand_2)
        rand_1 = rand(0..offspring.length - 1)
        rand_2 = rand(0..offspring.length - 1)
    end
    temp = offspring[rand_1]
    offspring[rand_1] = offspring[rand_2]
    offspring[rand_2] = temp
    return offspring
end
# Perform Genetic Algorithm Crossover
def genetic_crossover(parents, offspringSize, mutationRate)
    # Perform two-point crossover
    offsprings = Array.new()
    visited = Array.new(parents.length){Array.new(parents.length, 0)}
    while(offsprings.length < offspringSize)
        offspring = Array.new()
        rand_1 = rand(0..parents.length - 1)
        rand_2 = rand(0..parents.length - 1)
        while(visited[rand_1][rand_2] == 1 || rand_1 == rand_2)
            rand_1 = rand(0..parents.length - 1)
            rand_2 = rand(0..parents.length - 1)
        end
        parent_1 = parents[rand_1]
        parent_2 = parents[rand_2]
        parent_index_2 = Array.new(parent_2.length)
        index = 0
        while(index < parent_1.length)
            jndex = 0
            while(jndex < parent_2.length)
                if(parent_1[index] == parent_2[jndex])
                    parent_index_2[jndex] = index
                end
                jndex += 1
            end
            index += 1
        end
        # puts "#################"
        # output_playlist(parent_1)
        # output_playlist(parent_2)
        rand_point_1 = rand(1..parent_1.length - 2)
        rand_point_2 = rand(1..parent_1.length - 2)
        while(rand_point_1 == rand_point_2)
            rand_point_1 = rand(1..parent_1.length - 2)
            rand_point_2 = rand(1..parent_1.length - 2)
        end
        point_1 = [rand_point_1, rand_point_2].min
        point_2 = [rand_point_1, rand_point_2].max
        crossover_chromosome = parents[rand_1].slice(point_1, point_2 - point_1 + 1)
        contained = Array.new(parent_1.length, 0)
        index = point_1
        while(index <= point_2)
            contained[index] = 1
            index += 1
        end
        index = 0
        while(offspring.length < parent_2.length)
            if(offspring.length == point_1)
                offspring.concat(crossover_chromosome)
            end
            if(parent_index_2[index] != nil && contained[parent_index_2[index]] == 0)
                offspring << parent_2[index]
            end
            index += 1
        end
        mutation = rand(0...100)
        if(mutation <= mutationRate)
            temp = genetic_mutation(offspring)
            if(genetic_fitness(temp) < genetic_fitness(offspring))
                offspring = temp
            end
        end
        offsprings << offspring
        visited[rand_1][rand_2] = 1
        visited[rand_2][rand_1] = 1
    end
    return offsprings
end
# Perform Playlist Evaluation after performing genetic algorithm to get the best total distance
def genetic_evaluation(population)
    index = 0
    total_distance = 1e7
    result = Array.new(2)
    while(index < population.length)
        distance = genetic_fitness(population[index])
        if(total_distance > distance)
            total_distance = distance
            result[1] = total_distance
            result[0] = population[index]
        end
        index += 1
    end
    return result
end
# Check if the playlist has already existed in the population pool
def existed_route(route, population)
    index = 0
    while(index < population.length)
        if(route == population[index])
            return true
        end
        index += 1
    end
    return false
end
# Perform Genetic Algorithm to solve Open Traveller Salesman Problem
def genetic_algorithm_OTSP(iterations, playlist, initial_population, initial_population_size, population_size)
    population = Array.new()
    index = 0
    while(index < [initial_population_size, initial_population.length].min)
        population << initial_population[index]
        index += 1
    end
    while(population.length < population_size - population.length)
        temp = playlist.shuffle()
        while(existed_route(temp, population) == true)
            temp = playlist.shuffle()
        end
        population << temp
    end
    # population.each do |order|
    #     output_playlist(order)
    #     puts "######################"
    # end
    iteration = 0
    eliteSize = population_size / 10
    parentsSize = population_size / 4
    mutationRate = 20 # 20% rate of mutation
    while(iteration < iterations)
        results = genetic_selection(population, eliteSize, parentsSize)
        parents = results[0]
        eliteParents = results[1]
        offspringSize = population_size - eliteParents.length
        offsprings = genetic_crossover(parents, offspringSize, mutationRate)
        population = Array.new()
        eliteParents.each do |elite|
            population << elite
        end
        offsprings.each do |candidate|
            population << candidate
        end
        iteration += 1
    end
    result = genetic_evaluation(population)
    return result
end
# Display result playlist in smooth_transition_playlist function
def output_playlist(playlist)
    index = 0
    n = playlist.length
    while(index < n)
        track = playlist[index]
        puts "Name: #{track.name}"
        puts "Artist: #{track.artist}"
        # puts "Genre: #{track.genre}"
        # puts "Year: #{track.year}"
        # puts "Popularity: #{track.features.popularity}"
        # puts "Acousticness: #{track.features.acousticness}"
        # puts "Valence: #{track.features.valence}"
        # puts "Energy: #{track.features.energy}"
        # puts "Danceability: #{track.features.danceability}"
        # puts "Speechiness: #{track.features.speechiness}"
        # puts "Tempo: #{track.features.tempo}"
        puts "-----------------------------"
        index += 1
    end
end
# Returns playlist total distances
def output_playlist_total_distance(playlist)
    index = 1
    total_distance = 0
    while(index < playlist.length)
        total_distance += euclidean_distance_calculation(playlist[index], playlist[index - 1])
        index += 1
    end
    return total_distance
end
# Reordering the playlist with smooth-transition by combining Repeated Nearest Neighbor Algorithm (RNN) and Genetic Algorithm (GA)
def smooth_transition_playlist(playlist)

    #######################
    elite = nearest_neighbor_type(playlist, NearestNeighbor::REPEATED) # Repeated Nearest Neighbor -> Get elite parents
    initial_population = elite[2]
    #######################

    #######################
    # Genetic Algorithm Combine with Repeated Nearest Neighbor Elite Parents
    initial_population_size = 50
    population_size = 100
    iterations = 20
    result = genetic_algorithm_OTSP(iterations, playlist, initial_population, initial_population_size, population_size)
    return result[0]
    #######################
end
##########################################################
# Perform Playlist Generation with Recommendation System
def playlist_generation(tracks_storage, target, popularity_required, same_genres_required)
    chosen_track_index = most_similar_track_selection(tracks_storage, target, popularity_required, same_genres_required)
    playlist = neighbor_of_center_track(tracks_storage, chosen_track_index, target, popularity_required, same_genres_required)
    unprocessed_total_distance = output_playlist_total_distance(playlist) # Total Distance with smooth-transition process
    final_playlist = smooth_transition_playlist(playlist)
    total_distance = output_playlist_total_distance(final_playlist) # Total Distance of Smooth-transition playlist
    return [final_playlist, unprocessed_total_distance, total_distance]
end
##########################################################
# Perform Playlist Generation with Custom Preferences
def playlist_generation_based_on_custom_preferences(tracks_storage, artists_storage, genres_storage, custom_preferences, history_preferences, popularity_required, same_genres_required)
    target_artist =artists_storage[custom_preferences[0][0]].chomp()
    target_genre = genres_storage[custom_preferences[1][0]].chomp()
    target_decade = history_preferences.decade
    target_acousticness = history_preferences.acousticness
    target_speechiness = history_preferences.speechiness
    target_tempo = history_preferences.tempo
    target_valence = 0.0
    target_energy = 0.0
    target_danceability = 0.0
    target_options = [0.15, 0.5, 0.85]
    index = 1
    while(index < custom_preferences.length)
        jndex = 0
        while(jndex < custom_preferences[index].length)
            if(custom_preferences[index][jndex] == true)
                case index
                when 1
                    target_valence = target_options[jndex]
                when 2
                    target_energy = target_options[jndex]
                when 3
                    target_danceability = target_options[jndex]
                end
            end
            jndex += 1
        end
        index += 1
    end
    target = Target.new(target_artist, target_genre, target_decade, target_acousticness, target_valence, target_energy, target_danceability, target_speechiness, target_tempo)
    return playlist_generation(tracks_storage, target, popularity_required, same_genres_required)
end
##########################################################
# Returns Playlist Generation based on popularity
def playlist_generation_based_on_popularity(tracks_storage, playlist_size, restriction_type, restriction)
    index = 0
    current_playlist = Array.new()
    while(index < tracks_storage.length)
        case restriction_type
        when "Genre"
            if(tracks_storage[index].genre != restriction)
                index += 1
                next
            end
        when "Artist"
            if(tracks_storage[index].artist != restriction)
                index += 1
                next
            end
        when "Decade"
            if(tracks_storage[index].year / 10 * 10 != restriction)
                index += 1
                next
            end
        end
        current_playlist << [tracks_storage[index], tracks_storage[index].features.popularity]
        index += 1
    end
    # Sort the array by comparing the popularity value from highest to lowest
    current_playlist = current_playlist.sort {|a,b| a[1] <=> b[1]}.reverse
    # Only produce playlist with certain size
    index = 0
    sorted_playlist = Array.new()
    while(sorted_playlist.length < [current_playlist.length, playlist_size].min)
        sorted_playlist << current_playlist[index][0]
        index += 1
    end
    unprocessed_total_distance = output_playlist_total_distance(sorted_playlist)

    # Perform OTSP Solving to create smooth-transition playlist
    final_playlist = smooth_transition_playlist(sorted_playlist)

    smooth_total_distance = output_playlist_total_distance(final_playlist)
    return [final_playlist, unprocessed_total_distance, smooth_total_distance]
end
##########################################################
# Perform Playlist Generation with Random Preferences
def playlist_generation_based_on_random_criteria(type, playlist_size, generated_check, storage_type, tracks_storage)
    restriction = nil
    case type
    when "All"
        restriction = ["All", nil]
    when "Genre" # Random genres in genres_storage
        index = rand(0..storage_type.length - 1)
        while(generated_check[index] == true)
            index = rand(0..storage_type.length - 1)
        end
        restriction = ["Genre", storage_type[index]]
    when "Artist" # Random artists in artists_storage
        index = rand(0..storage_type.length - 1)
        restriction = ["Artist", storage_type[index]]
    when "Decade" # Random decade in decade_storage
        index = rand(0..storage_type.length - 1)
        #Extracts the numberic part of the decade string
        required_decade = storage_type[index][/\d+/].to_i
        restriction = ["Decade", required_decade]
    end
    return [index, playlist_generation_based_on_popularity(tracks_storage, playlist_size, restriction[0], restriction[1])]
end

##########################################################
# Playlist Generation based on history interaction
INTERACTION_HISTORY_FILE_NAME = "config/historyinteractions.txt"
def calculate_user_interaction_to_preferences_weight(artists_storage, genres_storage, decades_storage, preferences_array, track, score)
    artist_preferences = preferences_array[0].clone
    genres_preferences = preferences_array[1].clone
    decades_preferences = preferences_array[2].clone
    acousticness_preferences = preferences_array[3].clone
    valence_preferences = preferences_array[4].clone
    energy_preferences = preferences_array[5].clone
    danceability_preferences = preferences_array[6].clone
    speechiness_prefererences = preferences_array[7].clone
    tempo_preferences = preferences_array[8].clone
    ######################
    ## Plus score to the counting array if the interacted tracks artist match
    index = 0
    while(index < artists_storage.length)
        if(artists_storage[index] == track.artist)
            artist_preferences[index] += score
            break
        end
        index += 1
    end
    ######################
    ## Plus score to the counting array if the interacted tracks genre match
    index = 0
    while(index < artist_preferences.length)
        if(genres_storage[index] == track.genre)
            genres_preferences[index] += score
            break
        end
        index += 1
    end
    ######################
    ## Plus score to the counting array if the interacted tracks decade match
    index = 0
    while(index < artist_preferences.length)
        #Extracts the numberic part of the decade string
        current_decade = decades_storage[index][/\d+/].to_i
        if(current_decade == track.year.to_i / 10 * 10)
            decades_preferences[index] += score
            break
        end
        index += 1
    end
    features = [track.features.acousticness, track.features.valence, track.features.energy, track.features.danceability, track.features.speechiness, track.features.tempo]
    preferences = [acousticness_preferences, valence_preferences, energy_preferences, danceability_preferences, speechiness_prefererences, tempo_preferences]
    # Audio Features Array User Interaction Counting: 0, 0.05, 0.1, 0.15, ... , 1 for Acousticness, Valence, Energy and Danceability
    standardize_value = 0.05
    index = 0
    while(index < 4)
        preferences[index] = calculating_features_index(preferences[index], features[index], standardize_value, score)
        index += 1
    end
    # Audio Features Array User Interaction Counting: 0, 0.02, 0.04, 0.06, ... , 0.4 for Speechiness
    standardize_value = 0.02
    preferences[index] = calculating_features_index(preferences[index], features[index], standardize_value, score)
    index += 1
    # Audio Features Array User Interaction Counting: 0, 10, 20, 30, ... , 200 for Tempo
    standardize_value = 10
    preferences[index] = calculating_features_index(preferences[index], features[index], standardize_value, score)
    acousticness_preferences = preferences[0].clone
    valence_preferences = preferences[1].clone
    energy_preferences = preferences[2].clone
    danceability_preferences = preferences[3].clone
    speechiness_prefererences = preferences[4].clone
    tempo_preferences = preferences[5].clone
    return [artist_preferences, genres_preferences, decades_preferences, acousticness_preferences, valence_preferences, energy_preferences, danceability_preferences, speechiness_prefererences, tempo_preferences]
end

# Calculating index of a preference array that track feature is belonging to
def calculating_features_index(preference_type, feature_value, standard_value, score)
    feature_value = feature_value.to_f
    floor_index = (feature_value / standard_value).round(0)
    final_index = feature_value - standard_value * floor_index > standard_value / 2 ? floor_index + 1 : floor_index
    preference_type[final_index] += score
    return preference_type
end
# Reading user interaction history from historyinteractions.txt file
def calculate_user_interactions_history_from_files(artists_storage, genres_storage, decades_storage, tracks_storage)
    artist_preferences = Array.new(artists_storage.length, 0)
    genres_preferences = Array.new(genres_storage.length, 0)
    decades_preferences = Array.new(decades_storage.length, 0)
    # Audio Features Array User Interaction Counting: 0, 0.05, 0.1, 0.15, ... , 1 for Acousticness, Valence, Energy and Danceability
    acousticness_preferences = Array.new(21, 0)
    valence_preferences = Array.new(21, 0)
    energy_preferences = Array.new(21, 0)
    danceability_preferences = Array.new(21, 0)
    # Audio Features Array User Interaction Counting: 0, 0.02, 0.04, 0.06, ... , 0.4 for Speechiness
    speechiness_prefererences = Array.new(21, 0)
    # Audio Features Array User Interaction Counting: 0, 10, 20, 30, ... , 200 for Tempo
    tempo_preferences = Array.new(21, 0)
    # Returns array with 0 counting for user interactions history array
    if (Dir.glob(INTERACTION_HISTORY_FILE_NAME).any? == false)
        return [artist_preferences, genres_preferences, decades_preferences, acousticness_preferences, valence_preferences, energy_preferences, danceability_preferences, speechiness_prefererences, tempo_preferences]
    else
        file_data = File.open(INTERACTION_HISTORY_FILE_NAME, "r")
        number_of_interactions = file_data.gets().chomp().to_i
        index = 0
        score_weight = 1 # The older the interaction is, the less weight that interaction will
        compressed_preferences = [artist_preferences, genres_preferences, decades_preferences, acousticness_preferences, valence_preferences, energy_preferences, danceability_preferences, speechiness_prefererences, tempo_preferences]
        while(index < number_of_interactions)
            track_location = file_data.gets().chomp()
            interaction_score = file_data.gets().chomp().to_f
            track = nil
            # Getting track index in the tracks_storage by comparing file location
            track_index = 0
            while(track_index < tracks_storage.length)
                if(track_location == tracks_storage[track_index].location)
                    track = tracks_storage[track_index]
                    break
                end
                track_index += 1
            end
            if(track != nil)
                preferences = calculate_user_interaction_to_preferences_weight(artists_storage, genres_storage, decades_storage, compressed_preferences, track, (interaction_score * score_weight).round(5)) # The older the interaction is, the less weight that interaction will
                compressed_preferences = preferences.clone
            end
            index += 1
            score_weight *= 0.90 # The older the interaction is, the less weight that interaction will
        end
        file_data.close()
        return preferences
    end
end
# Finding the index of a categories storage that have the most interactions defining by score
def find_categories_index_with_most_interactions(preferences_storage)
    index = 0
    maximum_interactions = 0
    maximum_interaction_index = 0
    while(index < preferences_storage.length)
        if(preferences_storage[index] > maximum_interactions)
            maximum_interactions = preferences_storage[index]
            maximum_interaction_index = index
        end
        index += 1
    end
    return maximum_interaction_index
end
# Returns a target preferences based on user history interactions
def calculation_target_preferences_based_on_history(preferences, artists_storage, genres_storage, decades_storage, tracks_storage)
    target_array = Array.new()
    artist_preferences = preferences[0].clone
    target_array << artists_storage[find_categories_index_with_most_interactions(artist_preferences)]
    genres_preferences = preferences[1].clone
    target_array << genres_storage[find_categories_index_with_most_interactions(genres_preferences)]
    decades_preferences = preferences[2].clone
    target_array << decades_storage[find_categories_index_with_most_interactions(decades_preferences)][/\d+/].to_i
    # Audio Features Array User Interaction Counting: 0, 0.05, 0.1, 0.15, ... , 1 for Acousticness, Valence, Energy and Danceability
    index = 3
    while (index < 7)
        current_preferences = preferences[index].clone
        target_array << find_categories_index_with_most_interactions(current_preferences) * 0.05
        index += 1
    end
    speechiness_prefererences = preferences[7].clone
    target_array << find_categories_index_with_most_interactions(speechiness_prefererences) * 0.02
    # Audio Features Array User Interaction Counting: 0, 10, 20, 30, ... , 200 for Tempo
    tempo_preferences = preferences[8].clone
    target_array << find_categories_index_with_most_interactions(tempo_preferences) * 10
    target = Target.new(target_array[0], target_array[1], target_array[2], target_array[3], target_array[4], target_array[5], target_array[6], target_array[7], target_array[8])
    return target
end
# Generationg Playling based on user history interactions
def playlist_generation_based_on_history(tracks_storage, target, popularity_required, same_genres_required)
    return playlist_generation(tracks_storage, target, popularity_required, same_genres_required)
end
# Creating or modifying historyinteractions.txt
def creating_and_modify_user_interaction_history_file(track_location, score)
    # Creating historyinteractions.txt if it doesn't exist
    if (Dir.glob(INTERACTION_HISTORY_FILE_NAME).any? == false)
        file_data = File.new(INTERACTION_HISTORY_FILE_NAME, "w")
        file_data.puts(1)
        file_data.puts(track_location)
        file_data.puts(score)
        file_data.close()
    else # Modifying historyinteractions.txt if it does exist
        file_data = File.open(INTERACTION_HISTORY_FILE_NAME, "r")
        number_of_interactions = file_data.gets().chomp().to_i
        interactions = Array.new(number_of_interactions)
        index = number_of_interactions - 1
        while(index >= 0)
            stored_track_location = file_data.gets().chomp()
            stored_interaction_score = file_data.gets().chomp()
            interactions[index] = [stored_track_location, stored_interaction_score]
            index -= 1
        end
        maximum_interactions = 100
        # The maximum number of interactions is 100 -> Pop the oldest interaction out to push the new interaction in
        if(interactions.length == maximum_interactions)
            interactions.delete_at(0)
            interactions << [track_location, score]
        else
            interactions << [track_location, score]
        end
        file_data.close()
        # Rewrites (modify) a new file
        file_data = File.new(INTERACTION_HISTORY_FILE_NAME, "w")
        file_data.puts(interactions.length)
        index = interactions.length - 1
        while(index >= 0)
            file_data.puts(interactions[index][0])
            file_data.puts(interactions[index][1])
            index -=1
        end
        file_data.close()
    end
end
