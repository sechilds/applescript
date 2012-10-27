-- Set start date or due date in terms of each other or themselves
-- Define Start Date in terms of  self or due date +/-  N days/weeks
-- Define Due Date in terms of  self or start date +/-  N days/weeks

property pTitle : "Set relative (Start|Due) dates"
property pVer : "Ver .011"

property pstrSyntax : "Note: 'start' and 'due' can be abbreviated to 'sd' and 'dd')

DEFER OR BRING AHEAD:
	start=start+7d
	due=due-1w
DEFINE START OR DUE IN TERMS OF EACH OTHER:
	due=start+2w
	start=due-5d
SIMPLE RELATIVE SETTINGS:
	start=<sep>
	start=tomorrow
	start=today+2w
	due=now+2d
DEFAULTS
	Expressions with no left-hand side 
	are interpreted as references to due dates.
	Interval strings with no units are interpreted
	as a number of days.
	
Enter commands separated by comma or semi-colon
e.g.
	sd=today+10d, dd=sd+2w
"

property pCancel : "Cancel"
property pGrowlURL : "http://growl.info/"

-- SCRIPT BEHAVIOUR OPTIONS
property pblnUseDialog : false -- always use a display dialog rather than just a Growl notification

on handle_string(strCMD)
	Apply2SeldTasks(strCMD)
end handle_string

on run
	-- CHECK WHETHER THERE ARE ANY SELECTED TASKS OR PROJECTS
	tell application id "OFOC"
		tell front document window of front document
			if (count of (selected trees of content where class of its value is not item and class of its value is not folder)) < 1 then
				if (count of (selected trees of sidebar where class of its value is not item and class of its value is not folder)) < 1 then return
			end if
		end tell
	end tell
	
	-- TRY TO GET A COMMAND STRING
	tell application id "sevs"
		activate
		tell (display dialog pstrSyntax default answer "" buttons {pCancel, "Set date(s)"} default button 2 with title pTitle & space & pVer)
			set {strCMD, strButton} to {text returned, button returned}
		end tell
	end tell
	
	-- PROCESS ANY COMMAND STRING
	if strCMD ­ "" then Apply2SeldTasks(strCMD)
end run

