-- Real shortcut test in TextEdit. Returns a line of results.
on run argv
	set mode to "command"
	if (count of argv) ≥ 1 then set mode to item 1 of argv
	-- mode: command | control
	set clipBefore to ""
	try
		set clipBefore to the clipboard as string
	end try
	tell application "TextEdit"
		activate
		make new document
		set text of front document to "HELLO_UNDO_TEST"
	end tell
	delay 0.6
	tell application "System Events"
		tell process "TextEdit"
			set frontmost to true
			keystroke "a" using command down
			delay 0.2
			if mode is "control" then
				keystroke "c" using control down
			else
				keystroke "c" using command down
			end if
			delay 0.3
		end tell
	end tell
	set clipAfter to ""
	try
		set clipAfter to the clipboard as string
	end try
	tell application "System Events"
		tell process "TextEdit"
			set frontmost to true
			if mode is "control" then
				keystroke "z" using control down
			else
				keystroke "z" using command down
			end if
			delay 0.4
		end tell
	end tell
	tell application "TextEdit"
		set body to text of front document
		close front document saving no
	end tell
	return "mode=" & mode & " copy=[" & clipAfter & "] afterUndo=[" & body & "]"
end run
