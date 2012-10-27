--	Created by: Sean Korzdorfer
--	Created on: 10/23/12 08:53:07
--	OmniFocus2Due_script v 1.0
--	Release Notes:
-- - An Applescript implementation. Keyboard Maestro is no longer required
-- - The script allows multiple selections.

-- If you have selected multiple tasks, the script can ask if you need to make changes.

-- AskForChanges is OFF by default.

-- If the script behaves as if it's possessed, please adjust the pause commands on line numbers: 55, 63, 71

-- This can be toggled to true
property askForChanges : false


tell application "OmniFocus"
	activate
	-- This first bit is from a RobTrew example from a few years back É Lost the source url.
	tell front window of application "OmniFocus"
		set oTrees to selected trees of content
		set lngTrees to count of oTrees
		
		if lngTrees < 1 then
			set oTrees to selected trees of sidebar
		end if
		
		if lngTrees < 1 then
			return
		end if
		if (lngTrees > 0) then
			repeat with iTree from 1 to lngTrees
				set SelectedItemInMainView to selected trees of content
				set theSelection to value of (item iTree of oTrees)
				
				-- First Test: Future Start Date found
				if start date of theSelection is not missing value and start date of theSelection is greater than (current date) then
					set theURl to "due:///add?title=" & my urlEncode((name of theSelection & " " & start date of theSelection as rich text) & "                                                    omnifocus:///task/" & id of theSelection as rich text)
					-- Second Test: No valid start date, but future due date found
				else if due date of theSelection is not missing value and the due date of theSelection is greater than (current date) then
					set theURl to "due:///add?title=" & my urlEncode((name of theSelection & " " & due date of theSelection as rich text) & "                                                    omnifocus:///task/" & id of theSelection as rich text)
					-- No valid start date or due date found. I could test for start date > due date, but that's on the user.
				else
					-- Throw a dialog to get the date information from the user.
					-- Seems if I let the use add the date information to the task input after the URL is sent, 
					-- Due will not generate the selection used for deletion 
					tell application "Due"
						activate
						display dialog "Enter Date for Task: " & the name of theSelection default answer ""
						set theDate to (text returned of result) as text
					end tell
					set theURl to "due:///add?title=" & my urlEncode(((name of theSelection as rich text) & " " & theDate as rich text) & "                                                    omnifocus:///task/" & id of theSelection as rich text)
				end if
				
				tell application "Finder" to open location theURl
				tell application "Due" to activate
				delay 0.5 -- This delay can be tweaked for your system
				tell application "System Events" to key code 51
				
				-- If there are multiple selections. You might want to play with the clipboard delay.
				if askForChanges is false and iTree is less than lngTrees then
					tell application "Due" to activate
					tell application "System Events" to key code 36
					delay 1 -- This delay can be tweaked for your system
				end if
				if askForChanges is true and iTree is less than lngTrees then
					-- Throw a simple display to pause the script and allow the user to make any edits to the reminder
					tell application "System Events" to (display dialog "If needed, make  edits to the reminder, then complete the task. Only complete the task if you made changes." buttons {"Okay"})
					-- Complete Due reminder.
					tell application "Due" to activate
					tell application "System Events" to key code 36
					delay 1 -- This delay can be tweaked for your system
					
				end if
			end repeat
		end if
	end tell
end tell

(* http://applescript.bratis-lover.net/library/url/
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
--c-                                                                                                URL LIBRARY
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--d-- Last modification date:                                                             2012-01-14


Two simple handlers to decode and encode URLs. The urlEncode handler is also 
very useful for creating AppleScript URLs as found throughout this site.


--m-- http://applescript.bratis-lover.net/library/url/

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
--c-                                                                                                   COPYRIGHT
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

COPYRIGHT (c) 2008 ljr (http://applescript.bratis-lover.net)
                                [ urlEncode, urlDecode ]

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

*)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
--c-                                                                                                 PROPERTIES
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --


--c--   property myName
--d--   Name that should be used when loading this library.
property myName : "_url"


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
--c-                                                                                         ENCODE/DECODE
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --


--c--   urlEncode(str)
--d--   URL encode the passed string.
--a--   str : string
--r--   string
--x--   urlEncode("NŸrnberg $%@") --> "N%C3%BCrnberg%20%24%25%40"
--m--  echo (man1/echo.1.html), perl (man1/perl.1.html)
--u--   ljr (http://applescript.bratis-lover.net/library/url/)
on urlEncode(str)
	local str
	try
		return (do shell script "/bin/echo " & quoted form of str & Â
			" | perl -MURI::Escape -lne 'print uri_escape($_)'")
	on error eMsg number eNum
		error "Can't urlEncode: " & eMsg number eNum
	end try
end urlEncode

--c--   urlDecode(str)
--d--   URL decode the passed string.
--a--   str : string
--r--   string
--x--   urlDecode("N%C3%BCrnberg%20%24%25%40") --> "NŸrnberg $%@"
--m--  echo (man1/echo.1.html), perl (man1/perl.1.html)
--u--   ljr (http://applescript.bratis-lover.net/library/url/)
on urlDecode(str)
	local str
	try
		return (do shell script "/bin/echo " & quoted form of str & Â
			" | perl -MURI::Escape -lne 'print uri_unescape($_)'")
	on error eMsg number eNum
		error "Can't urlDecode: " & eMsg number eNum
	end try
end urlDecode



-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
--                                                                                                                 EOF
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

