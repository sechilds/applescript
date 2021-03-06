-- Includes pieces of scripts found at http://blog.zenspider.com/blog/2012/05/omnifocus-scripts.html

tell application "OmniFocus"
	tell content of front document window of front document
		--Get selection
		set validSelectedItemsList to value of (selected trees where class of its value is not item and class of its value is not folder)
		set totalItems to count of validSelectedItemsList
		if totalItems is 0 then
			return
		end if
		
		--Perform action
		set listOfItems to {}
		set AppleScript's text item delimiters to return
		repeat with thisItem in validSelectedItemsList
			set td to "☐ " & name of thisItem & "  "
			copy td to the end of listOfItems
		end repeat
	end tell
end tell

set the clipboard to listOfItems as string