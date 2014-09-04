try
	tell application "Google Chrome"
		set theURL to URL of (active tab of window 1)
		set theTitle to title of (active tab of window 1)
	end tell
	set crlf to (ASCII character 13) & (ASCII character 10)
	set theTitleLong to theTitle & ".url" as string
	set theTitleShort to first word of theTitle & ".url"
	set res to "[InternetShortcut]" & crlf & "URL=" & theURL & crlf & "IconIndex=0" & crlf
	do shell script "echo \"" & res & "\" > ~/Downloads/" & theTitleShort
	set theTitleShort to theTitleShort as string
	set source_folder to path to downloads folder as string
	set this_item to (source_folder & theTitleShort) as alias
	tell application "Finder"
		set the name of this_item to theTitleLong
	end tell
on error x
	display dialog x
end try

