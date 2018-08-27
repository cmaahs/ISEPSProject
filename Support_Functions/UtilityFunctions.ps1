<#
This file has been excluded from build.
#>

function Get-PspPowershellProjectCurrentVersion
{
<#
.Synopsis
   Returns the most current version of .psproj files.
.DESCRIPTION
   Returns the lastest version of the .psproj files supported by the code.

.EXAMPLE
   Get-PspPowershellProjectCurrentVersion
#>
    [CmdletBinding()]
    Param
    (        
    )

    Begin
    {        
    }
    Process
    {        
        $item = "" | Select-Object CurrentVersion
        $item.CurrentVersion = "1.1"
        Write-Output $item
   }
    End
    {
    }
}

function Get-PspPowershellProjectVersion
{
<#
.Synopsis
   Get the .psproj data version
.DESCRIPTION
   Returns the version of the .psproj data

.EXAMPLE
PS> Get-PspPowershellProjectVersion -ProjectFile ISEPSProject.psproj

Version CurrentVersion IsLatest
------- -------------- --------
1.1     1.1                True

#>
    [CmdletBinding()]
    Param
    (
        # Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]
        $ProjectFile = (Get-PspPowershellProjectDefaultProjectFile)
    )

    Begin
    {
        $continueProcessing = $true
        if ( $ProjectFile -ne "" ) 
        {            
            if ( -not ( Test-Path $ProjectFile ) ) 
            {
                Write-Warning "Cannot locate the specified ProjectFile"
                $continueProcessing = $false
            }        
        } else {
            Write-Warning "Must specify the -ProjectFile, or use Set-PspPowershellProjectDefaults command to set a default ProjectFile"
            $continueProcessing = $false
        }
    }
    Process
    {
        if ( $continueProcessing -eq $true )
        {
            $projectData = Import-Clixml -Path $ProjectFile
            $item = "" | Select-Object Version,CurrentVersion,IsLatest
            $item.CurrentVersion = (Get-PspPowershellProjectCurrentVersion).CurrentVersion
            $item.IsLatest = $false
        
            if ( $projectData.ContainsKey("ISEPSProjectDataVersion") )
            {
                $item.Version = $projectData["ISEPSProjectDataVersion"]
            } else {
                $item.Version = "1.0"
            }
            if ( $item.CurrentVersion -eq $item.Version ) 
            {
                $item.IsLatest = $true
            }
            Write-Output $item
        } #continue processing
    }
    End
    {
        if ( $continueProcessing -eq $true )
        {
        }
    }
}

