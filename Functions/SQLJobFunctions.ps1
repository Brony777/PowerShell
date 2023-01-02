function CreateJob {
    param (
        [CmdletBinding()]
        [string]$JobName,
        [Int16]$Enabled = 1,
        [string]$Description = "",
        [string]$CategoryName = "[Uncategorized (Local)]",
        [string]$OwnerLoginName = "sa",
        [string]$SQLServerConnectionString,
        [Int16]$DeleteLevel = 0
    )
    $Query = "
    DECLARE @jobId BINARY(16)
    EXEC [msdb].[dbo].[sp_add_job]
    @job_name=N'$JobName',
    @enabled=$Enabled,
    @notify_level_eventlog=0,
    @notify_level_email=0,
    @notify_level_netsend=0,
    @notify_level_page=0,
    @delete_level=$DeleteLevel,
    @description=N'$Description',
    @category_name=N'$CategoryName',
    @owner_login_name=N'$OwnerLoginName'
    ,@job_id = @jobId OUTPUT
   
    EXEC [msdb].[dbo].[sp_add_jobserver] @job_id=@jobId, @server_name = @@SERVERNAME
    Select
        'CREATED' as Output
    "
    try {
        $ResultOfExecution = Invoke-SqlCmd `
            -ConnectionString $SQLServerConnectionString `
            -Query $Query `
            -OutputAs DataRows
        $ExecuteResult = $ResultOfExecution.Item(0)
        "JOB: '$JobName' $ExecuteResult."
    }
    catch {
        throw "There was error with Function:CreateJob ", $Error
        return
    }
}
function MappingJobParams {
    param (
        [System.Object]$MapTable,
        [string]$ParamName
    )
    [string]$MapTable.Get_Item("$ParamName")
}

function CreateStep {
    param (
        [CmdletBinding()]
        [string]$StepName,
        [string]$JobName,
        [Int32]$StepId,
        [string]$Subsystem,
        [string]$Command,
        [Int32]$CmdexecSuccessCode = 0,
        [byte]$OnSuccessAction = 1,
        [Int32]$OnSuccessStepId = 0,
        [byte]$OnFailAction = 2,
        [Int32]$OnFailStepId = 0,
        [Int32]$RetryAttempts = 0,
        [Int32]$RetryInterval = 0,
        [Int32]$Flags = 0,
        [string]$DataBaseName,
        [string]$SQLServerConnectionString
    )

    $Query = "
    EXEC [msdb].[dbo].[sp_add_jobstep] 
    @job_name = N'$JobName',
    @step_name = N'$StepName', 
    @step_id = $StepId, 
    @cmdexec_success_code = $CmdexecSuccessCode, 
    @on_success_action = $OnSuccessAction, 
    @on_success_step_id = $OnSuccessStepId, 
    @on_fail_action = $OnFailAction, 
    @on_fail_step_id = $OnFailStepId, 
    @retry_attempts = $RetryAttempts, 
    @retry_interval = $RetryInterval, 
    @os_run_priority = 0, 
    @subsystem = N'$Subsystem', 
    @command = N'$Command', 
    @database_name = N'$DataBaseName', 
    @flags = $Flags
    Select
        'CREATED' as Output"
    try {
        $ResultOfExecution = Invoke-SqlCmd `
            -ConnectionString $SQLServerConnectionString `
            -Query $Query `
            -OutputAs DataRows
        $ExecuteResult = $ResultOfExecution.Item(0)
        "Step: '$StepName' in job '$JobName' $ExecuteResult."
    }
    catch {
        throw "There was error with Function:CreateStep $Query ", $Error
        return
    }   
}

