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


## ISEPSProject

### Description
A set of functions to help with code management and build.

### Functionality
#### New-PspPowershellProject

```powershell

NAME
    New-PspPowershellProject
    
SYNOPSIS
    Create an empty .psproj file, and optionally creates some base template files for a module Project.
    
    
SYNTAX
    New-PspPowershellProject [-ProjectFile] <String> [-CreateNewProjectDetails] [<CommonParameters>]
    
    
DESCRIPTION
    In order to start populating a .psproj file with the Add and Remove commands one needs to have an existing .psproj because we are validating the existance of the file in all of the other commands in this module that take the -ProjectFile parameter.
    

PARAMETERS
    -ProjectFile <String>
        Specify the project file to open.
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -CreateNewProjectDetails [<SwitchParameter>]
        Create new project details, adding defaults, PSD file, etc.
        
        Required?                    true
        Position?                    1
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS>New-PspPowershellProject -ProjectFile ISEPSProject -CreateNewProjectDetails
    
    1 file(s) have been added to the project
    0 duplicate file(s) have been skipped
    0 source file(s) have had their TAB locations updated
    0 source file(s) have been skipped
    1 file(s) have been added to the project
    0 duplicate file(s) have been skipped
    0 source file(s) have had their TAB locations updated
    0 source file(s) have been skipped
    
    PS> Get-ChildItem ISEPSProject.psproj
    
    
    Directory: C:\Powershell\ISEPSProject
    
    
    Mode                LastWriteTime         Length Name                                                                                                                                                                
    ----                -------------         ------ ----                                                                                                                                                                
    -a----       12/28/2016   7:57 AM            912 ISEPSProject.psproj
    
    PS> Get-ChildItem .psproj
    
    
    Directory: C:\Users\Christopher.Maahs\Documents\Projects\Documentation\ISEPSProjectDocs\.psproj
    
    
    Mode                LastWriteTime         Length Name                                                                                            
    ----                -------------         ------ ----                                                                                            
    d-----        8/27/2018   8:14 PM                files                                                                                           
    -a----        8/27/2018   8:14 PM           1456 defaults.clixml
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>When the file exists with the .psproj extension, and we only specify the basename, we will fail with a warning.
    
    dir
    
    
        Directory: C:\Powershell\ISEPSProject
    
    
    Mode                LastWriteTime         Length Name                                                                                                                                                                
    ----                -------------         ------ ----                                                                                                                                                                
    -a----       12/28/2016   7:28 AM           1993 Add-PspSourceToPowershellProject.ps1                                                                                                                                   
    -a----       12/27/2016   8:04 PM           1865 Repair-PspPowershellProject.ps1                                                                                                                                         
    -a----       12/27/2016   7:46 PM           1715 Compare-PspPowershellProjectBackup.ps1                                                                                                                                 
    -a----       12/28/2016   7:44 AM           1207 New-PspPowershellProject.ps1                                                                                                                                        
    -a----       12/28/2016   7:17 AM            691 Get-PspPowershellProject.ps1                                                                                                                                           
    -a----       12/27/2016   7:45 PM            916 Get-PspPowershellProjectBackup.ps1                                                                                                                                     
    -a----       12/28/2016   7:44 AM            912 ISEPSProject.psproj                                                                                                                                                   
    -a----       12/28/2016   7:23 AM           2035 Open-PspPowershellProject.ps1                                                                                                                                          
    -a----       12/28/2016   7:29 AM           2135 Remove-PspSourceFromPowershellProject.ps1                                                                                                                              
    
        New-PspPowershellProject ISEProject
    
    WARNING: After adding .psproj extension to the chosen filename, we have determined the file already exists.
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>When we specify a project file with the extension, and it already exists, we will fail via the ValidationScript.
    
    New-PspPowershellProject ISEPSProject.psproj
    
    New-PspPowershellProject : Cannot validate argument on parameter 'ProjectFile'. The " -Not (Test-Path $_) " validation script for the argument with value "ISEPSProject.psproj" did not return a result of True. 
    Determine why the validation script failed, and then try the command again.
    At line:1 char:26
    + New-PspPowershellProject ISEPSProject.psproj
    +                          ~~~~~~~~~~~~~~~~~
        + CategoryInfo          : InvalidData: (:) [New-PspPowershellProject], ParameterBindingValidationException
        + FullyQualifiedErrorId : ParameterArgumentValidationError,New-PspPowershellProject
    
    
    
    
    
RELATED LINKS





```
#### Open-PspPowershellProject

```powershell

NAME
    Open-PspPowershellProject
    
SYNOPSIS
    Open a Powershell .PSPROJ file in ISE, separated by TABS
    
    
SYNTAX
    Open-PspPowershellProject [[-ProjectFile] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    Define a collection of scripts and open them in a single command.
    
    This process will loop through the Source files and their associated Project TAB names and open new TABs and open the Source files on those TABs.
    

PARAMETERS
    -ProjectFile <String>
        Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [ValidateScript({ Test-Path $_ })]
        
        Required?                    false
        Position?                    1
        Default value                (Get-PspPowershellProjectDefaultProjectFile)
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Open-PspPowershellProject -ProjectFile ISEPSProject.psproj
    
    
    
    
    
    
    
RELATED LINKS





```
#### Close-PspPowershellProject

```powershell

NAME
    Close-PspPowershellProject
    
SYNOPSIS
    Close Project Source files if they are saved.  This routine was born out of the problem of simply closing ISE with bunches of files/tabs open.  Often the next re-open caused ISE to go into recovery mode.
    
    
SYNTAX
    Close-PspPowershellProject [[-ProjectFile] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    This process will loop through the Source files and their associated Project TAB names and close the open files (if they are saved) and close any empty TABs.
    

PARAMETERS
    -ProjectFile <String>
        Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [ValidateScript({ Test-Path $_ })]
        
        Required?                    false
        Position?                    1
        Default value                (Get-PspPowershellProjectDefaultProjectFile)
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Close-PspPowershellProject -ProjectFile ISEPSProject.psproj
    
    Files that are not part of the .psproj file AND files unsaved will be left open.
    
    
    
    
    
RELATED LINKS





```
#### Add-PspSourceToPowershellProject

