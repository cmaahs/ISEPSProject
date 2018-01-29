# ISEPSProject
A Powershell module for using ISE to manage projects.

# SHORT DESCRIPTION
    Set of utility functions to allow one to group and quickly open a set of related Powershell files within the ISE environment.

# LONG DESCRIPTION
    Project files with the extension of .psproj are created and maintained using the related scripts.

    Commands use to create and modify these .psproj files are included.  

    Each source file added to the .psproj file is locally referenced (no full paths) 
    Source files are assigned a TAB name.

    When the .psproj file is opened a new PowerShellTab in ISE ($psISE.PowershellTabs.Add) is created and the .Description is set to the TAB name.
    Each source file associted with a particular TAB is then opened within the associated PowerShellTab.
    A Set-Location is called on the SHELL window to set the working directory to match the source of the files.

    Enhancements that might be nice:
        Full path support, potentially creating a new TAB for each directory.


# EXAMPLES

    This is a sample workflow.

    Source files are created (New-Something.ps1, Remove-Something.ps1, Get-Something.ps1, Maintain-Something.ps1)

    Create-PowershellProject -ProjectFile MyProject
        -This creates: MyProject.psproj

    Add-SourceToPowershellProject -ProjectFile .\MyProject.psproj -SourceFile .\New-Something.ps1 -ProjectTab "MyProject" -IncludeInBuild
    Add-SourceToPowershellProject -ProjectFile .\MyProject.psproj -SourceFile .\Remove-Something.ps1 -ProjectTab "MyProject" 
    Add-SourceToPowershellProject -ProjectFile .\MyProject.psproj -SourceFile .\Get-Something.ps1 -ProjectTab "MyProject" -IncludeInBuild
    Add-SourceToPowershellProject -ProjectFile .\MyProject.psproj -SourceFile .\Maintain-Something.ps1 -ProjectTab "MyProjectMaintenance" -IncludeInBuild

    Set-IncludeInBuildFlagForSource -ProjectFile .\MyProject.psproj -SourceFile Remove-Something.ps1 -Include

    Open-PowershellProject -ProjectFile .\MyProject.psproj
        -This creates a new PowerShellTab named "MyProject" and opens the Add-Something.ps1,Remove-Something.ps1 and Get-Something.ps1 file.
        -It also creates a second new PowerShellTab named "MyProjectMaintenance" and opens the Maintain-Something.ps1 file there.


    Remove-SourceFromPowershellProject -ProjectFile .\MyProject.psproj -SourceFile .\Remove-Somethings.ps1
        -This will remove the source file from the project.

    Build-PowershellProject -ProjectFile .\MyProject.psproj 
        -This will loop through all of the source items in the .psproj file, and copy all of the items with the IncludeInBuild flag set to true into MyProject.psm1 module.

    Close-PowershellProject -ProjectFile .\MyProject.psproj
        -This loops through the source files in the .psproj file and determines if the file is opened, and if not modified, closes the open file.
        -ISE tends to not close properly when there are a good number of TABs and Files open.
        -This can mitigate the "recovered" documents message when reopening ISE.

    (Get-PowershellProject -ProjectFile .\MyProject.psproj).Values | Format-Table -AutoSize
        -This will list the items in the file.

    Set-PowershellProjectDefaults -ProjectFile .\MyProject.psproj
        -This will set the default -ProjectFile for any subsequent commands that require the -ProjectFile parameter.
        -The defaults are stored in a .\.psproj\defaults.clixml file.
