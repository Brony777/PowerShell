$import = Join-Path $PSScriptRoot "CollectionOfObject.ps1"
. $import
# $SmoServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') -argumentlist '.'
# $SmoServer.ConnectionContext.LoginSecure = $false
# $SmoServer.ConnectionContext.set_Login("test")
# $SmoServer.ConnectionContext.set_Password("test")

# $db = $SmoServer.Databases['Sandbox']

# #$Objects = $db.Tables
# $Objects = $db.Schemas
# $Objects += $db.Views
# $Objects += $db.StoredProcedures
# $Objects += $db.UserDefinedFunctions

# Progress tracking
# [int]$TotObj = $Objects.Count
# [int]$CurObj = 1

# # Build this portion of the directory structure out here in case scripting takes more than one minute.
# $SavePath = "C:\Rawdata\Test\$(Get-Date -Format yyyyMMddHHmm)"

# foreach ($CurrentObject in $Objects ) {

#     $TypeFolder = $CurrentObject.GetType().Name
#     $ObjectType = $TypeFolder
#     $OutputFile = "$($CurrentObject.Name).$ObjectType.sql"
#     $OutputFolder = "$SavePath\$TypeFolder"

#     # if (!(Test-Path -Path $OutputFolder)) {
#     #     New-Item -ItemType directory -Path $OutputFolder
#     # }
#     Write-Output "$($CurrentObject.Name)"
#     # Create a Scripter object with our preferences.
#     # $Scripter = New-Object ('Microsoft.SqlServer.Management.Smo.Scripter') ($SmoServer)
#     # $Scripter.Options.FileName = "$OutputFolder\$OutputFile"
#     # $Scripter.Options.AppendToFile = $True
#     # $Scripter.Options.AllowSystemObjects = $False
#     # $Scripter.Options.ClusteredIndexes = $True
#     # $Scripter.Options.DriAll = $True
#     # $Scripter.Options.ScriptDrops = $False
#     # $Scripter.Options.IncludeHeaders = $False
#     # $Scripter.Options.ToFileOnly = $True
#     # $Scripter.Options.Indexes = $True
#     # $Scripter.Options.Permissions = $True
#     # $Scripter.Options.WithDependencies = $True
#     # $Scripter.Options.Encoding = [System.Text.Encoding]::ASCII

#     # # This is where each object actually gets scripted one at a time.
#     # Write-Output "[$CurObj of $TotObj] ($("{0:P1}" -f ($CurObj / $TotObj))) Scripting out $TypeFolder $CurrentObject"
#     # $Scripter.Script($CurrentObject)
#     $CurObj++

# } # This ends the loop

foreach ($Schema in $KMObjects){
    $SchemaName = $Schema.SchemaName
    foreach ($Table in $KMObjects.Objects.Tables.TableName){
        Write-Output "[$SchemaName].[$Table]"
    }    
}