```powershell

NAME
    Add-PspSourceToPowershellProject
    
SYNOPSIS
    Add a source file to an existing .psproj file.
    
    
SYNTAX
    Add-PspSourceToPowershellProject [-Name <String[]>] [-Directory <String[]>] [[-ProjectFile] <String>] [[-SourceFile] <String[]>] [[-ReadMeOrder] <Int32>] [[-IncludeInBuild]] [[-ExcludeFromBuild]] [<CommonParameters>]
    
    
DESCRIPTION
    Add a source file and corresponding TAB name to the .psproj file so it can be opened as a single project later.  A backup in the -streams section of the file will also be created.
    10 backups will be kept and can be listed with Get-PspPowershellProjectBackup function.
    

PARAMETERS
    -Name <String[]>
        Specify the source file name to add to the project.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       true (ByPropertyName)
        Accept wildcard characters?  false
        
    -Directory <String[]>
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       true (ByPropertyName)
        Accept wildcard characters?  false
        
    -ProjectFile <String>
        Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [ValidateScript({ Test-Path $_ })]
        
        Required?                    false
        Position?                    1
        Default value                (Get-PspPowershellProjectDefaultProjectFile)
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -SourceFile <String[]>
        Specify the source file name to add to the project.
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -ReadMeOrder <Int32>
        Name of TAB to place the source file on when opening in ISE via the Open-PspPowershellProject command.
        
               [Parameter(Mandatory=$false,
                          Position=2)]
               [Alias('Tab','TabName')]
               [string]
               $ProjectTab = ""
               ,
               
        Used to set the ReadMeOrder for the source file.
        
        Required?                    false
        Position?                    4
        Default value                999
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -IncludeInBuild [<SwitchParameter>]
        Flag the source file for inclusion in a module build via Start-PspBuildPowershellProject command.  Default can be set via Set-PspPowershellProjectDefaults command.
        
        Required?                    false
        Position?                    5
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -ExcludeFromBuild [<SwitchParameter>]
        Flag the source file for exclusion in a module build via Start-PspBuildPowershellProject command.  Default can be set via Set-PspPowershellProjectDefaults command.
        
        Required?                    false
        Position?                    6
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Get-ChildItem
    
    Directory: C:\Powershell\ISEPSProject
    
    
    Mode                LastWriteTime         Length Name                                                                                                                                                                
    ----                -------------         ------ ----                                                                                                                                                                
    -a----       12/28/2016   8:10 AM           2115 Add-PspSourceToPowershellProject.ps1                                                                                                                                   
    -a----       12/27/2016   8:04 PM           1865 Repair-PspPowershellProject.ps1                                                                                                                                         
    -a----       12/27/2016   7:46 PM           1715 Compare-PspPowershellProjectBackup.ps1                                                                                                                                 
    -a----       12/28/2016   8:06 AM           5637 New-PspPowershellProject.ps1                                                                                                                                        
    -a----       12/28/2016   7:17 AM            691 Get-PspPowershellProject.ps1                                                                                                                                           
    -a----       12/27/2016   7:45 PM            916 Get-PspPowershellProjectBackup.ps1                                                                                                                                     
    -a----       12/28/2016   8:06 AM            718 ISEPSProject.psproj                                                                                                                                                 
    -a----       12/28/2016   7:23 AM           2035 Open-PspPowershellProject.ps1                                                                                                                                          
    -a----       12/28/2016   7:29 AM           2135 Remove-PspSourceFromPowershellProject.ps1                                                                                                                              
    
    
    
    Add-PspSourceToPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile .\Add-PspSourceToPowershellProject.ps1 -ProjectTab "ISE PSProj" -IncludeInBuild
    
    1 file(s) have been added to the project
    0 duplicate file(s) have been skipped
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-ChildItem
    
    Directory: C:\Powershell\ISEPSProject
    
    
    Mode                LastWriteTime         Length Name                                                                                                                                                                
    ----                -------------         ------ ----                                                                                                                                                                
    -a----       12/28/2016   8:10 AM           2115 Add-PspSourceToPowershellProject.ps1                                                                                                                                   
    -a----       12/27/2016   8:04 PM           1865 Repair-PspPowershellProject.ps1                                                                                                                                         
    -a----       12/27/2016   7:46 PM           1715 Compare-PspPowershellProjectBackup.ps1                                                                                                                                 
    -a----       12/28/2016   8:06 AM           5637 New-PspPowershellProject.ps1                                                                                                                                        
    -a----       12/28/2016   7:17 AM            691 Get-PspPowershellProject.ps1                                                                                                                                           
    -a----       12/27/2016   7:45 PM            916 Get-PspPowershellProjectBackup.ps1                                                                                                                                     
    -a----       12/28/2016   8:06 AM            718 ISEPSProject.psproj                                                                                                                                                 
    -a----       12/28/2016   7:23 AM           2035 Open-PspPowershellProject.ps1                                                                                                                                          
    -a----       12/28/2016   7:29 AM           2135 Remove-PspSourceFromPowershellProject.ps1                                                                                                                              
    
    
    
    Add-PspSourceToPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile .\Repair-PspPowershellProject.ps1,Compare-PspPowershellProjectBackup.ps1 -ProjectTab "ISE PSProj" -IncludeInBuild
    
    2 file(s) have been added to the project
    0 duplicate file(s) have been skipped
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Get-ChildItem
    
    Directory: C:\Powershell\ISEPSProject
    
    
    Mode                LastWriteTime         Length Name                                                                                                                                                                
    ----                -------------         ------ ----                                                                                                                                                                
    -a----       12/28/2016   8:26 AM           7895 Add-PspSourceToPowershellProject.ps1                                                                                                                                   
    -a----       12/27/2016   8:04 PM           1865 Repair-PspPowershellProject.ps1                                                                                                                                         
    -a----       12/27/2016   7:46 PM           1715 Compare-PspPowershellProjectBackup.ps1                                                                                                                                 
    -a----       12/28/2016   8:06 AM           5637 New-PspPowershellProject.ps1                                                                                                                                        
    -a----       12/28/2016   8:29 AM            716 Get-PspPowershellProject.ps1                                                                                                                                           
    -a----       12/27/2016   7:45 PM            916 Get-PspPowershellProjectBackup.ps1                                                                                                                                     
    -a----       12/28/2016   8:28 AM           1482 ISEPSProject.psproj                                                                                                                                                 
    -a----       12/28/2016   7:23 AM           2035 Open-PspPowershellProject.ps1                                                                                                                                          
    -a----       12/28/2016   7:29 AM           2135 Remove-PspSourceFromPowershellProject.ps1                                                                                                                              
    
    
    
    Get-PspPowershellProject -ProjectFile .\ISEPSProject.psproj
    
    Name                                   Value                                                                                              
    ----                                   -----                                                                                              
    Repair-PspPowershellProject.ps1            @{FileName=Repair-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                
    Compare-PspPowershellProjectBackup.ps1    @{FileName=Compare-PspPowershellProjectBackup.ps1; ProjectTab=ISE PSProj Backup; IncludeInBuild=False}
    Add-PspSourceToPowershellProject.ps1      @{FileName=Add-PspSourceToPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}          
     
    
    Add-PspSourceToPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile (Get-ChildItem -Filter *.ps1).FullName -ProjectTab "ISE PSProj"
    
    5 file(s) have been added to the project
    3 duplicate file(s) have been skipped
    
    
    
    
    -------------------------- EXAMPLE 4 --------------------------
    
    PS C:\>Get-PspPowershellProject .\ISEPSProject.psproj
    
    Name                                   Value                                                                                              
    ----                                   -----                                                                                              
    Remove-PspSourceFromPowershellProject.ps1 @{FileName=Remove-PspSourceFromPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}     
    Start-PspBuildPowershellProject.ps1            @{FileName=Start-PspBuildPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                
    Repair-PspPowershellProject.ps1            @{FileName=Repair-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                
    Open-PspPowershellProject.ps1             @{FileName=Open-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                 
    Get-PspPowershellProjectBackup.ps1        @{FileName=Get-PspPowershellProjectBackup.ps1; ProjectTab=ISE PSProj Backup; IncludeInBuild=False}    
    Get-PspPowershellProject.ps1              @{FileName=Get-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                  
    Compare-PspPowershellProjectBackup.ps1    @{FileName=Compare-PspPowershellProjectBackup.ps1; ProjectTab=ISE PSProj; IncludeInBuild=False}
    Add-PspSourceToPowershellProject.ps1      @{FileName=Add-PspSourceToPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}          
    New-PspPowershellProject.ps1           @{FileName=New-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}               
    
    
    
    Add-PspSourceToPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile .\Compare-PspPowershellProjectBackup.ps1 -ProjectTab "ISE PSProj Backup"
    
    0 file(s) have been added to the project
    0 duplicate file(s) have been skipped
    1 source file(s) have had their TAB locations updated.
    
    
    
    
    
RELATED LINKS





```
#### Remove-PspSourceFromPowershellProject

