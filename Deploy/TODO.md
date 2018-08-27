# TODO List

## Features / Functions to implements

### Move-PspSourceFile -Source -Destination

Source should be a file path, and destination should be a directory path.
This process will physically move the file, and adjust the file's JSON data in .psproj folder.

### Rename Add-PspSourceFileToPowershellProject to just Add-PspSourceFile and Alias the other.

### Create-PspNewTab -Name

This will create a directory named the same as the Tab name, and open the new Tab.

### Create-PspSourceFile -Source -FromTemplate? (inherit Add-PspSourceFile params?)

-Source should point to a (non existing) file inside a single directory from the source.  
-FromTemplate could be a thing, or perhaps a Defaults setting to always use a template, and point to where the template lives.

The process wil create the new file, empty or from template, and open the file on the corresponding tab.

Potentially we could inherit -Include, -Exclude, -ReadMeOrder

### Make the -Include*, -Exclude* work more intuitively.

Once I added a default for include or exclude, it became apparent that I had originally default excluded, and only had and -Include switch.  Need to make both switches available.

### Enhance New-PspPowershellProject -Name -Prefix

Include more items.
- DefaultTemplate
- TODO.md
- Completion_Stops Tab with Open-{Prefix} as default.
- Add a DefaultPrefix to the Defaults.  Use this in Create-PspSourcefile

### Add a -RemovePhysicalFile to Remove-PspSourceFile

### Add -WhatIf support to all destructive commands.

### Remove Powershell from ALL function names.

After adding the Psp prefix, the Powershell part becomes long and annoying.  

|Old Name|New Name|
|--------|--------|
|Add-PspSourceToPowershellProject|Add-PspSourceFile|
|Close-PspPowershellProject|Close-PspProject|
|Get-PspPowershellProject|Get-PspProject|
|New-PspPowershellProject|New-PspProject|
|Open-PspPowershellProject|Open-PspProject|
|Remove-PspSourceFromPowershellProject|Remove-PspSourceFile|
|Repair-PspPowershellProject|Repair-PspProject|
|Set-PspIncludeInBuildFlagForSource|Set-PspSourceFileDefauls|
||Get-PspSourceFileDefaults|
|Set-PspPowershellProjectDefaults|Set-PspProjectDefaults|
|Set-PspReadMeOrderForSource|*remove* see Set-PspSourceFileDefaults|
|Start-PspBuildPowershellProject|Start-PspProjectBuild|
|Start-PspBuildSourceFileFromPowershellProject|Start-PspSourceFileBuild|
|Start-PspDeployPowershellProject|Start-PspProjectDeploy|

### Add CompletionStops

- Start-PspProject

### Allow running Open-PspProject a second time, validate all windows are open, and open missing ones.

### Add Show-PspUnsavedFiles

This routine will loop through all of the open ISETabs and files and spit out the ones that are unsaved.