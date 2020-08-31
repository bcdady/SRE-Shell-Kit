#!/usr/bin/env pwsh
#Requires -Version 6
#========================================
# NAME      : Get-Password.ps1
# LANGUAGE  : Microsoft PowerShell Core
# AUTHOR    : Bryan Dady
# UPDATED   : 5/22/2020
# COMMENT   : Retrieve the current password (via WPS REST API) for credentials commonly referenced by Subsplash SREs
#========================================
[CmdletBinding()]
Param(
    [Parameter(Mandatory, Position = 0)]
    [string]
    $WPS_USERNAME = $ENV:USER,
    [Parameter(Mandatory, Position = 1)]
    [SecureString]
    $WPS_PASSWORD,
    [Parameter(Position = 2)]
    [string]
    $SecretName,
    [Parameter(Position = 3)]
    [Switch]
    $ListAvailable
)
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

if ($MyScriptInfo) {
    Write-Output -InputObject (' # Start of {0} #' -f $MyScriptInfo.CommandName)
} else {
    Write-Output -InputObject (' # Start of {0} #' -f $MyInvocation.MyCommand.Name)
}

# Start new script logic here

# URI constants
$WPS_REST_URL = 'https://ops.subsplash.net/wps/rest/'
 
if (-not $SecretName) {
    $ListAvailable = $true
}

# 1. Get the password/secret name (key), from a script/function parameter

# 2. Lookup the WPS ID for the password/secret name (key)

$Secrets = [ordered]@{
    # SecretName = WPS_ID
    'db-giving-dev'	          = '501'
    'db-giving-stage'         = '126'
    'db-giving-prod'	      = '493'
    'db-mysql-01'	          = '209'
    'db-prod-01'	          = '521'
    'db-sap-dev'	          = '540'
    'db-sap-stage'            = '247'
    'db-sap-prod'             = '247'
    'db-sap-prod (ops)' 	  = '325'
    'db-sap-transcoder-stage' = '1179'
    'db-sap-transcoder-prod'  = '182'
    'db-tca-dev-1'	          = '141'
    'db-tca-dev-2'	          = '178'
    'db-tca-stage-1'	      = '140'
    'db-tca-stage-2'	      = '358'
    'db-tca-prod-1'           = '361'
    'db-tca-prod-2'	          = '400'
}

if ($ListAvailable) {
    ''
    '= Available databases: ='
    '========================'
    $Secrets.Keys
    ''

} else {

    # $SecretName = 'prod-01'
    $WPSID = $Secrets[$SecretName]

    # 3. Get Current Password Value from Web Password Safe

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add('X-WPS-Username', $WPS_USERNAME)
    $headers.Add('X-WPS-Password', $(ConvertFrom-SecureString -SecureString $WPS_PASSWORD -AsPlainText))
    $headers.Add('X-WPS-TOTP', '123456')

    Write-Output -InputObject ''
    Write-Output -InputObject ('Looking up password for ''{0}''' -f $SecretName)

    $Info = Invoke-RestMethod -Uri ('{0}passwords/{1}/' -f $WPS_REST_URL, $WPSID) -Headers $headers -Method Get 
    $Password = Invoke-RestMethod -Uri ('{0}passwords/{1}/currentValue' -f $WPS_REST_URL, $WPSID) -Headers $headers -Method Get 

    Write-Output -InputObject ''
    Write-Output -InputObject (" Title: `t {0}" -f $Info.password.title)
    Write-Output -InputObject (" Notes: `t {0}" -f $Info.password.notes)
    Write-Output -InputObject (" username: `t {0}" -f $Info.password.username)
    Write-Output -InputObject (" Password: `t {0}" -f $Password.currentPassword)
    Write-Output -InputObject ''
        
}

 # End of script logic
 if ($MyScriptInfo) {
    Write-Output -InputObject (' # End of {0} #' -f $MyScriptInfo.CommandName)
} else {
    Write-Output -InputObject (' # Start of {0} #' -f $MyInvocation.MyCommand.Name)
}

# For intra-profile/bootstrap script flow Testing, in verbose output mode
if ($IsVerbose) {
    Write-Output -InputObject ''
    Start-Sleep -Seconds 3
}