```powershell

NAME
    Remove-PspSourceFromPowershellProject
    
SYNOPSIS
    Remove source files from the .psproj file.
    
    
SYNTAX
    Remove-PspSourceFromPowershellProject [-Name <String[]>] [-Directory <String[]>] [[-ProjectFile] <String>] [[-SourceFile] <String[]>] [<CommonParameters>]
    
    
DESCRIPTION
    This process will remove specified files from the project file, and create a backup in the -streams section of the file.
    10 backups will be kept and can be listed with Get-PspPowershellProjectBackup function.
    

PARAMETERS
    -Name <String[]>
        Specify the source file name to add to the project.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       true (ByPropertyName)
        Accept wildcard characters?  false
        
    -Directory <String[]>
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       true (ByPropertyName)
        Accept wildcard characters?  false
        
    -ProjectFile <String>
        Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [ValidateScript({ Test-Path $_ })]
        
        Required?                    false
        Position?                    1
        Default value                (Get-PspPowershellProjectDefaultProjectFile)
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -SourceFile <String[]>
        Specify the source file name to add to the project.
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Get-PspPowershellProject -ProjectFile .\ISEPSProject.psproj
    
    Name                                   Value                                                                                              
    ----                                   -----                                                                                              
    Remove-PspSourceFromPowershellProject.ps1 @{FileName=Remove-PspSourceFromPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}
    Repair-PspPowershellProject.ps1            @{FileName=Repair-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}
    Open-PspPowershellProject.ps1             @{FileName=Open-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}
    Get-PspPowershellProjectBackup.ps1        @{FileName=Get-PspPowershellProjectBackup.ps1; ProjectTab=ISE PSProj; IncludeInBuild=False}
    Compare-PspPowershellProjectBackup.ps1    @{FileName=Compare-PspPowershellProjectBackup.ps1; ProjectTab=ISE PSProj Backup; IncludeInBuild=False}
    Get-PspPowershellProject.ps1              @{FileName=Get-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}
    Add-PspSourceToPowershellProject.ps1      @{FileName=Add-PspSourceToPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}
    New-PspPowershellProject.ps1           @{FileName=New-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}
    
    
    Remove-PspSourceFromPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile .\Add-PspSourceToPowershellProject.ps1 
    
    1 source file(s) have been removed from the project
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-PspPowershellProject .\ISEPSProject.psproj
    
    Name                                   Value                                                                                              
    ----                                   -----                                                                                              
    Remove-PspSourceFromPowershellProject.ps1 @{FileName=Remove-PspSourceFromPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}     
    Repair-PspPowershellProject.ps1            @{FileName=Repair-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                
    Open-PspPowershellProject.ps1             @{FileName=Open-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                 
    Get-PspPowershellProjectBackup.ps1        @{FileName=Get-PspPowershellProjectBackup.ps1; ProjectTab=ISE PSProj; IncludeInBuild=False}   
    Compare-PspPowershellProjectBackup.ps1    @{FileName=Compare-PspPowershellProjectBackup.ps1; ProjectTab=ISE PSProj Backup; IncludeInBuild=False} 
    Get-PspPowershellProject.ps1              @{FileName=Get-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                  
    New-PspPowershellProject.ps1           @{FileName=New-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}               
    
    
    Remove-PspSourceFromPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile .\Repair-PspPowershellProject.ps1,.\Compare-PspPowershellProjectBackup.ps1
    
    2 source file(s) have been removed from the project
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Get-PspPowershellProject .\ISEPSProject.psproj
    
    Name                                   Value                                                                                              
    ----                                   -----                                                                                              
    Remove-PspSourceFromPowershellProject.ps1 @{FileName=Remove-PspSourceFromPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}     
    Open-PspPowershellProject.ps1             @{FileName=Open-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                 
    Get-PspPowershellProjectBackup.ps1        @{FileName=Get-PspPowershellProjectBackup.ps1; ProjectTab=ISE PSProj; IncludeInBuild=False}    
    Get-PspPowershellProject.ps1              @{FileName=Get-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                  
    New-PspPowershellProject.ps1           @{FileName=New-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}               
    
    Remove-PspSourceFromPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile (Get-ChildItem -Filter *.ps1).Name 
    
    5 source file(s) have been removed from the project
    3 source file(s) were not found in the project
    
    
    
    
    
RELATED LINKS





```
#### Repair-PspPowershellProject

