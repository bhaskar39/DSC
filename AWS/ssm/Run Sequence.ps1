﻿param ($Name='ssm')

Write-Verbose "Run Sequence - Name=$Name"
$host.ui.RawUI.WindowTitle = $Name

if (! (Test-PSTestExecuting)) {
    . "$PSScriptRoot\Setup.ps1"
}

Write-Verbose 'Executing Run'


$EC2Linux = $false
$EC2Windows = $false
$AzureWindows = $false
$AzureLinux = $true


if ($EC2Linux) {
    $tests = @(
        "$PSScriptRoot\EC2 Linux Create Instance.ps1"
        "$PSScriptRoot\Linux Run Command.ps1"
        "$PSScriptRoot\EC2 Terminate Instance.ps1"
    )
    $InputParameters = @{
        Name="$Name-linux"
        ImagePrefix='amzn-ami-hvm-*gp2'
    }
    Invoke-PsTest -Test $tests -InputParameters $InputParameters  -Count 1 -StopOnError -LogNamePrefix 'EC2 Linux'
}

if ($EC2Windows) {
    $tests = @(
        "$PSScriptRoot\EC2 Windows Create Instance.ps1"
        "$PSScriptRoot\Windows Run Command.ps1"
        "$PSScriptRoot\EC2 Terminate Instance.ps1"
    )
    $InputParameters = @{
        Name="$Name-windows"
        ImagePrefix='Windows_Server-2012-R2_RTM-English-64Bit-Base-20'
    }
    Invoke-PsTest -Test $tests -InputParameters $InputParameters  -Count 1 -StopOnError -LogNamePrefix 'EC2 Windows'
}


if ($AzureWindows) {
    $tests = @(
        "$PSScriptRoot\Azure Windows Create Instance.ps1"
        "$PSScriptRoot\Windows Run Command.ps1"
        "$PSScriptRoot\Azure Terminate Instance.ps1"
    )
    $InputParameters = @{
        Name=''
        ImagePrefix='Windows Server 2012 R2'
    }
    Invoke-PsTest -Test $tests -InputParameters $InputParameters  -Count 1 -StopOnError -LogNamePrefix 'Azure Windows'
}


if ($AzureLinux) {
    $tests = @(
        "$PSScriptRoot\Azure Linux Create Instance.ps1"
        "$PSScriptRoot\Linux Run Command.ps1"
        "$PSScriptRoot\Azure Terminate Instance.ps1"
    )
    $InputParameters = @{
        Name=''
        ImagePrefix='Ubuntu Server 14'
    }
    Invoke-PsTest -Test $tests -InputParameters $InputParameters  -Count 1 -StopOnError -LogNamePrefix 'Azure Linux'
}


gstat

Convert-PsTestToTableFormat    


if (! (Test-PSTestExecuting)) {
 #   & "$PSScriptRoot\Cleanup.ps1"
}