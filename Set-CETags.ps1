#!/usr/bin/env pwsh
#Requires -Version 6
#========================================
# NAME      : Set-CETags.ps1
# LANGUAGE  : Microsoft PowerShell Core
# AUTHOR    : Bryan Dady
# UPDATED   : 2020-02-17
# COMMENT   : Assign CE-Category and CE-Product tags to all AWS resources that don't yet have those tags populated.
#             CE is for Cost Explorer, so that AWS costs can be more readily seen and interpreted in the AWS Cost Explorer web console.
#========================================
[CmdletBinding()]
Param(
    [Parameter(Mandatory, Position = 0)]
    [ValidateSet('DMS', 'EC2','EBS', 'RDS', 'S3')]
    [string]
    $ResourceType = 'EBS',
    [Parameter(Position = 1)]
    [string]
    $Profile = (Get-Variable -Name StoredAWSCredentials).Value,
    [Parameter(Position = 2)]
    [ValidateScript({$ValidSet = @((Get-AWSRegion).Region); $ValidSet += 'USA'; $PSItem -in $ValidSet})]
    [string]
    $Region = 'USA'
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
    $MyScriptInfo = Get-MyScriptInfo($MyInvocation)
    if ($IsVerbose) { $MyScriptInfo }
}

if ($Region -eq 'USA') {
    Write-Verbose -Message 'Using RegionSet USA'
    $RegionSet = @('us-east-1', 'us-east-2', 'us-west-1', 'us-west-2')
} else {
    # Populate $Region array with default variable value, unless otherwise specified
    Write-Verbose -Message ('Region parameter is: {0}' -f $Region)
    if ($null -ne $Region) {
        if ($Region -in (Get-AWSRegion).Region) {
            Write-Verbose -Message ('Using Region {0}' -f $Region)
            $RegionSet = @($Region)
        } else {
            Write-Verbose -Message ('Invalid Region parameter ({0})' -f $Region)
        }
    } else {
        Write-Verbose -Message ('Null Region parameter ({0})' -f $Region)
    }

    if ($IsVerbose) { ('RegionSet is: {0}' -f $RegionSet) }
    ($null -ne $Env:StoredAWSRegion)

    if ($null -eq $RegionSet) {
        if ($null -ne $Env:StoredAWSRegion) {
            Write-Verbose -Message ('Using $Env:StoredAWSRegion: {0}' -f $Env:StoredAWSRegion)
            $RegionSet = @($Env:StoredAWSRegion) # @((Get-Variable -Name StoredAWSRegion).Value)
        } else {
            throw 'Failed to determine AWS Region to proceed in'
        }
    }
}

# Functions
Write-Verbose -Message 'Declaring function Test-EC2Tag'
function Test-EC2Tag {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ResourceID,
        [Parameter(Position = 1)]
        [string]
        $TagKey = 'CE-Category',
        [Parameter(Position = 2)]
        [string]
        $Value = ''
    )
    # Make sure the necessary module and cmdlet are available
    $null = Get-Command -Name Get-EC2Tag -ErrorAction Stop
    Write-Verbose -Message ('  Resource: {0}\n  Key: {1}\n  Value: {2}' -f $ResourceID, $TagKey, $Value)

    $TagArray = (Get-EC2Instance -InstanceId i-01f33590ee85cdec9).Instances | Select-Object -ExpandProperty Tags

    # We start out presuming the most likely outcome, that the actual Value doesn't match the specified $Value
    $TestResult = $False
    foreach($element in $TagArray) {
        Write-Verbose -Message ('<pre-if> {0} = {1}' -f $element.Key, $element.Value)
        if ($element.Key = $TagKey) {
            Write-Verbose -Message ('\n  <key> Key: {0} = Value: {1}' -f $element.Key, $element.Value)
            # If $Value includes an asterisk, treat is as a wildcard match with -like operator instead of strict equivalence comparison
            if ($Value -like '*') {
                # $Value includes an asterisk, so use a wildcard comparison against $element.Value
                if ($element.Value -like $Value) {
                    Write-Verbose -Message '$TestResult = $True'
                    $TestResult = $True
                }

            } else {
                # Use a strict equals comparison against $element.Value
                if ($element.Value -eq $Value) {
                    Write-Verbose -Message '$TestResult = $True'
                    $TestResult = $True
                }
            }
        }
    }

    return $TestResult
}

