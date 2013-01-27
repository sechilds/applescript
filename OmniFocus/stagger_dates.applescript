property defaultStartTime : 15 --default time to use (in hours, 24-hr clock)

tell application "OmniFocus"
	set will autosave of front document to false
	
	tell content of front document window of front document
		set validSelectedItemsList to value of (selected trees where class of its value is not item and class of its value is not folder)
		set timestamp to (current date) - (get time of (current date)) + (0 * 86400)
		
		repeat with thisItem in validSelectedItemsList
			if weekday of timestamp is Saturday then
				set timestamp to timestamp + (86400 * 2)
			else if weekday of timestamp is Sunday then
				set timestamp to timestamp + 86400
			end if
			
			set start date of thisItem to timestamp
			set start date of thisItem to timestamp + (defaultStartTime * 3600)
			
			set timestamp to timestamp + (86400 * 1)
		end repeat
	end tell
	
	set will autosave of front document to true
end tell