on Apply2SeldTasks(strCMD)
	if strCMD = "" then return
	
	-- CHECK THAT THERE ARE SELECTED TASKS
	tell application id "OFOC"
		tell front document window of front document
			set lstTasks to value of (selected trees of content where class of its value is not item and class of its value is not folder)
			set lngTasks to (count of lstTasks)
			if lngTasks < 1 then
				set lstTasks to value of (selected trees of sidebar where class of its value is not item and class of its value is not folder)
				set lngTasks to (count of lstTasks)
				if lngTasks < 1 then return
			end if
		end tell
	end tell
	
	-- PARSE THE COMMAND(S)
	set lstCmds to ParseCmd(strCMD)
	if lstCmds = {} then return
	
	-- LOAD RELATIVE DATES LIBRARY
	set libOFDates to load script "Users:sechilds:Library:Scripts:Libraries:OF_DateLIb.scpt" as alias
	
	-- PROCESS THE COMMANDS, WHILE BUILDING A LOG
	set {lngDue, lngStart} to {0, 0}
	
	set dteNow to (current date)
	set dteToday to dteNow
	set time of dteToday to 0
	
	set strCMDLog to ""
	tell application id "OFOC"
		repeat with oCmd in lstCmds
			set {strUnParsed, blnReflexive, blnReadStart, blnWriteStart, strExpression} to oCmd
			if strUnParsed ­ "" then
				set strCMDLog to strCMDLog & "LEFT HAND SIDE OF EXPRESSION UNPARSED:" & return & Â
					"\"" & strUnParsed & "\"     -     No change" & return
			else
				if blnReflexive then
					-- CALCULATE THE REQUIRED OFFSET AS A NUMBER OF SECONDS
					set dteNew to libOFDates's DatePlus(dteNow, strExpression)
					set lngSecs to dteNew - dteNow
					
					if lngSecs ­ 0 then
						-- APPLY THE OFFSET AS REQUIRED
						if blnReadStart then
							if blnWriteStart then -- ADJUST START DATES BY SPECIFIED AMOUNT OF TIME
								repeat with oTask in lstTasks
									set dteStart to start date of oTask
									if dteStart is missing value then set dteStart to dteToday
									set start date of oTask to (dteStart) + lngSecs
									set lngStart to lngStart + 1
								end repeat
							else -- SET DUE DATES IN RELATION TO START DATES
								repeat with oTask in lstTasks
									set dteStart to start date of oTask
									if dteStart is missing value then set dteStart to dteToday
									set due date of oTask to (dteStart) + lngSecs
									set lngDue to lngDue + 1
								end repeat
							end if
						else -- SET START DATES IN RELATION TO DUE DATES
							if blnWriteStart then
								repeat with oTask in lstTasks
									set dteDue to due date of oTask
									if dteDue is missing value then set dteDue to dteToday
									set start date of oTask to (dteDue) + lngSecs
									set lngStart to lngStart + 1
								end repeat
							else -- ADJUST DUE DATES BY A SPECIFIED AMOUNT OF TIME
								repeat with oTask in lstTasks
									set dteDue to due date of oTask
									if dteDue is missing value then set dteDue to dteToday
									set due date of oTask to (dteDue) + lngSecs
									set lngDue to lngDue + 1
								end repeat
							end if
						end if
					else
						set strCMDLog to strCMDLog & "No change" & return
					end if
				else
					-- APPLY ONE DATE TO ALL THE SELECTED TASKS
					set dteNew to libOFDates's DateExpression(strExpression)
					if dteNew is not missing value then
						tell dteNew
							set strCMDLog to strCMDLog & strExpression & " = " & short date string & space & rich text 1 thru 5 of time string & return
						end tell
						if blnWriteStart then
							repeat with oTask in lstTasks
								set start date of oTask to dteNew
							end repeat
							set lngStart to lngStart + lngTasks
						else
							repeat with oTask in lstTasks
								set due date of oTask to dteNew
							end repeat
							set lngDue to lngDue + lngTasks
						end if
					else
						set strCMDLog to strCMDLog & strExpression & " could not be parsed as a date" & return
					end if
				end if
			end if
		end repeat
	end tell
	
	-- REPORT RESULTS TO THE USER
	set strLog to BuildLog(lngTasks, strCMD, strCMDLog, lngDue, lngStart)
	
	if pblnUseDialog or (lngDue + lngStart) < 1 then
		tell application id "sevs"
			activate
			display dialog strLog buttons "OK" default button 1 with title pTitle
		end tell
	else
		Notify(strLog) -- use Growl if installed (otherwise fall back to display dialog)
	end if
end Apply2SeldTasks

on BuildLog(lngTasks, strCMD, strCMDLog, lngDue, lngStart)
	set strLog to pl("task", lngTasks) & " selected" & return & return & strCMD & return & return
	if strCMDLog ­ "" then set strLog to strLog & "(" & text 1 thru -2 of strCMDLog & ")" & return & return
	if lngStart > 0 then set strLog to strLog & pl("start date", lngStart) & " set" & return
	if lngDue > 0 then set strLog to strLog & pl("due date", lngDue) & " set" & return
	return strLog
end BuildLog

