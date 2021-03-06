﻿param (
    $Name = (Get-PSUtilDefaultIfNull -value $Name -defaultValue 'ssmlinux'), 
    $InstanceIds = $InstanceIds,
    $Region = (Get-PSUtilDefaultIfNull -value (Get-DefaultAWSRegion) -defaultValue 'us-east-1')
    )

Set-DefaultAWSRegion $Region

if ($InstanceIds.Count -eq 0) {
    Write-Verbose "InstanceIds is empty, retreiving instance with Name=$Name"
    $InstanceIds = (Get-WinEC2Instance $Name -DesiredState 'running').InstanceId
}

Write-Verbose "EC2 Terminate: Name=$Name, InstanceIds=$instanceIds"

function CFNDeleteStack ([string]$StackName)
{
    if (Get-CFNStack | ? StackName -eq $StackName) {
        Write-Verbose "Removing CFN Stack $StackName"
        Remove-CFNStack -StackName $StackName -Force

        $cmd = { $stack = Get-CFNStack | ? StackName -eq $StackName; -not $stack}

        $null = Invoke-PSUtilWait -Cmd $cmd -Message "Remove Stack $StackName" -RetrySeconds 300
    } else {
        Write-Verbose "Skipping Remove CFN Stack, as Stack with Name=$StackName not found"
    }
}

CFNDeleteStack $Name

#Terminate
foreach ($instanceId in $InstanceIds) {
    Remove-WinEC2Instance $instanceId -NoWait
}

Remove-WinEC2Instance $Name -NoWait