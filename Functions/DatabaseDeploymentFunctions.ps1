function BuildArtefacts {
    param (
        [CmdletBinding()]
        [Parameter(Mandatory = $true)]
        [string]$BuildToolPath,
        [string]$ArtefactsLocalization,
        [Parameter(Mandatory = $true)]
        [ValidateSet("Database")]
        [string]$TypeOfTool,
        [string]$PathToDatabaseProject,
        [Parameter(Mandatory = $true)]
        [ValidateSet("Build", "Rebuild", "Clean")]
        [string]$BuildAction,
        [Parameter(Mandatory = $true)]
        [ValidateSet("quiet", "minimal", "normal", "detailed", "diagnostic")]
        [string]$Verbosity      
    )
    if ($TypeOfTool -eq "Database") {
        try {
            Write-Output "Building Database project: $($PathToDatabaseProject)`r`nBuild options:`r`n -build action: $BuildAction`r`n -verbosity: $Verbosity"
            & "$($BuildToolPath)" "$($PathToDatabaseProject)" /t:"$BuildAction" /m /verbosity:"$Verbosity"
        }
        catch {
            throw "There was error with build action with project: $PathToDatabaseProject", $Error
        }        
    }
}

function GiveMeBackJobsConfigurationPath {
    [CmdletBinding()]
    param (
        [string]$Envirioment
    )
    switch ($Envirioment) {
        'dev' { "configuration\EnviriomentConfiguration\Dev.ps1" }
        'prod' { "configuration\EnviriomentConfiguration\Prod.ps1" }
        Default { "No matches" }
    }
}

function XMLPublishProfile {
    [CmdletBinding()]
    param (
        [string]$PublishProfileFilePath,
        [string]$DeployServer,
        [string]$WhereDeploy,
        [string]$DataBaseName,
        [string]$RawSourceDataBaseName,
        [string]$BackupDatabaseBeforeChanges,
        [string]$BlockOnPossibleDataLoss,
        [string]$InfraConfigPath,
        [string]$InventoryConfigPath,
        [string]$ItemConfigPath,
        [string]$RangingConfigPath,
        [string]$SalesConfigPath,
        [string]$StoreConfigPath,
        [string]$Login,
        [SecureString]$Pd,
        [string]$ClientRawSamples,
        [bool]$End
    )
    try {
        $XMLFile = [xml](Get-Content -Path "$PublishProfileFilePath")
        if ($WhereDeploy -eq "Local") {
            $XMLFile.Project.PropertyGroup.TargetConnectionString = "Data Source=$DeployServer;Integrated Security=True;Persist Security Info=False;Pooling=False;MultipleActiveResultSets=False;Connect Timeout=60;Encrypt=False;TrustServerCertificate=False"
        }
        elseif ($WhereDeploy -eq "Dev") {
            $Psd = ConvertFrom-SecureString -SecureString $Pd -AsPlainText
            $XMLFile.Project.PropertyGroup.TargetConnectionString = "Data Source=$DeployServer;Persist Security Info=False;User ID=$Login;Password=$Psd;Pooling=False;MultipleActiveResultSets=False;Connect Timeout=60;Encrypt=False;TrustServerCertificate=False"
        }    
        $XMLFile.Project.PropertyGroup.BackupDatabaseBeforeChanges = "$BackupDatabaseBeforeChanges"
        $XMLFile.Project.PropertyGroup.BlockOnPossibleDataLoss = "$BlockOnPossibleDataLoss"
        $XMLFile.Project.PropertyGroup.TargetDatabaseName = "$DataBaseName"
        
        $Node = $XMLFile.Project.ItemGroup.SqlCmdVariable | Where { $_.Include -eq 'variable1' }
        $Node.Value = "$DataBaseName"
        $Node = $XMLFile.Project.ItemGroup.SqlCmdVariable | Where { $_.Include -eq 'variable2' }
        $Node.Value = "$RawSourceDataBaseName"
        $Node = $XMLFile.Project.ItemGroup.SqlCmdVariable | Where { $_.Include -eq 'variable3' }
        $Node.Value = "$InfraConfigPath"
        $Node = $XMLFile.Project.ItemGroup.SqlCmdVariable | Where { $_.Include -eq 'variable4' }
        $Node.Value = "$InventoryConfigPath"
        $Node = $XMLFile.Project.ItemGroup.SqlCmdVariable | Where { $_.Include -eq 'variable5' }
        $Node.Value = "$ItemConfigPath"
        $Node = $XMLFile.Project.ItemGroup.SqlCmdVariable | Where { $_.Include -eq 'variable6' }
        $Node.Value = "$RangingConfigPath"
        $Node = $XMLFile.Project.ItemGroup.SqlCmdVariable | Where { $_.Include -eq 'variable7' }
        $Node.Value = "$SalesConfigPath"
        $Node = $XMLFile.Project.ItemGroup.SqlCmdVariable | Where { $_.Include -eq 'variable8' }
        $Node.Value = "$StoreConfigPath"
        $Node = $XMLFile.Project.ItemGroup.SqlCmdVariable | Where { $_.Include -eq 'variable9' }
        $Node.Value = "$ClientRawSamples"
        if ($end -eq $true) {
            $XMLFile.Project.PropertyGroup.TargetConnectionString = "Data Source=.;Integrated Security=True;Persist Security Info=False;Pooling=False;MultipleActiveResultSets=False;Connect Timeout=60;Encrypt=False;TrustServerCertificate=False"
        }
        $XMLFile.Save("$PublishProfileFilePath")        
     }
     catch {
         throw "There was error with save XML publish file: $PublishProfileFilePath", $Error
     }
}