```powershell

NAME
    Repair-PspPowershellProject
    
SYNOPSIS
    Removes abandoned files from the .psproj file.
    
    
SYNTAX
    Repair-PspPowershellProject [[-ProjectFile] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    Occasionally you will have removed/renamed source files and since we are doing ValidateScripts on passed in source file names these cannot be removed using the Remove-PspSourceFromPowershellProject cmdlet.
    
    This command will loop through the .psproj file's source files and determine if they exist, and if not, they will be removed.
    

PARAMETERS
    -ProjectFile <String>
        Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [ValidateScript({ Test-Path $_ })]
        
        Required?                    false
        Position?                    1
        Default value                (Get-PspPowershellProjectDefaultProjectFile)
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Get-ChildItem
    
    Directory: C:\Powershell\ISEPSProject
    
    
    Mode                LastWriteTime         Length Name                                                                                                                                                                
    ----                -------------         ------ ----                                                                                                                                                                
    -a----       12/28/2016  10:12 AM          11291 Add-PspSourceToPowershellProject.ps1                                                                                                                                   
    -a----       12/28/2016  10:26 AM           2470 Repair-PspPowershellProject.ps1                                                                                                                                         
    -a----       12/27/2016   7:46 PM           1715 Compare-PspPowershellProjectBackup.ps1                                                                                                                                 
    -a----       12/28/2016   8:06 AM           5637 New-PspPowershellProject.ps1                                                                                                                                        
    -a----       12/28/2016  10:22 AM           1688 Get-PspPowershellProject.ps1                                                                                                                                           
    -a----       12/27/2016   7:45 PM            916 Get-PspPowershellProjectBackup.ps1                                                                                                                                     
    -a----       12/28/2016  10:14 AM           2648 ISEPSProject.psproj                                                                                                                                                 
    -a----       12/28/2016   7:23 AM           2035 Open-PspPowershellProject.ps1                                                                                                                                          
    -a----       12/28/2016  10:12 AM           5237 Remove-PspSourceFromPowershellProject.ps1                                                                                                                              
    
    
    
    New-Item -Path DoNothing-OnNothing.ps1 -ItemType File
    
    
    Directory: C:\Powershell\ISEPSProject
    
    
    Mode                LastWriteTime         Length Name                                                                                                                                                                
    ----                -------------         ------ ----                                                                                                                                                                
    -a----       12/28/2016  10:27 AM              0 DoNothing-OnNothing.ps1                                                                                                                                             
    
    
    
    Add-PspSourceToPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile .\DoNothing-OnNothing.ps1 -ProjectTab "ISE PSProj"
    
    1 file(s) have been added to the project
    0 duplicate file(s) have been skipped
    
    Get-PspPowershellProject -ProjectFile .\ISEPSProject.psproj
    
    Name                                   Value     
    ----                                   -----     
    Add-PspSourceToPowershellProject.ps1      ISE PSProj
    Remove-PspSourceFromPowershellProject.ps1 ISE PSProj
    New-PspPowershellProject.ps1           ISE PSProj
    Open-PspPowershellProject.ps1             ISE PSProj
    Repair-PspPowershellProject.ps1            ISE PSProj
    Get-PspPowershellProjectBackup.ps1        ISE PSProj
    Compare-PspPowershellProjectBackup.ps1    ISE PSProj
    DoNothing-OnNothing.ps1                ISE PSProj
    Get-PspPowershellProject.ps1              ISE PSProj
    
    Remove-Item -Path .\DoNothing-OnNothing.ps1
    
    Get-ChildItem 
    
    
    Directory: C:\Powershell\ISEPSProject
    
    
    Mode                LastWriteTime         Length Name                                                                                                                                                                
    ----                -------------         ------ ----                                                                                                                                                                
    -a----       12/28/2016  10:12 AM          11291 Add-PspSourceToPowershellProject.ps1                                                                                                                                   
    -a----       12/28/2016  10:26 AM           2470 Repair-PspPowershellProject.ps1                                                                                                                                         
    -a----       12/27/2016   7:46 PM           1715 Compare-PspPowershellProjectBackup.ps1                                                                                                                                 
    -a----       12/28/2016   8:06 AM           5637 New-PspPowershellProject.ps1                                                                                                                                        
    -a----       12/28/2016  10:22 AM           1688 Get-PspPowershellProject.ps1                                                                                                                                           
    -a----       12/27/2016   7:45 PM            916 Get-PspPowershellProjectBackup.ps1                                                                                                                                     
    -a----       12/28/2016  10:28 AM           2868 ISEPSProject.psproj                                                                                                                                                 
    -a----       12/28/2016   7:23 AM           2035 Open-PspPowershellProject.ps1                                                                                                                                          
    -a----       12/28/2016  10:12 AM           5237 Remove-PspSourceFromPowershellProject.ps1                                                                                                                              
    
    
    
    Remove-PspSourceFromPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile DoNothing-OnNothing.ps1
    
    Remove-PspSourceFromPowershellProject : Cannot validate argument on parameter 'SourceFile'. The " Test-Path $_ " validation script for the argument with value "DoNothing-OnNothing.ps1" did not return a result of 
    True. Determine why the validation script failed, and then try the command again.
    At line:1 char:83
    + ... ProjectFile .\ISEPSProject.psproj -SourceFile DoNothing-OnNothing.ps1
    +                                                   ~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidData: (:) [Remove-PspSourceFromPowershellProject], ParameterBindingValidationException
    + FullyQualifiedErrorId : ParameterArgumentValidationError,Remove-PspSourceFromPowershellProject
    
    
    Repair-PspPowershellProject -ProjectFile .\ISEPSProject.psproj
    
    1 source file(s) have been removed from the project.
    
    
    
    
    
RELATED LINKS





```
#### Get-PspPowershellProject

```powershell

NAME
    Get-PspPowershellProject
    
SYNOPSIS
    Display a list of source files contained in the .psproj file.
    
    
SYNTAX
    Get-PspPowershellProject [[-ProjectFile] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    Used to view the list of files and their associated data. 
    
    Sources files are in the NAME column, and the associated item details are in the Value column.  
    
    Value column structure:
    Filename: matches the Name field.
    ProjectTab: name of the ISE TAB the file will be opened on.
    IncludeInBuild: True/False value for including the source file in the building of the psm1 file.
    

PARAMETERS
    -ProjectFile <String>
        Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [ValidateScript({ Test-Path $_ })]
        
        Required?                    false
        Position?                    1
        Default value                (Get-PspPowershellProjectDefaultProjectFile)
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Get-PspPowershellProject -ProjectFile .\ISEPSProject.psproj | Format-Table -AutoSize
    
    Name                                   Value                                                                                              
    ----                                   -----                                                                                              
    Remove-PspSourceFromPowershellProject.ps1 @{FileName=Remove-PspSourceFromPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}     
    Start-PspBuildPowershellProject.ps1            @{FileName=Start-PspBuildPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                
    Close-PspPowershellProject.ps1            @{FileName=Close-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                
    Repair-PspPowershellProject.ps1            @{FileName=Repair-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                
    Set-PspIncludeInBuildFlagForSource.ps1    @{FileName=Set-PspIncludeInBuildFlagForSource.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}        
    Open-PspPowershellProject.ps1             @{FileName=Open-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                 
    Get-PspPowershellProjectBackup.ps1        @{FileName=Get-PspPowershellProjectBackup.ps1; ProjectTab=ISE PSProj Backup; IncludeInBuild=False}    
    Get-PspPowershellProject.ps1              @{FileName=Get-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                  
    Compare-PspPowershellProjectBackup.ps1    @{FileName=Compare-PspPowershellProjectBackup.ps1; ProjectTab=ISE PSProj Backup; IncludeInBuild=False}
    Set-PspPowershellProjectDefaults.ps1      @{FileName=Set-PspPowershellProjectDefaults.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}          
    UtilityFunctions.ps1                   @{FileName=UtilityFunctions.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                       
    Add-PspSourceToPowershellProject.ps1      @{FileName=Add-PspSourceToPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}          
    New-PspPowershellProject.ps1           @{FileName=New-PspPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}
    
    
    
    
    
RELATED LINKS





```
#### Set-PspPowershellProjectDefaults

