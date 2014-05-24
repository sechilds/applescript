(*

A smarter "Clip-O-Tron" for sending Email Messages from Mail.app to OmniFocus

By Shawn Blanc -- shawnblanc.net

May 23, 2014

With inspiration from Matt Henderson: 
	http://www.dafacto.com/2014/05/23/using-keyboard-maestro-to-create-todos-in-omnifocus-2-that-are-linked-to-original-messages-in-mail/


========
How it Works
========

When the Script is run, it will create a new item in the Quick Entry box. 

1. The name of the action item is "Follow Up with NAME about SUBJECT"

2. In the note of the action item, there will be a link to the original email message, 
as well as the basics of the email itself: Sender, Subject, Date, and email body. 


Works great with Keyboard Maestro which "sees" keyboard shortcuts before OS X does.
In Keybaord Maestro, run this script in a Mail Only Gropu, that way you can still use the 
same hotkey for "send to OmniFocus Inbox" that you use in the Finder.
*)

on appIsRunning(GTDAppName)
	tell application "System Events"
		return (count of (application processes whose name is GTDAppName)) is not 0
	end tell
end appIsRunning

-- To make a fancy task name, we extract just the name of the sender (not name and email address)

tell application "Mail"
	set _senderName to {}
	set _theMessages to the selected messages of message viewer 0
	repeat with _aMessage in _theMessages
		set end of _senderName to (extract name from sender of _aMessage)
	end repeat
end tell

-- Get all the message details from Mail

tell application "Mail"
	set _sel to get selection
	set _links to {}
	repeat with _msg in _sel
		set _messageURL to "message://%3c" & _msg's message id & "%3e"
		set end of _links to _messageURL
		set _messageSubject to subject of _msg
		set _messageSender to sender of _msg
		set _messageDate to date received of _msg
		set _messageBody to content of _msg
	end repeat
	set AppleScript's text item delimiters to return
	set the clipboard to (_links as string)
end tell

-- If OmniFocus is running then create a new Quick Entry

if appIsRunning("OmniFocus") then
	tell application "OmniFocus"
		tell quick entry
			open
			make new inbox task with properties {name:("Follow up with " & _senderName & " about " & _messageSubject), note:_messageURL & return & return & "From: " & _messageSender & return & "Subject: " & _messageSubject & return & "Date: " & _messageDate & return & "----------" & return & return & _messageBody}
		end tell
		tell application "System Events" to keystroke tab
	end tell
	
	-- if OmniFocus is not running, launch it first and then create the Quick Entry
else
	tell application "OmniFocus"
		activate
		tell quick entry
			open
			activate
			make new inbox task with properties {name:("Follow up with " & _senderName & " about " & _messageSubject), note:_messageURL & return & return & "From: " & _messageSender & return & "Subject: " & _messageSubject & return & "Date: " & _messageDate & return & "----------" & return & return & _messageBody}
		end tell
		tell application "System Events" to keystroke tab
	end tell
end if