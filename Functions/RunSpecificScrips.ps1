function LogExecScripts {
    param (
        [CmdletBinding()]
        [string]$ScriptName,
        [string]$ConnectionString,
        [Int32]$Id,
        [string]$Status
    )
    $Query = "
    Declare @ExecIdOutPut INT
        ,@ActionOutPut nvarchar(50)
        ,@StatusOutPut nvarchar(10)
    EXEC [metadata].[procedureLoging]
                    @ScriptName = '$ScriptName'
                    ,@Id = $Id
                    ,@Status = '$Status'
                    ,@ExecIdOutPut = @ExecIdOutPut OUT
                    ,@ActionOutPut = @ActionOutPut OUT
                    ,@StatusOutPut = @StatusOutPut OUT
    Select
        @ExecIdOutPut AS ExecId
        ,@ActionOutPut as ActionOutPut
        ,@StatusOutPut as StatusOutPut
        "
    $ResultTable = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $Query -OutputAs DataRows -QueryTimeout 0
    @(
        @{
            IdOutPut     = $ResultTable.Item(0)
            ActionOutPut = $ResultTable.Item(1)
            Status       = $ResultTable.Item(2)
        }
    )
}

function RunSqlScriptFromPath {
    param (
        [CmdletBinding()]
        [string]$ConnectionString,
        [String]$ScriptPath,
        [String]$ErrorScriptBehavior = 'Continue'
    )
    $ScriptName = Get-ChildItem -Path $ScriptPath -Name
    $Results = @(LogExecScripts -ConnectionString $ConnectionString -Status 'Running' -ScriptName $ScriptName)
    try {
        if ($Results.ActionOutPut -eq 'No action') {
            if ($Results.Status -eq 'Success') {
                Write-Output "Script: $ScriptName already executed with status $($Results.Status)"
            }
            elseif ($Results.Status -eq 'Failure') {
                Write-Output "Try again run script: $ScriptName"
                Invoke-Sqlcmd -InputFile "$ScriptPath" `
                    -ConnectionString "$ConnectionString" `
                    -QueryTimeout 0 `
                    -ErrorAction $ErrorScriptBehavior
                    if ($? -eq $false) {
                    $Results = @(LogExecScripts -ConnectionString $ConnectionString -Status "Failure" -ScriptName $ScriptName -Id $Id)
                    Write-Output "Script: $ScriptPath executed with failure"
                }
                else {
                    $Results = @(LogExecScripts -ConnectionString $ConnectionString -Status "Success" -ScriptName $ScriptName -Id $Id)
                    Write-Output "Script: $ScriptPath executed with success"
                }

            }  
        }
        elseif ($Results.ActionOutPut -eq 'Insert') {
            Write-Output "Start run script: $ScriptPath"
            Invoke-Sqlcmd -InputFile "$ScriptPath" `
                -ConnectionString "$ConnectionString" `
                -QueryTimeout 0 `
                -ErrorAction $ErrorScriptBehavior
            if ($? -eq $false) {
                $Results = @(LogExecScripts -ConnectionString $ConnectionString -Status "Failure" -ScriptName $ScriptName -Id $Id)
                Write-Output "Script: $ScriptPath executed with failure"
            } 
            else {
                $Results = @(LogExecScripts -ConnectionString $ConnectionString -Status "Success" -ScriptName $ScriptName -Id $Id)
                Write-Output "Script: $ScriptPath executed with status success"
            }
        }
    }
    catch {
        $Results = @(LogExecScripts -ConnectionString $ConnectionString -Status "Failure" -ScriptName $ScriptName -Id $Id)
        throw "There was problem in function RunSqlScriptFromPath: $ScriptPath", $Error
    }
}

function ExecScriptsCollecion {
    param (
        [string]$ScriptType = 'SQL',
        [string]$ConnectionString,
        [string[]]$PathToScripts
    )
    $Scripts = Get-ChildItem -Path $PathToScripts -Recurse -Filter "*.$ScriptType"
    foreach ($Script in $Scripts) {
        RunSqlScriptFromPath -ConnectionString $ConnectionString -ScriptPath "$Script"
    }
}