--==============================
-- OmniFocus > Swap Selected Task Names and Notes
-- Version 1.0.0
-- Written By: Ben Waldie <ben@automatedworkflows.com>
-- http://www.automatedworkflows.com

-- Description: This script retrieves the selected tasks in OmniFocus. Next, it swaps the task names and notes.
-- Version History:
-- 1.0.0 - Initial release
--==============================

tell application "OmniFocus"
	
	-- Target the content of the front window
	tell content of front window
		
		-- Retrieve every selected task
		set theTasks to value of every selected tree
		
		-- Notify the user if no tasks are selected
		if theTasks = {} then
			display alert "Unable to swap selected task names and notes." message "No tasks were selected. Please select one or more OmniFocus tasks and try again." as warning
			return
		end if
		
		-- Confirm that the user truly wants to swap task names and notes
		display alert "Ready to Swap Selected Task Names and Notes?" message "Once you do this, you will loose any formatting applied to your notes." buttons {"Cancel", "Continue"} cancel button "Cancel"
		
		-- Initialize some tracking variables
		set tasksWithAttachmentsDetected to false
		set theTasksSwapped to 0
		
		-- Begin looping through the tasks
		repeat with aTask in theTasks
			
			-- Target the current task
			tell aTask
				
				-- If the current task contains attachments, skip it
				if (count attachments of note) is greater than 0 then
					set tasksWithAttachmentsDetected to true
				else
					
					-- Retrieve the name of the current task
					set theTaskName to name
					
					-- Retrieve the note for the current task
					set theNote to note
					
					-- Set the name of the current task to the retrieved note
					if theNote is not equal to "" then
						set name to theNote
						
						-- Set the note of the current task to the retrieve name
						set note to theTaskName
						
						-- Increment the number of tasks and notes swapped
						set theTasksSwapped to theTasksSwapped + 1
					end if
				end if
			end tell
		end repeat
	end tell
	
	-- Notify the user that processing is complete and indicate whether any notes were skipped
	set theAlert to "Done. " & theTasksSwapped & " tasks and notes were swapped."
	if tasksWithAttachmentsDetected = true then
		display alert theAlert message "Some tasks were not processed because their notes contained attachments." as warning
	else
		display alert theAlert
	end if
end tell