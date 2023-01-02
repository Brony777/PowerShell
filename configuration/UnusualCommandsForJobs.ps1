$SearchAndLoadData = @'
$Credential = Import-Clixml -Path "
'@+
[string]$PathCredFile + '"
$Credential.Password.MakeReadOnly()   
$Username = $Credential.Username
$Password = $Credential.GetNetworkCredential().Password
$DataFolder = "'+ $DataFolder + '"
$FormatFolder = "'+ $FormatFolder + '"
$ConString = "'+$SQLServerConnectionStringPS+'"
$ClientRawSamples = "'+$ClientRawSamples+'" '+
@'

foreach ($Folder in Get-ChildItem -Path "$DataFolder" -Name -Directory) {
     $Files = Get-ChildItem -Path "$DataFolder\$Folder" -Filter "*.csv"
     $FormatFile = Get-ChildItem -Path "$FormatFolder" -Filter "$Folder.fmt"
     $TruncateTableQuery = "Declare @TableName NVARCHAR(100) = ''$Folder''
                                   ,@ClientRawSamples NVARCHAR(30) = ''$ClientRawSamples''
     EXEC [dbo].[csp_TruncateTable] @TableName = @TableName, @ClientRawSamples = @ClientRawSamples"
     Invoke-SqlCmd -ConnectionString $ConString -Query $TruncateTableQuery -QueryTimeout 0
     foreach ($Rawfiles in $Files) {
          $DataFilePath = $Rawfiles.FullName
          $FormatFilePath = $FormatFile.FullName
          $Task = "Data loading"
          $LoadQuery = "
            DECLARE
                   @TableName nvarchar(100)
                   ,@DataFileLocationPath nvarchar(300)
                   ,@FormatFileLocationPath nvarchar(300)
            EXEC [dbo].[csp_LoadDataFromFlatFile]
                 @TableName = ''$Folder''
                 ,@DataFileLocationPath = ''$DataFilePath''
                 ,@FormatFileLocationPath = ''$FormatFilePath''
                 ,@ClientRawSamples = ''$ClientRawSamples''
                 "
          Invoke-SqlCmd -ConnectionString $ConString -Query $LoadQuery -OutputAs DataRows -QueryTimeout 0
     }
}
'@