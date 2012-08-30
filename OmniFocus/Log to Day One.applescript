(*
Jered Benoit
jeredb.com

Omnifocus -> Day One Daily Completed Task Log

Based upon [Version 1.0] [1] of [OmniFocus - Weekly Project Report Generator] [2]
Originally Authored by Chris Brogan and Rob Trew
February 5, 2012

AND

the usual brilliance of Brett Terpstra's
[LOG TASKPAPER ARCHIVES TO DAY ONE Applescript] [3]


[1]: http://veritrope.com/code/omnifocus-weekly-project-report-generator
[2]: http://cl.ly/1H1M0S3R160x3401150u
[3]: http://brettterpstra.com/log-taskpaper-archives-to-day-one/

// NOTES

This only selects tasks completed with in the last day.

As noted in [Brett's post] [3], you must have a symbolic link to the Day One.app CLI. I dorked mine up, so there you will have to modify the noted line noted to get this scrip to work properly.

Symbolic Link terminal goodness:

> ln -s "/Applications/Day One/Day One.app/Contents/MacOS/dayone" /usr/local/bin/dayone

*)

(* 
======================================
// MAIN PROGRAM 
======================================
*)

tell application "OmniFocus"
	
	--SET THE REPORT TITLE
	set ExportList to (current date) & return & return & "Completed Projects in the Last Day" & return & "---" & return & return as Unicode text
	
	--PROCESS THE PROJECTS
	tell default document
		
		set refFolders to a reference to (flattened folders where hidden is false)
		repeat with idFolder in (id of refFolders) as list
			set oFolder to folder id idFolder
			set ExportList to ExportList & my IndentAndProjects(oFolder) & return
		end repeat
		
		--ASSEMBLE THE COMPLETED TASK LIST
		set ExportList to ExportList & return & return & "Tasks Completed in the last day" & return & "---" & return & return & return
		set day_ago to (current date) - 1 * days
		set refDoneInLastWeek to a reference to (flattened tasks where (completion date >= day_ago))
		set {lstName, lstContext, lstProject, lstDate} to {name, name of its context, name of its containing project, completion date} of refDoneInLastWeek
		set strText to ""
		repeat with iTask from 1 to length of lstName
			set {strName, varContext, varProject, varDate} to {item iTask of lstName, item iTask of lstContext, item iTask of lstProject, item iTask of lstDate}
			if varProject is not "Weekday Morning" and varProject is not "Weekday Evening" and varProject is not "Weekend Morning" and varProject is not "Weekend Evening" then
				if varDate is not missing value then set strText to strText & short date string of varDate & " - "
				if varProject is not missing value then set strText to strText & " [" & varProject & "] - "
				set strText to strText & strName
				if varContext is not missing value then set strText to strText & " *@" & varContext & "*"
				set strText to strText & "  " & return
			end if
		end repeat
	end tell
	
	set ExportList to ExportList & strText as Unicode text
	
	-- Modify "/usr/local/bin/dayone/dayone" to "/usr/local/bin/dayone" if you didn't screw it up like I did.
	do shell script "echo " & (quoted form of ExportList) & "|tr -d \"\\t\"|/usr/local/bin/dayone new"
	
end tell

(* 
======================================
// MAIN HANDLER SUBROUTINES 
======================================
*)

on IndentAndProjects(oFolder)
	tell application id "OFOC"
		
		set {dlm, my text item delimiters} to {my text item delimiters, return & return}
		set day_ago to (current date) - 1 * days
		set strCompleted to (name of (projects of oFolder where its status is done and completion date >= day_ago)) as string
		
		set my text item delimiters to dlm
		
		return strCompleted & return
	end tell
end IndentAndProjects
