$LocalPath = Get-Location

$DcPath = "$($LocalPath)\Database.dacpac"
$DcPath = $DcPath.Replace("database-deployment\", "")

$DacPubProfile = "$($LocalPath)\project-database\project.Database\PublishLocations\projectDatabase.publish.xml"
$DacPubProfile = $DacPubProfile.Replace("project-deployment\", "")

$PathDatabaseProject = "$($LocalPath)\project-database\project.Database\project.Database.sqlproj"
$PathDatabaseProject = $PathDatabaseProject.Replace("project-deployment\", "")

$PathMsBuildTool = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe"

$PathsToFiles = @{
    Local = @{
        PathCredFile    = "$($LocalPath)\project-setup-local\data\CredFile.XML".Replace("project-deployment\", "")
        DataFolder      = "$($LocalPath)\project-setup-local\data\$ClientRawSamples".Replace("project-deployment\", "")
        FormatFolder    = "$($LocalPath)\configuration\Formats\$ClientRawSamples"
        ConfigFilesPath = @{
            Item  = "$($LocalPath)\project-custom\$ClientRawSamples\item-key-definition.json".Replace("project-deployment\", "")
            Store = "$($LocalPath)\project-custom\$ClientRawSamples\store-key-definition.json".Replace("project-deployment\", "")
            Infra = "$($LocalPath)\project-custom\$ClientRawSamples\infra-config.json".Replace("project-deployment\", "")
            Inventory = "$($LocalPath)\project-custom\$ClientRawSamples\mapping-inventory-definition.json".Replace("project-deployment\", "")
            Ranging = "$($LocalPath)\project-custom\$ClientRawSamples\mapping-ranging-definition.json".Replace("project-deployment\", "")
            Sales = "$($LocalPath)\project-custom\$ClientRawSamples\mapping-sales-definition.json".Replace("project-deployment\", "")
        }
            
        
    }
    Dev   = @{
        PathCredFile    = "M:\project\CredFile.XML"
        DataFolder      = "M:\project\Data\$ClientRawSamples"
        FormatFolder    = "M:\project\Formats\$ClientRawSamples"
        ConfigFilesPath = @{
            Item  = "M:\project\Config\$ClientRawSamples\item-key-definition.json"
            Store = "M:\project\Config\$ClientRawSamples\store-key-definition.json"
            Infra = "M:\project\Config\$ClientRawSamples\infra-config.json"
            Inventory = "M:\project\Config\$ClientRawSamples\mapping-inventory-definition.json"
            Ranging = "M:\project\Config\$ClientRawSamples\mapping-ranging-definition.json"
            Sales = "M:\project\Config\$ClientRawSamples\mapping-sales-definition.json"
        }
    }
}

$PathCredFile = GiveMeFolderToSearch -WhereDeploy $WhereDeploy -Type "cred"
$DataFolder = GiveMeFolderToSearch -WhereDeploy $WhereDeploy -Type "data"
$FormatFolder = GiveMeFolderToSearch -WhereDeploy $WhereDeploy -Type "format"
$ItemConfigPath = GiveMeFolderToSearch -WhereDeploy $WhereDeploy -Type "Config" -Subtype "Item"
$StoreConfigPath = GiveMeFolderToSearch -WhereDeploy $WhereDeploy -Type "Config" -Subtype "Store"
$InfraConfigPath = GiveMeFolderToSearch -WhereDeploy $WhereDeploy -Type "Config" -Subtype "Infra"
$InventoryConfigPath = GiveMeFolderToSearch -WhereDeploy $WhereDeploy -Type "Config" -Subtype "Inventory"
$RangingConfigPath = GiveMeFolderToSearch -WhereDeploy $WhereDeploy -Type "Config" -Subtype "Ranging"
$SalesConfigPath = GiveMeFolderToSearch -WhereDeploy $WhereDeploy -Type "Config" -Subtype "Sales"
`
    $PathToScripts = @(
    #"$($LocalPath)\project-tests\02_mapping-process".Replace("project-deployment\", "")
    #"$($LocalPath)\project-tests\03_mapping-extract".Replace("project-deployment\", "")
    "$($LocalPath)\project-tests\Scripts".Replace("project-deployment\", "")
)