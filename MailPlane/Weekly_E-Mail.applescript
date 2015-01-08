tell application "Mailplane 3"
	set theSubject to "The Week Ahead (week "
	set theSubject to theSubject & do shell script "date +%V"
	set theSubject to theSubject & " starting "
	set theSubject to theSubject & date string of (current date)
	set theSubject to theSubject & ")"
	activate
	set m to make new outgoing message with properties {directlySend:false, optimizeAttachments:true}
	tell m
		set theSender to "Stephen Childs <schild2@uottawa.ca>"
		make new to recipient with properties {name:"Ross Finnie", address:"rfinnie@uottawa.ca"}
		make new bcc recipient at end of bcc recipients with properties {name:"Dejan Pavlic", address:"Dejan.Pavlic@uottawa.ca"}
		make new bcc recipient at end of bcc recipients with properties {name:"Kaveh Afshar", address:"kaveh.afshar@irpe-epri.ca"}
		make new bcc recipient at end of bcc recipients with properties {name:"John Sergeant", address:"jsergeant@irpe-epri.ca"}
		set the subject to theSubject
		set the sender to theSender
		-- set visible to true
	end tell
	compose m
end tell

