(*
	# DESCRIPTION #
	
	This script clears the start and due dates of the currently selected actions or projects.
	
	
	# LICENSE #

	Copyright � 2010-2011 Dan Byler (contact: dbyler@gmail.com)
	Licensed under MIT License (http://www.opensource.org/licenses/mit-license.php)
	(TL;DR: no warranty, do whatever you want with it.)


	# CHANGE HISTORY #


	0.4 (2011-07-07)
	-	Added ability to specify a new context for cleared items (off by default; change this in the
		script settings below)
	-	No longer fails when a Grouping divider is selected
	-	Reorganized; incorporated Rob Trew's method to get items from OmniFocus
	-	Fixes potential issue when launching from OmniFocus toolbar
	-	Added to GitHub repo

	0.3 "Someday Branch" 2010-11-03: Added option to change context 
	0.2b 2010-06-22: Re-fixed autosave
	0.2 2010-06-21: Encapsulated autosave in "try" statements in case this fails
	0.1: Initial release.


	# INSTALLATION #

	1. Copy to ~/Library/Scripts/Applications/Omnifocus
 	2. If desired, add to the OmniFocus toolbar using View > Customize Toolbar... within OmniFocus



	# KNOWN ISSUES #
	-	None
		
*)

-- To change settings, modify the following properties
property changeContext : false --true/false; if true, set newContextName (below)
property newContextName : "Someday" --context the item will change to if changeContext = true

property showSummaryNotification : true --if true, will display success notifications
property useGrowl : true --if true (and showAlert is true), uses Growl for alerts

-- Don't change these
property alertItemNum : ""
property alertDayNum : ""
property dueDate : ""
property growlAppName : "OF Date Scripts"
property allNotifications : {"General", "Error"}
property enabledNotifications : {"General", "Error"}
property iconApplication : "OmniFocus.app"

on main()
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
			
			--Perform action
			set successTot to 0
			set autosave to false
			if changeContext then set newContext to my getContext(newContextName)
			repeat with thisItem in validSelectedItemsList
				if changeContext then set context of thisItem to newContext
				set succeeded to my clearDate(thisItem)
				if succeeded then set successTot to successTot + 1
			end repeat
			set autosave to true
		end tell
	end tell
	
	--Display summary notification
	if showSummaryNotification then
		set alertName to "General"
		set alertTitle to "Clear Dates Script complete"
		if successTot > 1 then set alertItemNum to "s"
		set alertText to "Date(s) cleared for " & successTot & " item" & alertItemNum & "." as string
		my notify(alertName, alertTitle, alertText)
	end if
end main

on getContext(contextName)
	tell application "OmniFocus"
		tell front document
			set contextID to id of item 1 of (complete contextName as context)
			return first context whose id is contextID
		end tell
	end tell
end getContext

on clearDate(selectedItem)
	set success to false
	tell application "OmniFocus"
		try
			set start date of selectedItem to missing value
			set due date of selectedItem to missing value
			set success to true
		end try
	end tell
	return success
end clearDate

on notify(alertName, alertTitle, alertText)
	if useGrowl then
		tell application "Growl"
			register as application growlAppName all notifications allNotifications default notifications enabledNotifications icon of application iconApplication
			notify with name alertName title alertTitle description alertText application name growlAppName
		end tell
	end if
end notify

main()