Write-Verbose -Message 'Declaring function Set-EC2Tag'
function Set-EC2Tag {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ResourceID,
        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $TagKey = 'CE-Product',
        [Parameter(Position = 2)]
        [string]
        $Value = 'Giving'
    )
    # Make sure the necessary module and cmdlet are available
    $null = Get-Command -Name New-EC2Tag -ErrorAction Stop
    Write-Verbose -Message ('  Resource: {0}\n  Key: {1}\n  Value: {2}' -f $ResourceID, $TagKey, $Value)

    # Assemble the Tag object
    $Tag = @{
        'Key'   = $TagKey
        'Value' = $Value
    }

    return New-EC2Tag -Resource $ResourceID -Tag $Tag
}

Write-Verbose -Message 'Declaring function Get-S3TagSet'
function Get-S3TagSet {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $BucketName
    )
    # Make sure the necessary module and cmdlet are available
    $null = Get-Command -Name Get-S3BucketTagging -ErrorAction Stop
    Write-Verbose -Message ('  Resource: {0}' -f $BucketName)

    # [System.Collections.ArrayList]$TagSet
    # Get-S3Bucket -BucketName $BucketName | ForEach-Object -Process {
    #     #$BucketName = $bucket.BucketName
    #     $TagSet += @(Get-S3BucketTagging -BucketName $PSItem.BucketName) -as [System.Collections.ArrayList]
    # }

    return @(Get-S3BucketTagging -BucketName $BucketName) -as [System.Collections.ArrayList]
}

Write-Output -InputObject (' # Start of {0} #' -f $MyScriptInfo.CommandName)

# Start new script logic here
# >> Pseudo-code
# Get EC2 resources
# Evaluate existing tags via ResourceType-specific function
# If it has a Service Tag, then that should be evaluated as the value for a new CE-Category Tag

