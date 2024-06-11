# This file read available albums in the music folder
require_relative 'Albums_Read.rb'
# This file store avaiable genres, artists, decades
require_relative 'Metadata_Storage.rb'
# This file store avaiable tracks
require_relative 'Tracks_Storage.rb'
# This file filter albums with required item in a category
require_relative 'Filter_Selection.rb'
# This file creates and modifies playlists.txt, read all saved playlists in playlists.txt
require_relative 'Playlists_File_Read_And_Modify.rb'
# This file provides functions to create and modify playlists
require_relative 'Playlists_Functions.rb'
# This file provides shuffle playlists/albums
require_relative 'Shuffle_Queue.rb'
# This file provides Approximately Searching Functionality
require_relative 'Approximately_Searching.rb'
# This file generates playlists based on user preferences and interactions
require_relative 'Playlists_Generation.rb'
