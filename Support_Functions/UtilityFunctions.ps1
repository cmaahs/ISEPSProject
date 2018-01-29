<#
.Synopsis
   Returns the most current version of .psproj files.
.DESCRIPTION
   Returns the lastest version of the .psproj files supported by the code.

.EXAMPLE
   Get-PowershellProjectCurrentVersion
#>
function Get-PowershellProjectCurrentVersion
{
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

<#
.Synopsis
   Get the .psproj data version
.DESCRIPTION
   Returns the version of the .psproj data

.EXAMPLE
PS> Get-PowershellProjectVersion -ProjectFile ISEPSProject.psproj

Version CurrentVersion IsLatest
------- -------------- --------
1.1     1.1                True

#>
function Get-PowershellProjectVersion
{
    [CmdletBinding()]
    Param
    (
        # Specify the project file to open.  Default project can be specified via the Set-PowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]
        $ProjectFile = (Get-PowershellProjectDefaultProjectFile)
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
            Write-Warning "Must specify the -ProjectFile, or use Set-PowershellProjectDefaults command to set a default ProjectFile"
            $continueProcessing = $false
        }
    }
    Process
    {
        if ( $continueProcessing -eq $true )
        {
            $projectData = Import-Clixml -Path $ProjectFile
            $item = "" | Select-Object Version,CurrentVersion,IsLatest
            $item.CurrentVersion = (Get-PowershellProjectCurrentVersion).CurrentVersion
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
<#
.Synopsis
   Process to upgrade from a previous version to current.
.DESCRIPTION
   When the existing .psproj file is not at the current version, calling this command will upgrade all previous version to the current version.

.EXAMPLE
PS> Update-PowershellProjectVersion -ProjectFile ISEPSProject.psproj

UpgradeNeeded UpgradeStatus    
------------- -------------    
         True Updated to latest

#>
function Update-PowershellProjectVersion
{
    [CmdletBinding()]
    Param
    (
        # Specify the project file to open.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]
        $ProjectFile = (Get-PowershellProjectDefaultProjectFile)
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
            Write-Warning "Must specify the -ProjectFile, or use Set-PowershellProjectDefaults command to set a default ProjectFile"
            $continueProcessing = $false
        }
    }
    Process
    {
        if ( $continueProcessing -eq $true )
        {
            $projectData = Import-Clixml -Path $ProjectFile

            $dataVersion = Get-PowershellProjectVersion -ProjectFile $ProjectFile
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
<#
.Synopsis
   Gets the BACKUP Data from a .psproj file.
.DESCRIPTION
   Returns a hash table of backup data.

.EXAMPLE
PS> $backupData = Get-PowershellProjectBackupData -ProjectFile ISEPSProject.psproj
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
function Get-PowershellProjectBackupData
{
    [CmdletBinding()]
    Param
    (
        # Specify the project file to open.  Default project can be specified via the Set-PowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]
        $ProjectFile = (Get-PowershellProjectDefaultProjectFile)
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
            Write-Warning "Must specify the -ProjectFile, or use Set-PowershellProjectDefaults command to set a default ProjectFile"
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
<#
.Synopsis
   Save a .psproj file.
.DESCRIPTION
   This process saves, and optionally stores backups within the NTFS streams of the file.

.EXAMPLE
PS> $projectData = Get-PowershellProject -ProjectFile ISEPSProject.psproj 
PS> Save-PowershellProject -ProjectFile ISEPSProject.psproj -ProjectData $projectData

#>
function Save-PowershellProject
{
    [CmdletBinding()]
    Param
    (
        # Specify the project file to open.  Default project can be specified via the Set-PowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]
        $ProjectFile = (Get-PowershellProjectDefaultProjectFile)
        ,
        #backup data gathered from the Get-PowershellProjectBackupData command.
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
            Write-Warning "Must specify the -ProjectFile, or use Set-PowershellProjectDefaults command to set a default ProjectFile"
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
                $backupData = Get-PowershellProjectBackupData $ProjectFile
            } else {
                $backupData = Get-PowershellProjectBackupData $ProjectFile -AllBackups
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
<#
.Synopsis
   Save a .psproj\defaults.clixml file.  This will allow you to skip the -ProjectFile parameter and sets the default IncludeInBuild option for adding items to the project.
.DESCRIPTION
   This is simply a file that will be read by each of the commands in order to pre-populate the -ProjectFile and -IncludeInBuild parameters.

.EXAMPLE
PS> $default = "" | Select-Object ProjectFile,IncludeInBuild
PS> $defualt.ProjectFile = ".\ISEPSProject.psproj"
PS> $default.IncludeInBuild = $true
PS> Save-PowershellProjectDefaults -DefaultData $default
#>
function Save-PowershellProjectDefaults
{
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
<#
.Synopsis
   Extract the ProjectFile default from .psproj\defaults.clixml file.
.DESCRIPTION
   Called by the commands to fetch the default value for ProjectFile.

.EXAMPLE
For Use in [Parameters]
   $ProjectFile = (Get-PowershellProjectDefaultProjectFile)
#>
function Get-PowershellProjectDefaultProjectFile
{
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
<#
.Synopsis
   Gets a list of the commands (function) inside of the source files contained in the .psproj file.
.DESCRIPTION
   Generate a list of commands (function) with their containing source file information.

.EXAMPLE
PS> Get-PowershellProjectFunctions -ProjectFile .\ISEPSProject.psproj | Sort-Object -Property SourceFile,FunctionName

FunctionName                               SourceFile                            
------------                               ----------                            
Add-SourceToPowershellProject              Add-SourceToPowershellProject.ps1     
Build-PowershellProject                    Build-PowershellProject.ps1           
Clean-PowershellProject                    Clean-PowershellProject.ps1           
Close-PowershellProject                    Close-PowershellProject.ps1           
Compare-PowershellProjectBackup            Compare-PowershellProjectBackup.ps1   
Create-PowershellProject                   Create-PowershellProject.ps1          
Get-PowershellProject                      Get-PowershellProject.ps1             
Get-PowershellProjectBackup                Get-PowershellProjectBackup.ps1       
Open-PowershellProject                     Open-PowershellProject.ps1            
Remove-SourceFromPowershellProject         Remove-SourceFromPowershellProject.ps1
Set-IncludeInBuildFlagForSource            Set-IncludeInBuildFlagForSource.ps1   
Set-PowershellProjectDefaults              Set-PowershellProjectDefaults.ps1     
Get-CSVFromStringArray                     UtilityFunctions.ps1                  
Get-PowershellProjectBackupData            UtilityFunctions.ps1                  
Get-PowershellProjectCurrentVersion        UtilityFunctions.ps1                  
Get-PowershellProjectDefaultIncludeInBuild UtilityFunctions.ps1                  
Get-PowershellProjectDefaultProjectFile    UtilityFunctions.ps1                  
Get-PowershellProjectFunctions             UtilityFunctions.ps1                  
Get-PowershellProjectVersion               UtilityFunctions.ps1                  
Save-PowershellProject                     UtilityFunctions.ps1                  
Save-PowershellProjectDefaults             UtilityFunctions.ps1                  
Update-PowershellProjectVersion            UtilityFunctions.ps1               

.EXAMPLE
PS> Get-PowershellProjectFunctions -ProjectFile .\ISEPSProject.psproj -IncludedInBuildOnly | Sort-Object -Property SourceFile,FunctionName

FunctionName                               SourceFile                            
------------                               ----------                            
Add-SourceToPowershellProject              Add-SourceToPowershellProject.ps1     
Build-PowershellProject                    Build-PowershellProject.ps1           
Clean-PowershellProject                    Clean-PowershellProject.ps1           
Close-PowershellProject                    Close-PowershellProject.ps1           
Create-PowershellProject                   Create-PowershellProject.ps1          
Get-PowershellProject                      Get-PowershellProject.ps1             
Open-PowershellProject                     Open-PowershellProject.ps1            
Remove-SourceFromPowershellProject         Remove-SourceFromPowershellProject.ps1
Set-IncludeInBuildFlagForSource            Set-IncludeInBuildFlagForSource.ps1   
Set-PowershellProjectDefaults              Set-PowershellProjectDefaults.ps1     
Get-CSVFromStringArray                     UtilityFunctions.ps1                  
Get-PowershellProjectBackupData            UtilityFunctions.ps1                  
Get-PowershellProjectCurrentVersion        UtilityFunctions.ps1                  
Get-PowershellProjectDefaultIncludeInBuild UtilityFunctions.ps1                  
Get-PowershellProjectDefaultProjectFile    UtilityFunctions.ps1                  
Get-PowershellProjectFunctions             UtilityFunctions.ps1                  
Get-PowershellProjectVersion               UtilityFunctions.ps1                  
Save-PowershellProject                     UtilityFunctions.ps1                  
Save-PowershellProjectDefaults             UtilityFunctions.ps1                  
Update-PowershellProjectVersion            UtilityFunctions.ps1                  

#>
function Get-PowershellProjectFunctions
{
    [CmdletBinding()]
    Param
    (
        # Specify the project file to open.  Default project can be specified via the Set-PowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]
        $ProjectFile = (Get-PowershellProjectDefaultProjectFile)
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
            Write-Warning "Must specify the -ProjectFile, or use Set-PowershellProjectDefaults command to set a default ProjectFile"
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
<#
.Synopsis
   Extract the IncludeInBuild default from .psproj\defaults.clixml file.
.DESCRIPTION
   Called by the commands to fetch the default value for IncludeInBuild.

.EXAMPLE
For Use in [Parameters]
   $IncludeInBuild = (Get-PowershellProjectDefaultIncludeInBuild)
#>
function Get-PowershellProjectDefaultIncludeInBuild
{
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
<#
.Synopsis
   Given a [string[]] array, convert it to a CSV formatted string.
.DESCRIPTION
   Used by the Build-PowershellProject command to output the FunctionsToExport = line for inclusion in the psd1 file.

.EXAMPLE
PS> $functionInfo = (Get-PowershellProjectFunctions -ProjectFile .\ISEPSProject.psproj -IncludedInBuildOnly | Sort-Object -Property SourceFile,FunctionName).FunctionName
PS> Get-CSVFromStringArray -StringArray $functionInfo -SingleQuotes
'Add-SourceToPowershellProject','Build-PowershellProject','Clean-PowershellProject','Close-PowershellProject','Create-PowershellProject','Get-PowershellProject','Open-PowershellP
roject','Remove-SourceFromPowershellProject','Set-IncludeInBuildFlagForSource','Set-PowershellProjectDefaults','Get-CSVFromStringArray','Get-PowershellProjectBackupData','Get-Pow
ershellProjectCurrentVersion','Get-PowershellProjectDefaultIncludeInBuild','Get-PowershellProjectDefaultProjectFile','Get-PowershellProjectFunctions','Get-PowershellProjectVersio
n','Save-PowershellProject','Save-PowershellProjectDefaults','Update-PowershellProjectVersion'
#>
function Get-CSVFromStringArray
{
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
<#
.Synopsis
   Returns the most current version of .psproj files.
.DESCRIPTION
   Returns the lastest version of the .psproj files supported by the code.

.EXAMPLE
   Get-PowershellProjectCurrentVersion
#>
function Get-ISETabNameFromPath
{
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
        $ProjectFile = (Get-PowershellProjectDefaultProjectFile)
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
