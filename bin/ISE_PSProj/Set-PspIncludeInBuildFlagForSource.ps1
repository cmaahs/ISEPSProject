Function Set-PspIncludeInBuildFlagForSource
{
<#
.Synopsis
    Set the IncludeInBuild flag for a source file.
.DESCRIPTION
    Each source item in the .psproj file contains a flag named IncludeInBuild.  This flag drives the inclusion of the source file in the Start-PspBuildPowershellProject command.
.EXAMPLE
    (Get-PspPowershellProject)["Open-PspPowershellProject.ps1"]

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

.EXAMPLE
    Set-PspIncludeInBuildFlagForSource -ProjectFile .\ISEPSProject.psproj -SourceFile Open-PspPowershellProject.ps1 -Include

1 source file(s) have been updated in the project
0 source file(s) were not found in the project

    (Get-PspPowershellProject)["Open-PspPowershellProject.ps1"]

FileName                   ProjectTab IncludeInBuild
--------                   ---------- --------------
Open-PspPowershellProject.ps1 ISE PSProj           True

.EXAMPLE 
    $projectData = Get-PspPowershellProject -ProjectFile .\ISEPSProject.psproj
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

.EXAMPLE
    $projectData = Get-PspPowershellProject -ProjectFile .\ISEPSProject.psproj
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

#>
    [CmdletBinding()]
    Param
    (
        # Specify the source file name to add to the project.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]        
        [string[]]
        $Name
        ,
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]        
        [string[]]
        $Directory
        ,
        # Specify the project file to open.  Default project can be specified via the Set-PspPowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [Alias('File','FilePath')]
        #[ValidateScript({ Test-Path $_ })]
        [string]       
        $ProjectFile = (Get-PspPowershellProjectDefaultProjectFile)
        ,
        # Specify the source file name to add to the project.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [Alias('Source','SourcePath')]
        [ValidateScript({ Test-Path $_ })]
        [string[]]
        $SourceFile
        ,
        # Use this switch to EXCLUDE the source file from the build process, -Include overrides -Exclude.
        [Parameter(Mandatory=$false,
                   Position=2)]
        [switch]
        $Exclude
        ,
        # Use this switch to INCLUDE the source file in the build process, -Include overrides -Exclude.
        # -Include is the default operation.
        [Parameter(Mandatory=$false,
                   Position=3)]
        [switch]
        $Include
    )

    Begin
    {           
        $continueProcessing = $true
        $m_SourceFileList = @()
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
        if ( ( $Exclude -eq $true ) -and ( $Include -eq $true ) )
        {
            $Exclude = $false            
        }   
        if ( ( $Exclude -eq $false ) -and ( $Include -eq $false ) ) 
        {
            $Include = $true
        }
    }
    Process
    {
        if ( $continueProcessing -eq $true )
        {
            if ( $SourceFile.Length -gt 0 )
            {
                $addFile = $SourceFile
            }
            if ( ( $Name.Length -gt 0 ) -and ( $Directory.Length -gt 0 ) )
            {
                Write-Verbose "File: $($Name)"
                Write-Verbose "Path: $($Directory)"
                Write-Verbose "FullName: $($Directory)\$($Name)"
                $addFile = Get-PspRelativePathFromProjectRoot -FullName "$($Directory)\$($Name)"
            }
            Write-Verbose "Adding $($addFile)"
            if ( $addFile.Length -gt 0 )
            {
                $m_SourceFileList += $addFile
            }
        } #continue processing
    }
    End
    {
        if ( $continueProcessing -eq $true ) 
        {
            if ( (Get-PspPowershellProjectVersion -ProjectFile $ProjectFile).IsLatest -eq $false )
            {
                Update-PspPowershellProjectVersion -ProjectFile $ProjectFile
            }

            if ( (Get-PspPowershellProjectVersion -ProjectFile $ProjectFile).IsLatest -eq $true )
            {                
                # version 1.3 and later.
                $projectData = Get-PspProjectData # Import-Clixml -Path $ProjectFile

                $updatedItems = 0
                $notFoundItems = 0  
                $keyToUpdate = @()      
                foreach ($item_SourceFile in $m_SourceFileList)
                {
                    if ( $item_SourceFile.StartsWith(".\") )
                    {
                        $item_SourceFile = $item_SourceFile.SubString(2)
                    }        
           
                    if ( $projectData.ContainsKey($item_SourceFile) )
                    {
                        $keyToUpdate += $item_SourceFile
                    } else {
                        $notFoundItems++
                    }
                }
                $controlDirectory = Get-PspControlDirectory
                foreach ( $item_keyToUpdate in $keyToUpdate )
                {
                    $item = $projectData[$item_keyToUpdate]
                    if ( $Include -eq $true ) 
                    {
                        $item.IncludeInBuild = $true
                    }
                    if ( $Exclude -eq $true ) 
                    {
                        $item.IncludeInBuild = $false
                    }
                    $projectData[$item_keyToUpdate] = $item
                    Write-Verbose "Updating key: $($item_keyToUpdate)"
                    $ProjectData[$item_keyToUpdate] | ConvertTo-Json | Out-File -FilePath "$($controlDirectory)\.psproj\files\$($item_keyToUpdate).json" -Encoding ascii
                    $updatedItems++
                }

            } else {
                # versions pre 1.3
                $projectData = Import-Clixml -Path $ProjectFile

                $updatedItems = 0
                $notFoundItems = 0  
                $keyToUpdate = @()      
                foreach ($item_SourceFile in $m_SourceFileList)
                {
                    if ( $item_SourceFile.StartsWith(".\") )
                    {
                        $item_SourceFile = $item_SourceFile.SubString(2)
                    }        
           
                    if ( $projectData.ContainsKey($item_SourceFile) )
                    {
                        $keyToUpdate += $item_SourceFile
                    } else {
                        $notFoundItems++
                    }
                }
                foreach ( $item_keyToUpdate in $keyToUpdate )
                {
                    $item = $projectData[$item_keyToUpdate]
                    if ( $Include -eq $true ) 
                    {
                        $item.IncludeInBuild = $true
                    }
                    if ( $Exclude -eq $true ) 
                    {
                        $item.IncludeInBuild = $false
                    }
                    $projectData[$item_keyToUpdate] = $item
                    $updatedItems++
                }
                Save-PspPowershellProject -ProjectFile $ProjectFile -ProjectData $projectData
            } # end version 1.3 check
                    
            Write-Output "$($updatedItems) source file(s) have been updated in the project"
            Write-Output "$($notFoundItems) source file(s) were not found in the project"

        } #continue processing
    }
}

