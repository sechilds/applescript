property plstMonthTags : {"<jan>", "<feb>", "<mar>", "<apr>", "<may>", "<jun>", "<jul>", "<aug>", "<sep>", "<oct>", "<nov>", "<dec>"}

on run
	tell application id "com.apple.systemevents"
		activate
		display dialog (path to me as string) & "
	
is a library module, mainly providing

DateExpression(strDate)

	which will parse expressions like:
	 
		today +4d
		today +1w
		today +2m
		now + 2d
		soon
	or
		<feb>
		<sep>
		etc.
		
	into applescript dates.
	
The term \"soon\" is defined by the current setting in OmniFocus preferences." buttons {"OK"} with title "OF date parsing library"
	end tell
end run

on DateExpression(strExpression)
	if strExpression is "" then return missing value
	set strScript to "
set now to (current date)
set strDefault to short date string of now
set today to date strDefault
set yesterday to today - 1 * days
set tomorrow to today + 1 * days
tell application id \"com.omnigroup.omnifocus\"
	tell default document to set soon to now + ((value of setting id \"DueSoonInterval\") as integer)
end tell 
"
	set strTest to strScript & strExpression
	-- is it directly parseable by applescript ? (today|yesterday|tomorrow) [+ N * days|weeks]
	try
		set oScript to missing value
		set oScript to run script strTest
		if class of oScript is date then return oScript
	end try
	
	-- Does it become parseable to applescript if we prefix "date "  :  date "08/08/1988"
	set strASDate to "date " & quote & strExpression & quote
	try
		set oScript to run script strASDate
	end try
	if class of oScript is date then return oScript
	
	set lstTokens to my Tokenize(strExpression)
	
	-- Translate any date tag tokens (<jan>, <feb> etc) to applescript date strings
	set {blnMonthFound, lstTokens} to my ReadDateTags(lstTokens)
	
	-- 		Translate any relative date expressions now|today|tomorrow|yesterday|soon
	set {blnRelvFound, lstTokens} to ReadRelvDates(lstTokens)
	
	-- Translate any expressions of the form today +|- Nd|w|m|y   > date ShortDateString
	set {blnIntervalFound, lstTokens} to my ReadIntervals2(lstTokens)
	
	if (blnMonthFound or blnIntervalFound or blnRelvFound) then
		return run script (my ReString(lstTokens, space))
	else
		return missing value
	end if
end DateExpression

on Tokenize(str)
	-- Make sure that + or - are preceded by a space
	if str does not contain space then set str to do shell script "echo " & quoted form of str & " | perl -pe 's/([\\-\\+])/ $1/'"
	set text item delimiters to space
	set lstParts to text items of str
	set lstTokens to {}
	repeat with refPart in lstParts
		if length of refPart > 0 then
			set lstTokens to lstTokens & TokenizeBrackets(refPart)
		end if
	end repeat
	
	set lstUnSigned to {}
	repeat with oToken in lstTokens
		set strToken to oToken as string
		if length of strToken > 1 then
			set strChar to first character of strToken
			if strChar is "-" or strChar is "+" then
				set lstUnSigned to lstUnSigned & {strChar, text 2 thru end of strToken}
			else
				set end of lstUnSigned to strToken
			end if
		else
			set end of lstUnSigned to strToken
		end if
	end repeat
	lstUnSigned
end Tokenize

on TokenizeBrackets(strPhrase)
	set lstTokens to {}
	if length of strPhrase = 1 then Â
		if strPhrase is in {"(", ")"} then return {strPhrase}
	set text item delimiters to "("
	set lstParts to text items of strPhrase
	set text item delimiters to ")"
	repeat with oPart in lstParts
		if length of oPart < 1 then
			set end of lstTokens to "("
		else
			set lstBracketFree to text items of oPart
			repeat with oFree in lstBracketFree
				if length of oFree > 0 then
					set end of lstTokens to contents of oFree
				else
					set end of lstTokens to ")"
				end if
			end repeat
		end if
	end repeat
	set text item delimiters to space
	lstTokens
end TokenizeBrackets

on ReadDateTags(lstTokens)
	set blnFound to false
	repeat with iToken from 1 to length of lstTokens
		set strToken to contents of (item iToken of lstTokens)
		if length of strToken is 5 then
			if strToken is in plstMonthTags then
				set strMonth to Tag2ASDate(text 2 thru 4 of strToken)
				set item iToken of lstTokens to strMonth
				set blnFound to true
			end if
		end if
	end repeat
	{blnFound, lstTokens}
end ReadDateTags

on Tag2ASDate(strMonthTag)
	if length of strMonthTag ­ 3 then return missing value
	set lngMonth to ((offset of strMonthTag in "janfebmaraprmayjunjulaugsepoctnovdec") + 2) div 3
	if lngMonth < 1 then return missing value
	set dteBase to (current date)
	set lngThisMonth to month of dteBase
	set month of dteBase to lngMonth
	if lngMonth < lngThisMonth then set year of dteBase to (year of dteBase) + 1
	set day of dteBase to 1
	"date " & quote & short date string of dteBase & quote
end Tag2ASDate

on ReadRelvDates(lstTokens)
	set blnFound to false
	
	repeat with iToken from 1 to length of lstTokens
		set strToken to item iToken of lstTokens
		if strToken is "now" then
			set item iToken of lstTokens to "date \"" & ((current date) as string) & quote
			set blnFound to true
			-- exit repeat
		else if strToken is "soon" then
			tell application id "com.omnigroup.omnifocus"
				set item iToken of lstTokens to "date \"" & (((current date) + ((value of setting id "DueSoonInterval" of default document) as integer)) as string) & quote
			end tell
			set blnFound to true
			-- exit repeat
		else if strToken is "today" then
			set item iToken of lstTokens to "date \"" & short date string of (current date) & quote
			set blnFound to true
			-- exit repeat
		else if strToken is "tomorrow" then
			set item iToken of lstTokens to "date \"" & short date string of ((date (short date string of (current date))) + days) & quote
			set blnFound to true
			-- exit repeat
		else if strToken is "yesterday" then
			set item iToken of lstTokens to "date \"" & short date string of ((date (short date string of (current date))) - days) & quote
			set blnFound to true
			-- exit repeat
		end if
	end repeat
	
	return {blnFound, lstTokens}
end ReadRelvDates

on ReadIntervals2(lstTokens)
	
	set lngTokens to count of lstTokens
	set lngSkip to 0
	set lstTrans to {}
	set blnFound to false
	repeat with i from 1 to lngTokens
		if lngSkip > 0 then
			set lngSkip to lngSkip - 1
		else
			set strToken to item i of lstTokens
			if (lngTokens - i) > 1 then
				if strToken begins with "date \"" then
					set strOp to item (i + 1) of lstTokens
					
					if strOp is in {"+", "-"} then
						set strInterval to item (i + 2) of lstTokens
						
						set strUnit to last character of strInterval
						if strUnit is in {"d", "m", "w", "y"} then
							
							set dte to run script strToken
							set dte to DatePlus(dte, strOp & strInterval)
							if dte is not missing value then
								if length of strToken > 18 then
									set end of lstTrans to "date \"" & (dte as string) & quote
								else
									set end of lstTrans to "date \"" & (short date string of dte) & quote
								end if
								set blnFound to true
								set lngSkip to 2 -- (we've already made use of the next two tokens)
							else -- not an interval -- pass through
								set end of lstTrans to strToken
							end if
						else -- not a unit - pass through
							set end of lstTrans to strToken
						end if
					else -- not an operator - pass through
						set lstTrans to lstTrans & {strToken, strOp}
						set lngSkip to 1
					end if
				else -- not a date - pass through
					set end of lstTrans to strToken
				end if
			else -- not enough tokens left for triad - pass through
				set end of lstTrans to strToken
			end if
		end if
	end repeat
	{blnFound, lstTrans}
end ReadIntervals2


on DatePlus(dte, strNUnits)
	copy dte to dteNew
	if strNUnits = "" then return missing value
	
	if IsDigits(strNUnits) then
		set strUnit to "d"
		set lngDelta to strNUnits as integer
	else
		set strUnit to last character of strNUnits
		try
			set lngDelta to (text 1 thru -2 of strNUnits) as integer
		on error
			return missing value
		end try
	end if
	
	ignoring case
		if strUnit = "d" then
			return dteNew + lngDelta * days
		else if strUnit = "w" then
			return dteNew + lngDelta * weeks
		else if strUnit = "y" then
			set (year of dteNew) to (year of dteNew) + lngDelta
			return dteNew
		else if strUnit = "m" then
			-- Get current month and year
			set lngMonth to (month of dteNew) * 1
			set lngYear to (year of dteNew)
			
			-- and simply add the increment to the month, 
			-- negative possibly getting something negative, and/or too large
			set lngNewMonth to lngMonth + lngDelta
			
			-- get the YEAR
			set lngDateMonth to lngNewMonth mod 12
			set lngYearDelta to lngNewMonth div 12
			
			-- if we have gone down to a negative month, we are already in the previous year, 
			-- regardless of any multiples of 12
			if lngDateMonth ² 0 then set lngYearDelta to (lngYearDelta - 1)
			if lngYearDelta is not 0 then
				set lngDateYear to lngYear + lngYearDelta
			else
				set lngDateYear to lngYear
			end if
			
			-- and the MONTH
			if lngDateMonth is 0 then
				set lngDateMonth to 12
			else if lngDateMonth < 0 then
				set lngDateMonth to (12 + lngDateMonth)
			end if
			
			-- and update the date variable
			if lngYear is not lngDateYear then set (year of dteNew) to lngDateYear
			if lngMonth is not lngDateMonth then set (month of dteNew) to lngDateMonth
		else
			return missing value
		end if
	end ignoring
	dteNew
end DatePlus

on IsDigits(str)
	try
		str as integer
		true
	on error
		false
	end try
end IsDigits

on ReString(lstTokens, strDelimiter)
	set text item delimiters to strDelimiter
	set str to lstTokens as text
	set str to FindReplace(str, "( ", "(")
	set str to FindReplace(str, " )", ")")
	set text item delimiters to space
	str
end ReString

to FindReplace(strText, strFind, strReplace)
	if the strText contains strFind then
		set AppleScript's text item delimiters to strFind
		set lstParts to text items of strText
		set AppleScript's text item delimiters to strReplace
		set strText to lstParts as string
		set AppleScript's text item delimiters to space
	end if
	return strText
end FindReplace