```powershell

NAME
    Set-PspPowershellProjectDefaults
    
SYNOPSIS
    Set some default values for common parameters (-ProjectFile and -IncludeInBuild)
    
    
SYNTAX
    Set-PspPowershellProjectDefaults [[-ProjectFile] <String>] [[-IncludeInBuild] <String>] [[-BuildStyle] <String>] [[-LocalDeployDirectory] <String>] [[-ModuleInitFile] <String>] [[-ModulePSDFile] <String>] [[-ModuleREADMEFile] <String>] [[-ModuleAdditionalZipFile] <Object>] [[-PreBuildCommand] 
    <Object>] [<CommonParameters>]
    
    
DESCRIPTION
    To avoid having to constantly call out the -ProjectFile and -IncludeInBuild parameters we will store some default values in .\.psproj\defaults.clixml file.
    All commands that have these parameters will attempt to read the defaults.clixml data if the parameter is excluded from the command.
    

PARAMETERS
    -ProjectFile <String>
        Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [ValidateScript({ Test-Path $_ })]
        
        Required?                    false
        Position?                    1
        Default value                (Get-PspPowershellProjectDefaultProjectFile)
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -IncludeInBuild <String>
        Specify Yes/No to set the default IncludeInBuild to be used when running the Add-PspSourceToPowershellProject command.
        
        Required?                    false
        Position?                    2
        Default value                Don't Modify
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -BuildStyle <String>
        Specify IncludeStyle/SingleFileStyle to set the default BuildStyle to be used when running the Start-PspBuildPowershellProject command.
        
        Required?                    false
        Position?                    3
        Default value                Don't Modify
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -LocalDeployDirectory <String>
        Specify Local Deploy Directory to set the default directory to be used when running the Start-PspDeployPowershellProject command.
        
        Required?                    false
        Position?                    4
        Default value                ("$($HOME)\Documents\WindowsPowerShell\Modules\$((Get-ChildItem $ProjectFile).BaseName)\")
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -ModuleInitFile <String>
        Specify the Module INIT file (file to be loaded LAST) when running Start-PspBuildPowershellProject command.  Use "-" to remove.
        
        Required?                    false
        Position?                    5
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -ModulePSDFile <String>
        Specify the location of the PSD1 file.  Use "-" to remove.
        
        Required?                    false
        Position?                    6
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -ModuleREADMEFile <String>
        Specify the location of the README.md file.  Use "-" to remove.
        
        Required?                    false
        Position?                    7
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -ModuleAdditionalZipFile <Object>
        Add a ZIP file
        
        Required?                    false
        Position?                    7
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -PreBuildCommand <Object>
        Add a command to run prior to starting a build.
        
        Required?                    false
        Position?                    8
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Set-PspPowershellProjectDefaults -ProjectFile .\ISEPSProject.psproj
    
    Set-PspPowershellProjectDefaults -IncludeInBuild No
    
    Get-PspPowershellProjectDefaultProjectFile
    
    .\ISEPSProject.psproj
    
    Get-PspPowershellProjectDefaultIncludeInBuild
    False
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-PspPowershellProjectDefaults
    
    ProjectFile          : .\ISEPSProject.psproj
    IncludeInBuild       : False
    BuildStyle           : IncludeStyle
    LocalDeployDirectory : C:\Program Files\WindowsPowerShell\Modules\ISEPSProject
    ModuleInitFile       : .\ISE_PSProj\Module_Init.ps1
    ModulePSDFile        : .\ISE_PSProj\ISEPSProject.psd1
    ModuleREADMEFile     : .\ISE_PSProj\README.md
    PreBuildCommand      : Add-PSAddin SwisAddIn; Get-Help Connect-Swis -Full
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Set the Build Style of the project.  Single PSM1 file, or an Include PSM1 file that imports single PS1 files.
    
    Set-PspPowershellProjectDefaults -BuildStyle IncludeStyle
    
    
    
    
    -------------------------- EXAMPLE 4 --------------------------
    
    PS C:\>Set the Local Deploy directory.  The Start-PspDeployPowershellProject function uses this setting.
    
    Set-PspPowershellProjectDefaults -LocalDeployDirectory C:\Program Files\WindowsPowerShell\Modules\ISEPSProject
    
    
    
    
    -------------------------- EXAMPLE 5 --------------------------
    
    PS C:\>Set the PSD file for the project.  Do NOT reference this file in the ROOT of the project.  This "source" version will be used as a template to build the module psd1 file in the ROOT of the project.
    
    The reason for this is so we can simply check out from Git into a Modules directory and have the module function correctly.
    
        Set-PspPowershellProjectDefaults -ModulePSDFile .\ISE_PSProj\ISEPSProject.psd1
    
    
    
    
    -------------------------- EXAMPLE 6 --------------------------
    
    PS C:\>Set the Module Init file.  This is a PS1 file that will be RUN upon loading (Import-Module) the module into your session.
    
    Set-PspPowershellProjectDefaults -ModuleInitFile .\ISE_PSProj\Module_Init.ps1
    
    
    
    
    
RELATED LINKS





```
#### Set-PspIncludeInBuildFlagForSource

```powershell

NAME
    Set-PspIncludeInBuildFlagForSource
    
SYNOPSIS
    Set the IncludeInBuild flag for a source file.
    
    
SYNTAX
    Set-PspIncludeInBuildFlagForSource [-Name <String[]>] [-Directory <String[]>] [[-ProjectFile] <String>] [[-SourceFile] <String[]>] [[-Exclude]] [[-Include]] [<CommonParameters>]
    
    
DESCRIPTION
    Each source item in the .psproj file contains a flag named IncludeInBuild.  This flag drives the inclusion of the source file in the Start-PspBuildPowershellProject command.
    

PARAMETERS
    -Name <String[]>
        Specify the source file name to add to the project.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       true (ByPropertyName)
        Accept wildcard characters?  false
        
    -Directory <String[]>
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       true (ByPropertyName)
        Accept wildcard characters?  false
        
    -ProjectFile <String>
        Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [ValidateScript({ Test-Path $_ })]
        
        Required?                    false
        Position?                    1
        Default value                (Get-PspPowershellProjectDefaultProjectFile)
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -SourceFile <String[]>
        Specify the source file name to add to the project.
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Exclude [<SwitchParameter>]
        Use this switch to EXCLUDE the source file from the build process, -Include overrides -Exclude.
        
        Required?                    false
        Position?                    3
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Include [<SwitchParameter>]
        Use this switch to INCLUDE the source file in the build process, -Include overrides -Exclude.
        -Include is the default operation.
        
        Required?                    false
        Position?                    4
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>(Get-PspPowershellProject)["Open-PspPowershellProject.ps1"]
    
    FileName                   ProjectTab IncludeInBuild
    --------                   ---------- --------------
    Open-PspPowershellProject.ps1 ISE PSProj           True
    
    Set-PspIncludeInBuildFlagForSource -ProjectFile .\ISEPSProject.psproj -SourceFile Open-PspPowershellProject.ps1 -Exclude
    
    1 source file(s) have been updated in the project
    0 source file(s) were not found in the project
    
    (Get-PspPowershellProject)["Open-PspPowershellProject.ps1"]
    
    FileName                   ProjectTab IncludeInBuild
    --------                   ---------- --------------
    Open-PspPowershellProject.ps1 ISE PSProj          False
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Set-PspIncludeInBuildFlagForSource -ProjectFile .\ISEPSProject.psproj -SourceFile Open-PspPowershellProject.ps1 -Include
    
    1 source file(s) have been updated in the project
    0 source file(s) were not found in the project
    
    (Get-PspPowershellProject)["Open-PspPowershellProject.ps1"]
    
    FileName                   ProjectTab IncludeInBuild
    --------                   ---------- --------------
    Open-PspPowershellProject.ps1 ISE PSProj           True
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>$projectData = Get-PspPowershellProject -ProjectFile .\ISEPSProject.psproj
    
    Set-PspIncludeInBuildFlagForSource -ProjectFile .\ISEPSProject.psproj -SourceFile $projectData.Keys -Exclude
    
    13 source file(s) have been updated in the project
    0 source file(s) were not found in the project
    
    (Get-PspPowershellProject).Values | Format-Table -AutoSize
    
    FileName                               ProjectTab        IncludeInBuild
    --------                               ----------        --------------
    Remove-PspSourceFromPowershellProject.ps1 ISE PSProj                 False
    Start-PspBuildPowershellProject.ps1            ISE PSProj                 False
    Close-PspPowershellProject.ps1            ISE PSProj                 False
    Repair-PspPowershellProject.ps1            ISE PSProj                 False
    Set-PspIncludeInBuildFlagForSource.ps1    ISE PSProj                 False
    Open-PspPowershellProject.ps1             ISE PSProj                 False
    Get-PspPowershellProjectBackup.ps1        ISE PSProj Backup          False
    UtilityFunctions.ps1                   ISE PSProj                 False
    Compare-PspPowershellProjectBackup.ps1    ISE PSProj Backup          False
    Set-PspPowershellProjectDefaults.ps1      ISE PSProj                 False
    Get-PspPowershellProject.ps1              ISE PSProj                 False
    Add-PspSourceToPowershellProject.ps1      ISE PSProj                 False
    New-PspPowershellProject.ps1           ISE PSProj                 False
    
    
    
    
    -------------------------- EXAMPLE 4 --------------------------
    
    PS C:\>$projectData = Get-PspPowershellProject -ProjectFile .\ISEPSProject.psproj
    
    $singleTab = $projectData.GetEnumerator() | Where-Object { $_.Value.ProjectTab -eq "ISE PSProj" }
    Set-PspIncludeInBuildFlagForSource -ProjectFile .\ISEPSProject.psproj -SourceFile $singleTab.Key -Include
    
    11 source file(s) have been updated in the project
    0 source file(s) were not found in the project
    
    (Get-PspPowershellProject).Values | Format-Table -AutoSize
    
    FileName                               ProjectTab        IncludeInBuild
    --------                               ----------        --------------
    Remove-PspSourceFromPowershellProject.ps1 ISE PSProj                  True
    Start-PspBuildPowershellProject.ps1            ISE PSProj                  True
    Close-PspPowershellProject.ps1            ISE PSProj                  True
    Repair-PspPowershellProject.ps1            ISE PSProj                  True
    Set-PspIncludeInBuildFlagForSource.ps1    ISE PSProj                  True
    Open-PspPowershellProject.ps1             ISE PSProj                  True
    Get-PspPowershellProjectBackup.ps1        ISE PSProj Backup          False
    UtilityFunctions.ps1                   ISE PSProj                  True
    Compare-PspPowershellProjectBackup.ps1    ISE PSProj Backup          False
    Set-PspPowershellProjectDefaults.ps1      ISE PSProj                  True
    Get-PspPowershellProject.ps1              ISE PSProj                  True
    Add-PspSourceToPowershellProject.ps1      ISE PSProj                  True
    New-PspPowershellProject.ps1           ISE PSProj                  True
    
    
    
    
    
RELATED LINKS





```
#### Set-PspReadMeOrderForSource