function Update-PspPowershellProjectVersion_Old
{
<#
.Synopsis
   Process to upgrade from a previous version to current.
.DESCRIPTION
   When the existing .psproj file is not at the current version, calling this command will upgrade all previous version to the current version.

.EXAMPLE
PS> Update-PspPowershellProjectVersion -ProjectFile ISEPSProject.psproj

UpgradeNeeded UpgradeStatus    
------------- -------------    
         True Updated to latest

#>
    [CmdletBinding()]
    Param
    (
        # Specify the project file to open.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]
        $ProjectFile = (Get-PspPowershellProjectDefaultProjectFile)
    )

    Begin
    {    
        $continueProcessing = $true
        if ( $ProjectFile -ne "" ) 
        {            
            if ( -not ( Test-Path $ProjectFile ) ) 
            {
                Write-Warning "Cannot locate the specified ProjectFile"
                $continueProcessing = $false
            }        
        } else {
            Write-Warning "Must specify the -ProjectFile, or use Set-PspPowershellProjectDefaults command to set a default ProjectFile"
            $continueProcessing = $false
        }
    }
    Process
    {
        if ( $continueProcessing -eq $true )
        {
            $projectData = Import-Clixml -Path $ProjectFile

            $dataVersion = Get-PspPowershellProjectVersion -ProjectFile $ProjectFile
            $item = "" | Select-Object UpgradeNeeded,UpgradeStatus

            if ( $dataVersion.Version -ne $dataVersion.CurrentVersion ) 
            {
                Write-Verbose "Need an update: $($dataVersion.Version) to $($dataVersion.CurrentVersion)"
                $bakProjectData = Get-Content -Path $ProjectFile

                $backupList =  Get-Item -Path $ProjectFile -Stream * | Where-Object { $_.Stream -ne ':$DATA' }  | Sort-Object -Property Stream -Descending
                if ( $backupList )
                {
                    if ( $backupList.Count -gt 8 ) { $backupCount = 8 } else { $backupCount = ($backupList.Count)-1 }
                    $backupData = @{}
                    for ( $x = 0; $x -le $backupCount; $x++ )
                    {
                        $backData = Get-Content -Path $ProjectFile -Stream $backupList[$x].Stream
                        $backupData.Add($backupList[$x].Stream, $backData)
                    }
                }


                if ( ( $dataVersion.Version -eq "1.1" ) -and ( $continueProcessing -eq $true ) )
                {
                    #current version
                    $item.UpgradeNeeded = $false
                    $item.UpgradeStatus = "Current"
                    $continueProcessing = $false
                }
                if ( ( $dataVersion.Version -eq "1.0" ) -and ( $continueProcessing -eq $true ) )
                {
                    #upgrade from 1.0
                    Write-Verbose "Update from 1.0"
                    $projectData.Add("ISEPSProjectDataVersion", "1.1")

                    if ( $ProjectFile.StartsWith(".\") )
                    {
                        $projectFileKey = $ProjectFile.SubString(2)
                    }    
                    $newProjectData = @{}    
                    foreach ( $key in $projectData.Keys )
                    {
                        if ( ( $key -ne $projectFileKey ) -and ( $key -ne "ISEPSProjectDataVersion" ) ) 
                        {
                            $newStruct = "" | Select-Object FileName,ProjectTab,IncludeInBuild
                            $newStruct.FileName = $key
                            $newStruct.ProjectTab = $projectData[$key]
                            $newStruct.IncludeInBuild = $true
                            $newProjectData.Add($key, $newStruct)
                        } else {
                            $newProjectData.Add($key, $projectData[$key])
                        }
                    }
                    $item.UpgradeNeeded = $true
                    $item.UpgradeStatus = "Updated to latest"
                    $continueProcessing = $true
                }

                if ( $continueProcessing -eq $true ) 
                {
                    $newProjectData | Export-Clixml -Path $ProjectFile -Force

                    $backupName = (Get-Date).ToString('yyyy-MM-dd_HHmmss')
                    Add-Content -Path $ProjectFile -Value $bakProjectData -Stream $backupName

                    foreach ( $key in $backupData.Keys )
                    {
                        Add-Content -Path $ProjectFile -Value $backupData.Get_Item($key) -Stream $key
                    }                
                }
            } else {
                $item.UpgradeNeeded = $false
                $item.UpgradeStatus = "Current"
            }
            Write-Output $item
        } #continue processing
    }
    End
    {
        if ( $continueProcessing -eq $true )
        {
        }
    }
}

function Get-PspPowershellProjectBackupData
{
<#
.Synopsis
   Gets the BACKUP Data from a .psproj file.
.DESCRIPTION
   Returns a hash table of backup data.

.EXAMPLE
PS> $backupData = Get-PspPowershellProjectBackupData -ProjectFile ISEPSProject.psproj
PS> $backupData
Name                           Value                                                                                                                                             
----                           -----                                                                                                                                             
2017-08-29_112937              {<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">,   <Obj ...
2017-08-29_112834              {<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">,   <Obj ...
2017-08-29_113448              {<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">,   <Obj ...
2017-08-28_141817              {<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">,   <Obj ...
2017-08-29_113355              {<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">,   <Obj ...
2017-08-29_112646              {<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">,   <Obj ...
2017-08-29_080326              {<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">,   <Obj ...
2017-08-28_141113              {<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">,   <Obj ...
2017-08-28_144227              {<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">,   <Obj ...

#>
    [CmdletBinding()]
    Param
    (
        # Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]
        $ProjectFile = (Get-PspPowershellProjectDefaultProjectFile)
        ,
        # Switch to return ALL backups, instead of the previous 9.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [switch]
        $AllBackups
    )

    Begin
    {
        $continueProcessing = $true
        if ( $ProjectFile -ne "" ) 
        {            
            if ( -not ( Test-Path $ProjectFile ) ) 
            {
                Write-Warning "Cannot locate the specified ProjectFile"
                $continueProcessing = $false
            }        
        } else {
            Write-Warning "Must specify the -ProjectFile, or use Set-PspPowershellProjectDefaults command to set a default ProjectFile"
            $continueProcessing = $false
        }
    }
    Process
    {
        if ( $continueProcessing -eq $true )
        {
            $bakProjectData = Get-Content -Path $ProjectFile

            $backupList =  Get-Item -Path $ProjectFile -Stream * | Where-Object { $_.Stream -ne ':$DATA' }  | Sort-Object -Property Stream -Descending
            if ( $backupList )
            {
                if ( $backupList.Count -gt 8 ) 
                {
                    if ( $AllBackups -eq $true )
                    {
                        $backupCount = ($backupList.Count)-1
                    } else {
                        $backupCount = 8 
                    }
                } else {
                    $backupCount = ($backupList.Count)-1 
                }
                $backupData = @{}
                for ( $x = 0; $x -le $backupCount; $x++ )
                {
                    $backData = Get-Content -Path $ProjectFile -Stream $backupList[$x].Stream
                    $backupData.Add($backupList[$x].Stream, $backData)
                }
            }
            Write-Output $backupData
        } #continue processing
    }
    End
    {
        if ( $continueProcessing -eq $true )
        {
        }
    }
}

function Save-PspPowershellProject
{
<#
.Synopsis
   Save a .psproj file.
.DESCRIPTION
   This process saves, and optionally stores backups within the NTFS streams of the file.

.EXAMPLE
PS> $projectData = Get-PspPowershellProject -ProjectFile ISEPSProject.psproj 
PS> Save-PspPowershellProject -ProjectFile ISEPSProject.psproj -ProjectData $projectData

#>
    [CmdletBinding()]
    Param
    (
        # Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]
        $ProjectFile = (Get-PspPowershellProjectDefaultProjectFile)
        ,
        #backup data gathered from the Get-PspPowershellProjectBackupData command.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [Hashtable]
        $ProjectData
        ,
        #Skip backing up the current file data, just write the $ProjectData values.
        [Parameter(Mandatory=$false,
                   Position=2)]
        [switch]
        $SkipBackup = $false
    )

    Begin
    {
        $continueProcessing = $true
        if ( $ProjectFile -ne "" ) 
        {            
            if ( -not ( Test-Path $ProjectFile ) ) 
            {
                Write-Warning "Cannot locate the specified ProjectFile"
                $continueProcessing = $false
            }        
        } else {
            Write-Warning "Must specify the -ProjectFile, or use Set-PspPowershellProjectDefaults command to set a default ProjectFile"
            $continueProcessing = $false
        }
    }
    Process
    {
        if ( $continueProcessing -eq $true )
        {
            if ( $SkipBackup -eq $false )
            {
                $bakProjectData = Get-Content -Path $ProjectFile
                $backupData = Get-PspPowershellProjectBackupData $ProjectFile
            } else {
                $backupData = Get-PspPowershellProjectBackupData $ProjectFile -AllBackups
            }

            $projectData | Export-Clixml -Path $ProjectFile -Force

            if ( $SkipBackup -eq $false )
            {
                $backupName = (Get-Date).ToString('yyyy-MM-dd_HHmmss')
                Add-Content -Path $ProjectFile -Value $bakProjectData -Stream $backupName

                foreach ( $key in $backupData.Keys )
                {
                    Add-Content -Path $ProjectFile -Value $backupData.Get_Item($key) -Stream $key
                }
            } else {
                foreach ( $key in $backupData.Keys )
                {
                    Add-Content -Path $ProjectFile -Value $backupData.Get_Item($key) -Stream $key
                }
            }
        } #continue processing
    }
    End
    {
        if ( $continueProcessing -eq $true )
        {
        }
    }
}

function Save-PspPowershellProjectDefaults
{
<#
.Synopsis
   Save a .psproj\defaults.clixml file.  This will allow you to skip the -ProjectFile parameter and sets the default IncludeInBuild option for adding items to the project.
.DESCRIPTION
   This is simply a file that will be read by each of the commands in order to pre-populate the -ProjectFile and -IncludeInBuild parameters.

.EXAMPLE
PS> $default = "" | Select-Object ProjectFile,IncludeInBuild
PS> $defualt.ProjectFile = ".\ISEPSProject.psproj"
PS> $default.IncludeInBuild = $true
PS> Save-PspPowershellProjectDefaults -DefaultData $default
#>
    [CmdletBinding()]
    Param
    (
        # Default data in the form of $default = "" | Select-Object ProjectFile,IncludeInBuild
        [Parameter(Mandatory=$true,
                   Position=0)]
        [PSObject]
        $DefaultData
    )

    Begin
    {        
    }
    Process
    {
        $DefaultData | Export-Clixml -Path ".\.psproj\defaults.clixml" -Force
    }
    End
    {
    }
}

function Get-PspPowershellProjectDefaultProjectFile
{
<#
.Synopsis
   Extract the ProjectFile default from .psproj\defaults.clixml file.
.DESCRIPTION
   Called by the commands to fetch the default value for ProjectFile.

.EXAMPLE
For Use in [Parameters]
   $ProjectFile = (Get-PspPowershellProjectDefaultProjectFile)
#>
    [CmdletBinding()]
    Param
    (       
    )

    Begin
    {        
    }
    Process
    {
        if ( Test-Path ".\.psproj\defaults.clixml" ) 
        {
            $defaults = Import-Clixml -Path ".\.psproj\defaults.clixml"
            if ( Test-Path $defaults.ProjectFile ) 
            {
                Write-Output $defaults.ProjectFile
            } else {
                Write-Output ""
            }
        } else {
            Write-Output ""
        }
    }
    End
    {
    }
}

function Get-PspPowershellProjectFunctions
{
<#
.Synopsis
   Gets a list of the commands (function) inside of the source files contained in the .psproj file.
.DESCRIPTION
   Generate a list of commands (function) with their containing source file information.

.EXAMPLE
PS> Get-PspPowershellProjectFunctions -ProjectFile .\ISEPSProject.psproj | Sort-Object -Property SourceFile,FunctionName

FunctionName                               SourceFile                            
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

.EXAMPLE
PS> Get-PspPowershellProjectFunctions -ProjectFile .\ISEPSProject.psproj -IncludedInBuildOnly | Sort-Object -Property SourceFile,FunctionName

FunctionName                               SourceFile                            
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

#>
    [CmdletBinding()]
    Param
    (
        # Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]
        $ProjectFile = (Get-PspPowershellProjectDefaultProjectFile)
        ,
        # Switch to only include those source files that have the IncludeInBuild flag set.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [switch]
        $IncludedInBuildOnly = $false
    )

    Begin
    {
        $functionList = @()
        $continueProcessing = $true
        if ( $ProjectFile -ne "" ) 
        {            
            if ( -not ( Test-Path $ProjectFile ) ) 
            {
                Write-Warning "Cannot locate the specified ProjectFile"
                $continueProcessing = $false
            }        
        } else {
            Write-Warning "Must specify the -ProjectFile, or use Set-PspPowershellProjectDefaults command to set a default ProjectFile"
            $continueProcessing = $false
        }
    }
    Process
    {
        if ( $continueProcessing -eq $true ) 
        {
            $projectData = Import-Clixml -Path $ProjectFile
            if ( $ProjectFile.StartsWith(".\") )
            {
                $projectFileKey = $ProjectFile.SubString(2)
            }        
            if ( $projectData.ContainsKey($projectFileKey) )
            {
                $projectData.Remove($projectFileKey)
            }
            if ( $projectData.ContainsKey("ISEPSProjectDataVersion") )
            {
                $projectData.Remove("ISEPSProjectDataVersion")
            }

            if ( $IncludedInBuildOnly -eq $true ) 
            {
                $includedSources = ($projectData.Values | Where-Object { $_.IncludeInBuild -eq $true } | Select-Object -Property FileName | Sort-Object -Property FileName).FileName
            } else {
                $includedSources = ($projectData.Values | Select-Object -Property FileName | Sort-Object -Property FileName).FileName
            }

            foreach ( $key in $includedSources )
            {
                $content = Get-Content -Path $key
                foreach ( $line in $content )
                {
                    if ( $line.Trim().StartsWith("function") )
                    {
                        $item = "" | Select-Object FunctionName,SourceFile
                        $item.FunctionName = $line.Trim().Split(" ")[1]
                        $item.SourceFile = $key
                        $functionList += $item
                    }
                }
            }
            Write-Output $functionList
        } #continue processing
   }
    End
    {
        if ( $continueProcessing -eq $true )
        {
        }
    }
}

function Get-PspPowershellProjectDefaultIncludeInBuild
{
<#
.Synopsis
   Extract the IncludeInBuild default from .psproj\defaults.clixml file.
.DESCRIPTION
   Called by the commands to fetch the default value for IncludeInBuild.

.EXAMPLE
For Use in [Parameters]
   $IncludeInBuild = (Get-PspPowershellProjectDefaultIncludeInBuild)
#>
    [CmdletBinding()]
    Param
    (    
    )

    Begin
    {        
    }
    Process
    {
        if ( Test-Path ".\.psproj\defaults.clixml" ) 
        {
            $defaults = Import-Clixml -Path ".\.psproj\defaults.clixml"
            Write-Output $defaults.IncludeInBuild
        } else {
            Write-Output $false
        }
    }
    End
    {
    }
}

function Get-PspCSVFromStringArray
{
<#
.Synopsis
   Given a [string[]] array, convert it to a CSV formatted string.
.DESCRIPTION
   Used by the Start-PspBuildPowershellProject command to output the FunctionsToExport = line for inclusion in the psd1 file.

.EXAMPLE
PS> $functionInfo = (Get-PspPowershellProjectFunctions -ProjectFile .\ISEPSProject.psproj -IncludedInBuildOnly | Sort-Object -Property SourceFile,FunctionName).FunctionName
PS> Get-PspCSVFromStringArray -StringArray $functionInfo -SingleQuotes
'Add-PspSourceToPowershellProject','Start-PspBuildPowershellProject','Repair-PspPowershellProject','Close-PspPowershellProject','New-PspPowershellProject','Get-PspPowershellProject','Open-PowershellP
roject','Remove-PspSourceFromPowershellProject','Set-PspIncludeInBuildFlagForSource','Set-PspPowershellProjectDefaults','Get-PspCSVFromStringArray','Get-PspPowershellProjectBackupData','Get-Pow
ershellProjectCurrentVersion','Get-PspPowershellProjectDefaultIncludeInBuild','Get-PspPowershellProjectDefaultProjectFile','Get-PspPowershellProjectFunctions','Get-PspPowershellProjectVersio
n','Save-PspPowershellProject','Save-PspPowershellProjectDefaults','Update-PspPowershellProjectVersion'
#>
    [CmdletBinding()]
    Param
    (
        # String Array to convert to CSV Line
        [Parameter(Mandatory=$false,
                   Position=0)]
        [string[]]
        $StringArray
        ,
        # Add single quotes around each element
        [Parameter(Mandatory=$false,
                   Position=1)]
        [switch]
        $SingleQuotes
    )

    Begin
    {   
        $csvLine = ""
    }
    Process
    {
        foreach ( $string in $StringArray )
        {
            if ( $SingleQuotes -eq $true )
            {
                $csvLine += "'$($string)',"
            } else {
                $csvLine += "$($string),"
            }
        }
    }
    End
    {
        $csvLine = $csvLine.Substring(0, $csvLine.Length-1)        
        Write-Output $csvLine
    }
}

function Get-PspISETabNameFromPath_Old
{
<#
.Synopsis
    Given an ISEProject item, extract the TAB name from the Path.   
.DESCRIPTION
   
.EXAMPLE
    
#>
    [CmdletBinding()]
    Param
    (
        # File Item from .psproj file.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [string]
        $ProjectFileItem
        ,
        # Specify the project file to open.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]
        $ProjectFile = (Get-PspPowershellProjectDefaultProjectFile)
    )

    Begin
    {        
    }
    Process
    {
        if ( Test-Path $ProjectFile )
        {
            if ( Test-Path $ProjectFileItem )
            {
                $rootPath = (Get-ChildItem ($ProjectFile)).Directory.FullName        
                $fileFullPath = (Get-ChildItem "$($rootPath)$($ProjectFileItem)").Directory.FullName
                $tabName = $fileFullPath.Substring($rootPath.Length+1)       
                Write-Output $tabName
            } else {
                Write-Output ""
            }
        } else {
            Write-Output ""
        }
    }
    End
    {
    }
}

Function Get-PspPowershellProjectFilesNotIncludedInProject
{
<#
.Synopsis
    Display the files in the PROJECT directory that haven't been added as a source.   
.DESCRIPTION
   
.EXAMPLE
    
#>
    $projectFiles = @{}

    $psFiles = Get-ChildItem -Filter *.ps1 -Recurse
    $pspKeys = Get-PspPowershellProjectKeys | Sort-Object
    foreach ( $p in $pspKeys )
    {
        $f = Get-ChildItem $p
        $projectFiles.Add($f.FullName,$p)
    }
    
    foreach ( $p in $psFiles ) 
    { 
        if ( -not ( $p.FullName.Contains("\bin\") ) )
        {
            #Write-Verbose $p.FullName -Verbose
            #Write-Verbose $projectFiles.ContainsKey($p.FullName) -Verbose
            if ( -Not ( $projectFiles.ContainsKey($p.FullName) ) ) 
            {
                Write-Output "Missing: $($p.FullName)" 
            }
        }
    }
}