Function Remove-PspSourceFromPowershellProject
{
<#
.Synopsis
   Remove source files from the .psproj file.
.DESCRIPTION
   This process will remove specified files from the project file, and create a backup in the -streams section of the file.
   10 backups will be kept and can be listed with Get-PspPowershellProjectBackup function.
.EXAMPLE
    Get-PspPowershellProject -ProjectFile .\ISEPSProject.psproj

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

.EXAMPLE
    Get-PspPowershellProject .\ISEPSProject.psproj

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
.EXAMPLE
    Get-PspPowershellProject .\ISEPSProject.psproj

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
#>
    [CmdletBinding()]
    Param
    (
        <#PINC:SourceFileWithPipeline#>
        <#PINC:PARAMCOMMA#>
        <#PINC:ProjectFile#>
        <#PINC:PARAMCOMMA#>
        <#PINC:SourceFile#>
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
                $projectData = Get-PspProjectData #Import-Clixml -Path $ProjectFile

                $removedItems = 0
                $notFoundItems = 0
                $keyToRemove = @()
                foreach ($item_SourceFile in $m_SourceFileList)
                {
                    if ( $item_SourceFile.StartsWith(".\") )
                    {
                        $item_SourceFile = $item_SourceFile.SubString(2)
                    }        
           
                    if ( $projectData.ContainsKey($item_SourceFile) )
                    {
                        $keyToRemove += $item_SourceFile
                    } else {
                        $notFoundItems++
                    }
                }
                $controlDirectory = Get-PspControlDirectory
                foreach ( $item_keyToRemove in $keyToRemove )
                {
                    $projectData.Remove($item_keyToRemove)                    
                    if ( $controlDirectory -ne "" )
                    {
                        Write-Verbose "Attempting to remove $($controlDirectory)\.psproj\files\$($item_keyToRemove).json"
                        $removedItem = Remove-Item -Path "$($controlDirectory)\.psproj\files\$($item_keyToRemove).json" 
                    }
                    $removedItems++
                }
            } else {
                # pre version 1.3
                $projectData = Import-Clixml -Path $ProjectFile

                $removedItems = 0
                $notFoundItems = 0
                $keyToRemove = @()
                foreach ($item_SourceFile in $m_SourceFileList)
                {
                    if ( $item_SourceFile.StartsWith(".\") )
                    {
                        $item_SourceFile = $item_SourceFile.SubString(2)
                    }        
           
                    if ( $projectData.ContainsKey($item_SourceFile) )
                    {
                        $keyToRemove += $item_SourceFile
                    } else {
                        $notFoundItems++
                    }
                }
                foreach ( $item_keyToRemove in $keyToRemove )
                {
                    $projectData.Remove($item_keyToRemove)
                    $removedItems++
                }
                Save-PspPowershellProject -ProjectFile $ProjectFile -ProjectData $projectData
            } # version 1.3 check
        
            Write-Output "$($removedItems) source file(s) have been removed from the project"
            Write-Output "$($notFoundItems) source file(s) were not found in the project"
        
        } #continue procesing
    }
}