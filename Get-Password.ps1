#!/usr/bin/env pwsh
#Requires -Version 6
#========================================
# NAME      : template.ps1
# LANGUAGE  : Microsoft PowerShell Core
# AUTHOR    : Bryan Dady
# UPDATED   : [todays_date]
# COMMENT   : Retrieve the current password, from WPS for credentials commonly referenced by Subsplash SREs
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

if ($MyScriptInfo) {
    Write-Output -InputObject (' # Start of {0} #' -f $MyScriptInfo.CommandName)
} else {
    Write-Output -InputObject (' # Start of {0} #' -f $MyInvocation.MyCommand.Name)
}

# Start new script logic here

# 3. Get Current Password Value from Web Password Safe

<# 
curl -H "X-WPS-Username: $WPS_USERNAME" -H "X-WPS-Password: $WPS_PASSWORD" -H "X-WPS-TOTP: 123456" -H "Content-Type: application/json" https://ops.subsplash.net/wps/rest/passwords/126/
curl -H "X-WPS-Username: $WPS_USERNAME" -H "X-WPS-Password: $WPS_PASSWORD" -H "X-WPS-TOTP: 123456" -H "Content-Type: application/json" https://ops.subsplash.net/wps/rest/passwords/126/currentValue
 -- example json response:

  {
    "message": "",
    "success": true,
    "password": {
      "tags": "",
      "id": "126",
      "username": "admin",
      "title": "db-stage-00.awsusw2.subsplash.net MySQL",
      "active": "Y",
      "notes": "host/port: db-tca-read-00.awsusw2.subsplash.net:3606"
    }
  }
  {
      "message": "",
      "success": true,
      "currentPassword": "##########"
  }
 #>

 # Dictionary of common SRE credentials, to retrieve from Web Password Safe

 { "id": "325", "username": "ops", "title": "MySQL AWS (Prod)", "notes": "Used for creating backups and administrative tasks" },
 { "id": "247", "username": "admin", "title": "MySQL AWS (Prod and Stage)", "notes": "Also works for Accounts and Auth DBs\nmysql-00.awsusw2.subsplash.net\nmysql-stage-00.awsusw2.subsplash.net\nmysql-prod-accounts-00.awsusw2.subsplash.net\nmysql-prod-accounts-00-read-00.awsusw2.subsplash.net\nmysql-prod-auth-00.awsusw2.subsplash.net\nmysql-prod-media-00.awsusw2.subsplash.net\nmysql-prod-media-00-read-00.awsusw2.subsplash.net" },
 { "id": "540", "username": "admin", "title": "MySQL AWS Dev", "notes": "Host: mysql-dev-00.awsus2.subsplash.net" },
 
 { "id": "1179", "username": "admin", "title": "MySQL AWS Stage Transcoder", "notes": "" },
 { "id": "126", "username": "admin", "title": "db-stage-00.awsusw2.subsplash.net MySQL", "notes": "host/port: db-tca-read-00.awsusw2.subsplash.net:3606" },
 { "id": "140", "username": "root", "title": "TCA db-stage-00.awsusw2.subsplash.net MySQL (staging)", "notes": "host:port: db-stage-00.awsusw2.subsplash.net:3333" },
 { "id": "141", "username": "root", "title": "TCA db-dev-00.awsusw2.subsplash.net MySQL (dev)", "notes": "host:port: db-dev-00.awsusw2.subsplash.net:3344" },
 { "id": "178", "username": "root", "title": "TCA db-dev-00.awsusw2.subsplash.net dev", "notes": "mysql -u root -p --port=3344 --host=db-dev-00.awsusw2.subsplash.net\n\n\ndb-dev-00.awsusw2.subsplash.net:3344" },
 { "id": "209", "username": "admin", "title": "mysql-01", "notes": "" },
 { "id": "378", "username": "root", "title": "mysql-02 (system)", "notes": "" },
 { "id": "400", "username": "admin", "title": "mysql-02 (system)", "notes": "" },
 { "id": "518", "username": "root", "title": "mysql-03", "notes": "box root access" },
 { "id": "521", "username": "admin", "title": "prod-01", "notes": "mysql" },
 { "id": "546", "username": "root", "title": "db-dev-00.awsusw2.subsplash.net MySQL root Password", "notes": "" },
 { "id": "551", "username": "root", "title": "db-warehouse-00.awsusw2.subsplash.net MySQL root", "notes": "" },

 { "id": "1145", "username": "sa_util", "title": "MySQL AWS Dev Database", "notes": "User: sa_util@172.20.124.93\nCI Variable: DSN_AUTH_DEV \nHost mysql-dev-00.awsusw2.subsplash.net:3306\nAccess: ALL PRIVILEGES on 'auth'" },

 { "id": "501", "username": "admin", "title": "MySQL (dev-01) giving", "notes": "" },
 { "id": "182", "username": "admin", "title": "MySQL AWS Prod Transcoder", "notes": "Host: mysql-prod-transcoder-00.awsusw2.subsplash.net" },
 { "id": "361", "username": "admin", "title": "mysql-02 (Prod)", "notes": "" },
 { "id": "358", "username": "root", "title": "TCA db-stage-00.awsusw2.subsplash.net:3333 stage", "notes": "mysql -u root -p --port=3333 --host=db-stage-00.awsusw2.subsplash.net\n\nhost:port: db-stage-00.awsusw2.subsplash.net:3333" },
  { "id": "493", "username": "root", "title": "Giving Mysql Prod", "notes": "Must use an ssh tunnel\nssh host: 172.20.132.5:22\nusername: root\nUse your rsa key\n\nMysql Hostname: 172.20.132.5\nUser: root" },
 { "id": "494", "username": "root", "title": "Giving Mysql Dev", "notes": "Must use ssh tunnel\nssh hostname: 172.20.132.3:22\nssh user: root\nuse rsa key\n\nmysql hostname: 127.0.0.1\nServer Port: 3306" },

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
