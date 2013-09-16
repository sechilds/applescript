tell application "Mail"
	activate
	set addrVar to "sechilds@gmail.com"
	set theSubject to "The Week Ahead (week "
	set theSubject to theSubject & do shell script "date +%V"
	set theSubject to theSubject & " starting "
	set theSubject to theSubject & date string of (current date)
	set theSubject to theSubject & ")"
	set theSender to "Stephen Childs <schild2@uottawa.ca>"
	set composeMessage to (a reference to (make new outgoing message))
	tell composeMessage
		make new to recipient with properties {name:"Ross Finnie", address:"rfinnie@uottawa.ca"}
		make new cc recipient at end of cc recipients with properties {name:"Dejan Pavlic", address:"Dejan.Pavlic@uottawa.ca"}
		make new cc recipient at end of cc recipients with properties {name:"Andrew Wismer", address:"awismer@irpe-epri.ca"}
		make new cc recipient at end of cc recipients with properties {name:"Nemanja Jevtovic", address:"njevtovic@irpe-epri.ca"}
		set the subject to theSubject
		set the sender to theSender
		set visible to true
	end tell
	-- save composeMessage
end tell

