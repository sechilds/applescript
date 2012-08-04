(*
	This script marks the selected actions as complete and creates new actions in a "Waiting For" context to track replies.
	
	version 0.1, by Curt Clifton
	
	Copyright © 2007-2008, Curtis Clifton
	
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
	
		¥ Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
		
		¥ Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
		
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	
	version 0.1: Original release
*)

(*
	This string is matched against your contexts to find a context in which to place the new "waiting-for" action.  The matching is the same as in the context column in OmniFocus, so you don't need the entire contexxt name, just a unique fragment.
*)
property waitingForContext : "wait"

(*
	This string is used as a prefix on the original item title when creating the "waiting-for" action.
*)
property waitingPrefix : "Reply on: "

(* 
	This string is used in the Growl notification if multiple items are processed. For single items, we use the actual item title. 
*)
property multipleItemsCompleted : "Multiple Items"

(*
	The following properties are used for script notification via Growl.
*)
property growlAppName : "Curt's Scripts"
property scriptStartNotification : "Script Began"
property scriptFinishNotification : "Script Completed"
property defaultNotifications : {scriptFinishNotification}
property allNotifications : defaultNotifications & {scriptStartNotification}
property iconLoaningApplication : "OmniFocus.app"

set itemTitle to missing value
tell application "OmniFocus"
	tell front document
		-- Gets target context
		set theContextID to id of item 1 of (complete waitingForContext as context) as string
		set theWaitingForContext to first flattened context whose id is theContextID
		tell content of document window 1 -- (first document window whose index is 1)
			set theSelectedItems to value of every selected tree
			if ((count of theSelectedItems) < 1) then
				display alert "You must first select an item to complete." as warning
				return
			end if
			repeat with anItem in theSelectedItems
				set itemTitle to name of anItem
				set theDupe to duplicate anItem to after anItem
				set completed of anItem to true
				
				-- Configure the duplicate item
				set oldName to name of theDupe
				set name of theDupe to waitingPrefix & oldName
				set context of theDupe to theWaitingForContext
				set repetition of theDupe to missing value
			end repeat
			if (count of theSelectedItems) > 1 then
				set itemTitle to multipleItemsCompleted
			end if
		end tell
	end tell
end tell
if itemTitle is not missing value then
	my notify("Completed and Awaiting Reply", itemTitle, scriptFinishNotification)
end if

(*
	Uses Growl to display a notification message.
	theTitle Ð a string giving the notification title
	theDescription Ð a string describing the notification event
	theNotificationKind Ð a string giving the notification kind (must be an element of allNotifications)
*)
on notify(theTitle, theDescription, theNotificationKind)
	tell application "Growl"
		register as application growlAppName all notifications allNotifications default notifications defaultNotifications icon of application iconLoaningApplication
		notify with name theNotificationKind title theTitle application name growlAppName description theDescription
	end tell
end notify