Write-Output -InputObject ('Working in AWS Account / Profile: {0}' -f $Profile)
switch ($ResourceType) {
    'EC2' {
        ForEach ($region in $RegionSet) {
            ('Getting EC2 Tags for region: {0}' -f $region)
            Get-EC2Tag -ProfileName $Profile -Region $region | ForEach-Object -Process {
                if ($PSItem.ResourceType -in ('instance', 'snapshot', 'SecurityGroup', 'volume')) {
                    if ($PSItem.Key -eq 'Service') {
                        $TestCat = Test-EC2Tag -ResourceID $PSItem.ResourceId -TagKey 'CE-Category' -Value 'SRE'
                        if (-not $TestCat) {
                            ('Set-EC2Tag -ResourceID {0} -TagKey CE-Category -Value Product' -f $PSItem.ResourceId)
                            Set-EC2Tag -ResourceID $PSItem.ResourceId -TagKey 'CE-Category' -Value 'Product'
                            if ($IsVerbose) { Start-Sleep -Seconds 5 }
                        }
                        $TestCat = Test-EC2Tag -ResourceID $PSItem.ResourceId -TagKey 'CE-Product' -Value '*'
                        if (-not $TestCat) {
                            ('Set-EC2Tag -ResourceID {0} -TagKey CE-Category -Value Product' -f $PSItem.ResourceId)
                            Set-EC2Tag -ResourceID $PSItem.ResourceId -TagKey 'CE-Category' -Value 'Product'
                            if ($IsVerbose) { Start-Sleep -Seconds 5 }
                        }
                    }

                    if ($PSItem.Key -eq 'Service') {
                        # 1st, we check if Service has a useful value
                        if ($PSItem.Value) {
                            ('Set-EC2Tag -ResourceID {0} -TagKey CE-Product -Value {1}' -f $PSItem.ResourceId, $PSItem.Value)
                            Set-EC2Tag -ResourceID $PSItem.ResourceId -TagKey 'CE-Product' -Value $PSItem.Value
                            if ($IsVerbose) { Start-Sleep -Seconds 5 }
                        } else {
                            # Use a default / empty value, so that the Key at least exists
                            ('Set-EC2Tag -ResourceID {0} -TagKey CE-Product -Value Giving' -f $PSItem.ResourceId, $PSItem.Value)
                            Set-EC2Tag -ResourceID $PSItem.ResourceId -TagKey 'CE-Product' -Value ''
                            if ($IsVerbose) { Start-Sleep -Seconds 5 }
                        }
                    }
                } else {
                    # Assign per-account defaults for all other (non-instance) resources
                    ('Set-EC2Tag -ResourceID {0} -TagKey CE-Category -Value Product' -f $PSItem.ResourceId)
                    Set-EC2Tag -ResourceID $PSItem.ResourceId -TagKey 'CE-Category' -Value 'Product'
                    if ($IsVerbose) { Start-Sleep -Seconds 1 }
                    ('Set-EC2Tag -ResourceID {0} -TagKey CE-Product -Value Giving' -f $PSItem.ResourceId)
                    Set-EC2Tag -ResourceID $PSItem.ResourceId -TagKey 'CE-Product' -Value ''
                    if ($IsVerbose) { Start-Sleep -Seconds 2 }
                }
            }
        }
    }
    'S3' {
        ForEach ($region in $RegionSet) {
            # Get S3 resources
            ('Getting Tags from S3 resources in Region: {0}' -f $region)
            # Evaluate existing tags
            Get-S3Bucket -ProfileName $Profile -Region $region | ForEach-Object -Process {
                #$BucketName = $bucket.BucketName
                $TagSet = @(Get-S3BucketTagging -BucketName $PSItem.BucketName) -as [System.Collections.ArrayList]

                Write-Verbose -Message ('-Pre- Tags for Bucket {0} are: ...' -f $PSItem.BucketName)
                if ($IsVerbose) { $TagSet }

                if ((-not $TagSet) -or ('CE-Category' -notin $TagSet.Key)) {
                    $CatTags = [Amazon.S3.Model.Tag]@{ 'Key' = 'CE-Category'; 'Value' = 'Infrastructure' }
                    Write-Verbose -Message ('Adding to $TagSet {0} = {1}' -f $CatTags.Key, $CatTags.Value)
                    #$TagSet = $TagSet += $CatTags
                    $TagSet.Add($CatTags)
                }

                if ((-not $TagSet) -or ('CE-Product' -notin $TagSet.Key)) {
                    $PrdTags = [Amazon.S3.Model.Tag]@{ 'Key' = 'CE-Product'; 'Value' = 'Storage' }
                    Write-Verbose -Message ('Adding to $TagSet {0} = {1}' -f $PrdTags.Key, $PrdTags.Value)
                    #$TagSet = $TagSet += $PrdTags
                    $TagSet.Add($PrdTags)
                }

                Write-Verbose -Message ('Write-S3BucketTagging -BucketName {0} -TagSet $TagSet )' -f $PSItem.BucketName)
                Write-Verbose -Message '-Post- Tags for Bucket are: ...'
                if ($IsVerbose) {
                    $TagSet
                    Start-Sleep -Seconds 1
                }
                Write-S3BucketTagging -BucketName $PSItem.BucketName -TagSet $TagSet
                if ($IsVerbose) { Start-Sleep -Seconds 4 }
            }
        }
    }
    Default {
        Write-Warning -Message ('ResourceType {0} is not yet supported.' -f $ResourceType)
        # ('Getting Tags from EBS resources in Region: {0}' -f $region)
    }
}

# End of script logic
Write-Output -InputObject (' # End of {0} #' -f $MyScriptInfo.CommandName)

# For intra-profile/bootstrap script flow Testing, in verbose output mode
if ($IsVerbose) {
    Write-Output -InputObject ''
    Start-Sleep -Seconds 3
}