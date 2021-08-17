#!/usr/bin/env pwsh
#Requires -Version 5
#========================================
# NAME      : aws.tools.helpers.elb.ps1
# LANGUAGE  : Microsoft PowerShell (Core)
# AUTHOR    : Bryan Dady
# UPDATED   : 06/01/2020 - First edition
# COMMENT   : Provides wrapper functions that make interaction with AWS.Tools.ELB2 modules and cmdlets more powershell-native
#========================================
[CmdletBinding()]
param()
Set-StrictMode -Version latest

# Uncomment the following 2 lines for testing profile scripts with Verbose output
# '$VerbosePreference = ''Continue'''
# $VerbosePreference = 'Continue'

Write-Verbose -Message 'Loading function Find-ELB2LoadBalancerArnByName'
function Find-ELB2LoadBalancerArnByName {
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='Name of the LoadBalancer of which to get its ARN.'
        )]
        [Alias('LoadBalancerName')]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    Write-Verbose -Message ('Getting Load Balancer Name and ARN with Name matching *{0}' -f $Name)
    Get-ELB2LoadBalancer | Where-Object -FilterScript {$_.LoadBalancerName -like ('*{0}' -f $Name) } | Select-Object -Property LoadBalancerName, LoadBalancerArn | Sort-Object -Property LoadBalancerName

}

Write-Verbose -Message 'Loading function Get-ELB2ListenerByPort'
function Get-ELB2ListenerByPort {
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='To get the Name for an ELB2, try Find-ELB2LoadBalancerArnByName.'
        )]
        [string]$LoadBalancerArn,
        [Parameter(
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='IPv4 Port Number.'
        )]
        [string]$Port = 443
    )

    if ($LoadBalancerArn) {
      $LoadBalancerName = $(Get-ELB2LoadBalancer -LoadBalancerArn $LoadBalancerArn).LoadBalancerName
    } else {
      $ELB2LoadBalancer = Find-ELB2LoadBalancerArnByName | Select-Object -Last 1
      $LoadBalancerName = $ELB2LoadBalancer.LoadBalancerName
      $LoadBalancerArn = $ELB2LoadBalancer.LoadBalancerArn
    }

    Write-Output -InputObject ''
    Write-Output -InputObject ('LoadBalancerName: {0}' -f $LoadBalancerName)
    Write-Output -InputObject ('LoadBalancerArn: {0}' -f $LoadBalancerArn)
    Get-ELB2Listener -LoadBalancerArn $LoadBalancerArn | Where-Object -FilterScript {$_.Port -eq $Port}

}

Write-Verbose -Message 'Loading function Get-ELB2RuleByLbNameAndPort'
function Get-ELB2RuleByLbNameAndPort {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='Specify the name of the LoadBalancer to search for.'
        )]
        [Alias('LoadBalancerName')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='IPv4 Port Number.'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Port = 443
    )

    #Get-ELB2Listener -LoadBalancerArn $Name | Where-Object -FilterScript {$_.Port -eq 443}
    Write-Verbose -Message ('Getting (1st) $LoadBalancerArn with Name matching *{0}' -f $Name)
    try {
        $LoadBalancer = Get-ELB2LoadBalancer -Name $Name
    }
    Catch {
        # [InvalidOperation] {
        #if ($null -eq $LoadBalancer) {
        throw ('Failed to find a LoadBalancer matching the name: {0}' -f $Name)
    }
    #finally {
    #    $LoadBalancer
    #}
    '$LoadBalancer:'
    $LoadBalancer
    # $LoadBalancer has 2 properties: LoadBalancerArn and LoadBalancerName
    Write-Verbose -Message ('$LoadBalancerArn is {0}' -f $LoadBalancer.LoadBalancerArn) -ErrorAction SilentlyContinue
    Write-Verbose -Message ('Getting $ListenerArn for LoadBalancerName {0} and (IP) port {1}' -f $LoadBalancer.LoadBalancerName, $Port) -ErrorAction SilentlyContinue

    #$ListenerArn = (Get-ELB2ListenerByPort -LoadBalancerArn $LoadBalancer.LoadBalancerArn -Port $Port)[0].ListenerArn
    $ListenerArn = Get-ELB2ListenerByPort -LoadBalancerArn $LoadBalancer.LoadBalancerArn -Port $Port  -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty ListenerArn
    Write-Verbose -Message ('$ListenerArn is {0}' -f $ListenerArn) -ErrorAction SilentlyContinue

    Write-Verbose -Message ('Getting ELB2 $Rule(s) for Listener {0}' -f $ListenerArn) -ErrorAction SilentlyContinue
    AWS.Tools.ElasticLoadBalancingV2\Get-ELB2Rule -ListenerArn $ListenerArn

}

