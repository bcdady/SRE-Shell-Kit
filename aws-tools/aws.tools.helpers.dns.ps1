#!/usr/bin/env pwsh
#Requires -Version 5
#========================================
# NAME      : aws.tools.helpers.elb.ps1
# LANGUAGE  : Microsoft PowerShell (Core)
# AUTHOR    : Bryan Dady
# UPDATED   : 09/01/2020 - First edition
# COMMENT   : Provides wrapper functions that make interaction with AWS.Tools.R53 modules and cmdlets more powershell-native
#========================================
[CmdletBinding()]
param()
Set-StrictMode -Version latest

# Uncomment the following 2 lines for testing profile scripts with Verbose output
# '$VerbosePreference = ''Continue'''
# $VerbosePreference = 'Continue'

Write-Verbose -Message 'Loading function Find-DNSZoneIdByName'
function Find-DNSZoneIdByName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage='Name of the DNS Zone for which to get its HostedZoneId.'
        )]
        [Alias('DNSName')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [int]$MaxItem = 20
    )

    Write-Verbose -Message ('Getting Domain Name and HostedZoneId with Name matching *{0}' -f $Name)

    # Operate against a local 'cache' to avoid unnecessary API delays from Get-R53HostedZonesByName
    $Quicklist = @{
        'subsplash.com' = 'Z17IK3PVTVEWB2'
        'subsplash.net' = 'ZVVRZ6LU0EYP8'
        'awsusw2.subsplash.net' = 'Z3K9LZ63DPDCEK'
        'sandbox.subsplash.net' = 'Z1HZITHNC4L8WD'
        'thechurchapp.org' = 'Z2PPRXBF37R0OX'
    }

    if ($Name -in $Quicklist.Keys) {
        # Create the custom object to be returned by the function
        $properties = [ordered]@{
            'Name'   = $Name
            'ZoneID' = $Quicklist.$Name
        }

        $ResultObject = New-Object -TypeName PSObject -Property $properties
        return $ResultObject

    } else {

        # In case the Name parameter does not end in the (expected) '.', append it
        if ($Name -notmatch '\.$') {
            $Name = ('{0}.' -f $Name)
        }
        
        # Lookup the HostedZoneId by the AWS.Tools cmdlet
        Get-R53HostedZonesByName -DNSName Name -MaxItem $MaxItem | Select-Object -Property Name, @{label='ZoneId';expression={$PSItem.Id -replace '\/hostedzone\/'}} | Where-Object { $PSItem.Name -like $Name }
    }
}

Write-Verbose -Message 'Loading function Get-DNSResourceRecord'
function Get-DNSResourceRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage='Name of the Domain Name for which to get its Values.'
        )]
        [Alias('ZoneName')]
        [ValidateNotNullOrEmpty()]
        [string]$DomainName,
        [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage='Name of the DNS Name for which to get its Values.'
        )]
        [Alias('DNSName')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [string]$Type = 'A',
        [int]$MaxItem = 20
    )

    Write-Verbose -Message ('Getting DNS Name and values, where Name matches *{0}' -f $Name)

    $HostedZoneInfo = Find-DNSZoneIdByName -Name $DomainName
    Write-Verbose -Message ('$HostedZoneInfo: {0}, {1}' -f $HostedZoneInfo.Name, $HostedZoneInfo.ZoneId)

    Write-Output -InputObject ('Looking up records matching ''{0}'' in domain ''{1}''' -f $Name, $HostedZoneInfo.Name)

    $Records = Get-R53ResourceRecordSet -HostedZoneId $HostedZoneInfo.ZoneId -StartRecordType $Type -StartRecordName $Name -MaxItem $MaxItem

    # Setup an array for returning results from this function
    $ResultSet = New-Object System.Collections.ArrayList

    #Loop through all matches, processing only those with a matching name
    $Records.ResourceRecordSets | Where-Object { $PSItem.Name -match "$Name*" } | ForEach-Object -Process {
        $RecordName = $PSItem.Name
        $RecordType = $PSItem.Type
        Write-Verbose -Message ('Name: {0}' -f $PSItem.Name)
        Write-Verbose -Message ('Type: {0}' -f $PSItem.Type)

        if ($PSItem.AliasTarget) {
            # Is an Alias
            $RecordType = ('{0} (Alias)' -f $RecordType)
            $Value = ('[ZoneId: {0}] {1}' -f $PSItem.AliasTarget.HostedZoneId, $PSItem.AliasTarget.DNSName)

        } else {
            # Is NOT an Alias
            $Value = $PSItem.ResourceRecords.Value
        }

        # Create the custom object to be returned by the function
        $properties = [ordered]@{
            'RecordName' = $RecordName
            'Type'       = $RecordType
            'Value'      = $Value
            'ZoneName'   = $HostedZoneInfo.Name
            'ZoneID'     = $HostedZoneInfo.ZoneId
        }

        $ResultObject = New-Object -TypeName PSObject -Property $properties #-ErrorAction SilentlyContinue
        $ResultSet += $ResultObject
    }

    return $ResultSet
}
