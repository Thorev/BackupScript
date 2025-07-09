@echo off
pwsh -NoExit -File "%~dp0CopyFolders.ps1" -ConfigFile "%~dp0config.ini"
