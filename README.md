## 📌 Purpose
The script provides automated file backup functionality, copying files from specified source folders to destination locations with optional archiving capabilities. The entire process is controlled via a configuration (.ini) file.

---

## 🚀 How to Use
Double-click the `run_backup.bat` file to execute the backup process

The script will automatically:

Read configuration from the .ini file

Perform all enabled backup tasks

Generate logs of the operation

Note: Must be executed via run_backup.bat (direct execution may default to PowerShell 5.x and fail)

---

## ⚙️ Configuration (INI File Setup)
Main Settings Section

`[Settings]`

`LogPath = log.log`  # Path to the log file (can be renamed or relocated)


Backup Task Sections
For each backup task, create a section with the following structure:

`[source1]`  # Task identifier (increment number for additional tasks)

`Enabled = true`             # true to enable, false to disable this task

`Source = E:\BACKUP_source`  # Source directory to back up

`Destination = F:\BACKUP_destination`  # Target backup location

`Archive = true`             # Enable ZIP archiving (true/false)

---

### ⚠️ **Important Notice: PowerShell Version Required**

This script **requires Microsoft PowerShell version 7.5 or higher**.

> 🪟 **Note for Windows 11 users:**
> By default, Windows 11 comes with an **older version** of PowerShell (usually 5.x), which is **not compatible** with this script.
> Running it without the correct version will cause it to fail.

✅ **Download the latest PowerShell from the official repository:**
[https://github.com/PowerShell/PowerShell/](https://github.com/PowerShell/PowerShell/)


