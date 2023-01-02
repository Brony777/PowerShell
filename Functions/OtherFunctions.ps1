function MappingJobParams {
    param (
        [CmdletBinding()]
        [System.Object]$MapTable,
        [string]$ParamName
    )
    if (([string]$MapTable.Get_Item("$ParamName")) -eq "") {
        $ParamName
    }
    else {
        [string]$MapTable.Get_Item("$ParamName")
    }
}
function WaitTime {
    param (
        [CmdletBinding()]
        [Int16]$HowManySecondsWait = 0
    )
    for ($i = 0; $i -lt $HowManySecondsWait; $i++) {
        Write-Output "Script will wait: $($HowManySecondsWait - $i) seconds"
        Start-Sleep -Seconds 1
    }
}