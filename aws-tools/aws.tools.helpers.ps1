#!/usr/bin/env pwsh
#Requires -Version 5
#========================================
# NAME      : aws.tools.helpers.ps1
# LANGUAGE  : Microsoft PowerShell (Core)
# AUTHOR    : Bryan Dady
# UPDATED   : 07/24/2021 - v0.0.1 : Enhance ELBv2 helper functions
# COMMENT   : Provides wrapper functions that make interaction with AWS.Tools. modules and cmdlets more powershell-native
#========================================
[CmdletBinding()]
param()
Set-StrictMode -Version latest

# Uncomment the following 2 lines for testing profile scripts with Verbose output
# '$VerbosePreference = ''Continue'''
# $VerbosePreference = 'Continue'

Write-Output -InputObject 'Loading functions from ./aws.tools.helpers.elb.ps1'
. (Join-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -ChildPath 'aws.tools.helpers.elb.ps1') -Verbose

Write-Output -InputObject 'Loading functions from ./aws.tools.helpers.dns.ps1'
. (Join-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -ChildPath 'aws.tools.helpers.dns.ps1') -Verbose
