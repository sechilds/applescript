(*
	This script scans all projects and action groups in the front OmniFocus document identifying any that
	lack a next action.
	
	version 0.5, by Curt Clifton
	
	Copyright © 2007-2008, Curtis Clifton
	
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
	
		¥ Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
		
		¥ Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
		
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	
	version 0.5.1: Added a script to remove suffix to the package
	version 0.5: Move tag string to be a suffix rather than a prefix
	version 0.4.1: Removed sometimes-problematic use of 'activate' command
	version 0.4: Doesn't flag singleton holding projects as missing next actions even if they are empty
	version 0.3: Limited list of next-action-lacking projects in the dialog to 10.  More than 10 results in a dialog giving the number of such projects (along with the usual identifying-string instructions from the previous release).
	version 0.2: Added identifying string to offending projects based on idea from spiralocean.  Fixed bug where top-level projects without any actions were omitted.
	version 0.1: Original release
*)

property lackingListingDelim : (return & "    ¥ ")
property missingNASuffix : "Missing NA"
property missingNADelimiter : "Ñ"

(*
	The following properties are used for script notification via Growl.
*)
property nl : "
"
property stickyOn : true
property stickyOff : false
global growlIsRunning
property missingNextAction : "Missing Next Action"
property iconOmniFocus : "OmniFocus.app"
property iconAppNetworkUtility : "Network Utility.app"
property iconDirectoryUtility : "Directory Utility.app"
property OmniGroupCrashCatcher : "OmniGroupCrashCatcher.app"
property omniFocusFlagIconPath : "/Applications/OmniFocus.app/Contents/Resources/Flag.icns"
property suffixToStrip : missingNADelimiter & missingNASuffix
property suffixLength : count of suffixToStrip
property growlAppName : "Curt's Scripts"
property scriptStartNotification : "Script Began"
property scriptFinishNotification : "Script Completed"
property defaultNotifications : {scriptFinishNotification, scriptStartNotification, missingNextAction}
property allNotifications : defaultNotifications

--check to see that growl is running
set growlIsRunning to true

my notify("Checking for Next Actions", "Scanning all projects and action groups for any that lack a next action", scriptStartNotification, stickyOff, growlIsRunning, iconAppNetworkUtility)

tell application "OmniFocus"
	tell front document
		set theSections to every section
		set lackingNextActions to my accumulateMissingNAs(theSections, {})
		if (lackingNextActions is {}) then
			my notifyWithImageIcon("Congratulations!", "Next actions are identified for all active projects and subprojects.", scriptFinishNotification, stickyOff, growlIsRunning, omniFocusFlagIconPath)
		else
			if ((count of lackingNextActions) > 10) then
				set msg to "Next actions are missing for " & (count of lackingNextActions) & " active projects or subprojects"
			else
				set oldDelim to AppleScript's text item delimiters
				set AppleScript's text item delimiters to lackingListingDelim
				set lackingListing to (lackingNextActions as rich text)
				set AppleScript's text item delimiters to oldDelim
				set msg to "Next actions are missing for the following active projects or subprojects:" & lackingListingDelim & lackingListing
			end if
			if not growlIsRunning then
				display alert "Missing Next Actions" message (msg & return & "Search all projects for \"" & missingNASuffix & "\" to find them quickly.") buttons {"Drat"}
			end if
		end if
	end tell
end tell

my notify("Completed Checking for Next Actions", "Script has successfully scanned action groups for next actions", scriptFinishNotification, stickyOff, growlIsRunning, iconAppNetworkUtility)

(* 
	Recurses over the tree, accumulates a list of items that are:
		¥ not complete and 
		¥ have subtasks, but 
		¥ have no incomplete or pending subtasks.
	theSections: a list of folders, projects, and tasks
	accum: the items lacking next actions that have been found so far 
*)
on accumulateMissingNAs(theSections, accum)
	if (theSections is {}) then return accum
	return accumulateMissingNAs(rest of theSections, accumulateMissingNAsHelper(item 1 of theSections, accum))
end accumulateMissingNAs

(* 
	Recurses over the tree rooted at the given item, accumulates a list of items that are:
		¥ not complete and 
		¥ have subtasks, but 
		¥ have no incomplete or pending subtasks.
	theItem: a folder, project, or task
	accum: the items lacking next actions that have been found so far 
*)
on accumulateMissingNAsHelper(theItem, accum)
	using terms from application "OmniFocus"
		if (class of theItem is project) then
			return my accumulateMissingNAsProject(theItem, accum)
		else if (class of theItem is folder) then
			return my accumulateMissingNAsFolder(theItem, accum)
		else
			return my accumulateMissingNAsTask(theItem, false, accum)
		end if
	end using terms from
end accumulateMissingNAsHelper

(* 
	Recurses over the tree rooted at the given project, accumulates a list of items that are:
		¥ not complete and 
		¥ have subtasks, but 
		¥ have no incomplete or pending subtasks.
	theProject: a project
	accum: the items lacking next actions that have been found so far 
*)
on accumulateMissingNAsProject(theProject, accum)
	local nameProcessed
	
	using terms from application "OmniFocus"
		tell theProject
			if name of theProject contains "Impossible" then
				set mypause to true
			end if
			if (status is not active) and (name ends with suffixToStrip) then set name to my removeMissingNA(name, name)
			set nameProcessed to name
			if (singleton action holder is true) then return accum --changes this to send all projects into the recursion to clear any MissingNA tags on action groups in a project.  If project has missing NA, and is on hold, will be sent into recursion to check names
		end tell
		set theRootTask to root task of theProject
		return my accumulateMissingNAsTask(theRootTask, true, accum)
	end using terms from
