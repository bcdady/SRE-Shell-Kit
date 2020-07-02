#!/usr/bin/env pwsh
#Requires -Version 6
#========================================
# NAME      : template.ps1
# LANGUAGE  : Microsoft PowerShell Core
# AUTHOR    : Bryan Dady
# UPDATED   : [todays_date]
# COMMENT   : Describe what this script is supposed to do.
#========================================
[CmdletBinding()]
param ()
Set-StrictMode -Version latest

# Uncomment the following 2 lines for testing profile scripts with Verbose output
#'$VerbosePreference = ''Continue'''
#$VerbosePreference = 'Continue'

# Only call (and use results from Get-IsVerbose function, if it was loaded from ./Bootstrap.ps1)
if (Test-Path -Path Function:\Get-IsVerbose) {
    Get-IsVerbose
}

# Only call (and use results from Get-MyScriptInfo function, if it was loaded from ./Bootstrap.ps1)
if (Test-Path -Path Function:\Get-MyScriptInfo) {
    $MyScriptInfo = Get-MyScriptInfo($MyInvocation) -Verbose
    if ($IsVerbose) { $MyScriptInfo }    
}

Write-Output -InputObject (' # Start of {0} #' -f $MyScriptInfo.CommandName)

# Start new script logic here


# End of script logic
Write-Output -InputObject (' # End of {0} #' -f $MyScriptInfo.CommandName)

# For intra-profile/bootstrap script flow Testing, in verbose output mode
if ($IsVerbose) {
    Write-Output -InputObject ''
    Start-Sleep -Seconds 3
}
