### Purpose:

The CopyFolders.ps1 script copies files from specified source folders to destination folders, with optional archiving. It is controlled via a .ini file.

### How to Use:

To run launch the `run_backup.bat` file with a double-click.

Configure the .ini file:

`[Settings]`
`LogPath = log.log`  — path to the log file (can be renamed or moved).

`[source1]`

`Enabled = true`

`Source = E:\BACKUP_source`

`Destination = F:\BACKUP_destination`

`Archive = true`

`[sourceX]` — task name. You can add as many as you want, just change the number (e.g., `[source6], [source7]`, etc.).

Enabled — enable (true) or disable (false) this task.

Source — path to the folder to back up.

Destination — path to where the files will be copied.

Archive — if true, creates a ZIP archive with the current date.

### Requirements:

PowerShell 7.5 or higher

Must be launched via run_backup.bat, not directly (otherwise it may run in PowerShell 5 and fail to work)
