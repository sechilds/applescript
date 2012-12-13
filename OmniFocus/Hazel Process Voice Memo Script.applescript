on hazelProcessFile(theFile)
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
	set destFileName to (parentPath & "/" & theFileNameNoext & ".caf")
	do shell script ("afconvert -v -f 'caff' -d ima4@22050 " & theFilePath & " " & destFileName)
	tell application "OmniFocus"
		activate
		tell the first document
			set theContext to first flattened context where its name = "OmniFocus"
			set theProject to the first flattened project where its name = "DropVox"
			tell theProject
				set NewTask to make new task with properties {name:"Process Voice Note " & theFileNameNoext & ".caf", note:"Created from DropVox.", context:theContext}
			end tell
			tell the note of NewTask
				make new file attachment with properties {file name:destFileName, embedded:true}
			end tell
		end tell
	end tell
end hazelProcessFile

