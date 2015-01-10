-- this is the OmniFocus 2 Beta compatible version of the above
tell application "Mailplane 3"
	set theEmailUrl to currentURL
	set theSubject to currentTitle
	
	tell application "OmniFocus"
		set theTask to theSubject
		set theNote to theEmailUrl
		
		tell quick entry
			make new inbox task with properties {name:theTask, note:theNote}
			open
		end tell
		
		tell application "System Events"
			keystroke tab
		end tell
	end tell
end tell
