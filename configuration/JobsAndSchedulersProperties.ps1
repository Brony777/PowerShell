$DeleteLevel = @{
    Never     = 0;
    OnSuccess = 1;
    OnFailure = 2;
    Always    = 3;
}

$StepAction = @{
    QuitWithSuccess = 1;
    QuitWithFailure = 2;
    GoToNextStep    = 3;
    GoToStepOnFail  = 4;
}

$FreqType = @{
    Once                    = 1;
    Daily                   = 4;
    Weekly                  = 8;
    Monthly                 = 16;
    MonthlyRelative         = 32;
    RunWithSQLSerAgentStart = 64;
    RunWhenComputerIdle     = 128;
}

$FreqInterval = @{
    Once                    = 1;
    Daily                   = 4;
    Weekly                  = 8;
    Monthly                 = 16;
    MonthlyRelative         = 32;
    RunWithSQLSerAgentStart = 64;    
    Sunday                  = 1;
    Monday                  = 2;
    Tuesday                 = 4;
    Wednesday               = 8;
    Thursday                = 16;
    Friday                  = 32;
    Saturday                = 64;
}

$FreqRelativeInterval = @{
    First  = 1;
    Second = 4;
    Fourth = 8;
    Last   = 16;
}

$FreqSubdayType = @{
    AtTheSpecifiedTime = 1;
    Seconds            = 2;
    Minutes            = 4;
    Hours              = 8;
}