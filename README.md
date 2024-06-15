# Origami Musica
### Origami Musica - Basic Music Player in Ruby.
This program is created using Ruby with Gosu library by Viet Hoang Pham. This is my project for an unit (Introduction To Programming) during my undergraduate program. 

### Music Player Functionalities (more details in reports folder):
-	**Categories:** Users can interact with the categories bar to filter albums based on their selected genres/artists/decades.
-	**Albums Display:** The Home Page will display available albums, and the ability to scroll through all albums by clicking on the arrow at the top right. There are a maximum of 4 albums on each page.
-	**Create Playlist:** The user can type a name when they want to create a new playlist.
-	**Tracks Display:** This page will display all available tracks in the album, and the ability to scroll through all tracks by clicking on the arrows at the top right. There are a maximum of 8 tracks on each page.
-	**Add to Playlist:** When the user hovers over a track, they can click on “Add to Playlist”.
-	**Add Tracks To Playlist:** The user can either cancel or add track to the playlist. After adding a track to the playlist, there will be a notification box appear.
-	**Notification Box**: When a user interaction needs to be notified, the notification box will appear and automatically close in 5 seconds.
-	**Tracks Display:** This page will display all tracks in the selected playlist, and the ability to scroll through all tracks by clicking on the arrows at the top right. There are a maximum of 8 tracks on each page.
-	**Some Playlist Operations (Delete Playlist, Delete Track From Playlist, Rename Playlist, …)** will be documented in the Playlist Operations in Origami Musica Functionalities.
-	**Approximately Track Searching:** By using the Restricted Danmereu-Levenshtein Algorithm, the user can search for the track they want in the music player, even if they make two or three typos in the track name (maximum typos is 7). The user can also search for the keyword in a track with a long name.
-	**Initial Generation Playlist:** The initial generation playlist will be generated when the user opens the music player (the music player must contain tracks to show this page). These playlists are not personalized because the program will choose random genres/artists/decades and the playlists will contain popular tracks starting from the most popular.
-	**Personalized Generation Playlists:** By tracking user interactions history and storing it in historyinteractions.txt, the playlists will be generated based on the most interactions genres, artists, decades, and audio features, …. The user can also choose their preferences for the playlist. 
-	**Smooth-Transition Playlist Generation:** After the initial playlists or personalized playlists have been created, the program performs the last step that reorders the track's position in the playlist making the tracks transition in the playlist as smooth as possible by using Open Travelling Salesman to order it based on valence, danceability, ... 
-	**Save the generated playlist to playlist libraries:** The user can save these generated playlists into their playlist libraries.

### You can access reports folder to read more about the program or watch the following videos:
[Short-Version Video (5 mins, no explaination)](https://drive.google.com/file/d/18P8v_e14zT99Q7gjewNO5JHIDiBcdO9n/view?usp=drive_link)

[Long-Version Video (28 mins, speed up)](https://drive.google.com/file/d/1DnxV169BNHJivuwf03-nTw7p60VXRCmz/view?usp=drive_link)
