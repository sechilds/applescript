(*
	This script adds an action at the beginning of each selected project
	or at the beginning of the parent project of the selected task that
	tells you to plan this project.
	
	version 0.1, by Stephen Childs
	
	October 10, 2011
*)

(*
	This string is matched against your contexts to find a context in which to place the new "planning" action.  The matching is the same as in the context column in OmniFocus, so you don't need the entire context name, just a unique fragment.
*)
property planningContext : "planning"

(*
	The following properties are used for script notification via Growl.
*)
property growlAppName : "OF Planning Script"
property allNotifications : {"General", "Error"}
property enabledNotifications : {"General", "Error"}
property iconApplication : "OmniFocus.app"

on main()
	set ProjectValueList to {}
	set ProjectRefList to {}
	set ProjectNameList to {}
	tell application "OmniFocus"
		tell front document
			set theContextID to id of item 1 of (complete planningContext as context) as string
			set thePlanningContext to first flattened context whose id is theContextID
		end tell
		set theDoc to document window 1 of document 1
		set TreeList to the value of the selected tree of the content of theDoc
		repeat with theSelectedTree in TreeList
			if class of theSelectedTree is equal to project then
				set newProjectValue to theSelectedTree
			else
				if class of theSelectedTree is equal to task then
					set newProjectValue to (a reference to containing project of theSelectedTree)
				end if
			end if
			if newProjectValue is not equal to missing value then
				if (get id of newProjectValue) is not in ProjectValueList then
					set end of ProjectValueList to (id of newProjectValue)
					set end of ProjectRefList to newProjectValue
				end if
			end if
		end repeat
		set plannedProjects to length of ProjectRefList
		repeat with theReference in ProjectRefList
			set theProjectName to (get name of theReference)
			set MyTaskTopic to "Plan the \"" & theProjectName & "\" project"
			tell document 1
				tell theReference
					set myTask to make new task at before task 1 with properties {name:MyTaskTopic, context:thePlanningContext}
				end tell
				compact
			end tell
		end repeat
		set alertName to "General"
		set alertTitle to "Plan Current Project Script Complete"
		if plannedProjects is equal to 1 then
			set alertTExt to "Added planning action to 1 project" as string
		else
			set alertTExt to "Added planning actions to " & plannedProjects & " projects." as string
		end if
		my notify(alertName, alertTitle, alertTExt)
	end tell
end main

on notify(alertName, alertTitle, alertTExt)
	tell application "Growl"
		register as application growlAppName all notifications allNotifications default notifications enabledNotifications icon of application iconApplication
		notify with name alertName title alertTitle description alertTExt application name growlAppName
	end tell
end notify

main()