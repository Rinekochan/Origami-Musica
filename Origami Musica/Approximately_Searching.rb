# Calculating Edit Distance for the current string and target string using Restricted Danmereu-Levenshtein Distancve
def danmereu_levenshtein_distances(s1, s2, threshold)
    s1 = " " + s1
    s2 = " " + s2
    # Create 2D Array to calculate edit distance
    dis = Array.new(s1.length){Array.new(s2.length, 10000000)}
    # Intialize the array
    dis[0][0] = 0
    index = 1
    while(index < s1.length)
        dis[index][0] = index
        index += 1
    end
    index = 1
    while(index < s2.length)
        dis[0][index] = index
        index += 1
    end
    # Using Dynamic Programming to implement Damereu-Levenshtein distance
    # Optimize the algorithm: Maximum insertion or deletion is a threshold value (Restricted Damereu-Levenshtein distance)
    # By optimizing, time complexity is reduced to O(s1.length * 2 * threshold). 2 * threshold should be lower than 20.
    index1 = 1
    while(index1 < s1.length)
        index2 = [1, index1 - threshold].max
        # dis[index1 - 1][index2] is the number of edit distances to change the string s1 at length index1 - 1 to string s2 at length index2  => Delete
        # dis[index1][index2 - 1] is the number of edit distances to change the string s1 at length index1 to string s2 at length index2 - 1  => Insert
        # dis[index1 - 1][index2 - 1] is the number of edit distances to change the string s1 at length index1 - 1 to string s2 at length index2 - 1 => Replace
        # dis[index1 - 2][index2 - 2] is the number of edit distances to change the string s1 at length index1 - 2 to string s2 at length index2 - 2 => Transpositions
        while(index2 < [index1 + threshold, s2.length].min)
            similarity_check = (s1[index1] != s2[index2]) ? 1 : 0

            dis[index1][index2] = [dis[index1 - 1][index2] + 1, dis[index1][index2 - 1] + 1, dis[index1 - 1][index2 - 1] + similarity_check].min
            if(index1 > 1 && index2 > 1 && s1[index1] == s2[index2 - 1] && s1[index1 - 1] == s2[index2])
                dis[index1][index2] = [dis[index1][index2], dis[index1 - 2][index2 - 2] + 1].min
            end

            index2 += 1
        end
        index1 += 1
    end
    return dis[s1.length - 1][s2.length - 1]
end

# This function convert edit distances to similarity %
def danmereu_levenshtein_similarity(s1, s2, threshold)
    distances = danmereu_levenshtein_distances(s1, s2, threshold)
    similarity_percentage = (1 - distances.to_f / [s1.length, s2.length].max) * 100.0
    return similarity_percentage.round(2)
end

# Processing String (Divide into substrings if the target string is longer than the query string)
def string_processing(s1, s2, threshold)
    s1 = s1.downcase
    s2 = s2.downcase

    if(s1 == s2)
        return 100.0
    end

    s1_split = s1.split
    s2_split = s2.split
    if(s1_split.length >= s2_split.length)
        result = danmereu_levenshtein_similarity(s1, s2, threshold)
        return result < 0 ? 0.0 : result
    else
        # If the user is searching for the keyword of a song name, split the song name to substrings with same length of searching string
        s2_current = ""
        index = 0
        while(index < s1_split.length)
            s2_current += "#{s2_split[index]} "
            index += 1
        end
        s2_current.strip!
        # puts "\"#{s2_current}\""

        maximum_similarity = danmereu_levenshtein_similarity(s1, s2_current, threshold)
        # If the similarity is already high, return the value
        if(maximum_similarity >= 80)
            return maximum_similarity
        elsif(maximum_similarity <= 0)
            return 0.0
        end

        # Using Sliding Window Technique for Approximately Matching Substring. Worst Case Time Complexity: O(s2_split.length - s1_split.length + 1)
        left = 0
        right = s1_split.length - 1
        while(left <= right && right < s2_split.length - 1)
            s2_current.delete_prefix!(s2_split[left])
            if(right + 1 < s2_split.length)
                s2_current += " #{s2_split[right + 1]} "
            end
            s2_current.strip!
            # puts "\"#{s2_current}\""

            maximum_similarity = [maximum_similarity, danmereu_levenshtein_similarity(s1, s2_current, threshold)].max
            if(maximum_similarity >= 80)
                return maximum_similarity
            elsif(maximum_similarity <= 0)
                return 0.0
            end

            left += 1
            right += 1
        end
        return maximum_similarity
    end
    return nil
end
# Perform Approximately String Matching between query and checking string
def searching(searched_string, checking_string, threshold)
    # Best Case Time Complexity: O(searched_string * 2 * threshold)
    # Worst Case Time Complexity : O((number of checking_string words - number of searched_string words + 1) * searched_string.length * 2 * threshold)
    result = string_processing(searched_string, checking_string, 7)
    if(result != nil)
        return result
    end
end
# Perform Approximately String Matching between query and all tracks stored in @tracks_storage
def searching_query(searched_string, tracks_storage)
    similarity_sorted = Array.new(tracks_storage.length){Array.new(2)}
    index = 0
    while (index < tracks_storage.length)
        track_name = tracks_storage[index].name
        similarity_sorted[index][0] = index
        similarity_sorted[index][1] = searching(searched_string, track_name, 5)
        index += 1
    end

    # Sort the array by comparing the second value from highest to lowest
    similarity_sorted = similarity_sorted.sort {|a,b| a[1] <=> b[1]}.reverse
    top_results = Array.new(){Array.new()}
    index = 0
    while(index < 7)
        top_results << similarity_sorted[index]
        index += 1
    end
    index = 0
    while(index < top_results.length)
        track_index = top_results[index][0]
        puts "#{tracks_storage[track_index].name} - #{top_results[index][1]}"
        index += 1
    end
    return top_results
end