```powershell

NAME
    Set-PspReadMeOrderForSource
    
SYNOPSIS
    Set the ReadMeOrder value for a source file.
    
    
SYNTAX
    Set-PspReadMeOrderForSource [-Name <String[]>] [-Directory <String[]>] [[-ProjectFile] <String>] [[-SourceFile] <String[]>] [[-ReadMeOrder] <Int32>] [<CommonParameters>]
    
    
DESCRIPTION
    Each source item in the .psproj file contains a flag named ReadMeOrder.  This flag drives the order of appearance of Help Text in the README.md file.
    

PARAMETERS
    -Name <String[]>
        Specify the source file name to add to the project.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       true (ByPropertyName)
        Accept wildcard characters?  false
        
    -Directory <String[]>
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       true (ByPropertyName)
        Accept wildcard characters?  false
        
    -ProjectFile <String>
        Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [ValidateScript({ Test-Path $_ })]
        
        Required?                    false
        Position?                    1
        Default value                (Get-PspPowershellProjectDefaultProjectFile)
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -SourceFile <String[]>
        Specify the source file name to add to the project.
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -ReadMeOrder <Int32>
        Used to set the ReadMeOrder for the source file.
        
        Required?                    false
        Position?                    3
        Default value                999
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>
    
    
    
    
    
    
    
RELATED LINKS





```
#### Start-PspBuildPowershellProject

```powershell

NAME
    Start-PspBuildPowershellProject
    
SYNOPSIS
    Create a single PSM1 file from the PS1 files included in the .psproj file.  Because the ISE editor doesn't yet have great code navigation tools, it is easier to have smaller source files opened separately.
    
    
SYNTAX
    Start-PspBuildPowershellProject [[-ProjectFile] <String>] [[-Force]] [[-PerformBackup]] [<CommonParameters>]
    
    
DESCRIPTION
    This process will loop through the Source files and check for the IncludeInBuild flag.  Any source file with the include flag will be copied into the {projectname}.psm1 file.
    

PARAMETERS
    -ProjectFile <String>
        Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [ValidateScript({ Test-Path $_ })]
        
        Required?                    false
        Position?                    1
        Default value                (Get-PspPowershellProjectDefaultProjectFile)
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Force [<SwitchParameter>]
        Force overwrite of the existing psm1 file.
        
        Required?                    false
        Position?                    2
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -PerformBackup [<SwitchParameter>]
        Add an NTFS streams version of the existing module content to the newly created psm1 file.
        
        Required?                    false
        Position?                    3
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Start-PspBuildPowershellProject -ProjectFile ISEPSProject.psproj -Force
    
    Build Created.
    All functions export: FunctionsToExport = @('Add-PspSourceToPowershellProject','Start-PspBuildPowershellProject','Repair-PspPowershellProject','Close-PspPowershellProject','Create-PowershellProjec
    t','Get-PspPowershellProject','Open-PspPowershellProject','Remove-PspSourceFromPowershellProject','Set-PspIncludeInBuildFlagForSource','Set-PspPowershellProjectDefaults','Get-PspCSVFromStringArray
    ','Get-PspPowershellProjectBackupData','Get-PspPowershellProjectCurrentVersion','Get-PspPowershellProjectDefaultIncludeInBuild','Get-PspPowershellProjectDefaultProjectFile','Get-PowershellPr
    ojectFunctions','Get-PspPowershellProjectVersion','Save-PspPowershellProject','Save-PspPowershellProjectDefaults','Update-PspPowershellProjectVersion')
    
    
    
    
    
RELATED LINKS





```
#### Start-PspBuildSourceFileFromPowershellProject

```powershell

NAME
    Start-PspBuildSourceFileFromPowershellProject
    
SYNOPSIS
    Build a single PS1 from from a source PS1 file.
    
    
SYNTAX
    Start-PspBuildSourceFileFromPowershellProject [[-ProjectFile] <String>] [-SourceFile] <String[]> [[-Force]] [[-PerformBackup]] [<CommonParameters>]
    
    
DESCRIPTION
    when we use the <#PINC: replacement feature, we cannot simply RUN the code in the ISE editor window in order to add the function to our session.  We need to "build" it first, then we can dot load it into our session from the "bin" directory.
    

PARAMETERS
    -ProjectFile <String>
        Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [ValidateScript({ Test-Path $_ })]
        
        Required?                    false
        Position?                    2
        Default value                (Get-PspPowershellProjectDefaultProjectFile)
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -SourceFile <String[]>
        Specify the source file name to build in ./bin/
        
        Required?                    true
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Force [<SwitchParameter>]
        Force overwrite of the existing ps1 file.
        
        Required?                    false
        Position?                    3
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -PerformBackup [<SwitchParameter>]
        Add an NTFS streams version of the existing module content to the newly created ps1 file.
        
        Required?                    false
        Position?                    4
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Start-PspBuildSourceFileFromPowershellProject -SourceFile ISE_PSProj\Add-PspSourceToPowershellProject.ps1 -ProjectFile ISEPSProject.psproj -Force
    
    Build Created.
    Import the built PS1 file into your session with:
    . .\bin\Add-PspSourceToPowershellProject.ps1
    
    
    
    
    
RELATED LINKS





```
#### Start-PspDeployPowershellProject

