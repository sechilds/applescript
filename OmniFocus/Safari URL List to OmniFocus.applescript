(*
http://veritrope.com
Safari URLs List to OmniFocus
Version 1.0
April 23, 2011
Project Status, Latest Updates, and Comments Collected at:
http://veritrope.com/code/safari-tab-list-to-omnifocus
=========
BASED ON THIS SAFARI/EVERNOTE SCRIPT:
http://veritrope.com/code/export-all-safari-tabs-to-evernote/

WITH GREAT THANKS TO GORDON WHO SUBMITTED THE OMNIFOCUS MODIFICATION!
=========
Installation: Just double-click on the script!

FastScripts Installation (Optional, but recommended):
--Download and Install FastScripts from http://www.red-sweater.com/fastscripts/index.html
--Copy script or an Alias to ~/Library/Scripts/Applications/Yojimbo
--Set up your keyboard shortcut

CHANGELOG:
1.00    INITIAL RELEASE

*)

set url_list to {}
set the date_stamp to ((the current date) as string)
set NoteTitle to "URL List from Safari Tabs on " & the date_stamp
tell application "Safari"
    activate
    set safariWindow to window 1
    repeat with w in safariWindow
        try
            repeat with t in (tabs of w)
                set TabTitle to (name of t)
                set TabURL to (URL of t)
                set TabInfo to ("" & TabTitle & return & TabURL & return & return)
                copy TabInfo to the end of url_list
            end repeat
        end try
    end repeat
end tell

-- convert url_list to text
set old_delim to AppleScript's text item delimiters
set AppleScript's text item delimiters to return
set url_list to url_list as text
set AppleScript's text item delimiters to old_delim

tell front document of application "OmniFocus"
    make new inbox task with properties {name:(NoteTitle), note:url_list}
end tell

