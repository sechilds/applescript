(*◸ Veritrope.comOmniFocus - Write Active Project List to Text FileVERSION 1.02October 9, 2014Project Status, Latest Updates, and Comments Collected at:http://veritrope.com/code/omnifocus-write-active-project-list-to-text-file// CHANGELOG:1.02  Fix for OF2 Changes in Rich Text AppleScript1.01  Fix for Projects not contained in folders.1.00  Initial Release// RECOMMENDED INSTALLATION INSTRUCTIONS:FastScripts Installation (Optional, but recommended):--Download and Install FastScripts from http://www.red-sweater.com/fastscripts/index.html--Copy script or an Alias to ~/Library/Scripts/Applications/NAME OF APP--Set up your keyboard shortcut*)(* ======================================// MAIN PROGRAM ======================================*)tell application "OmniFocus"	set list_Projects to {}	set oDoc to default document	set nofolder_Projects to (name of (flattened projects of oDoc where its folder is missing value and its status is active))	set folder_Projects to (name of (flattened projects of oDoc where hidden of its folder is false and its status is active))	set projNames to nofolder_Projects & folder_Projects	-- SORT THE LIST 	set projects_Sorted to my simple_sort(projNames)		-- CONVERT LIST TO TEXT	set old_delim to AppleScript's text item delimiters	set AppleScript's text item delimiters to return	set projects_Sorted to projects_Sorted as text	set AppleScript's text item delimiters to old_delim	set ExportList to "Current List of Active Projects:" & return & (current date) & return & return & projects_Sorted as Unicode text	set fn to choose file name with prompt "Name this file" default name "List of Active OmniFocus Projects" & ¬		".txt" default location (path to desktop folder)	tell application "System Events"		set fid to open for access fn with write permission		write ExportList to fid		close access fid	end tell	end tell(* ======================================// UTILITY SUBROUTINES ======================================*)--SORT SUBROUTINEon simple_sort(my_list)	set the index_list to {}	set the sorted_list to {}	repeat (the number of items in my_list) times		set the low_item to ""		repeat with i from 1 to (number of items in my_list)			if i is not in the index_list then				set this_item to item i of my_list as text				if the low_item is "" then					set the low_item to this_item					set the low_item_index to i				else if this_item comes before the low_item then					set the low_item to this_item					set the low_item_index to i				end if			end if		end repeat		set the end of sorted_list to the low_item		set the end of the index_list to the low_item_index	end repeat	return the sorted_listend simple_sort