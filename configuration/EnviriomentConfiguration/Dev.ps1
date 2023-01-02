$PasswordString = ConvertFrom-SecureString $Password -AsPlainText
$Jobs = @(
    @{
        JobName     = "Save credential to connectionstring"
        Create      = $true
        Steps       = @{
            StepName        = "Create credential file"
            StepId          = 1
            Subsystem       = "PowerShell"
            StepCommand     = '[String]$Username = "' + $Login + '"
                            [SecureString]$Password = ConvertTo-SecureString "'+ $PasswordString + '" -AsPlainText -Force
                            [PSCredential]$Credential = New-Object System.Management.Automation.PSCredential ($Username, $Password)
                            $Credential | Export-CliXml -Path "'+ $PathCredFile + '"'
            OnSuccessAction = "QuitWithSuccess"
            OnFailAction    = "QuitWithFailure"
        }
        DeleteLevel = "Always"
        Run         = $true
        Schedule    = ""
    }
    @{
        JobName     = "Load raw data samples"
        Create      = $true
        Steps       = @(
            @{
                StepName        = "Search files in folder: $DataFolder"
                StepId          = 1
                Subsystem       = "PowerShell"
                StepCommand     = $SearchAndLoadData
                OnSuccessAction = "GoToNextStep"
                OnFailAction    = "QuitWithFailure"
            }
            @{
                StepName        = "Execute procedure 1"
                StepId          = 2
                Subsystem       = "TSQL"
                StepCommand     = "EXEC [dbo].[procedure1]"
                OnSuccessAction = "GoToNextStep"
                OnFailAction    = "GoToStepOnFail"
                OnFailStepId    = 4
            }
            @{
                StepName        = "Exec procedure 2"
                StepId          = 3
                Subsystem       = "TSQL"
                StepCommand     = "EXEC [dbo].[procedure2]"
                OnSuccessAction = "GoToNextStep"
                OnFailAction    = "GoToStepOnFail"
                OnFailStepId    = 4
            }
         
            @{
                StepName        = "Exec procedure 3"
                StepId          = 4
                Subsystem       = "TSQL"
                StepCommand     = "EXEC [dbo].[procedure3]"
                OnSuccessAction = "GoToNextStep"
                OnFailAction    = "QuitWithFailure"
            }
            @{
                StepName        =  "Exec procedure 4"
                StepId          = 5
                Subsystem       = "TSQL"
                StepCommand     = "EXEC [dbo].[procedure4]"
                OnSuccessAction = "GoToNextStep"
                OnFailAction    = "QuitWithFailure"
            }
            @{
                StepName        = "Exec procedure 5"
                StepId          = 6
                Subsystem       = "TSQL"
                StepCommand     = "EXEC [dbo].[procedure5]"
                OnSuccessAction = "GoToNextStep"
                OnFailAction    = "QuitWithFailure"
            }
            @{
                StepName        = "Exec procedure 6"
                StepId          = 7
                Subsystem       = "TSQL"
                StepCommand     = "EXEC [dbo].[procedure6]"
                OnSuccessAction = "GoToNextStep"
                OnFailAction    = "QuitWithFailure"
            }
            @{
                StepName        = "Exec procedure 7"
                StepId          = 8
                Subsystem       = "TSQL"
                StepCommand     = "EXEC [dbo].[procedure7]"
                OnSuccessAction = "GoToNextStep"
                OnFailAction    = "QuitWithFailure"
            }
            @{
                StepName        = "Exec procedure 8"
                StepId          = 9
                Subsystem       = "TSQL"
                StepCommand     = "EXEC [dbo].[procedure8]"
                OnSuccessAction = "QuitWithSuccess"
                OnFailAction    = "QuitWithFailure"
            }
        )
        DeleteLevel = "Never"
        Run         = $true
        Schedule    = ""
    }
    @{
        JobName     = "Test job"
        Create      = $RunSpecificScrips
        Steps       = @{
            StepName        = "Run test procedure"
            StepId          = 1
            Subsystem       = "TSQL"
            StepCommand     = "EXEC [dbo].[testprocedure]"
            OnSuccessAction = "QuitWithSuccess"
            OnFailAction    = "QuitWithFailure"
        }
        DeleteLevel = "Never"
        Run         = $false
        Schedule    = ""
    }
)