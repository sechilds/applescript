tell application "Google Chrome"
	activate
	set myTab to make new tab at end of tabs of window 1
	set URL of myTab to "https://mail.google.com/mail/?ui=2&view=cm&fs=1&tf=1&shva=1"
end tell
