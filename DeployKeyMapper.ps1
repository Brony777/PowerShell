<#
    .SYNOPSIS
        Runs scripts against a target database
    .DESCRIPTION
        Takes a config files or set from other way
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("Local", "Dev")]
    [string]$WhereDeploy,
    [Parameter(Mandatory)]
    [string]$DeployServer,
    [Parameter(Mandatory)]
    [string]$Login,
    [Parameter(Mandatory)]
    [SecureString]$Password,
    [Parameter(Mandatory = $false)]
    [ValidateSet("Local", "Dev")]
    [string]$Config = "Dev",
    [Parameter(Mandatory = $false)]
    [ValidateSet("False", "True")]
    [string]$BackupDatabaseBeforeChanges = 'False',
    [Parameter(Mandatory = $false)]
    [ValidateSet("False", "True")]
    [string]$BlockOnPossibleDataLoss = 'False',
    [bool]$LoadData = $true,
    [bool]$PublishDataBase = $true,
    [bool]$DropDataBase = $true,
    [bool]$RunSpecificScrips = $false,
    [bool]$StartJobsFromDefinition = $true,
    [Parameter(Mandatory = $false)]
    [string]$DataBase = "Database",
    [Parameter(Mandatory = $false)]
    [string]$RawSourceDataBaseName = "Database",
    [Parameter(Mandatory = $false)]
    [ValidateSet("Client1", "Client2", "Client3")]
    [string]$ClientRawSamples = "Client1"
)

#Variables and set visible functions
$import = Join-Path $PSScriptRoot "Functions\DatabaseDeploymentFunctions.ps1"
. "$import"
$import = Join-Path $PSScriptRoot "Functions\FlatFilesFunctions.ps1"
. "$import"
$import = Join-Path $PSScriptRoot "Functions\SQLJobFunctions.ps1"
. "$import"
$import = Join-Path $PSScriptRoot "Functions\OtherFunctions.ps1"
. "$import"
$import = Join-Path $PSScriptRoot "Functions\RunSpecificScrips.ps1"
. "$import"

$import = Join-Path $PSScriptRoot "configuration\Paths.ps1"
. "$import"
$import = Join-Path $PSScriptRoot "configuration\Schedules.ps1"
. "$import"

$ConnectionStringIntegratedParams = @{
    DeployServer = $DeployServer
    WhereDeploy  = $WhereDeploy
    Psd          = $Password
    Login        = $Login
    DataBase     = $DataBase
    ConType      = "Integrated"
}
$ConnectionStringIntegrated = GenerateConnectionString @ConnectionStringIntegratedParams

$ConnectionStringIntegratedMaster = @{
    DeployServer = $DeployServer
    WhereDeploy  = $WhereDeploy
    Psd          = $Password
    Login        = $Login
    DataBase     = 'master'
    ConType      = "Integrated"
}
$ConnectionStringIntegratedMaster = GenerateConnectionString @ConnectionStringIntegratedMaster

$ConnectionStringNoIntegrated = @{
    DeployServer = $DeployServer
    WhereDeploy  = $WhereDeploy
    Psd          = $Password
    Login        = $Login
    DataBase     = $DataBase
    ConType      = "NoIntegrated"
}
$SQLServerConnectionString = GenerateConnectionString @ConnectionStringNoIntegrated

$ConnectionStringMasterNoIntegrated = @{
    DeployServer = $DeployServer
    WhereDeploy  = $WhereDeploy
    Psd          = $Password
    Login        = $Login
    DataBase     = "master"
    ConType      = "NoIntegrated"
}
[String]$SQLServerConnectionStringMasterNoIntegrated = GenerateConnectionString @ConnectionStringMasterNoIntegrated

$ConnectionStringPS = @{
    DeployServer = $DeployServer
    WhereDeploy  = $WhereDeploy
    Psd          = $Password
    Login        = $Login
    DataBase     = $DataBase
    ConType      = "PowerShellXML"
}
$SQLServerConnectionStringPS = GenerateConnectionString @ConnectionStringPS

