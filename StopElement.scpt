-- Stop MkConsoleElement.applescript
-- MkConsole

try
	tell application "MkConsoleElement" to quit
on error -- (Do nothing; just suppress any confusing error messages.)
end try
