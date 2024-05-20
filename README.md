# Songbird
Lua Mod for Morrowind that allows you to choose a song to play from among your installed music tracks.

* See which music tracks you have installed in Explore and Battle folders
* See which song is currently playing
* Select an individual track to play without having to wait for the music engine to randomly select it
* Hotkey to quickly get to the songs menu. Default: # (may be \ BACKSLASH depending on your keyboard layout)
* Custom playlist: any songs you put in "Data Files/Music/Songbird" will show up in the "Custom" menu. They're available to play, but won't play automatically like the Battle or Explore tracks.

## Known Issues
* As of v1.1 there are no longer any known issues, other than the Currently Playing ui being a bit slow to update.

## Changelog
### Version 1.1
* Added Herbert's fix for the crash that happened if you closed the UI too soon after choosing a song
* Removed the workaround that let you disable the "currently playing" ui because it's now obsolete
* Some code tidying
* Any songs you put in the "Data Files/Music/Songbird" folder will now be available under the "Custom" menu. Ideal for songs you don't want to show up in your Explore or Battle rotations, but still want to play occasionally.
* Added some error handling for songs that are in your favourites but whose underlying files have been removed. It will no longer crash, instead it will produce a popup telling you to remove the song from favourites.

### Version 1.0
* After a number of complete rewrites, basic features are now working. We're ready to go!

### Version 0.03
* Hotkey is working (thanks Herbert!)
* Favourites are working - as long as you restart the game. Still need to sort out real-time refreshing.

### Version 0.02
* Refactored mcm to automatically generate pages from folders defined in config
* Refactored logging
* Added hotkey configuration (but using the hotkey to open the menu doesn't work yet)
* Added credits

### Version 0.01
* See which music tracks you have installed in Explore and Battle folders
* See which song is currently playing
* Select an individual track to play without having to wait for the music engine to randomly select it