-- Developed by Joe Workman
-- http://joeworkman.net

on encode_URL(txt)
	set python_script to "import sys, urllib; print urllib.quote(sys.argv[1])"
	set python_script to "python -c " & �
		quoted form of python_script & " " & �
		quoted form of txt
	return do shell script python_script
end encode_URL

on handle_string(theString)
	-- say theString
	open location "kiwi://post?window=false&text=" & encode_URL(theString)
end handle_string