```powershell

NAME
    Start-PspDeployPowershellProject
    
SYNOPSIS
    Deploy a .psproj deliverable to the local Documents\WindowsPowershell\Modules\{projectname}\{projectname}.psm1 target.
    
    Location can be set with: Set-PspPowershellProjectDefaults -LocalDeployDirectory {deploy directory}
    
    
SYNTAX
    Start-PspDeployPowershellProject [[-ProjectFile] <String>] [[-Force]] [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -ProjectFile <String>
        Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [ValidateScript({ Test-Path $_ })]
        
        Required?                    false
        Position?                    1
        Default value                (Get-PspPowershellProjectDefaultProjectFile)
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Force [<SwitchParameter>]
        Force overwrite of the existing psm1 file.
        
        Required?                    false
        Position?                    2
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Start-PspDeployPowershellProject -ProjectFile ISEPSProject.psproj -Force
    
    VERBOSE: Default Target Directory: C:\Program Files\WindowsPowerShell\Modules\ISEPSProject
    VERBOSE: Module File Name: ISEPSProject.psm1
    VERBOSE: Manifest File Name: ISEPSProject.psd1
    VERBOSE: Target Path: C:\Program Files\WindowsPowerShell\Modules\ISEPSProject
    
    
    
    
    
RELATED LINKS





```
#### Start-Psp

```powershell

NAME
    Start-Psp
    
SYNOPSIS
    This is a stub function that STOPS TAB completion at Start-Psp, allowing you to type an additional character.
    
    
SYNTAX
    Start-Psp [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS>Get-E{TAB} will expan to Get-Evc, allow you to type the first letter or a few of the next match.
    
    
    
    
    
    
    
RELATED LINKS





```
#### Set-Psp

```powershell

NAME
    Set-Psp
    
SYNOPSIS
    This is a stub function that STOPS TAB completion at Set-Psp, allowing you to type an additional character.
    
    
SYNTAX
    Set-Psp [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS>Get-E{TAB} will expan to Get-Evc, allow you to type the first letter or a few of the next match.
    
    
    
    
    
    
    
RELATED LINKS





```
#### Get-PspPowershellProjectBackup

```powershell

NAME
    Get-PspPowershellProjectBackup
    
SYNOPSIS
    EXPERIMENTAL: List the STREAMS backups stored for the .psproj file.
    
    
SYNTAX
    Get-PspPowershellProjectBackup [[-ProjectFile] <String>] [-StartAt] <Int32> [<CommonParameters>]
    
    
DESCRIPTION
    The list contains a numbered slot and the file can contain 0-9 numbered slots.
    The names reference the date and time the backup was made.
    

PARAMETERS
    -ProjectFile <String>
        Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [ValidateScript({ Test-Path $_ })]
        
        Required?                    false
        Position?                    1
        Default value                (Get-PspPowershellProjectDefaultProjectFile)
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -StartAt <Int32>
        Use the Get-PspPowershellProjectBackup command to get a list of backup numbers, provide 0-9 for the LEFT side compare.
        [ValidateRange(0,9)]
        
        Required?                    true
        Position?                    2
        Default value                0
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Get-PspPowershellProjectBackup
    
    0. 2018-06-04_011755
    1. 2018-06-04_011742
    
    
    
    
    
RELATED LINKS





```
#### Restore-PspPowershellProjectBackup

```powershell

NAME
    Restore-PspPowershellProjectBackup
    
SYNOPSIS
    EXPERIMENTAL: Restore a previous version of the .psproj file.
    
    
SYNTAX
    Restore-PspPowershellProjectBackup [[-ProjectFile] <String>] [-BackupNumberToRestore] <Int32> [<CommonParameters>]
    
    
DESCRIPTION
    Versions of the .psproj file are saved in the STREAMS of NTFS and each modification to the .psproj file will create a new backup and bump the old backups down one slot.
    

PARAMETERS
    -ProjectFile <String>
        Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [ValidateScript({ Test-Path $_ })]
        
        Required?                    false
        Position?                    1
        Default value                (Get-PspPowershellProjectDefaultProjectFile)
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -BackupNumberToRestore <Int32>
        Use the Get-PspPowershellProjectBackup command to get a list of backup numbers, provide 0-9 for the LEFT side compare.
        
        Required?                    true
        Position?                    2
        Default value                0
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Restore-PspPowershellProjectBackup -BackupNumberToRestore 1
    
    
    
    
    
    
    
RELATED LINKS





```
#### Compare-PspPowershellProjectBackup

```powershell

NAME
    Compare-PspPowershellProjectBackup
    
SYNOPSIS
    EXPIRIMENTAL: Compare two backups stored in the STREAMS backup list of the .psproj file.
    
    
SYNTAX
    Compare-PspPowershellProjectBackup [[-ProjectFile] <String>] [-LeftFile] <Int32> [-RightFile] <Int32> [<CommonParameters>]
    
    
DESCRIPTION
    Specify left and right slot numbers to compare.
    

PARAMETERS
    -ProjectFile <String>
        Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [ValidateScript({ Test-Path $_ })]
        
        Required?                    false
        Position?                    1
        Default value                (Get-PspPowershellProjectDefaultProjectFile)
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -LeftFile <Int32>
        Use the Get-PspPowershellProjectBackup command to get a list of backup numbers, provide 0-9 for the LEFT side compare.
        
        Required?                    true
        Position?                    2
        Default value                0
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -RightFile <Int32>
        Use the Get-PspPowershellProjectBackup command to get a list of backup numbers, provide 0-9 for the RIGHT side compare.
        
        Required?                    true
        Position?                    3
        Default value                0
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Compare-PspPowershellProjectBackup -LeftFile 1 -RightFile 0
    
    The output is currently just a Compare-Object of the clixml format.
    
    
    
    
    
RELATED LINKS





```
#### Get-PspPowershellProjectDefaults

```powershell

NAME
    Get-PspPowershellProjectDefaults
    
SYNOPSIS
    We are saving some build/project defaults in .psproj\defaults.clixml.  This function will display those settings.
    
    
SYNTAX
    Get-PspPowershellProjectDefaults [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS>Get-PspPowershellProjectDefaults
    
    ProjectFile             : ISEPSProject.psproj
    IncludeInBuild          : True
    BuildStyle              : IncludeStyle
    LocalDeployDirectory    : 
    ModuleInitFile          : 
    ModuleREADMEFile        : .\Deploy\README.md
    ModuleAdditionalZipFile : 
    PreBuildCommand         : 
    ModulePSDFile           : .\Deploy\ISEPSProject.psd1
    
    
    
    
    
RELATED LINKS





```
#### New-PspIsePsZipInstallDetails

```powershell

NAME
    New-PspIsePsZipInstallDetails
    
SYNOPSIS
    Extract Zip File information.
    
    
SYNTAX
    New-PspIsePsZipInstallDetails [-ZipFile] <String> [-RelativeInstallPath] <String> [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -ZipFile <String>
        Zip File to expand during deploy
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -RelativeInstallPath <String>
        Relative Path to Extract ZIP to
        
        Required?                    true
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>
    
    
    
    
    
    
    
RELATED LINKS





```
#### Start-IsePsPublishToEvcNuGet

```powershell

NAME
    Start-IsePsPublishToEvcNuGet
    
SYNTAX
    Start-IsePsPublishToEvcNuGet  
    
    
PARAMETERS
    None
    
    
INPUTS
    None
    
    
OUTPUTS
    System.Object
    
ALIASES
    None
    

REMARKS
    None





```
#### Get-PspRelativePathFromProjectRoot

```powershell

NAME
    Get-PspRelativePathFromProjectRoot
    
SYNOPSIS
    Returns the PATH part of the SourceFile removing the ROOT path of the .psproj file.
    
    
SYNTAX
    Get-PspRelativePathFromProjectRoot [[-FullName] <Object>] [[-ProjectFile] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    Used to feed other Powershell Project commands.
    

PARAMETERS
    -FullName <Object>
        File Item from .psproj file.
        
        Required?                    false
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -ProjectFile <String>
        Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [ValidateScript({ Test-Path $_ })]
        
        Required?                    false
        Position?                    2
        Default value                (Get-PspPowershellProjectDefaultProjectFile)
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>
    
    
    
    
    
    
    
RELATED LINKS





```
#### Get-PspPowershellProjectFunctions

