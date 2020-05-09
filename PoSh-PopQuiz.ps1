clear-Host

Write-Host ''
Write-Host "Preparing the Environment..." -ForegroundColor Cyan
Write-Host ''

cd C:\Users\admin\Documents\GitHub\PoSh-PopQuiz
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
New-PSDrive -Name PoSh-PopQuiz -PSProvider FileSystem -Root $ScriptPath
Set-Location -Path 'PoSh-PoPQuiz:\'
$global:QuestionsAndAnswers = Import-Csv "$ScriptPath\PoSh-PopQuiz.csv"


function global:Correct {
    Write-Host -ForegroundColor Green 'Correct!'
    Write-Host ''
}

function global:Wrong {
    Write-Host -ForegroundColor Red 'Wrong!'
    Write-Host -ForegroundColor White  "Try Again..."
    Write-Host ''
}

function global:NativeCommand {
    Write-Host -ForegroundColor Yellow "While Native Commands may provide the correct answer, they don't produce object formatted data."
    Write-Host -ForegroundColor White  "This will not count against your attempts."
    Write-Host -ForegroundColor White  "Try Again..."
    Write-Host ''
}

function global:DotNetFramework {
    Write-Host -ForegroundColor Yellow "Are you trying to use the .Net Framework? If so, that is out of scope for this quiz."
    Write-Host -ForegroundColor White  "This will not count against your attempts."
    Write-Host -ForegroundColor White  "Try Again..."
    Write-Host ''
}


