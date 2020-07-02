#!/usr/bin/env pwsh
#Requires -Version 6 -Module powershell-yaml
#========================================
# NAME      : Set-DeploymentResource.ps1
# LANGUAGE  : Microsoft PowerShell Core
# AUTHOR    : Bryan Dady
# UPDATED   : 2020-07-02
# COMMENT   : Calculate and set/update values in Kubernetes values*.yaml files
#========================================
[CmdletBinding()]
param (
    [parameter(Mandatory,
        Position = 0,
        HelpMessage='Provide the path to the root of the Kubernetes project repository.'
    )]
    [ValidateScript({Test-Path -Path $PSItem})]
    [Alias('Project','Repository')]
    [String]$Path
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

Write-Verbose -Message 'Declaring Function Get-YAMLfromFile'
Function Get-YAMLfromFile {
    [Cmdletbinding(SupportsShouldProcess)]
    param (
        [parameter(Mandatory,
            Position = 0,
            HelpMessage='Provide the path to the file from which to read YAML.',
            ValueFromPipeline
        )]
        [ValidateScript({Test-Path -Path $PSItem})]
        [Alias('File','FilePath')]
        [String]$Path
    )

    $YAML = Get-Content -Path $Path | ConvertFrom-Yaml

    # Do we need to validate the YAML before returning?
    # $YAML.GetType().Name = Hashtable
    # $YAML.Count -gt 1
    # $YAML.Keys should include 'deployment'

    if ($YAML.Count -gt 1) {
        Return $YAML
    } else {
        Write-Warning -Message 'Invalid YAML'
        Return $null
    }
}

Write-Verbose -Message 'Declaring Function Set-YAMLtoFile'
Function Set-YAMLtoFile {
    [Cmdletbinding(SupportsShouldProcess)]
    param (
        [parameter(Mandatory,
            Position = 0,
            HelpMessage='Provide the YAML content to be written.',
            ValueFromPipeline
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Object')]
        [String]$Content,
        [parameter(Mandatory,
            Position = 1,
            HelpMessage='Provide the path to the file to write $Content.',
            ValueFromPipeline
        )]
        [ValidateScript({Test-Path -Path $PSItem})]
        [Alias('File','FilePath')]
        [String]$Path
    )

    $Content | ConvertTo-Yaml | Set-Content -Path $Path

    # Do we need to validate the YAML was written before returning?
    # $YAML.GetType().Name = Hashtable
    # $YAML.Count -gt 1
    # $YAML.Keys should include 'deployment'

    if ($YAML.Count -gt 1) {
        Return $YAML
    } else {
        Write-Warning -Message 'Invalid YAML'
        Return $null
    }
}

# Load current values from existing files into variables
# Confirm the expected file/folder structure in the project repository
Write-Verbose -Message ('Opening project {0}' -f $Path)
$ProjectPath = Get-Item -Path $Path

# Derive the path to the values files
$ValuesFile   = Join-Path -Path $ProjectPath -ChildPath '/chart/values.yaml'
$DevFile   = Join-Path -Path $ProjectPath -ChildPath '/chart/values-dev.yaml'
$StageFile = Join-Path -Path $ProjectPath -ChildPath '/chart/values-stage.yaml'
$ProdFile  = Join-Path -Path $ProjectPath -ChildPath '/chart/values-prod.yaml'

# Use function to read yaml from file
$Shared = Get-YAMLfromFile -Path $ValuesFile
$Dev    = Get-YAMLfromFile -Path $DevFile
$Stage  = Get-YAMLfromFile -Path $StageFile
$Prod   = Get-YAMLfromFile -Path $ProdFile

# Get the root / 'shared' autoscaling and deployment values
$Shared.autoscaling.enable # should always be true
Write-Verbose -Message ('$Shared.autoscaling.enable: {0}' -f $Shared.autoscaling.enable)

$s_rep_min = $Shared.autoscaling.minReplicas
$s_rep_max = $Shared.autoscaling.maxReplicas

$s_rep_qty = $Shared.deployment.replicaCount

$s_cpu_lim = $Shared.deployment.resources.limits.cpu
$s_mem_lim = $Shared.deployment.resources.limits.memory
$s_cpu_req = $Shared.deployment.resources.requests.cpu
$s_mem_req = $Shared.deployment.resources.requests.memory

# Calculate ratio of prod for Stage
# - for now it's in a variable
# Calculate 1/3 of prod for Dev

$d_rep_min = # $Dev.autoscaling.minReplicas
$d_rep_max = # $Dev.autoscaling.maxReplicas

$d_rep_qty = # $Dev.deployment.replicaCount

$d_cpu_lim = # $Dev.deployment.resources.limits.cpu
$d_mem_lim = # $Dev.deployment.resources.limits.memory
$d_cpu_req = # $Dev.deployment.resources.requests.cpu
$d_mem_req = # $Dev.deployment.resources.requests.memory

# Now we can setup some changes
Write-Verbose -Message ('$Dev.deployment.replicaCount was {0}, setting to {1}' -f $s_rep_qty, $d_rep_qty)
$Dev.deployment.replicaCount = $d_rep_qty

Write-Verbose -Message ('$Dev.autoscaling.minReplicas was {0}, setting to {1}' -f $s_rep_min, $d_rep_min)
$Dev.autoscaling.minReplicas = $d_rep_min

Write-Verbose -Message ('$Dev.autoscaling.maxReplicas was {0}, setting to {1}' -f $s_rep_max, $d_rep_max)
$Dev.autoscaling.maxReplicas = $d_rep_max

Write-Verbose -Message ('$Dev.resources.limits.cpu was {0}, setting to {1}' -f $s_cpu_lim, $d_cpu_lim)
$Dev.deployment.resources.limits.cpu = $d_cpu_lim

Write-Verbose -Message ('$Dev.resources.requests.cpu was {0}, setting to {1}' -f $s_cpu_req, $d_cpu_req)
$Dev.deployment.resources.requests.cpu = $d_cpu_req

Write-Verbose -Message ('$Dev.resources.limits.memory was {0}, setting to {1}' -f $s_mem_lim, $d_mem_lim)
$Dev.deployment.resources.limits.memory = $d_mem_lim

Write-Verbose -Message ('$Dev.resources.requests.memory was {0}, setting to {1}' -f $s_mem_req, $d_mem_req)
$Dev.deployment.resources.requests.memory = $d_mem_req


# And finally ... commit the changes to file
$DevTestFile   = Join-Path -Path $ProjectPath -ChildPath '/chart/values-dev-test.yaml'
$StageTestFile = Join-Path -Path $ProjectPath -ChildPath '/chart/values-stage-test.yaml'


<#
    .SYNOPSIS
    Edit the System PATH statement globally in Windows Powershell with 4 new Advanced functions. Add-EnvPath, Set-EnvPath, Remove-EnvPath, Get-EnvPath - SUPPORTS -whatif parameter
    .DESCRIPTION
    Adds four new Advanced Functions to allow the ability to edit and Manipulate the System PATH ($Env:Path) from Windows Powershell - Must be run as a Local Administrator
    .EXAMPLE
    PS C:\> Get-EnvPathFromRegistry
    Get Current Path
    .EXAMPLE
    PS C:\> Add-EnvPath C:\Foldername
    Add Folder to Path
    .EXAMPLE
    PS C:\> Remove-EnvPath C:\Foldername
    Remove C:\Foldername from the PATH
    .EXAMPLE
    PS C:\> Set-EnvPath C:\Foldernam;C:\AnotherFolder
    Set the current PATH to the above.  WARNING- ERASES ORIGINAL PATH
    .NOTES
    NAME        :  Set-EnvPath
    VERSION     :  1.0
    LAST UPDATED:  2/20/2015
    AUTHOR      :  Sean Kearney
    # Added 'Test-LocalAdmin' function written by Boe Prox to validate is PowerShell prompt is running in Elevated mode
    # Removed lines for correcting path in Add-EnvPath
    # Switched Path search to an Array for "Exact Match" searching
    # 2/20/2015
    .LINK
    https://gallery.technet.microsoft.com/3aa9d51a-44af-4d2a-aa44-6ea541a9f721
    .LINK
    Test-LocalAdmin
    .INPUTS
    None
    .OUTPUTS
    None
#>