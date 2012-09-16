set p to POSIX path of "/Users/sechilds/Dropbox/Apps/Drafts/Journal.txt"
set input_file to POSIX path of p
set l to paragraphs of (do shell script "grep . " & input_file)
do shell script ">" & input_file

tell app "OmniFocus" to tell document 1
	repeat with v in l
		make new inbox task with properties {name:v}
	end repeat
end tell