$InitialLoad = $true
# Gerates the questions and updates the Question Status
function global:Status {
    if (-not $InitialLoad){ Clear-Host}

    $AnsweredQuestions = @()
    foreach ($Entry in $global:QuestionsAndAnswers) {
        $num = [int]$($entry.Number)
        $num = $num.ToString("000")
        $AnswerNumber   = '$A'+$num
        Invoke-Expression @"
        if ($AnswerNumber) {`$AnsweredQuestions += $AnswerNumber}
"@
    }
    Write-Host "================================================================================"
    Write-Host -ForegroundColor Cyan  "Question Status" -NoNewline
    Write-Host -ForegroundColor Yellow  "`t`t`t`t`t`t       Progress: $($AnsweredQuestions.count)/$($global:QuestionsAndAnswers.count)"
    Write-Host "================================================================================"

    # Generates the Question Status table
    foreach ($Entry in $global:QuestionsAndAnswers) {

        # Gets the questions number from the csv file
        $num = [int]$($entry.Number)

        # Pads the questoin numbers with leading zeroes if they're not three digits
        $num = $num.ToString("000")

        # Generates Qestion and Answers Names used for functions and variables
        $QuestionNumber =  'Q'+$num
        $AnswerNumber   = '$A'+$num
        
        # Determines when to start a new line
        if ( $Entry.Number % 10 -eq 1 ){ Write-Host '' }

        # Checks if a questions is answered, if yes = green font, if no = red font
        Invoke-Expression @"
        if (-Not $AnswerNumber) { Write-Host -ForegroundColor Red "$QuestionNumber`t" -NoNewLine }
        else { Write-Host -ForegroundColor Green "$QuestionNumber`t" -NoNewLine }
"@
    }
    Write-Host ""
    Write-Host ""
    Write-Host -ForegroundColor Cyan "The above section displays answered/unanswered questions in color:"
    Write-Host -ForegroundColor Red "    Red Font" -NoNewline
    Write-Host "    = Unanswered"
    Write-Host -ForegroundColor Green "    Green Font" -NoNewline
    Write-Host "  = Answered"
    Write-Host ""
    Write-Host ""

}


# Dynamically uses the questions from the imported csv to creats cooresponding function questions
foreach ($Entry in $global:QuestionsAndAnswers) {
    # Gets the questions number from the csv file
    $num = [int]$($entry.Number)

    # Pads the questoin numbers with leading zeroes if they're not three digits
    $num = $num.ToString("000")

    # Generates Qestion and Answers Names used for functions and variables
    $QuestionNumber =  'Q'+$num
    $AnswerNumber   = '$A'+$num

    Invoke-Expression -Command @"
        function global:$QuestionNumber {
            Clear-Host
            global:status
            #global:Help

            Write-Host -ForegroundColor Yellow "================================================================================"
            Write-Host -ForegroundColor Yellow "Question $num ($QuestionNumber)"
            Write-Host -ForegroundColor Yellow "================================================================================"
            Write-Host ""

            #Write-Host -ForegroundColor Cyan "$QuestionNumber`: $($Entry.Question)"
            #if ($AnswerNumber){
            #    Write-Host -ForegroundColor Yellow "You answered: " -NoNewline    
            #    Write-Host -ForegroundColor White  "$($AnswerNumber)"
            #}

            global:AnswerTheQuestion -Count $num -num $num

        }
"@
}
    

function global:Help {
    if (-not $InitialLoad){ Clear-Host}
    Write-Host "================================================================================"
    Write-Host -ForegroundColor Cyan "Help: PoSh-PopQuiz Commands"
    Write-Host "================================================================================"
    Write-Host -ForegroundColor Yellow "Help" -NoNewline
    Write-Host "         - Displays this help section"

    Write-Host -ForegroundColor Yellow "Get-Help" -NoNewline
    Write-Host "     - Include -Category Cmdlet when looking for help with cmdlets"
    Write-Host "               Example: Get-Help Get-Process -Category Cmdlet"

    Write-Host -ForegroundColor Yellow "Status" -NoNewline
    Write-Host "       - Displays the Question Status section"

    Write-Host -ForegroundColor Yellow "Questions" -NoNewline
    Write-Host "    - Displays all the questions and their answer status"

    Write-Host -ForegroundColor Yellow "Q##" -NoNewline
    Write-Host "          - Displays the coorelating question"
    Write-Host "               Example: `Q00"
    Write-Host "                        How do you view the PowerShell version information?"

    Write-Host -ForegroundColor Yellow "`$A## = <...>" -NoNewline
    Write-Host " - Answers may be variables, cmdlets, aliases, or native commands"
    Write-Host "               Example: `$A00 = `Get-Host"
    Write-Host "               Note: When answering with a vairable, don't include the $"
    Write-Host "                   Example: NO...  `$A00 = `$PSversionTable"
    Write-Host "                   Example: Yes... `$A00 = 'PSversionTable'"

    Write-Host -ForegroundColor Yellow "`$A##" -NoNewline
    Write-Host "         - Displays the the answer you entered; answers can be changed"
    Write-Host "               Example: `$A00"
    Write-Host "               Example: `$PSversionTable"

    Write-Host -ForegroundColor Yellow "Next" -NoNewline
    Write-Host "         - Moves to the next question"
    Write-Host "             - Has an alias of >"

    Write-Host -ForegroundColor Yellow "Previous" -NoNewline
    Write-Host "       - Moves to the previous qestion"
    Write-Host "             - Has an alias of <"


    Write-Host -ForegroundColor Yellow "Submit" -NoNewline
    Write-Host "       - Submits and grades your responses"

    Write-Host -ForegroundColor Yellow "Exit" -NoNewline
    Write-Host "         - Exits PoSh-PopQuiz"
    Write-Host "================================================================================"
    Write-Host ""
}



function global:QuestionsOnly {
    Clear-Host
    # Generates the Question Status table
    foreach ($Entry in $global:QuestionsAndAnswers) {
        # Gets the questions number from the csv file
        $num = [int]$($entry.Number)

        # Pads the questoin numbers with leading zeroes if they're not three digits
        $num = $num.ToString("000")

        # Generates Qestion and Answers Names used for functions and variables
        $QuestionNumber =  'Q'+$num
        $AnswerNumber   = '$A'+$num

        Write-Host "$($QuestionNumber): " -ForegroundColor Cyan -NoNewline
        Write-Host "$($Entry.Question)" -ForegroundColor White 
        Write-Host ""
    }
}


function global:Questions {
    Clear-Host
    # Generates the Question Status table
    foreach ($Entry in $global:QuestionsAndAnswers) {
        # Gets the questions number from the csv file
        $num = [int]$($entry.Number)

        # Pads the questoin numbers with leading zeroes if they're not three digits
        $num = $num.ToString("000")

        # Generates Qestion and Answers Names used for functions and variables
        $QuestionNumber =  'Q'+$num
        $AnswerNumber   = '$A'+$num

        Write-Host "$($QuestionNumber): " -ForegroundColor Cyan -NoNewline
        Write-Host "$($Entry.Question)" -ForegroundColor White 
        Invoke-Expression @"
        if ($AnswerNumber){
            Write-Host "You Answered: " -ForegroundColor Green -NoNewline
            Write-Host $AnswerNumber -ForegroundColor Yellow 
        }
"@
        Write-Host ""
    }
}


function global:Answers {
    Clear-Host
    foreach ($Entry in $global:QuestionsAndAnswers) {
        # Gets the questions number from the csv file
        $num = [int]$($entry.Number)

        # Pads the questoin numbers with leading zeroes if they're not three digits
        $num = $num.ToString("000")

        # Generates Qestion and Answers Names used for functions and variables
        $QuestionNumber =  'Q'+$num
        $AnswerNumber   = '$A'+$num

        $AnswerResponse = Invoke-Expression $AnswerNumber -ErrorAction SilentlyContinue
        Write-Host "$AnswerNumber`: " -ForegroundColor Cyan -NoNewline
        Write-Host "$AnswerResponse" -ForegroundColor Yellow
        Write-Host ""
    }
}


<#
Get-Command | Foreach {
    $SkipCmdletList = @(
        'Clear-Host',
        'Get-Command',
        'Get-Help',
        'Get-Member',
        'Invoke-Expression',
        'Out-Default',
        'prompt',
        'Read-Host',
        'Set-StrictMode',
        'TabExpansion2',
        'Write-Host',
        'Status',
        'Start-Sleep',
        'Help',
        'Questions',
        'QuestionsOnly',
        'Answers',
        'Correct',
        'Wrong',
        'NativeCommand',
        'DotNetFramework'
    )
    if ( $_.Name -notin $SkipCmdletList ){
        $Cmdlet = $_.Name
        $Overwrite = @"
        function $Cmdlet {
            #Write-Host -NoNewline -ForegroundColor Red "Info: "
            #Write-Host -NoNewline -ForegroundColor Cyan "$Cmdlet "
            #Write-Host -ForegroundColor Yellow "- PoSh-PopQuiz has intercepted this command."
            #Get-Help -Name $Cmdlet -Category cmdlet
            #Start-Sleep 1
            Write-Host ''
        }
"@
        Invoke-Expression $Overwrite
    }
}

#>


Clear-Host
global:Status
global:Help
Read-Host -Prompt 'Press any key to start the PopQuiz'
Clear-Host
$InitialLoad = $false

[int]$global:count = 0

Function global:AnswerTheQuestion {
    param(
        [int]$count,
        [string]$num
    )
    $QuestionNumber =  'Q'+$num
    $AnswerNumber   = '$A'+$num
    
    $global:CurrentQuestion = $global:QuestionsAndAnswers[$count]
    Write-Host -ForegroundColor Cyan  "$($QuestionNumber): " -NoNewline
    Write-Host -ForegroundColor White "$($global:CurrentQuestion.Question)"

    if ($AnswerNumber){
        Write-Host ""
        Write-Host -ForegroundColor Yellow "Answer Provided: " -NoNewline
        
        Write-Host -ForegroundColor White "$(Invoke-Expression $AnswerNumber)"
    }
}


function global:Next {
    Clear-Host
    global:status
    #global:Help
    $global:count += 1
    $num = $count.ToString("000")
    $QuestionNumber =  'Q'+$num
    $AnswerNumber   = '$A'+$num

    Write-Host -ForegroundColor Yellow "================================================================================"
    Write-Host -ForegroundColor Yellow "Question $num ($QuestionNumber)"
    Write-Host -ForegroundColor Yellow "================================================================================"
    Write-Host ""

    global:AnswerTheQuestion -Count $global:count -num $num
    Write-Host ""
}
Set-Alias -Name '>' -Value global:Next -Scope global


function global:Previous {
    Clear-Host
    global:status
    #global:Help
    $global:count -= 1
    $num = $count.ToString("000")
    $QuestionNumber =  'Q'+$num
    Write-Host -ForegroundColor Yellow "================================================================================"
    Write-Host -ForegroundColor Yellow "Question $num ($QuestionNumber)"
    Write-Host -ForegroundColor Yellow "================================================================================"
    Write-Host ""

    global:AnswerTheQuestion -Count $global:count -num $num
    Write-Host ""
}
Set-Alias -Name '<' -Value global:Previous -Scope global



global:next


<#
    # This was my previous attempt... and decided to abandon it in favor of dynamically pulling it from a csv...
    # That said... I need to finish...

    # Gets the questions number from the csv file
    $num = [int]$($entry.Number)

    # Pads the questoin numbers with leading zeroes if they're not three digits
    $num = $num.ToString("000")

    # Generates Qestion and Answers Names used for functions and variables
    $QuestionNumber =  'Q'+$num
    $AnswerNumber   = '$A'+$num

    Write-Host ""
    Write-Host -ForegroundColor Yellow "=================================================="
    Write-Host -ForegroundColor Yellow "Question $num ($QuestionNumber)"
    Write-Host -ForegroundColor Yellow "=================================================="
    Write-Host ""


    Write-Host ""
    Write-Host -ForegroundColor Cyan "$($Entry.Question)"
    Write-Host ""

    if ($entry.psobject.Properties.name -match 'Command'){
        $entry.psobject.Properties.name
        '---------------------'
    }
    #>
    #switch -WildCard ($Response) {
    #    'Get-Process'{global:Correct}
    #    'gps' {global:Correct}
    #    'ps' {global:Correct}
    #    'Get-WmiObject *Win32_Process' {global:Correct}
    #    'gwmi *Win32_Process' {global:Correct}
    #    #[System.Diagnostics.Process]::GetProcesses()
    #    '::' {global:DotNetFramework}
    #    'tasklist*' {global:NativeCommand}
    #    'taskmgr' {global:NativeCommand}
    #    '' {continue}
    #    Default {global:Wrong}
    #}

    