function DeleteJob {
    param (
        [CmdletBinding()]
        [String]$JobName,
        [string]$SQLServerConnectionString
    )
    $Query = "IF EXISTS
    (
        SELECT *
        FROM msdb.dbo.sysjobs AS sj
        WHERE sj.name = '$JobName'
    )
    BEGIN
    EXEC [msdb].[dbo].[sp_delete_job] @job_name = '$JobName'
                ,@delete_unused_schedule = 1;
    SELECT 'DELETED' AS Results;
    END;
	ELSE
	SELECT 'NOT EXISTS' AS Results; "
    try {
        $ResultOfExecution = Invoke-SqlCmd `
            -ConnectionString $SQLServerConnectionString `
            -Query $Query `
            -OutputAs DataRows
        $ExecuteResult = $ResultOfExecution.Item(0)
        "JOB: '$JobName' $ExecuteResult."
    }
    catch {
        throw "There was error with Function:DeleteJob ", $Error
        return
    }   
}

function StartJobFromStep {
    param (
        [CmdletBinding()]
        [String]$JobName,
        [string]$SQLServerConnectionString,
        [bool]$RunJob
    )
    $Query = "
    EXEC [msdb].[dbo].[sp_start_job] @job_name = '$JobName'"
    try {
        if ($RunJob) {
            Invoke-SqlCmd -ConnectionString $SQLServerConnectionString -Query $Query
            Write-Output "Job $JobName started"
            WaitTime -HowManySecondsWait 5
        }
        else {
            Write-Output "Job $JobName not started"
        }
    }
    catch {
        throw "There was error with Function:StartJobFromStep ", $Error
        return
    }   
}

function CreateSchedule {
    param (
        [CmdletBinding()]
        [String]$SQLServerConnectionString,
        [String]$JobName,
        [String[]]$ScheduleName,
        [byte]$Enabled = $false,
        [Int32]$FreqType,
        [Int32]$FreqInterval,
        [Int32]$FreqSubdayType,
        [Int32]$FreqSubdayInterval,
        [Int32]$FreqRelativeInterval,
        [Int32]$FreqRecurrenceFactor,
        [Int32]$ActiveStartDate,
        [Int32]$ActiveEndDate,
        [Int32]$ActiveStartTime,
        [Int32]$ActiveEndTime
    )
    $Query = "
    EXEC [msdb].[dbo].[sp_add_jobschedule] 
        @job_name = '$JobName',
        @name = '$ScheduleName',
        @enabled = $Enabled, 
		@freq_type = $FreqType, 
		@freq_interval = $FreqInterval, 
		@freq_subday_type = $FreqSubdayType, 
		@freq_subday_interval = $FreqSubdayInterval, 
		@freq_relative_interval = $FreqRelativeInterval, 
		@freq_recurrence_factor = $FreqRecurrenceFactor, 
		@active_start_date = '$ActiveStartDate', 
		@active_end_date = '$ActiveEndDate', 
		@active_start_time = '$ActiveStartTime',
		@active_end_time = '$ActiveEndTime'
    "
    try {
        Invoke-SqlCmd -ConnectionString $SQLServerConnectionString -Query $Query
    }    
    catch {
        throw "There was error with Function:CreateSchedule. The query: '$Query'", $Error
        return
    } 
}

function DropAndCreateJobs {
    param (
        [CmdletBinding()]
        [String]$ConnectionStringDev,
        [String]$ConnectionStringLocal,
        [String]$WhereDeploy,
        [bool]$StartJobs = $true
    )
    if ($WhereDeploy -eq "Dev")
    {
        $SQLServerConnectionString = $ConnectionStringDev
    }
    else {
        $SQLServerConnectionString = $ConnectionStringLocal
    }
    foreach ($Job in $Jobs) {
        [string]$JobName = "[$DataBase]: $($Job.JobName)"
        $DeleteJobsParams = @{
            JobName                   = $JobName
            SQLServerConnectionString = $SQLServerConnectionString
        }
        DeleteJob @DeleteJobsParams

        If ($Job.Create -eq $true) {
            $CreateJobsParams = @{
                JobName                   = $JobName
                SQLServerConnectionString = $SQLServerConnectionString
                DeleteLevel               = (MappingJobParams -MapTable $DeleteLevel -ParamName "$($Job.DeleteLevel)")
            }
            CreateJob @CreateJobsParams
        
            foreach ($Step in $Job.Steps) {
                $CreateStepParams = @{
                    StepName                  = $Step.StepName
                    JobName                   = $JobName
                    StepId                    = $Step.StepId
                    Subsystem                 = $Step.Subsystem
                    Command                   = $Step.StepCommand
                    OnSuccessAction           = (MappingJobParams -MapTable $StepAction -ParamName "$($Step.OnSuccessAction)")
                    OnFailAction              = (MappingJobParams -MapTable $StepAction -ParamName "$($Step.OnFailAction)")
                    OnFailStepId              = $Step.OnFailStepId
                    DataBaseName              = $DataBase
                    SQLServerConnectionString = $SQLServerConnectionString 
                }
                CreateStep @CreateStepParams 
            }
            foreach ($Schedule in $Schedules) {
                $CreateScheduleParams = @{
                    SQLServerConnectionString = $SQLServerConnectionString
                    JobName                   = $JobName
                    ScheduleName              = "$($Schedule.ScheduleName)"
                    Enabled                   = $Schedule.Enabled
                    FreqType                  = (MappingJobParams -MapTable $FreqType -ParamName "$($Schedule.FreqType)")
                    FreqInterval              = (MappingJobParams -MapTable $FreqInterval -ParamName "$($Schedule.FreqInterval)")
                    FreqSubdayType            = (MappingJobParams -MapTable $FreqSubdayType -ParamName "$($Schedule.FreqSubdayType)")
                    FreqSubdayInterval        = "$($Schedule.FreqSubdayInterval)"
                    FreqRelativeInterval      = "$($Schedule.FreqRelativeInterval)"
                    FreqRecurrenceFactor      = "$($Schedule.FreqRecurrenceFactor)"
                    ActiveStartDate           = "$($Schedule.ActiveStartDate)"
                    ActiveEndDate             = "$($Schedule.ActiveEndDate)"
                    ActiveStartTime           = "$($Schedule.ActiveStartTime)"
                    ActiveEndTime             = "$($Schedule.ActiveEndTime)"
                }
                if ($Job.Schedule -contains "$($Schedule.ScheduleName)") {
                    Write-Output "Adding schedule '$($Job.Schedule)' to job '$JobName'"
                    CreateSchedule @CreateScheduleParams
                    Write-Output "Schedule '$($Job.Schedule)' added to job '$JobName'"
                }
            }
            if ($StartJobs -eq $true) {    
                StartJobFromStep -JobName $JobName `
                    -SQLServerConnectionString $SQLServerConnectionString `
                    -RunJob $Job.Run
            }
        }
    }
}