```powershell

NAME
    Get-PspPowershellProjectFunctions
    
SYNOPSIS
    Gets a list of the commands (function) inside of the source files contained in the .psproj file.
    
    
SYNTAX
    Get-PspPowershellProjectFunctions [[-ProjectFile] <String>] [[-IncludedInBuildOnly]] [[-IncludeOnlyPublic]] [<CommonParameters>]
    
    
DESCRIPTION
    Generate a list of commands (function) with their containing source file information.
    

PARAMETERS
    -ProjectFile <String>
        Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [ValidateScript({ Test-Path $_ })]
        
        Required?                    false
        Position?                    1
        Default value                (Get-PspPowershellProjectDefaultProjectFile)
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -IncludedInBuildOnly [<SwitchParameter>]
        Switch to only include those source files that have the IncludeInBuild flag set.
        
        Required?                    false
        Position?                    2
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -IncludeOnlyPublic [<SwitchParameter>]
        Switch to only include PUBLIC exported functions
        
        Required?                    false
        Position?                    3
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS>Get-PspPowershellProjectFunctions -ProjectFile .\ISEPSProject.psproj | Sort-Object -Property SourceFile,FunctionName
    
    Name                                       SourceFile                            
    ------------                               ----------                            
    Add-PspSourceToPowershellProject              Add-PspSourceToPowershellProject.ps1     
    Start-PspBuildPowershellProject                    Start-PspBuildPowershellProject.ps1           
    Repair-PspPowershellProject                    Repair-PspPowershellProject.ps1           
    Close-PspPowershellProject                    Close-PspPowershellProject.ps1           
    Compare-PspPowershellProjectBackup            Compare-PspPowershellProjectBackup.ps1   
    New-PspPowershellProject                   New-PspPowershellProject.ps1          
    Get-PspPowershellProject                      Get-PspPowershellProject.ps1             
    Get-PspPowershellProjectBackup                Get-PspPowershellProjectBackup.ps1       
    Open-PspPowershellProject                     Open-PspPowershellProject.ps1            
    Remove-PspSourceFromPowershellProject         Remove-PspSourceFromPowershellProject.ps1
    Set-PspIncludeInBuildFlagForSource            Set-PspIncludeInBuildFlagForSource.ps1   
    Set-PspPowershellProjectDefaults              Set-PspPowershellProjectDefaults.ps1     
    Get-PspCSVFromStringArray                     UtilityFunctions.ps1                  
    Get-PspPowershellProjectBackupData            UtilityFunctions.ps1                  
    Get-PspPowershellProjectCurrentVersion        UtilityFunctions.ps1                  
    Get-PspPowershellProjectDefaultIncludeInBuild UtilityFunctions.ps1                  
    Get-PspPowershellProjectDefaultProjectFile    UtilityFunctions.ps1                  
    Get-PspPowershellProjectFunctions             UtilityFunctions.ps1                  
    Get-PspPowershellProjectVersion               UtilityFunctions.ps1                  
    Save-PspPowershellProject                     UtilityFunctions.ps1                  
    Save-PspPowershellProjectDefaults             UtilityFunctions.ps1                  
    Update-PspPowershellProjectVersion            UtilityFunctions.ps1
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS>Get-PspPowershellProjectFunctions -ProjectFile .\ISEPSProject.psproj -IncludedInBuildOnly | Sort-Object -Property SourceFile,FunctionName
    
    Name                                       SourceFile                            
    ------------                               ----------                            
    Add-PspSourceToPowershellProject              Add-PspSourceToPowershellProject.ps1     
    Start-PspBuildPowershellProject                    Start-PspBuildPowershellProject.ps1           
    Repair-PspPowershellProject                    Repair-PspPowershellProject.ps1           
    Close-PspPowershellProject                    Close-PspPowershellProject.ps1           
    New-PspPowershellProject                   New-PspPowershellProject.ps1          
    Get-PspPowershellProject                      Get-PspPowershellProject.ps1             
    Open-PspPowershellProject                     Open-PspPowershellProject.ps1            
    Remove-PspSourceFromPowershellProject         Remove-PspSourceFromPowershellProject.ps1
    Set-PspIncludeInBuildFlagForSource            Set-PspIncludeInBuildFlagForSource.ps1   
    Set-PspPowershellProjectDefaults              Set-PspPowershellProjectDefaults.ps1     
    Get-PspCSVFromStringArray                     UtilityFunctions.ps1                  
    Get-PspPowershellProjectBackupData            UtilityFunctions.ps1                  
    Get-PspPowershellProjectCurrentVersion        UtilityFunctions.ps1                  
    Get-PspPowershellProjectDefaultIncludeInBuild UtilityFunctions.ps1                  
    Get-PspPowershellProjectDefaultProjectFile    UtilityFunctions.ps1                  
    Get-PspPowershellProjectFunctions             UtilityFunctions.ps1                  
    Get-PspPowershellProjectVersion               UtilityFunctions.ps1                  
    Save-PspPowershellProject                     UtilityFunctions.ps1                  
    Save-PspPowershellProjectDefaults             UtilityFunctions.ps1                  
    Update-PspPowershellProjectVersion            UtilityFunctions.ps1
    
    
    
    
    
RELATED LINKS





```
#### Get-PspControlDirectory

```powershell

NAME
    Get-PspControlDirectory
    
SYNOPSIS
    This function will walk from the current $PWD path until it finds the .psproj directory and return that path.
    
    
SYNTAX
    Get-PspControlDirectory [<CommonParameters>]
    
    
DESCRIPTION
    Used to feed other Powershell Project commands.
    

PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>
    
    
    
    
    
    
    
RELATED LINKS





```
#### Get-PspPowershellProjectFilesNotIncludedInProject

```powershell

NAME
    Get-PspPowershellProjectFilesNotIncludedInProject
    
SYNOPSIS
    Display the files in the PROJECT directory that haven't been added as a source.
    
    
SYNTAX
    Get-PspPowershellProjectFilesNotIncludedInProject [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>
    
    
    
    
    
    
    
RELATED LINKS





```
#### Save-PspProjectData

```powershell

NAME
    Save-PspProjectData
    
SYNOPSIS
    Build a PSObject based on the .psproj\files directory structure.
    
    
SYNTAX
    Save-PspProjectData [[-ProjectData] <Hashtable>] [<CommonParameters>]
    
    
DESCRIPTION
    Returns a PSObject based on the JSON data files in .psproj\files directory.
    

PARAMETERS
    -ProjectData <Hashtable>
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>TODO: Example
    
    
    
    
    
    
    
RELATED LINKS





```
#### Get-PspProjectData

```powershell

NAME
    Get-PspProjectData
    
SYNOPSIS
    Build a PSObject based on the .psproj\files directory structure.
    
    
SYNTAX
    Get-PspProjectData [[-ProjectFile] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    Returns a PSObject based on the JSON data files in .psproj\files directory.
    

PARAMETERS
    -ProjectFile <String>
        Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [ValidateScript({ Test-Path $_ })]
        
        Required?                    false
        Position?                    1
        Default value                (Get-PspPowershellProjectDefaultProjectFile)
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>TODO: Example
    
    
    
    
    
    
    
RELATED LINKS





```
