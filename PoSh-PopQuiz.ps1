Add-Type -AssemblyName System.Windows.Forms

$CommandsToBeQuestioned = Get-Command -CommandType 'Alias', 'Cmdlet', 'Function', 'Workflow'

$Modules = $CommandsToBeQuestioned | Select-Object ModuleName -Unique | Sort-Object ModuleName | Where-Object {$_.ModuleName -ne ''}

$AllCommands = $ModulesThatAreCurrentlyImported.ExportedCommands.Values.Name
$Sources     = $ModulesThatAreCurrentlyImported.ExportedCommands.Values.Source | Sort-Object -Unique

$script:CurrentQuestion = ''
$script:CurrentButton =''

function Generate-PopQuiz {
    param(
        $CommandsToBeQuestioned = $CommandsToBeQuestioned,
        [string[]]$ModuleName
    )
    $script:PopQuizAnswerTextBox.Text  = ''
    $PopQuizResultsTextBox.Text = ''

    $script:PopQuizPool = @()
    foreach ($Module in $ModuleName){
        $script:PopQuizPool += $CommandsToBeQuestioned | Where-Object {$_.ModuleName -eq $Module}
    }
    $script:PopQuizPool = $script:PopQuizPool | Sort-Object {Get-Random} | Where-Object {$_ -ne '' -or $_ -ne $null} | Select-Object -First 50
    #$script:PopQuizPool | ogv


    $script:TotalNumberOfCommands = $script:PopQuizPool.Count
    #$script:RandomNumber = Get-Random -Minimum 0 -Maximum $script:TotalNumberOfCommands 


    $script:InCrementQ = 0
    $script:IncrementX = 2
    $script:IncrementY = 0
    foreach ($q in $script:PopQuizPool) {
        $script:Question = $q

        # Creates the question buttons at the lower left of the GUI
        $script:InCrementQ += 1
        Invoke-Expression @"

        `$script:HintCount = 0
        `$script:Question$($script:InCrementQ)Hint = @()
        `$script:NoMoreHints = `$false
        `$CmdletHelp = Get-Help `$script:Question
    
    
        `$CmdletModule = `$script:Question | Select-Object -ExpandProperty Source
        `$script:Question$($script:InCrementQ)Hint += `@"
       Module = `$(`$CmdletModule.trim("`r`n"))
`"@
    
        # Adds Hint for syntax
        `$CmdletSyntax = `$CmdletHelp.Syntax
        `$CmdletSyntax = (`$CmdletSyntax | Out-String).Replace("`$script:Question",'     VERB-NOUN').Replace("`r`n`r`n","???").Replace("`r`n","").Replace("???","`r`n`r`n").Trim("`r`n")
        `$script:Question$($script:InCrementQ)Hint += `$CmdletSyntax.trim("`r`n")
    
        # Adds Hint for VERB
        if ("`$script:Question" -match "\-"){
            `$script:Question$($script:InCrementQ)Hint += `@"
        Cmdlet Verb = `$((`$script:Question -split '-')[0])
`"@
        }
    
        # Adds Hint for description
        if (`$(`$script:Question.Description) -ne ''){
            `$CmdletDescription = `$CmdletHelp.Description
            `$CmdletDescription = (`$CmdletDescription | Out-String).Replace("`$script:Question",'VERB-NOUN').Replace("`r`n`r`n","???").Replace("`r`n","").Trim("`r`n").Trim("?").Replace("???","`r`n`r`n     ")
        `$script:Question$($script:InCrementQ)Hint += `@"
    `$(`$CmdletDescription.trim("`r`n"))
`"@
        }
    
    # Adds Hint for examples - one hint for each example 
    `$CmdletExamples = `$CmdletHelp.Examples
    `$Separator = 'Example \d. '
    `$CmdletExamples = (`$CmdletExamples | Out-String) -split `$Separator
    `$ExampleCount = 1
    foreach (`$Example in `$(`$CmdletExamples | Select-Object -Skip 1) ){
        `$Example = (`$Example | Out-String).Replace("`$script:Question",'VERB-NOUN')
        `$script:Question$($script:InCrementQ)Hint += `@"
    Example: `$ExampleCount
    `$(`$Example.trim("`r`n").Replace("`$script:Question",'VERB-NOUN'))
`"@
        `$ExampleCount += 1
    }
    
    # Adds Hint for Parameters
    `$CmdletParameters = `$CmdletHelp.Parameters
    `$CmdletParameters = (`$CmdletParameters | Out-String).Replace("`$script:Question",'VERB-NOUN').Replace("`r`n`r`n","`r`n")
    `$script:Question$($script:InCrementQ)Hint += `@"
    `$(`$CmdletParameters.trim("`r`n"))
`"@


        # Generates Question buttons
        `$Status$($script:InCrementQ)Button = New-Object -TypeName System.Windows.Forms.Button -Property @{
            Text = "$script:InCrementQ"
            Location = @{ X = 10 + `$script:IncrementX
                          Y = 20 + `$script:IncrementY }
            Size     = @{ Width  = 27
                          Height = 18 }
            Font = New-Object System.Drawing.Font("Courier New",10,0,0,0)
            UseVisualStyleBackColor = `$true
            Add_Click = {
                `$script:CurrentQuestion = `$script:PopQuizPool[$script:InCrementQ - 1]
                `$script:CurrentButton   = `$This
                `$script:CurrentHint     = `$script:Question$($script:InCrementQ)Hint
                `$script:HintCount       = 0
                `$script:PopQuizAnswerTextBox.text = ''
                `$PopQuizQuestion = `$script:PopQuizPool[$script:InCrementQ - 1]
                `$PopQuizQuestionRichTextBox.Text = "Which `$(`$script:Question.CommandType) does the following?
    `$(Get-Help "`$PopQuizQuestion" | Select-Object -ExpandProperty Synopsis)
"
                # Unchecks all multiple choice radio buttons
                `$script:PopQuizMultipleChoice1RadioButton.Checked = `$False
                `$script:PopQuizMultipleChoice2RadioButton.Checked = `$False
                `$script:PopQuizMultipleChoice3RadioButton.Checked = `$False
                `$script:PopQuizMultipleChoice4RadioButton.Checked = `$False
                `$script:PopQuizMultipleChoice5RadioButton.Checked = `$False
                `$script:PopQuizMultipleChoice6RadioButton.Checked = `$False
            }
        }
        `$StatusGroupBox.Controls.Remove(`$Status$($script:InCrementQ)Button)
        `$StatusGroupBox.Controls.Add(`$Status$($script:InCrementQ)Button)
        `$script:IncrementX += 32
"@
        # Counts 10 buttons per row, then starts a new one
        if ($script:InCrementQ % 10 -eq 0) {
            $script:IncrementX = 2
            $script:IncrementY += 28
        }


        # Unchecks all multiple choice radio buttons
        $script:PopQuizMultipleChoice1RadioButton.Checked = $False
        $script:PopQuizMultipleChoice2RadioButton.Checked = $False
        $script:PopQuizMultipleChoice3RadioButton.Checked = $False
        $script:PopQuizMultipleChoice4RadioButton.Checked = $False
        $script:PopQuizMultipleChoice5RadioButton.Checked = $False
        $script:PopQuizMultipleChoice6RadioButton.Checked = $False

        # Populates the multiple choice options with a random incorrect answer an one correct answer
        if ($script:PopQuizMultipleChoiceCheckBox.Checked) {
            $script:PopQuizMultipleChoice1RadioButton.Text = "$($script:PopQuizPool[$(Get-Random -Minimum 0 -Maximum $script:PopQuizPool.Count)])"
            $script:PopQuizMultipleChoice2RadioButton.Text = "$($script:PopQuizPool[$(Get-Random -Minimum 0 -Maximum $script:PopQuizPool.Count)])"
            $script:PopQuizMultipleChoice3RadioButton.Text = "$($script:PopQuizPool[$(Get-Random -Minimum 0 -Maximum $script:PopQuizPool.Count)])"
            $script:PopQuizMultipleChoice4RadioButton.Text = "$($script:PopQuizPool[$(Get-Random -Minimum 0 -Maximum $script:PopQuizPool.Count)])"
            $script:PopQuizMultipleChoice5RadioButton.Text = "$($script:PopQuizPool[$(Get-Random -Minimum 0 -Maximum $script:PopQuizPool.Count)])"
            $script:PopQuizMultipleChoice6RadioButton.Text = "$($script:PopQuizPool[$(Get-Random -Minimum 0 -Maximum $script:PopQuizPool.Count)])"

            # Selects a random radiobutton to place the correct answer
            $RandomRadioButton = Get-Random -Minimum 1 -Maximum 7
            Invoke-Expression @"
        `$script:PopQuizMultipleChoice$($RandomRadioButton)RadioButton.Text = `$script:Question
"@
        }
        # If the checkbox is not checked, it populates the multiple choice options with default placeholders
        else {
            $script:PopQuizMultipleChoice1RadioButton.Text = "Question 1"
            $script:PopQuizMultipleChoice2RadioButton.Text = "Question 2"
            $script:PopQuizMultipleChoice3RadioButton.Text = "Question 3"
            $script:PopQuizMultipleChoice4RadioButton.Text = "Question 4"
            $script:PopQuizMultipleChoice5RadioButton.Text = "Question 5"
            $script:PopQuizMultipleChoice6RadioButton.Text = "Question 6"
        }
        $PoShPopQuiz.Refresh()
    }
    $script:CurrentQuestion = $script:PopQuizPool[0]

    $PopQuizQuestionRichTextBox.Text = @"
Which $($script:Question.CommandType) does the following?
    $(Get-Help "$script:CurrentQuestion" | Select-Object -ExpandProperty Synopsis)
"@
}






$PoShPopQuiz = New-Object System.Windows.Forms.Form -Property @{
    Text          = "PoSh-EasyWin   [$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)]"
    StartPosition = "CenterScreen"
    Size          = @{ Width  = 1000
                       Height = 600 }
    AutoScroll    = $True
    FormBorderStyle =  'Sizable' #  Fixed3D, FixedDialog, FixedSingle, FixedToolWindow, None, Sizable, SizableToolWindow
}



$ModuleCheckListBox = New-Object -TypeName System.Windows.Forms.CheckedListBox -Property @{
    Text     = "Modules"
    Location = @{ X = 10
                  Y = 10 }
    Size     = @{ Width  = 250
                  Height = 400 }
    ScrollAlwaysVisible = $true
    CheckOnClick = $True
}
        # Adds the modules to the checklistbox
        foreach ( $Module in $Modules ) { 
            $ModuleCheckListBox.Items.Add($Module.ModuleName)
        }
        # Finds the index location of the modules and adds them to the array
        $ModuleCheckLocation = 0
        $ModulesChecked = @()
        foreach ($ModuleName in $ModuleCheckListBox.items){
            if ($ModuleName -match 'Microsoft.Powershell'){
                #$ModuleName
                $ModulesChecked += $ModuleCheckLocation
            }
            $ModuleCheckLocation += 1
        }
        # Checks the modules that were added to the array
        foreach ($ModuleLocation in $ModulesChecked) { 
            $ModuleCheckListBox.SetItemChecked($ModuleLocation, $true) 
        }
$PoShPopQuiz.Controls.Add($ModuleCheckListBox)



$ModuleClearSelectionButton = New-Object -TypeName System.Windows.Forms.Button -Property @{
    Text     = "Clear Selection"
    Location = @{ X = $ModuleCheckListBox.Location.X
                  Y = $ModuleCheckListBox.Location.Y + $ModuleCheckListBox.Size.Height + 3 }
    Size     = @{ Width  = 120
                  Height = 22 }
    Add_Click = {
        (0..($ModuleCheckListBox.Items.Count -1)) | Foreach { $ModuleCheckListBox.SetItemChecked($_,$false)}    
    }
}
$PoShPopQuiz.Controls.Add($ModuleClearSelectionButton)



$ModuleSelectAllButton = New-Object -TypeName System.Windows.Forms.Button -Property @{
    Text     = "Select All"
    Location = @{ X = $ModuleClearSelectionButton.Location.X + $ModuleClearSelectionButton.Size.Width + 9
                  Y = $ModuleClearSelectionButton.Location.Y }
    Size     = @{ Width  = 120
                  Height = 22 }
    Add_Click = {
        (0..($ModuleCheckListBox.Items.Count -1)) | Foreach { $ModuleCheckListBox.SetItemChecked($_,$true)}    
    }
}
$PoShPopQuiz.Controls.Add($ModuleSelectAllButton)



$PopQuizGenerateButton = New-Object -TypeName System.Windows.Forms.Button -Property @{
    Text = "Generate PopQuiz"
    Location = @{ X = $ModuleClearSelectionButton.Location.X
                  Y = $ModuleClearSelectionButton.Location.Y + $ModuleClearSelectionButton.Size.Height + 5 }
    Size     = @{ Width  = 250
                  Height = 22 }
    Add_Click = {
        $ModulesSelectedCount = ($ModuleCheckListBox.CheckedItems).count
        if ($ModulesSelectedCount -gt 0){
            $ModulesSelected = @()
            foreach ($ModuledChecked in $ModuleCheckListBox.CheckedItems){
                $ModulesSelected += $ModuledChecked
            }
            Generate-PopQuiz -ModuleName $ModulesSelected
        }
    }
}
$PoShPopQuiz.Controls.Add($PopQuizGenerateButton)



$PopQuizHelpButton = New-Object -TypeName System.Windows.Forms.Button -Property @{
    Text = "Hint"
    Location = @{ X = $ModuleCheckListBox.Location.X + $ModuleCheckListBox.Size.Width + 5
                  Y = $ModuleCheckListBox.Location.Y }
    Size     = @{ Width  = 75
                  Height = 22 }
    Add_Click = {
        if ($script:HintCount -lt $script:CurrentHint.count -and -not $script:NoMoreHints) {
            $PopQuizQuestionRichTextBox.Focus()
            $PopQuizQuestionRichTextBox.AppendText("`r`n`r`n=============================================================================================`r`n[Hint $($script:HintCount + 1):]`r`n$($script:CurrentHint[$script:HintCount])")
            $script:HintCount += 1
        }
        elseif (-not $script:NoMoreHints) {
            $PopQuizQuestionRichTextBox.Focus()
            $PopQuizQuestionRichTextBox.AppendText("`r`n`r`n=============================================================================================`r`n[Hint ?:]`r`n     There are no more hints available.")
            $script:NoMoreHints = $true
        }
    }
}
$PoShPopQuiz.Controls.Add($PopQuizHelpButton)



$PopQuizQuestionGroupBox = New-Object -TypeName System.Windows.Forms.GroupBox -Property @{
    Text = "Question:"
    Location = @{ X = $PopQuizHelpButton.Location.X 
                  Y = $PopQuizHelpButton.Location.Y + $PopQuizHelpButton.Size.Height + 5}
    Size     = @{ Width  = 700
                  Height = 300 }
}
$PoShPopQuiz.Controls.Add($PopQuizQuestionGroupBox)



$PopQuizQuestionRichTextBox = New-Object -TypeName System.Windows.Forms.RichTextBox -Property @{
    Location = @{ X = 10 
                  Y = 20 }
    Size     = @{ Width  = 680
                  Height = 270 }
    ReadOnly = $True
    WordWrap = $True
    Multiline = $True
    Font = New-Object System.Drawing.Font("Courier New",11,0,0,0)
}
$PopQuizQuestionGroupBox.Controls.Add($PopQuizQuestionRichTextBox)



$PopQuizAnswerGroupBox = New-Object -TypeName System.Windows.Forms.GroupBox -Property @{
    Text = "Manual Answer:"
    Location = @{ X = $PopQuizQuestionGroupBox.Location.X 
                  Y = $PopQuizQuestionGroupBox.Location.Y + $PopQuizQuestionGroupBox.Size.Height + 5 }
    Size     = @{ Width  = 350
                  Height = 50 }
}
$PoShPopQuiz.Controls.Add($PopQuizAnswerGroupBox)


function Submit-ManualEntryAnswer {
    if ($script:PopQuizAnswerTextBox.Text -eq ''){
        $script:CurrentButton.ResetBackColor()
    }
    else {
        if ($script:PopQuizAnswerTextBox.Text -eq $script:CurrentQuestion) {
            $PopQuizResultsTextBox.Text = 'Correct'
        }
        else {
            $PopQuizResultsTextBox.Text = 'Wrong'
        }    
        $script:CurrentButton.BackColor = 'LightBlue'
    }
}


$script:PopQuizAnswerTextBox = New-Object -TypeName System.Windows.Forms.TextBox -Property @{
    Location = @{ X = 10 
                  Y = 20 }
    Size     = @{ Width  = 225
                  Height = 22 }
    Add_KeyDown = { if ($_.KeyCode -eq "Enter") { Submit-ManualEntryAnswer } }
    AutoCompleteSource = "CustomSource"
    AutoCompleteMode   = "SuggestAppend"
}
$CmdList = (Get-Command -CommandType 'Alias', 'Cmdlet', 'Function', 'Workflow').Name
$script:PopQuizAnswerTextBox.AutoCompleteCustomSource.AddRange($cmdList)
$PopQuizAnswerGroupBox.Controls.Add($script:PopQuizAnswerTextBox)



$PopQuizManualEntrySubmitButton = New-Object -TypeName System.Windows.Forms.Button -Property @{
    Text = "Submit"
    Location = @{ X = $script:PopQuizAnswerTextBox.Location.X + $script:PopQuizAnswerTextBox.Size.Width + 5 
                  Y = $script:PopQuizAnswerTextBox.Location.Y - 2 }
    Size     = @{ Width  = 100
                  Height = 22 }
    Add_Click = { Submit-ManualEntryAnswer }
}
$PopQuizAnswerGroupBox.Controls.Add($PopQuizManualEntrySubmitButton)



$StatusGroupBox = New-Object -TypeName System.Windows.Forms.GroupBox -Property @{
    Text = "Question Status:"
    Location = @{ X = $PopQuizAnswerGroupBox.Location.X + $PopQuizAnswerGroupBox.Size.Width + 10
                  Y = $PopQuizAnswerGroupBox.Location.Y }
    Size     = @{ Width  = 340
                  Height = 160 }
}
$PoShPopQuiz.Controls.Add($StatusGroupBox)



$PopQuizControlsGroupBox = New-Object -TypeName System.Windows.Forms.GroupBox -Property @{
    Text = "Controls:"
    Location = @{ X = $StatusGroupBox.Location.X 
                  Y = $StatusGroupBox.Location.Y + $StatusGroupBox.Size.Height + 5}
    Size     = @{ Width  = 340
                  Height = 50 }
}
$PoShPopQuiz.Controls.Add($PopQuizControlsGroupBox)



$PopQuizResultsTextBox = New-Object -TypeName System.Windows.Forms.RichTextBox -Property @{
    Location = @{ X = 10
                  Y = 20 }
    Size     = @{ Width  = 300
                  Height = 22 }
    ReadOnly = $True
}
$PopQuizControlsGroupBox.Controls.Add($PopQuizResultsTextBox)



$script:PopQuizMultipleChoiceCheckBox = New-Object -TypeName System.Windows.Forms.CheckBox -Property @{
    Text = "Multiple Choice:"
    Location = @{ X = $PopQuizAnswerGroupBox.Location.X + 10
                  Y = $PopQuizAnswerGroupBox.Location.Y + $PopQuizAnswerGroupBox.Size.Height + 1 }
    Size     = @{ Width  = 105
                  Height = 22 }
    Add_Click = {
        if ($This.checked){
            $script:PopQuizMultipleChoiceSubmitButton.Enabled = $True
            $script:PopQuizMultipleChoice1RadioButton.Enabled = $True
            $script:PopQuizMultipleChoice2RadioButton.Enabled = $True
            $script:PopQuizMultipleChoice3RadioButton.Enabled = $True
            $script:PopQuizMultipleChoice4RadioButton.Enabled = $True
            $script:PopQuizMultipleChoice5RadioButton.Enabled = $True
            $script:PopQuizMultipleChoice6RadioButton.Enabled = $True
        }
        else {
            $script:PopQuizMultipleChoiceSubmitButton.Enabled = $False
            $script:PopQuizMultipleChoice1RadioButton.Enabled = $False
            $script:PopQuizMultipleChoice2RadioButton.Enabled = $False
            $script:PopQuizMultipleChoice3RadioButton.Enabled = $False
            $script:PopQuizMultipleChoice4RadioButton.Enabled = $False
            $script:PopQuizMultipleChoice5RadioButton.Enabled = $False
            $script:PopQuizMultipleChoice6RadioButton.Enabled = $False

            $script:PopQuizMultipleChoice1RadioButton.Checked = $False
            $script:PopQuizMultipleChoice2RadioButton.Checked = $False
            $script:PopQuizMultipleChoice3RadioButton.Checked = $False
            $script:PopQuizMultipleChoice4RadioButton.Checked = $False
            $script:PopQuizMultipleChoice5RadioButton.Checked = $False
            $script:PopQuizMultipleChoice6RadioButton.Checked = $False    
        }
    }
}
$PoShPopQuiz.Controls.Add($script:PopQuizMultipleChoiceCheckBox)



$script:PopQuizMultipleChoiceGroupBox = New-Object -TypeName System.Windows.Forms.GroupBox -Property @{
    Location = @{ X = $PopQuizAnswerGroupBox.Location.X
                  Y = $PopQuizAnswerGroupBox.Location.Y + $PopQuizAnswerGroupBox.Size.Height + 5 }
    Size     = @{ Width  = 350
                  Height = 160 }
}
$PoShPopQuiz.Controls.Add($script:PopQuizMultipleChoiceGroupBox)


function Submit-MultipleChoiceAnswer {
    if     ($script:PopQuizMultipleChoice1RadioButton.checked -and $script:PopQuizMultipleChoice1RadioButton.Text -eq $script:CurrentQuestion) { $PopQuizResultsTextBox.Text = 'Correct' ; $script:CurrentButton.ResetBackColor() }
    elseif ($script:PopQuizMultipleChoice2RadioButton.checked -and $script:PopQuizMultipleChoice2RadioButton.Text -eq $script:CurrentQuestion) { $PopQuizResultsTextBox.Text = 'Correct' ; $script:CurrentButton.ResetBackColor() }
    elseif ($script:PopQuizMultipleChoice3RadioButton.checked -and $script:PopQuizMultipleChoice3RadioButton.Text -eq $script:CurrentQuestion) { $PopQuizResultsTextBox.Text = 'Correct' ; $script:CurrentButton.ResetBackColor() }
    elseif ($script:PopQuizMultipleChoice4RadioButton.checked -and $script:PopQuizMultipleChoice4RadioButton.Text -eq $script:CurrentQuestion) { $PopQuizResultsTextBox.Text = 'Correct' ; $script:CurrentButton.ResetBackColor() }
    elseif ($script:PopQuizMultipleChoice5RadioButton.checked -and $script:PopQuizMultipleChoice5RadioButton.Text -eq $script:CurrentQuestion) { $PopQuizResultsTextBox.Text = 'Correct' ; $script:CurrentButton.ResetBackColor() }
    elseif ($script:PopQuizMultipleChoice6RadioButton.checked -and $script:PopQuizMultipleChoice6RadioButton.Text -eq $script:CurrentQuestion) { $PopQuizResultsTextBox.Text = 'Correct' ; $script:CurrentButton.ResetBackColor() }
    elseif (!$script:PopQuizMultipleChoice1RadioButton.checked -and 
            !$script:PopQuizMultipleChoice2RadioButton.checked -and 
            !$script:PopQuizMultipleChoice3RadioButton.checked -and 
            !$script:PopQuizMultipleChoice4RadioButton.checked -and 
            !$script:PopQuizMultipleChoice5RadioButton.checked -and 
            !$script:PopQuizMultipleChoice6RadioButton.checked ) { $PopQuizResultsTextBox.Text = 'Nothing Selected' ; $script:CurrentButton.ResetBackColor()
    }
    else {
        $PopQuizResultsTextBox.Text = 'Wrong'
        $script:CurrentButton.BackColor = 'LightBlue'
    }  
}


$script:PopQuizMultipleChoiceSubmitButton = New-Object -TypeName System.Windows.Forms.Button -Property @{
    Text = "Submit"
    Location = @{ X = $script:PopQuizAnswerTextBox.Location.X + $script:PopQuizAnswerTextBox.Size.Width + 5 
                  Y = 128 }
    Size     = @{ Width  = 100
                  Height = 22 }
    Add_Click = { Submit-MultipleChoiceAnswer }
    Enabled = $false
}
$script:PopQuizMultipleChoiceGroupBox.Controls.Add($script:PopQuizMultipleChoiceSubmitButton)


$script:PopQuizMultipleChoice1RadioButton = New-Object -TypeName System.Windows.Forms.RadioButton -Property @{
    Text = "Question 1"
    Location = @{ X = 29
                  Y = 20 }
    Size     = @{ Width  = 310
                  Height = 22 }    
    Enabled = $false
    Add_KeyDown = { if ($_.KeyCode -eq "Enter") { Submit-MultipleChoiceAnswer } }
}
$script:PopQuizMultipleChoiceGroupBox.Controls.Add($script:PopQuizMultipleChoice1RadioButton)


$script:PopQuizMultipleChoice2RadioButton = New-Object -TypeName System.Windows.Forms.RadioButton -Property @{
    Text = "Question 2"
    Location = @{ X = $script:PopQuizMultipleChoice1RadioButton.Location.X
                  Y = $script:PopQuizMultipleChoice1RadioButton.Location.Y + $script:PopQuizMultipleChoice1RadioButton.Size.Height }
    Size     = @{ Width  = 310
                  Height = 22 }
    Enabled = $false
    Add_KeyDown = { if ($_.KeyCode -eq "Enter") { Submit-MultipleChoiceAnswer } }
}
$script:PopQuizMultipleChoiceGroupBox.Controls.Add($script:PopQuizMultipleChoice2RadioButton)


$script:PopQuizMultipleChoice3RadioButton = New-Object -TypeName System.Windows.Forms.RadioButton -Property @{
    Text = "Question 3"
    Location = @{ X = $script:PopQuizMultipleChoice2RadioButton.Location.X
                  Y = $script:PopQuizMultipleChoice2RadioButton.Location.Y + $script:PopQuizMultipleChoice2RadioButton.Size.Height }
    Size     = @{ Width  = 310
                  Height = 22 }
    Enabled = $false
    Add_KeyDown = { if ($_.KeyCode -eq "Enter") { Submit-MultipleChoiceAnswer } }
}
$script:PopQuizMultipleChoiceGroupBox.Controls.Add($script:PopQuizMultipleChoice3RadioButton)


$script:PopQuizMultipleChoice4RadioButton = New-Object -TypeName System.Windows.Forms.RadioButton -Property @{
    Text = "Question 4"
    Location = @{ X = $script:PopQuizMultipleChoice3RadioButton.Location.X
                  Y = $script:PopQuizMultipleChoice3RadioButton.Location.Y + $script:PopQuizMultipleChoice3RadioButton.Size.Height }
    Size     = @{ Width  = 310
                  Height = 22 }
    Enabled = $false
    Add_KeyDown = { if ($_.KeyCode -eq "Enter") { Submit-MultipleChoiceAnswer } }
}
$script:PopQuizMultipleChoiceGroupBox.Controls.Add($script:PopQuizMultipleChoice4RadioButton)


$script:PopQuizMultipleChoice5RadioButton = New-Object -TypeName System.Windows.Forms.RadioButton -Property @{
    Text = "Question 5"
    Location = @{ X = $script:PopQuizMultipleChoice4RadioButton.Location.X
                  Y = $script:PopQuizMultipleChoice4RadioButton.Location.Y + $script:PopQuizMultipleChoice4RadioButton.Size.Height }
    Size     = @{ Width  = 310
                  Height = 22 }
    Enabled = $false
    Add_KeyDown = { if ($_.KeyCode -eq "Enter") { Submit-MultipleChoiceAnswer } }
}
$script:PopQuizMultipleChoiceGroupBox.Controls.Add($script:PopQuizMultipleChoice5RadioButton)


$script:PopQuizMultipleChoice6RadioButton = New-Object -TypeName System.Windows.Forms.RadioButton -Property @{
    Text = "Question 6"
    Location = @{ X = $script:PopQuizMultipleChoice5RadioButton.Location.X
                  Y = $script:PopQuizMultipleChoice5RadioButton.Location.Y + $script:PopQuizMultipleChoice5RadioButton.Size.Height }
    Size     = @{ Width  = 310
                  Height = 22 }
    Enabled = $false
    Add_KeyDown = { if ($_.KeyCode -eq "Enter") { Submit-MultipleChoiceAnswer } }
}
$script:PopQuizMultipleChoiceGroupBox.Controls.Add($script:PopQuizMultipleChoice6RadioButton)



$PoShPopQuiz.ShowDialog()