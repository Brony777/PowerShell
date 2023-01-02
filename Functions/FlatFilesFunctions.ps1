function InsertDataFromFile {
    [CmdletBinding()]
    param (
        [string]$SourceFile,
        [string]$FormatFile,
        [string]$TargetTableName,        
        [string]$SQLServerConnectionString
    )
    $Query = "INSERT INTO $TargetTableName WITH(TABLOCK)
    select
        *
    from
        OPENROWSET(
        BULK '$SourceFile'
        ,FORMATFILE = N'$FormatFile'
        ,FIRSTROW=2
        ,CODEPAGE='1250'
        ) as Data
        select 'Inserted rows: '+convert(varchar(20),@@ROWCOUNT) as Info"
    try {
        Invoke-SqlCmd -ConnectionString $SQLServerConnectionString -Query $Query
    }
    catch {
        throw "There was error with Function:InsertDataFromFile ", $Error
        return
    }   
}

function ClearTable {
    [CmdletBinding()]
    param (
        [string]$TargetTableName,
        [string]$SQLServerConnectionString
    )    
    try {
        Invoke-SqlCmd -ConnectionString $SQLServerConnectionString -Query "TRUNCATE TABLE $TargetTableName"    
    }
    catch {
        throw "There was error with Function:ClearTable ", $Error
        return
    }
}

function FormatFileLocation {
    [CmdletBinding()]
    param (
        [string]$TableName
    )
    $FileName = $TableName.Substring($TableName.IndexOf(".") + 1).Replace("[", "").Replace("]", "")    
    "$(Get-Location)\Formats\$ClientRawSamples\$FileName.fmt".Replace("project-deployment\", "project\src\")
}

function LoadRawDataFromCSV {
    [CmdletBinding()]
    param (
        [string]$TableName,
        [string]$SQLServerConnectionString,
        [string]$FilesLocations
    )  
    $Files = Get-ChildItem -Path "$FilesLocations" -Filter "*.csv"
    if (!$Files) {
        Write-Output "There is no files!!!"
    }
    else {
        Write-Output "Clear table $TableName"
        ClearTable -TargetTableName "$TableName" -SQLServerConnectionString $SQLServerConnectionString
        
        foreach ($Rawfiles in $Files) {
            Write-Output "Loading data from: $($Rawfiles.FullName) to table: [$DataBase].$TableName"
            $FileFormatPath = FormatFileLocation -TableName $TableName
            InsertDataFromFile -SourceFile "$($Rawfiles.FullName)" `
                -FormatFile $FileFormatPath `
                -TargetTableName "$TableName" `
                -SQLServerConnectionString $SQLServerConnectionString
            Write-Output "Data loaded from: $($Rawfiles.FullName) to table: [$DataBase].$TableName"
        }
    }
}

function GiveMeFolderToSearch {
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [string]$WhereDeploy,
        [Parameter(Mandatory = $true)]
        [ValidateSet("Cred", "Data", "Format", "TestScripts", "Config")]
        [string]$Type,
        [Parameter(Mandatory = $false)]
        [string]$SubType = ''
    )
    if ($WhereDeploy -eq "Local") {
        switch ($Type) {
            "Cred" { "$($PathsToFiles.Local.PathCredFile)" }
            "Data" { "$($PathsToFiles.Local.DataFolder)" }
            "Format" { "$($PathsToFiles.Local.FormatFolder)" }
            "Config" {
                switch ($SubType) {
                    "Item" { "$($PathsToFiles.Local.ConfigFilesPath.Item)" }
                    "Store" { "$($PathsToFiles.Local.ConfigFilesPath.Store)" }
                    "Ranging" { "$($PathsToFiles.Local.ConfigFilesPath.Ranging)" }
                    "Sales" { "$($PathsToFiles.Local.ConfigFilesPath.Sales)" }
                    "Inventory" { "$($PathsToFiles.Local.ConfigFilesPath.Inventory)" }
                    "Infra" { "$($PathsToFiles.Local.ConfigFilesPath.Infra)" }
                }
            }
        }
    }
    elseif ($WhereDeploy -eq "dev") {
        switch ($Type) {
            "Cred" { "$($PathsToFiles.dev.PathCredFile)" }
            "Data" { "$($PathsToFiles.dev.DataFolder)" }
            "Format" { "$($PathsToFiles.dev.FormatFolder)" }
            "Config" {
                switch ($SubType) {
                    "Item" { "$($PathsToFiles.dev.ConfigFilesPath.Item)" }
                    "Store" { "$($PathsToFiles.dev.ConfigFilesPath.Store)" }
                    "Ranging" { "$($PathsToFiles.dev.ConfigFilesPath.Ranging)" }
                    "Sales" { "$($PathsToFiles.dev.ConfigFilesPath.Sales)" }
                    "Inventory" { "$($PathsToFiles.dev.ConfigFilesPath.Inventory)" }
                    "Infra" { "$($PathsToFiles.dev.ConfigFilesPath.Infra)" }
                }
            }
        }
    }
}