property StartTime : 6 --due time in hrs (24 hr clock)

--To enable alerts, change these settings to True _and_ uncomment
property showSummaryNotification : true --if true, will display success notifications
property useGrowl : true --if true, will use Growl for success/failure alerts

-- Don't change these
property alertItemNum : ""
property alertDayNum : ""
property dueDate : ""
property growlAppName : "OF Date Scripts"
property allNotifications : {"General", "Error"}
property enabledNotifications : {"General", "Error"}
property iconApplication : "OmniFocus.app"

on main()
	if not appIsRunning("Calendar") then
		tell application "Calendar"
			activate
		end tell
		tell application "System Events"
			set visible of process "Calendar" to false
		end tell
		delay 60
	end if
	
	tell application "Calendar"
		tell calendar "Stephen Childs (TripIt)"
			set theEventList to every event whose allday event is true and description does not contain "[Lodging]"
		end tell
		set dateList to {}
		repeat with theEvent in theEventList
			if (end date of theEvent) is greater than or equal to (current date) then
				set the end of dateList to ((end date of theEvent))
			end if
		end repeat
		set firstDate to first item of dateList
		-- return firstDate
	end tell
	tell application "System Events"
		set visible of process "Calendar" to false
	end tell
	
	
	tell application "OmniFocus"
		tell content of front document window of front document
			--Get selection
			set validSelectedItemsList to value of (selected trees where class of its value is not item and class of its value is not folder)
			set totalItems to count of validSelectedItemsList
			if totalItems is 0 then
				set alertName to "Error"
				set alertTitle to "Script failure"
				set alertText to "No valid task(s) selected"
				my notify(alertName, alertTitle, alertText)
				return
			end if
			
			--Calculate due date
			set dueDate to current date
			set theTime to time of dueDate
			
			--Perform action
			set successTot to 0
			set autosave to false
			repeat with thisItem in validSelectedItemsList
				set succeeded to my setDate(thisItem, firstDate, dueDate)
				if succeeded then set successTot to successTot + 1
			end repeat
			set autosave to true
		end tell
	end tell
	
	--Display summary notification
	if showSummaryNotification then
		if successTot > 1 then set alertItemNum to "s"
		set alertText to successTot & " item" & alertItemNum & " now starting on " & date string of (firstDate) & "." as string
		my notify("General", "After Trip Script complete", alertText)
	end if
end main

on setDate(selectedItem, startDate, dueDate)
	set success to false
	tell application "OmniFocus"
		try
			set originalStartDateTime to start date of selectedItem
			if (originalStartDateTime is not missing value) then
				-- Set new start date with original start time
				set start date of selectedItem to (startDate + (time of originalStartDateTime))
				set success to true
			else
				set start date of selectedItem to (startDate + (StartTime * hours))
				set success to true
			end if
		end try
	end tell
	return success
end setDate


on notify(alertName, alertTitle, alertText)
	display notification alertText with title alertName subtitle alertTitle
end notify

on appIsRunning(appName)
	tell application "System Events" to (name of processes) contains appName
end appIsRunning

main()

