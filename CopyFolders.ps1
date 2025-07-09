<#
.SYNOPSIS
    PowerShell 7.5 backup script with ZIP archiving
.DESCRIPTION
    Enhanced version using PowerShell 7.5 features for better performance and reliability
.NOTES
    Add 'Archive = true' to any [sourceX] section to enable ZIP compression
    Requires PowerShell 7.5 or later
#>

param(
    [string]$ConfigFile = "config.ini"
)

# INI file parser
function Get-IniContent {
    param([string]$filePath)
    
    $ini = [ordered]@{}
    $section = "NO_SECTION"
    $ini[$section] = [ordered]@{}
    
    Get-Content $filePath -ErrorAction Stop | Where-Object { 
        $_ -notmatch "^;" -and $_.Trim() -ne "" 
    } | ForEach-Object {
        $line = $_.Trim()
        switch -Regex ($line) {
            "^\[(.+)\]$" {
                $section = $matches[1].Trim()
                $ini[$section] = [ordered]@{}
            }
            "^(.+?)\s*=\s*(.+)$" {
                $key, $value = $matches[1..2]
                $ini[$section][$key.Trim()] = $value.Trim()
            }
        }
    }
    return $ini
}

# Enhanced logger
function Write-Log {
    param(
        [string]$message, 
        [string]$logFile, 
        [string]$color = "White",
        [bool]$isError = $false
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $message"
    
    try {
        Add-Content -Path $logFile -Value $logMessage -ErrorAction Stop
        if ($isError) {
            Write-Host $logMessage -ForegroundColor $color -BackgroundColor DarkRed
        } else {
            Write-Host $logMessage -ForegroundColor $color
        }
    }
    catch {
        Write-Host "Failed to write to log file: $_" -ForegroundColor Red
    }
}

# ZIP archiving
function Create-ZipArchive {
    param(
        [string]$SourcePath,
        [string]$ZipDestination,
        [string]$logFile
    )
    
    try {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        Write-Log "Creating ZIP archive for $SourcePath" $logFile "Cyan"
        
        if (Test-Path $ZipDestination) {
            Remove-Item $ZipDestination -Force -ErrorAction Stop
        }
        
        $compressParams = @{
            Path = $SourcePath
            DestinationPath = $ZipDestination
            CompressionLevel = "Optimal"
            ErrorAction = "Stop"
        }
        Compress-Archive @compressParams
        
        $zipSize = [math]::Round((Get-Item $ZipDestination).Length / 1MB, 2)
        $elapsed = $stopwatch.Elapsed.ToString("hh\:mm\:ss\.fff")
        Write-Log "ZIP created: $ZipDestination ($zipSize MB) in $elapsed" $logFile "Green"
        
        return $true
    }
    catch {
        Write-Log "ZIP creation failed: $_" $logFile -isError $true
        return $false
    }
}

# Main script
try {
    $config = Get-IniContent -filePath $ConfigFile
    $logPath = if ($config["Settings"]["LogPath"]) { $config["Settings"]["LogPath"] } else { "backup.log" }
    
    $logDir = Split-Path $logPath -Parent
    if ($logDir -and -not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    }
    
    Write-Log "=== BACKUP START ===" $logPath "Green"
    
    # Исправленная обработка секций
    ($config.Keys | Where-Object { $_ -match "^source\d+" } | Sort-Object) | ForEach-Object {
        $section = $_
        $settings = $config[$section]
        
        if ($settings["Enabled"] -ne "true") {
            Write-Log "[$section] SKIPPED (disabled)" $logPath "Yellow"
            return
        }
        
        $source = $settings["Source"].Trim('"')
        $dest = $settings["Destination"].Trim('"')
        $archive = $settings["Archive"] -eq "true"
        
        if (-not (Test-Path $source)) {
            Write-Log "[$section] SOURCE NOT FOUND: $source" $logPath -isError $true
            return
        }
        
        try {
            if ($archive) {
                $zipFile = Join-Path (Split-Path $dest) "$(Split-Path $source -Leaf)-$(Get-Date -Format 'yyyyMMdd').zip"
                if (Create-ZipArchive -SourcePath $source -ZipDestination $zipFile -logFile $logPath) {
                    Write-Log "[$section] ARCHIVED TO: $zipFile" $logPath "Green"
                }
            }
            else {
                if (-not (Test-Path $dest)) { 
                    New-Item -ItemType Directory -Force -Path $dest | Out-Null 
                }
                
                $robocopyParams = @{
                    Source = $source
                    Destination = $dest
                    Files = "*.*"
                    Recurse = $true
                    Mirror = $true
                    NP = $true
                    LogFile = $logPath
                    Append = $true
                }
                robocopy @robocopyParams
                
                Write-Log "[$section] COPIED TO: $dest" $logPath "Green"
            }
        }
        catch {
            Write-Log "[$section] ERROR: $_" $logPath -isError $true
        }
    }
    
    Write-Log "=== BACKUP COMPLETE ===" $logPath "Green"
    exit 0
}
catch {
    Write-Log "FATAL ERROR: $_" $logPath -isError $true
    exit 1
}