$import = Join-Path $PSScriptRoot "configuration\UnusualCommandsForJobs.ps1"
. "$import"

$PathToJobs = GiveMeBackJobsConfigurationPath -Envirioment $Config
$import = Join-Path $PSScriptRoot "$PathToJobs"
. "$import"

$import = Join-Path $PSScriptRoot "configuration\JobsAndSchedulersProperties.ps1"
. "$import"

if (-not (Get-Module -ListAvailable -Name PublishDacPac)) {
    try {
        Write-Output "Need to install PublishDacPac module in PowerShell"
        Install-Module -Name PublishDacPac
        Write-Output "PublishDacPac module installed"
    }
    catch {
        throw "Install-Module -Name PublishDacPac", $Error
        return
    }
}

if ($DropDataBase -eq $true) {
    Write-Output "Drop database: $DataBase on server: $DeployServer at: $(GiveMeData)"
    $DropDataBaseParams = @{
        ConnectionStringLocal = $ConnectionStringIntegratedMaster
        DataBase              = $DataBase
        ConnectionStringDev   = $SQLServerConnectionStringMasterNoIntegrated
        WhereDeploy           = $WhereDeploy
    }
    DropDataBase @DropDataBaseParams
    Write-Output "Database: $DataBase on server: $DeployServer dropped at: $(GiveMeData)"
}

if ($PublishDataBase -eq $true) {
    Write-Output "Building database started at: $(GiveMeData)"
    $BuildArtefactsParams = @{
        BuildToolPath         = $PathMsBuildTool
        TypeOfTool            = "Database"
        PathToDatabaseProject = $PathDatabaseProject
        BuildAction           = "Rebuild"
        Verbosity             = "quiet"
    }
    BuildArtefacts @BuildArtefactsParams
    Write-Output "Building database finished at: $(GiveMeData)"
    Write-Output "Publish database started at: $(GiveMeData)"
    $PublishProjectParams = @{
        TypeOfTool                  = "Database"
        DacPacPath                  = $DcPath
        DacPublishProfile           = $DacPubProfile
        TargetServer                = "$DeployServer"
        WhereDeploy                 = "$WhereDeploy"
        BackupDatabaseBeforeChanges = "$BackupDatabaseBeforeChanges"
        BlockOnPossibleDataLoss     = "$BlockOnPossibleDataLoss"
        Login                       = "$Login"
        Pd                          = $Password
        DataBaseName                = "$DataBase"
        RawSourceDataBaseName       = "$RawSourceDataBaseName"
        InfraConfigPath             = "$InfraConfigPath"
        InventoryConfigPath         = "$InventoryConfigPath"
        ItemConfigPath              = "$ItemConfigPath"
        RangingConfigPath           = "$RangingConfigPath"
        SalesConfigPath             = "$SalesConfigPath"
        StoreConfigPath             = "$StoreConfigPath"
        ClientRawSamples            = "$ClientRawSamples"
    }
    PublishProject @PublishProjectParams
    Write-Output "Publish database finished at: $(GiveMeData)"
}
if ($RunSpecificScrips -eq $true) {
    Write-Output "Run RunSpecificScrips from directory: $PathToScripts"
    ExecScriptsCollecion -PathToScripts $PathToScripts -ConnectionString $ConnectionStringIntegrated
}
if ($LoadData -eq $true) {
    Write-Output "Run Drop and create JOBS "
    $DropAndCreateJobsParams = @{
        StartJobs             = $StartJobsFromDefinition
        ConnectionStringLocal = $ConnectionStringIntegratedMaster
        ConnectionStringDev   = $SQLServerConnectionStringMasterNoIntegrated
        WhereDeploy           = $WhereDeploy
    }
    DropAndCreateJobs @DropAndCreateJobsParams
}

