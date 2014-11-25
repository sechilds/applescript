-- set cmd1 to do shell script POSIX path of "/usr/local/bin/icalBuddy" & " -npn -nc -eep \"*\" -ic \"John's EPRI Work Schedule\" eventsToday"
tell application "Mail"
	activate
	set addrVar to "sechilds@gmail.com"
	set theSubject to date string of (current date)
	set theSender to "Stephen Childs <schild2@uottawa.ca>"
	set composeMessage to (a reference to (make new outgoing message))
	tell composeMessage
		make new to recipient with properties {name:"Ross Finnie", address:"rfinnie@uottawa.ca"}
		make new bcc recipient at end of bcc recipients with properties {name:"Dejan Pavlic", address:"Dejan.Pavlic@uottawa.ca"}
		make new bcc recipient at end of bcc recipients with properties {name:"Kaveh Afshar", address:"kaveh.afshar@irpe-epri.ca"}
		make new bcc recipient at end of bcc recipients with properties {name:"John Sergeant", address:"jsergeant@irpe-epri.ca"}
		set the subject to theSubject
		set the sender to theSender
		set visible to true
	end tell
	-- save composeMessage
end tell