end accumulateMissingNAsProject

(* 
	Recurses over the tree rooted at the given task, accumulates a list of items that are:
		¥ not complete and 
		¥ have subtasks, but 
		¥ have no incomplete or pending subtasks.
	theTask: a task
	isProjectRoot: true iff theTask is the root task of a project
	accum: the items lacking next actions that have been found so far 
*)

on accumulateMissingNAsTask(theTask, isProjectRoot, accum)
	local myDebugTask
	local exitHandler
	local missingContext
	local currentName
	local isSequential
	local projectSequentialAndMissingNA
	
	using terms from application "OmniFocus"
		tell theTask
			
			set myDebugTask to theTask
			set isSequential to sequential
			local isAproject
			set isAproject to isProjectRoot
			local isActionGroup
			set isActionGroup to (count of tasks) > 0
			set isAProjectOrSubprojectTask to isAproject or isActionGroup
			
			set incompleteChildTasks to every task whose completed is false
			
			set currentName to name
			set missingContext to context of theTask is equal to missing value --modified: with OF's behaviour of showing action groups in a context, an action group that has a context is not considered stalled.  A project is considered stalled.
			-- 			set countOfIncompleteChildTasks to count of incompleteChildTasks
			-- 			local noIncompleteChildTasks
			-- 			set noIncompleteChildTasks to countOfIncompleteChildTasks is equal to 0
			
			
			--------------added to simplify logic
			set exitHandler to true
			set exitHandler to exitHandler and (completed and (count of incompleteChildTasks) is 0)
			set exitHandler to exitHandler or (not isAProjectOrSubprojectTask)
			
			-------------Completed projects need to be sent to recursion to clear the name
			if ((count incompleteChildTasks) is 0) and (completed of containing project is false) and (missingContext is true) then --modified for same reason as line above
				if completed is true or blocked is true or (status of containing project is on hold) or (status of containing project is dropped) then
					if (name ends with suffixToStrip) then set name to my removeMissingNA(name, name of containing project)
				else
					
					set noticeString to name
					if name is not equal to name of containing project then
						set noticeString to noticeString & nl & nl & "in project:" & nl & name of containing project
					else
						set noticeString to "Project:" & nl & noticeString
					end if
					
					my notify("Missing next action!", noticeString, scriptStartNotification, stickyOff, growlIsRunning, OmniGroupCrashCatcher)
					
					set end of accum to name
					-- The following idea of tagging the items with an identifying string is due to user spiralocean on the OmniFocus Extras forum and OmniGroup.com:
					if (name does not end with missingNASuffix) then
						set name to (name & missingNADelimiter & missingNASuffix)
					end if
					
				end if
				
				if isAProjectOrSubprojectTask then
					return my accumulateMissingNAs(every task, accum)
				else
					return accum
				end if
			else
				-- missing next action tags are cleared if group has a next action
				if (name ends with suffixToStrip) then set name to my removeMissingNA(name, name of containing project)
				return my accumulateMissingNAs(every task, accum) --changed this to recurse over completed tasks as well to search for Missing NA tags in completed items
			end if
		end tell
	end using terms from
end accumulateMissingNAsTask

(* 
	Recurses over the tree rooted at the given folder, accumulates a list of items that are:
		¥ not complete and 
		¥ have subtasks, but 
		¥ have no incomplete or pending subtasks.
	theFolder: a folder
	accum: the items lacking next actions that have been found so far 
*)
on accumulateMissingNAsFolder(theFolder, accum)
	using terms from application "OmniFocus"
		if (hidden of theFolder) then return accum
		set theChildren to every section of theFolder
		return my accumulateMissingNAs(theChildren, accum)
	end using terms from
end accumulateMissingNAsFolder

on removeMissingNA(inputString, projectName)
	set returnString to text 1 thru (-1 * (suffixLength + 1)) of (inputString)
	set noticeString to returnString
	if inputString is equal to projectName then
		set noticeString to "Project:" & nl & noticeString
	else
		set noticeString to noticeString & nl & nl & "in project:" & nl & projectName
	end if
	
	my notify("Cleared Missing Next Action!", noticeString, scriptStartNotification, stickyOff, growlIsRunning, iconOmniFocus)
	return returnString
end removeMissingNA

(*
	Uses Growl to display a notification message.
	theTitle Ð a string giving the notification title
	theDescription Ð a string describing the notification event
	theNotificationKind Ð a string giving the notification kind (must be an element of allNotifications)
*)

on notify(theTitle, theDescription, theNotificationKind, messageIsSticky, growlIsRunning, iconOfApplication)
	display notification theDescription with title theNotificationKind subtitle theTitle
end notify

on notifyWithImageIcon(theTitle, theDescription, theNotificationKind, messageIsSticky, growlIsRunning, pathOfIconImage)
	display notification theDescription with title theNotificationKind subtitle theTitle
end notifyWithImageIcon
