set theFile to (choose file with prompt "Create task based on file:")
set fileContents to (read theFile)
set theFilePath to (POSIX path of theFile)
set AppleScript's text item delimiters to "/"
set parentPath to (items 1 thru -2 of text items of theFilePath) as string
set theFileName to (item -1 of text items of theFilePath) as string
set AppleScript's text item delimiters to "."
set theFileNameNoext to (items 1 thru -2 of text items of theFileName) as string
set AppleScript's text item delimiters to ""
set quotedParentPath to quoted form of parentPath
set quotedFileName to quoted form of theFileName
set quotedFileNameNoext to quoted form of theFileNameNoext
tell application "OmniFocus"
	activate
	tell the first document
		set NewTask to make new inbox task with properties {name:theFileNameNoext, note:"Imported from Simplenote" & return & fileContents}
		tell the note of NewTask
			make new file attachment with properties {file name:theFile, embedded:true}
		end tell
	end tell
end tell
set theFileReference to open for access theFile with write permission
write return & "#oftask_entered" & return to theFileReference starting at eof
close access theFileReference
