<#
.Synopsis
    Set the IncludeInBuild flag for a source file.
.DESCRIPTION
    Each source item in the .psproj file contains a flag named IncludeInBuild.  This flag drives the inclusion of the source file in the Build-PowershellProject command.
.EXAMPLE
PS> (Get-PowershellProject)["Open-PowershellProject.ps1"]

FileName                   ProjectTab IncludeInBuild
--------                   ---------- --------------
Open-PowershellProject.ps1 ISE PSProj           True

PS> Set-IncludeInBuildFlagForSource -ProjectFile .\ISEPSProject.psproj -SourceFile Open-PowershellProject.ps1 -Exclude
1 source file(s) have been updated in the project
0 source file(s) were not found in the project

PS> (Get-PowershellProject)["Open-PowershellProject.ps1"]

FileName                   ProjectTab IncludeInBuild
--------                   ---------- --------------
Open-PowershellProject.ps1 ISE PSProj          False

.EXAMPLE
PS> Set-IncludeInBuildFlagForSource -ProjectFile .\ISEPSProject.psproj -SourceFile Open-PowershellProject.ps1 -Include
1 source file(s) have been updated in the project
0 source file(s) were not found in the project

PS> (Get-PowershellProject)["Open-PowershellProject.ps1"]

FileName                   ProjectTab IncludeInBuild
--------                   ---------- --------------
Open-PowershellProject.ps1 ISE PSProj           True

.EXAMPLE 
PS> $projectData = Get-PowershellProject -ProjectFile .\ISEPSProject.psproj
PS> Set-IncludeInBuildFlagForSource -ProjectFile .\ISEPSProject.psproj -SourceFile $projectData.Keys -Exclude
13 source file(s) have been updated in the project
0 source file(s) were not found in the project

PS> (Get-PowershellProject).Values | Format-Table -AutoSize

FileName                               ProjectTab        IncludeInBuild
--------                               ----------        --------------
Remove-SourceFromPowershellProject.ps1 ISE PSProj                 False
Build-PowershellProject.ps1            ISE PSProj                 False
Close-PowershellProject.ps1            ISE PSProj                 False
Clean-PowershellProject.ps1            ISE PSProj                 False
Set-IncludeInBuildFlagForSource.ps1    ISE PSProj                 False
Open-PowershellProject.ps1             ISE PSProj                 False
Get-PowershellProjectBackup.ps1        ISE PSProj Backup          False
UtilityFunctions.ps1                   ISE PSProj                 False
Compare-PowershellProjectBackup.ps1    ISE PSProj Backup          False
Set-PowershellProjectDefaults.ps1      ISE PSProj                 False
Get-PowershellProject.ps1              ISE PSProj                 False
Add-SourceToPowershellProject.ps1      ISE PSProj                 False
Create-PowershellProject.ps1           ISE PSProj                 False

.EXAMPLE
PS> $projectData = Get-PowershellProject -ProjectFile .\ISEPSProject.psproj
PS> $singleTab = $projectData.GetEnumerator() | Where-Object { $_.Value.ProjectTab -eq "ISE PSProj" }
PS> Set-IncludeInBuildFlagForSource -ProjectFile .\ISEPSProject.psproj -SourceFile $singleTab.Key -Include
11 source file(s) have been updated in the project
0 source file(s) were not found in the project

PS> (Get-PowershellProject).Values | Format-Table -AutoSize

FileName                               ProjectTab        IncludeInBuild
--------                               ----------        --------------
Remove-SourceFromPowershellProject.ps1 ISE PSProj                  True
Build-PowershellProject.ps1            ISE PSProj                  True
Close-PowershellProject.ps1            ISE PSProj                  True
Clean-PowershellProject.ps1            ISE PSProj                  True
Set-IncludeInBuildFlagForSource.ps1    ISE PSProj                  True
Open-PowershellProject.ps1             ISE PSProj                  True
Get-PowershellProjectBackup.ps1        ISE PSProj Backup          False
UtilityFunctions.ps1                   ISE PSProj                  True
Compare-PowershellProjectBackup.ps1    ISE PSProj Backup          False
Set-PowershellProjectDefaults.ps1      ISE PSProj                  True
Get-PowershellProject.ps1              ISE PSProj                  True
Add-SourceToPowershellProject.ps1      ISE PSProj                  True
Create-PowershellProject.ps1           ISE PSProj                  True

#>
Function Set-IncludeInBuildFlagForSource
{
    [CmdletBinding()]
    Param
    (
        <#PINC:ProjectFile#>
        ,
        <#PINC:SourceFile#>
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
            if ( (Get-PowershellProjectVersion -ProjectFile $ProjectFile).IsLatest -eq $false )
            {
                Update-PowershellProjectVersion -ProjectFile $ProjectFile
            }
            $projectData = Import-Clixml -Path $ProjectFile

            $updatedItems = 0
            $notFoundItems = 0  
            $keyToUpdate = @()      
            foreach ($item_SourceFile in $SourceFile)
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

            Save-PowershellProject -ProjectFile $ProjectFile -ProjectData $projectData
        
            Write-Output "$($updatedItems) source file(s) have been updated in the project"
            Write-Output "$($notFoundItems) source file(s) were not found in the project"
        } #continue processing
    }
    End
    {
        if ( $continueProcessing -eq $true ) 
        {
        }
    }
}