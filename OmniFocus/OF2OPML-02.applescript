-- 2008 Feb 19


property blnSkipDoneTasks : true

on run
	tell application "OmniFocus"
		-- set docSource to default document
		tell default document
			if number of document window is 0 then
				make new document window with properties {bounds:{0, 0, 1000, 500}}
			end if
			set tsksInbox to inbox tasks
			set lstSections to sections
		end tell
	end tell
	
	-- Prepare blank document in OO
	tell application "OmniOutliner Professional"
		activate
		set docTarget to make new document at before documents
		set bounds of front window to {0, 0, 1000, 500}
		-- Create required columns
		tell docTarget
			make new column with properties {type:rich text, name:"Context"}
			
			make new column with properties {type:date, name:"Start"}
			make new column with properties {type:date, name:"Due"}
			make new column with properties {type:date, name:"Completed"}
			make new column with properties {type:duration, name:"Duration"}
			
			set oCol to make new column with properties {type:checkbox, name:"Flagged"}
			set width of oCol to 64
			
			-- Export Inbox	
			set oParentRow to make new row at end of children with properties {topic:"Inbox"}
			my ExportTasks(docTarget, oParentRow, tsksInbox)
			
			-- Export Library
			set oParentRow to make new row at end of children with properties {topic:"Library"}
			my ExportSections(docTarget, oParentRow, lstSections)
			
			set expanded of every row to true
			
			set strPath to POSIX path of (path to desktop) & "OF_All.opml"
			export docTarget to strPath as "OOOPMLDocumentType"
		end tell
	end tell
end run

on ExportSections(docTarget, oParentRow, lstSections)
	
	using terms from application "OmniFocus"
		repeat with oSectn in lstSections
			-- Find out what kind of section this is
			set clSectn to class of oSectn
			set strName to name of oSectn
			
			if clSectn is folder then
				-- FOLDER 
				--Simple line 
				using terms from application "OmniOutliner Professional"
					tell docTarget
						if oParentRow is not equal to missing value then
							set oRow to make new row at end of children of oParentRow with properties {topic:strName}
						else
							set oRow to make new row at end of children with properties {topic:strName}
						end if
					end tell
				end using terms from
				
				-- and recurse with any contained sections
				set lstSubSections to sections of oSectn
				if (count of lstSubSections) > 0 then
					my ExportSections(docTarget, oRow, lstSubSections)
				end if
				
			else if clSectn is project then
				-- PROJECT
				-- Simple line 
				using terms from application "OmniOutliner Professional"
					tell docTarget
						if oParentRow is not equal to missing value then
							set oRow to make new row at end of children of oParentRow with properties {topic:strName}
						else
							set oRow to make new row at end of children with properties {topic:strName}
						end if
					end tell
				end using terms from
				
				-- and recurse with any tasks
				-- set oProj to oSectn as project
				set lstTasks to tasks of oSectn
				if (count of lstTasks) > 0 then
					my ExportTasks(docTarget, oRow, lstTasks)
				end if
			end if
			
		end repeat
	end using terms from
end ExportSections


on ExportTasks(docTarget, oParentRow, lstTasks)
	--if oParentRow is missing value then set oParentRow to docTarget
	using terms from application "OmniFocus"
		repeat with oTask in lstTasks
			
			-- get the OF Task property list
			set propsTask to properties of oTask
			
			-- extract a set of relevant variables
			set blnCompleted to completed of propsTask
			if blnSkipDoneTasks and blnCompleted then
				-- Skip this DONE task and its descendants
			else
				set strName to name of propsTask
				set strNote to note of propsTask
				
				set varContext to context of propsTask
				set varDuration to estimated minutes of propsTask
				set varStartDate to start date of propsTask
				set varDueDate to due date of propsTask
				set varDoneDate to completion date of propsTask
				set blnFlagged to flagged of propsTask
				
				using terms from application "OmniOutliner Professional"
					
					-- construct an OO Row property list			
					set propsRow to {topic:strName}
					if length of strNote > 0 then set propsRow to {note:strNote} & propsRow
					if blnCompleted then set propsRow to {state:checked} & propsRow
					
					-- make row
					
					tell docTarget
						if oParentRow is not equal to missing value then
							set oRow to make new row at end of children of oParentRow with properties propsRow
						else
							set oRow to make new row at end of children with properties propsRow
						end if
					end tell
					
					-- set oRow to make new row at end of children of oParentRow with properties propsRow
					
					tell oRow
						if varContext ­ missing value then set value of cell "Context" to name of varContext
						
						if varDuration ­ missing value then
							set lngMinutes to varDuration as integer
							if lngMinutes > 0 then
								set value of cell "Duration" to (lngMinutes / 60)
							end if
						end if
						
						if varStartDate is not equal to missing value then set value of cell "Start" to varStartDate
						if varDueDate is not equal to missing value then set value of cell "Due" to varDueDate
						if varDoneDate is not equal to missing value then set value of cell "Completed" to varDoneDate
						
						if blnFlagged then set state of cell "Flagged" to checked
					end tell
					
				end using terms from
				-- then recurse with any child tasks
				set lstSubTasks to tasks of oTask
				if (count of lstSubTasks) > 0 then
					my ExportTasks(docTarget, oRow, lstSubTasks)
				end if
			end if
		end repeat
	end using terms from
end ExportTasks