Write-Verbose -Message 'Loading function Get-ELB2Rule'
function Get-ELB2Rule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,
            Position=0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage='Search for Load Balancer by Name.'
        )]
        [Alias('LoadBalancerName')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(
            Position=1,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage='Rule condition path from URI.'
        )]
        [ValidatePattern('[\S\d]+')]
        [Alias('Path','URL','route','Service')]
        [string]$URLPath = '*',
        [Parameter(
            Position=2,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage='IPv4 Port Number.'
        )]
        [ValidateRange(1, 65535)]
        [string]$Port = 443
    )

    $SearchPath = ('*{0}*' -f $URLPath)

    $Rules = Get-ELB2RuleByLbNameAndPort -Name $Name -Port $Port
    # Rules properties:
    <#
        RuleArn    : arn:aws:elasticloadbalancing:{region}:{account}:listener-rule/{path}
        Actions    : {Amazon.ElasticLoadBalancingV2.Model.Action}
        Conditions : {Amazon.ElasticLoadBalancingV2.Model.RuleCondition}
        IsDefault  : {Boolean}
        Priority   : {integer}
    #>
    $Results = New-Object System.Collections.ArrayList
    # $Counter = 0

    Write-Verbose -Message ('Looking for path in URL (Conditions:values:) : {0}' -f $URLPath)

    Clear-Variable RuleArn -ErrorAction SilentlyContinue
    Clear-Variable ConditionsCount -ErrorAction SilentlyContinue

    $Rules | ForEach-Object -Process {
        # $Counter++
        # $RuleArn = $_.RuleArn
        try {
            $RuleArn = Select-Object -InputObject $PSItem -ExpandProperty RuleArn -ErrorAction SilentlyContinue
        }
        catch {
            $RuleArn = 'n/a'
        }
        Write-Verbose -Message ('RuleArn: {0}' -f $RuleArn)

        try {
            $ConditionsCount = Select-Object -InputObject $PSItem -ExpandProperty Conditions -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count
        }
        catch {
            $ConditionsCount = '0'
        }

        #$ConditionsCount = ($PSItem.Conditions).Count
        Write-Verbose -Message ('Conditions qty {0}' -f $ConditionsCount)

        if (($ConditionsCount -gt 0) -and ($PSItem.Conditions.Field -eq 'path-pattern')) {
            Write-Verbose -Message ('Conditions:values: {0}' -f $PSItem.Conditions.Values)
            if ($PSItem.Conditions.Values -like $SearchPath) {
                Write-Verbose -Message ('! Matched path in URL: {0}' -f $PSItem.Conditions.Values)
                start-sleep -Seconds 1
                $Index      = $PSItem.Priority
                $FilterPath = $PSItem.Conditions.Values

                # Loop through 1 or more actions target groups per condition
                $PSItem.Actions.ForwardConfig.TargetGroups | ForEach-Object -Process {
                    $TargetArn = $PSItem.TargetGroupArn
                    # Parse Target Group name from TargetGroupArn
                    $TargetGroupName = ($TargetArn -split '/')[1]
                    try {
                        $TargetWeight = $PSItem.Weight
                    }
                    catch {
                        $TargetWeight    = 'n/a'
                    }

                    $properties = [ordered]@{
                        #'Index'           = $Index
                        #'RuleArn'         = $RuleArn   # $PSItem.RuleArn
                        #'TargetGroupArn'  = $TargetArn # $PSItem.ForwardConfig.TargetGroups.TargetGroupArn
                        #'FilterField'     = $PSItem.Conditions.Field
                        'TargetGroupName' = $TargetGroupName
                        'Rule Path'       = $FilterPath
                        'TargetWeight'    = $TargetWeight
                    }

                    $rule = New-Object -TypeName PSObject -Property $properties -ErrorAction SilentlyContinue

                    if (Get-Variable -Name rule -ErrorAction SilentlyContinue) {
                        $null = $Results.Add($rule)
                    } else {
                        Write-Warning -Message 'Invalid $rule; unable to include in results'
                        Start-Sleep -Seconds 1
                    }
                }
            } else {
                Write-Verbose -Message ('No match: {0}' -f $PSItem.Conditions.Values)
            }
        #} else {
        #    Write-Warning -Message ('Action Type: {0}' -f $PSItem.Actions.Type.Value)
        #    Write-Warning -Message ('Rule {0} is Not a path-pattern based LB rule: (uses {1} = {2}' -f $RuleArn, $PSItem.Conditions.Field, $PSItem.Conditions.Values)
        }
        # Clear-Variable -Name properties
    }

    if (-not $Results) {
        Write-Output 'No matching rules found. You may re-run in -Verbose mode for additional detail.'
    } else {
        return $Results
    }

}

Write-Verbose -Message 'Loading function Get-ELB2RulebyPath'
function Get-ELB2RulebyPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage='Specify the URL route / path in the LoadBalancer rule to be matched.'
        )]
        [Alias('Path','URL','route','Service')]
        [ValidateNotNullOrEmpty()]
        [string]$URLPath
    )

    Write-Verbose -Message ('Getting rule target information for route / path matching {0}' -f $URLPath)

    Write-Verbose -Message 'Getting rule target information for Subsplash Dev environment Load Balancer'
    Write-Output -InputObject "`nDev:"
    Write-Output -InputObject '---------------'
    Get-ELB2Rule -Name api-dev-subsplash-net -Path $URLPath

    Write-Verbose -Message 'Getting rule target information for Subsplash Dev environment Load Balancer'
    Write-Output -InputObject "`nStage:"
    Write-Output -InputObject '---------------'
    Get-ELB2Rule -Name api-stage-subsplash-net -Path $URLPath

    Write-Verbose -Message 'Getting rule target information for Subsplash Dev environment Load Balancer'
    Write-Output -InputObject "`nProd:"
    Write-Output -InputObject '---------------'
    Get-ELB2Rule -Name api-subsplash-com -Path $URLPath

}
