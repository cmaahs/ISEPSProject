<#
.Synopsis
   Remove source files from the .psproj file.
.DESCRIPTION
   This process will remove specified files from the project file, and create a backup in the -streams section of the file.
   10 backups will be kept and can be listed with Get-PowershellProjectBackup function.
.EXAMPLE
PS> Get-PowershellProject -ProjectFile .\ISEPSProject.psproj

Name                                   Value                                                                                              
----                                   -----                                                                                              
Remove-SourceFromPowershellProject.ps1 @{FileName=Remove-SourceFromPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}
Clean-PowershellProject.ps1            @{FileName=Clean-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}
Open-PowershellProject.ps1             @{FileName=Open-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}
Get-PowershellProjectBackup.ps1        @{FileName=Get-PowershellProjectBackup.ps1; ProjectTab=ISE PSProj; IncludeInBuild=False}
Compare-PowershellProjectBackup.ps1    @{FileName=Compare-PowershellProjectBackup.ps1; ProjectTab=ISE PSProj Backup; IncludeInBuild=False}
Get-PowershellProject.ps1              @{FileName=Get-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}
Add-SourceToPowershellProject.ps1      @{FileName=Add-SourceToPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}
Create-PowershellProject.ps1           @{FileName=Create-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}


PS> Remove-SourceFromPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile .\Add-SourceToPowershellProject.ps1 
1 source file(s) have been removed from the project

.EXAMPLE
PS> Get-PowershellProject .\ISEPSProject.psproj

Name                                   Value                                                                                              
----                                   -----                                                                                              
Remove-SourceFromPowershellProject.ps1 @{FileName=Remove-SourceFromPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}     
Clean-PowershellProject.ps1            @{FileName=Clean-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                
Open-PowershellProject.ps1             @{FileName=Open-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                 
Get-PowershellProjectBackup.ps1        @{FileName=Get-PowershellProjectBackup.ps1; ProjectTab=ISE PSProj; IncludeInBuild=False}   
Compare-PowershellProjectBackup.ps1    @{FileName=Compare-PowershellProjectBackup.ps1; ProjectTab=ISE PSProj Backup; IncludeInBuild=False} 
Get-PowershellProject.ps1              @{FileName=Get-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                  
Create-PowershellProject.ps1           @{FileName=Create-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}               


PS> Remove-SourceFromPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile .\Clean-PowershellProject.ps1,.\Compare-PowershellProjectBackup.ps1
2 source file(s) have been removed from the project
.EXAMPLE
PS> Get-PowershellProject .\ISEPSProject.psproj

Name                                   Value                                                                                              
----                                   -----                                                                                              
Remove-SourceFromPowershellProject.ps1 @{FileName=Remove-SourceFromPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}     
Open-PowershellProject.ps1             @{FileName=Open-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                 
Get-PowershellProjectBackup.ps1        @{FileName=Get-PowershellProjectBackup.ps1; ProjectTab=ISE PSProj; IncludeInBuild=False}    
Get-PowershellProject.ps1              @{FileName=Get-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                  
Create-PowershellProject.ps1           @{FileName=Create-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}               

PS> Remove-SourceFromPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile (Get-ChildItem -Filter *.ps1).Name 
5 source file(s) have been removed from the project
3 source file(s) were not found in the project
#>
Function Remove-SourceFromPowershellProject
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
        # Specify the source file name to add to the project.
        [Parameter(Mandatory=$true,
                   Position=1)]
        [Alias('Source','SourcePath')]
        [ValidateScript({ Test-Path $_ })]
        [string[]]
        $SourceFile
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
            if ( (Get-PowershellProjectVersion -ProjectFile $ProjectFile).IsLatest -eq $false )
            {
                Update-PowershellProjectVersion -ProjectFile $ProjectFile
            }
            $projectData = Import-Clixml -Path $ProjectFile

            $removedItems = 0
            $notFoundItems = 0
            $keyToRemove = @()
            foreach ($item_SourceFile in $SourceFile)
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

            Save-PowershellProject -ProjectFile $ProjectFile -ProjectData $projectData
        
            Write-Output "$($removedItems) source file(s) have been removed from the project"
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

