(*
	Add last sent email to OmniFocus Script
	by simplicitybliss.com, Sven Fechner
	
	Straight forward script that sends the last email sent in Mail.app to OmniFocus either using the Quick Entry window or silently (well, with Growl based notifications if desired) straight to the Inbox.
	
	You can influence how the task is named by modifying the PreFix and MidFix properties. The note of the task will contain a link back the email in Mail.app.
	
	Use the AppleScript Menu or tools likle FastScripts, Launchbar or Alfred to trigger the script.
				
	The script uses Growl from the App Store for feedback notification if it is installed and running. 
	
*)
--!! EDIT THE PROPERTIES BELOW TO MEET YOUR NEEDS !!--

-- Mail.app account for the sent mailbox the script should use
-- Note that although you can theoretically target the virtual sent mailbox of all Mail.app acocunts combined
-- AppleScript delivers very inconsistent results when doing so, hence this is not recommended
property theAccount : "Uottawa"

-- Open OmniFocus Quick Entry window (true) or add the task silently to the OmniFocus Inbox (false)?
property ShowQuickEntry : true

-- First text in the task name before the email recipient
property PreFix : "Waiting For"

-- Text between receipient name and subject in the task name
property MidFix : "to reply re"

-- Enable Growl notification when adding tasks to OmniFocus Inbox?
-- Growl is not used when using the Quick Entry window
property GrowlRun : true

-- !! STOP EDITING HERE IF NOT FAMILAR WITH APPLESCRIPT !! --

on run
	my addEMail()
end run

on alfred_script(q)
	my addEMail()
end alfred_script

-- Main functionality

on addEMail()
	try
		tell application "Mail"
			set theSentMailbox to mailbox "Sent" of account theAccount
			set lastMsg to first message in theSentMailbox
			set theSubject to subject of lastMsg
			set theRecipient to name of to recipient of lastMsg
			set theMessageID to urlencode(the message id of lastMsg) of me
			
			-- See if there is more than one recipient in the 'To' field
			if (count of theRecipient) > 1 then
				set theRecipientName to (item 1 of theRecipient & (ASCII character 202) & "and" & (ASCII character 202) & ((count of theRecipient) - 1) as string) & (ASCII character 202) & "more"
			else
				set theRecipientName to item 1 of theRecipient
			end if
		end tell
		
		set theTaskTitle to PreFix & (ASCII character 202) & theRecipientName & (ASCII character 202) & MidFix & (ASCII character 202) & theSubject
		set theNote to "Created from message://%3C" & (theMessageID) & "%3E"
		
		tell application "OmniFocus"
			if ShowQuickEntry then
				tell quick entry
					open
					make new inbox task with properties {name:theTaskTitle, note:theNote}
					tell application "System Events" to keystroke tab
					activate
				end tell
			else
				tell default document to make new inbox task with properties {name:theTaskTitle, note:theNote}
				if GrowlRun then
					my growlSetup()
					my growlNotify(theTaskTitle)
				end if
			end if
		end tell
		
	on error theError
		
	end try
end addEMail

-- Text encoding routine
on urlencode(theText)
	set theTextEnc to ""
	repeat with eachChar in characters of theText
		set useChar to eachChar
		set eachCharNum to ASCII number of eachChar
		if eachCharNum = 32 then
			set useChar to "+"
		else if (eachCharNum ≠ 42) and (eachCharNum ≠ 95) and (eachCharNum < 45 or eachCharNum > 46) and (eachCharNum < 48 or eachCharNum > 57) and (eachCharNum < 65 or eachCharNum > 90) and (eachCharNum < 97 or eachCharNum > 122) then
			set firstDig to round (eachCharNum / 16) rounding down
			set secondDig to eachCharNum mod 16
			if firstDig > 9 then
				set aNum to firstDig + 55
				set firstDig to ASCII character aNum
			end if
			if secondDig > 9 then
				set aNum to secondDig + 55
				set secondDig to ASCII character aNum
			end if
			set numHex to ("%" & (firstDig as string) & (secondDig as string)) as string
			set useChar to numHex
		end if
		set theTextEnc to theTextEnc & useChar as string
	end repeat
	return theTextEnc
end urlencode

-- Send a notification using Growl
on growlNotify(message)
	tell application "System Events"
		set isRunning to (count of (every process whose bundle identifier is "com.Growl.GrowlHelperApp")) > 0
	end tell
	
	if isRunning then
		tell application id "com.Growl.GrowlHelperApp"
			notify with name "Result" title "Successfully added last email sent" description message application name "OmniFocus Sent Email"
		end tell
	end if
end growlNotify

-- Routine to setup Growl
on growlSetup()
	tell application "System Events"
		set isRunning to (count of (every process whose bundle identifier is "com.Growl.GrowlHelperApp")) > 0
	end tell
	
	if isRunning then
		tell application id "com.Growl.GrowlHelperApp"
			set the allNotificationsList to {"Result"}
			set the enabledNotificationsList to {"Result"}
			register as application "OmniFocus Sent Email" all notifications allNotificationsList default notifications enabledNotificationsList icon of application "OmniFocus.app"
		end tell
	end if
end growlSetup

