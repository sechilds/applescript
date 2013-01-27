(*
    Send the URL of the Safari tab to Pinboard from LaunchBar

    Author: Collin Donnell
    Website: http://collindonnell.com
    Date: 2013-01-06

    Initially based on script for sending Chrome links to Pinboard 
    using Alfred by Tim Bueno:
    http://www.timbueno.com/2012/06/27/pinboard-plus-alfred
*)

on handle_string(inputString)
    try
		set mytoken to do shell script "security 2>&1 >/dev/null find-generic-password -gs pinboard_token | cut -d '\"' -f 2"

        -- Get your API token from Pinboard's Settings/Password page. 
        set userToken to "sechilds:" & mytoken
        
        -- URL encode the input string as the tags to be used
        set tagsString to stringByURLEncodingString(inputString as text)
        
        -- Get the URL and title of the frontmost Safari tab.
        tell application "Safari"
            set pageURL to URL of current tab of window 1
            set pageName to name of current tab of window 1
        end tell
        
        set pageDescription to stringByURLEncodingString(pageName)
        
        set shellScript to ("curl --url \"https://api.pinboard.in/v1/posts/add?url=" & pageURL & "&description=" & pageDescription & "&tags=" & tagsString & "&auth_token=" & userToken & "\"")
        set responseText to (do shell script shellScript)
        
        if responseText contains "code=\"done\"" then
            tell application "LaunchBar" to display in notification center pageURL with title "Sent to Pinboard" subtitle pageName
        else
            tell application "LaunchBar" to display in notification center pageURL with title "Failed Sending to Pinboard" subtitle pageName
        end if
    end try
end handle_string


to stringByURLEncodingString(aString)
    do shell script "python -c 'import sys, urllib; print urllib.quote(sys.argv[1])' " & (quoted form of aString)
end stringByURLEncodingString
