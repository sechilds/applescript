property defaultStartTime : 15 --default time to use (in hours, 24-hr clock)

tell application "OmniFocus"
	set will autosave of front document to false
	
	tell content of front document window of front document
		set validSelectedItemsList to value of (selected trees where class of its value is not item and class of its value is not folder)
		set firstTask to value of first item of selected trees
		set timestamp to start date of firstTask
		
		repeat with thisItem in validSelectedItemsList
			set start date of thisItem to timestamp
			set forward_time to estimated minutes of thisItem
			if forward_time is missing value then
				set forward_time to 15
			end if
			set timestamp to timestamp + (forward_time * 60)
		end repeat
	end tell
	
	set will autosave of front document to true
end tell

