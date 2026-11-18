# Rebuilds App_Data\BakedWithLove.mdf from CreateDatabase.sql using SQL Server Express LocalDB.
# Run from PowerShell:  powershell -ExecutionPolicy Bypass -File Database\RebuildDatabase.ps1
$ErrorActionPreference = "Stop"
$root    = Split-Path -Parent $PSScriptRoot
$appData = Join-Path $root "App_Data"
$mdf     = Join-Path $appData "BakedWithLove.mdf"
$ldf     = Join-Path $appData "BakedWithLove_log.ldf"
$sql     = Join-Path $PSScriptRoot "CreateDatabase.sql"
$server  = "(localdb)\MSSQLLocalDB"

New-Item -ItemType Directory -Force $appData | Out-Null
sqllocaldb start MSSQLLocalDB | Out-Null

# Detach any copy that is still attached, then delete old files
$drop = "IF DB_ID('BakedWithLove_Build') IS NOT NULL BEGIN ALTER DATABASE BakedWithLove_Build SET SINGLE_USER WITH ROLLBACK IMMEDIATE; EXEC sp_detach_db 'BakedWithLove_Build'; END"
sqlcmd -S $server -b -Q $drop
Remove-Item $mdf, $ldf -ErrorAction SilentlyContinue

sqlcmd -S $server -b -Q "CREATE DATABASE BakedWithLove_Build ON (NAME='BakedWithLove', FILENAME='$mdf') LOG ON (NAME='BakedWithLove_log', FILENAME='$ldf')"
sqlcmd -S $server -b -d BakedWithLove_Build -i $sql
sqlcmd -S $server -b -Q "ALTER DATABASE BakedWithLove_Build SET SINGLE_USER WITH ROLLBACK IMMEDIATE; EXEC sp_detach_db 'BakedWithLove_Build';"
Write-Host "Database created at $mdf"