-- {{blnReflexive, blnReadStart, blnWriteStart, strExpression}, ...}
on ParseCmd(strCmds)
	-- NORMALISE ANY COMMAS TO SEMI-COLON COMMAND SEPARATORS
	set strText to Replace(strCmds, ",", ";")
	
	-- DIVIDE THE STRING INTO SEPARATE COMMANDS
	set {dlm, my text item delimiters} to {my text item delimiters, ";"}
	set lstExpressions to text items of strText
	
	-- BUILD A LIST OF PARSED COMMANDS
	set lstCmd to {}
	
	repeat with oCmd in lstExpressions
		set strUnParsed to ""
		
		-- DIVIDE THE EXPRESSION INTO LEFT AND RIGHT SIDES
		set my text item delimiters to "="
		set lstSides to text items of oCmd
		if (count of lstSides) > 1 then
			set {strLeft, strRight} to {my trim(item 1 of lstSides), my trim(item 2 of lstSides)}
			
			-- DETERMINE WHETHER DATE TO BE SET/ADJUSTED IS START OR DUE
			set blnWriteStart to (my PatternMatch(strLeft, "^(s|sd|start|start date)$")) > 0
			
			-- IF LEFT HAND SIDE UNRECOGNIZABLE, FAIL THE PARSE ??
			if not blnWriteStart then
				if (my PatternMatch(strLeft, "^(d|dd|due|due date)$")) < 1 then set strUnParsed to strLeft
			end if
		else
			-- IF NO LEFT HAND SIDE, ASSUME DUE DATE BY DEFAULT
			set {strLeft, strRight} to {"due", my trim(item 1 of lstSides)}
			set {blnReadStart, blnWriteStart} to {false, false}
		end if
		
		-- DETERMINE WHETHER THE EXPRESSION IS REFLEXIVE (BASED ON OWN START|DUE)
		-- (Assume that a bare interval string is a reflexive reference to a due date)
		set lngReflexEnd to my PatternMatch(strRight, "^(s|d|sd|dd|start|due|\\+|\\-|\\d)")
		set blnReflexive to (lngReflexEnd > 0)
		
		-- IF REFLEXIVE,  ARE WE READING THE START DATE OR THE DUE DATE ?
		if blnReflexive then
			set blnReadStart to not (my PatternMatch(strRight, "^(d|dd|due|\\+|\\-|\\d)")) > 0
		else
			set blnReadStart to false
		end if
		
		-- APPEND, WITH DATE EXPRESSION, TO COMMAND LIST
		if strRight ­ "" then
			if (my PatternMatch(strRight, "^(\\+|\\-|\\d)")) = 0 then Â
				set strRight to text (lngReflexEnd + 1) thru -1 of strRight
		end if
		set end of lstCmd to {strUnParsed, blnReflexive, blnReadStart, blnWriteStart, strRight}
	end repeat
	set my text item delimiters to dlm
	return lstCmd
end ParseCmd

-- "1 widget" or "3 widgets"
on pl(str, lng)
	if lng > 1 then
		(lng as string) & space & str & "s"
	else
		(lng as string) & space & str
	end if
end pl

on Replace(str, strFind, strReplace)
	do shell script "echo " & quoted form of str & " | sed -e 's/" & strFind & "/" & strReplace & "/g'"
end Replace

(* Returns position of last character of matched pattern *)
on PatternMatch(strText, strPattern)
	try
		(do shell script "echo " & quoted form of strText & " | perl -ne 'if (m/(" & strPattern & ")/) {print \"$+[1]\"}'") as integer
	on error
		0
	end try
end PatternMatch

on trim(strText)
	do shell script "echo " & quoted form of strText & " | perl -pe 's/^\\s+//; s/\\s+$//'"
end trim

-- REPORT RESULTS TO USER ( BY DEFAULT THROUGH GROWL - IF INSTALLED )
on Notify(strReport)
	set strGrowlPath to ""
	try
		tell application "Finder" to tell (application file id "GRRR") to set strGrowlPath to POSIX path of (its container as alias) & name
	end try
	set blnInstalled to (strGrowlPath ­ "")
	--set blnInstalled to false
	
	-- IF INSTALLED, THEN IS IT RUNNING ?
	if blnInstalled then
		tell application id "sevs"
			set blnGrowlRunning to exists (application process "GrowlHelperApp")
			
			-- IF NOT RUNNING THEN TRY TO WAKE IT UP ...
			if not blnGrowlRunning then
				do shell script "open " & strGrowlPath
				do shell script "sleep .5"
				set blnGrowlRunning to exists (application process "GrowlHelperApp")
			end if
			
			if blnGrowlRunning then
				tell application "Growl"
					register as application "houthakker scripts" all notifications {"Dates (re)set"} default notifications {"Dates (re)set"} icon of application "OmniFocus"
					notify with name "Dates (re)set" title "Dates (re)set" application name "houthakker scripts" description strReport
				end tell
			else
				-- IF NO REPORT HAS BEEN MADE THROUGH GROWL, REPORT THRU DIALOG
				set strReport to "(Growl not running)" & return & return & strReport
				tell application id "sevs"
					activate
					display dialog strReport buttons {"OK"} default button 1 with title pTitle
				end tell
			end if
		end tell
	else
		-- IF GROWL IS NOT INSTALLED , REPORT THROUGH DIALOG
		set strReport to "(Growl not installed)" & return & return & strReport
		tell application id "sevs"
			activate
			tell (display dialog strReport buttons {pGrowlURL, "OK"} default button 2 with title pTitle)
				if button returned = pGrowlURL then tell me to do shell script "open " & quoted form of pGrowlURL
			end tell
		end tell
	end if
end Notify