function PublishProject {
    param (        
        [CmdletBinding()]
        [string]$TargetServer,
        [Parameter(Mandatory = $true)]
        [ValidateSet("Database")]
        [string]$TypeOfTool,
        [string]$BackupDatabaseBeforeChanges,
        [string]$BlockOnPossibleDataLoss,
        [string]$DacPacPath,
        [string]$DataBaseName,
        [string]$RawSourceDataBaseName,        
        [string]$WhereDeploy,
        [string]$DacPublishProfile,
        [string]$InfraConfigPath,
        [string]$InventoryConfigPath,
        [string]$ItemConfigPath,
        [string]$RangingConfigPath,
        [string]$SalesConfigPath,
        [string]$StoreConfigPath,
        [string]$ClientRawSamples,
        [string]$Login,
        [SecureString]$Pd
    )
    if ($TypeOfTool -eq "Database") {
        try {
            Write-Output "Configure XML Publish file"

            XMLPublishProfile -PublishProfileFilePath "$DacPublishProfile" `
                -DeployServer "$TargetServer" `
                -BackupDatabaseBeforeChanges "$BackupDatabaseBeforeChanges" `
                -BlockOnPossibleDataLoss "$BlockOnPossibleDataLoss" `
                -WhereDeploy "$WhereDeploy" `
                -DataBaseName "$DataBaseName" `
                -RawSourceDataBaseName "$RawSourceDataBaseName" `
                -Login "$Login" `
                -Pd $Pd `
                -InfraConfigPath $InfraConfigPath `
                -InventoryConfigPath $InventoryConfigPath `
                -ItemConfigPath $ItemConfigPath `
                -RangingConfigPath $RangingConfigPath `
                -SalesConfigPath $SalesConfigPath `
                -StoreConfigPath $StoreConfigPath `
                -ClientRawSamples $ClientRawSamples
            Write-Output "Publish database from dacpack file: $DacPacPath with profile: $DacPublishProfile on server: $TargetServer"            
            Publish-DacPac -DacPacPath "$DacPacPath" `
                -DacPublishProfile "$DacPublishProfile" `
                -Database "$DataBaseName" `
                -Server "$TargetServer"
            
            XMLPublishProfile -PublishProfileFilePath "$DacPublishProfile" `
                -DeployServer "$TargetServer" `
                -WhereDeploy "$WhereDeploy" `
                -Login "$Login" `
                -Pd $Pd `
                -DataBaseName "$DataBaseName" `
                -RawSourceDataBaseName "$RawSourceDataBaseName" `
                -InfraConfigPath $InfraConfigPath `
                -InventoryConfigPath $InventoryConfigPath `
                -ItemConfigPath $ItemConfigPath `
                -RangingConfigPath $RangingConfigPath `
                -SalesConfigPath $SalesConfigPath `
                -StoreConfigPath $StoreConfigPath `
                -ClientRawSamples $ClientRawSamples `
                -End $true
        }
        catch {        
            throw "There was error with publish action with dacpack file: $DacPacPath", $Error
        }        
    }
}

function GiveMeData {    
        (Get-Date -Format "MM/dd/yyyy HH:mm:ss")    
}

function DropDataBase {
    param (
        [string]$DataBase,
        [string]$ConnectionStringLocal,
        [string]$ConnectionStringDev,
        [string]$WhereDeploy
    )
    if ($WhereDeploy -eq "Dev") {
        $ConnectionString = $ConnectionStringDev
    }
    else {
        $ConnectionString = $ConnectionStringLocal
    }
    $Query = "
    IF EXISTS (SELECT * FROM sys.databases where [name] = N'$DataBase')
    BEGIN
        SET DEADLOCK_PRIORITY HIGH
        EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'$DataBase';
        ALTER DATABASE [$DataBase] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        USE master
        DROP DATABASE [$DataBase]
    END"
    try {
        Invoke-SqlCmd -ConnectionString $ConnectionString -Query $Query
    }
    catch {
        throw "There was problem with drop database $DataBase", $Error
    }    
}
function GenerateConnectionString {
    param (
        [CmdletBinding()]
        [Parameter(Mandatory = $true)]
        [string]$DeployServer,
        [string]$ConType = "PowerShellXML" ,
        [Parameter(Mandatory = $true)]
        [string]$WhereDeploy,
        [securestring]$Psd,
        [string]$Login,
        [string]$DataBase
    )

    if (($WhereDeploy -eq "Dev") -and ($ConType -eq "PowerShellXML")) {
        'Server=$DeployServer;Database=' + $DataBase + '; User ID =$Username; Password=$Password;'
    }
    elseif (($WhereDeploy -eq "Local") -and ($ConType -eq "PowerShellXML")) {
        "Data Source=$DeployServer;Initial Catalog=$DataBase;Integrated Security=true;"
    }
    elseif (($WhereDeploy -eq "Local") -and ($ConType -eq "Integrated")) {
        "Data Source=$DeployServer;Initial Catalog=$DataBase;Integrated Security=true;"
    }
    elseif (($WhereDeploy -eq "Local") -and ($ConType -eq "NoIntegrated")) {
        $PasswordString = ConvertFrom-SecureString -SecureString $Psd -AsPlainText
        "Server=$DeployServer;Database= $DataBase; User ID = $Login; Password= $PasswordString;"
    }
    elseif (($WhereDeploy -eq "Dev") -and ($ConType -eq "NoIntegrated")) {
        $PasswordString = ConvertFrom-SecureString -SecureString $Psd -AsPlainText
        "Server=$DeployServer;Database= $DataBase; User ID = $Login; Password= $PasswordString;"
    }
}