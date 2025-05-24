# updateVista

This is a project that I did for fun while trying to learn batch script.
The function of the script is that it updates a freshly installed windows Vista SP2 all the way up to 2025-05 Cumulative update.
The UAC must be disabled for the script to work.

Recent changes: I implemented a function to check if an update is installed or not before trying to download it. This saves a lot of time if the system is already updated to a previous cumulative update. The user is able to choose to backup all the updates or download only the missing ones with a variable inside the script.
