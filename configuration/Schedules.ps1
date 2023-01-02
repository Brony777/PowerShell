<#
    Examples:
    EXEC msdb.dbo.sp_add_jobschedule 
		@job_name = N'SaturdayReports', -- Job name
		@name = N'Weekly_Sat_2AM',  -- Schedule name
		@freq_type = 8, -- Weekly
		@freq_interval = 64, -- Saturday
		@freq_recurrence_factor = 1, -- every week
		@active_start_time = 20000 -- 2:00 AM
#>

$Schedules = @(
    @{  
        ScheduleName         = "Daily"
        Enabled              = $true
        FreqType             = "Daily"
        FreqInterval         = "1"
        FreqSubdayType       = "AtTheSpecifiedTime"
        FreqSubdayInterval   = "0"
        FreqRelativeInterval = "0"
        FreqRecurrenceFactor = "1"
        ActiveStartDate      = "20220901"
        ActiveEndDate        = "0"
        ActiveStartTime      = "001010"
        ActiveEndTime        = "0"      
    }
    @{
        ScheduleName         = "Once"
        Enabled              = $true
        FreqType             = "Once"
        FreqInterval         = "1"
        FreqSubdayType       = "AtTheSpecifiedTime"
        FreqSubdayInterval   = "0"
        FreqRelativeInterval = "0"
        FreqRecurrenceFactor = "0"
        ActiveStartDate      = "0"
        ActiveEndDate        = "0"
        ActiveStartTime      = "0"
        ActiveEndTime        = "0"            
    }
    @{
        ScheduleName         = "Weekly"
        Enabled              = $true
        FreqType             = "Weekly"
        FreqInterval         = "3"
        FreqSubdayType       = "AtTheSpecifiedTime"
        FreqSubdayInterval   = "0"
        FreqRelativeInterval = "0"
        FreqRecurrenceFactor = "1"
        ActiveStartDate      = "19900101"
        ActiveEndDate        = "99900101"
        ActiveStartTime      = "010101"
        ActiveEndTime        = "235901"
    }
)