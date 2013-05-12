tell application "Transmit"
	set remoteFavorite to item 1 of (favorites whose name is "epri.wikispaces.com")
	set localPath to "~/epri_wikispaces/"
	
	tell current tab of (make new document at end)
		change location of local browser to path localPath
		connect to remoteFavorite
		
		synchronize remote browser to local browser
		close
	end tell
end tell
