<#
.Synopsis
   Add a source file to an existing .psproj file.
.DESCRIPTION
   Add a source file and corresponding TAB name to the .psproj file so it can be opened as a single project later.  A backup in the -streams section of the file will also be created.
   10 backups will be kept and can be listed with Get-PowershellProjectBackup function.
.EXAMPLE
PS> Get-ChildItem


    Directory: C:\Powershell\ISEPSProject


Mode                LastWriteTime         Length Name                                                                                                                                                                
----                -------------         ------ ----                                                                                                                                                                
-a----       12/28/2016   8:10 AM           2115 Add-SourceToPowershellProject.ps1                                                                                                                                   
-a----       12/27/2016   8:04 PM           1865 Clean-PowershellProject.ps1                                                                                                                                         
-a----       12/27/2016   7:46 PM           1715 Compare-PowershellProjectBackup.ps1                                                                                                                                 
-a----       12/28/2016   8:06 AM           5637 Create-PowershellProject.ps1                                                                                                                                        
-a----       12/28/2016   7:17 AM            691 Get-PowershellProject.ps1                                                                                                                                           
-a----       12/27/2016   7:45 PM            916 Get-PowershellProjectBackup.ps1                                                                                                                                     
-a----       12/28/2016   8:06 AM            718 ISEPSProject.psproj                                                                                                                                                 
-a----       12/28/2016   7:23 AM           2035 Open-PowershellProject.ps1                                                                                                                                          
-a----       12/28/2016   7:29 AM           2135 Remove-SourceFromPowershellProject.ps1                                                                                                                              



PS> Add-SourceToPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile .\Add-SourceToPowershellProject.ps1 -ProjectTab "ISE PSProj" -IncludeInBuild
1 file(s) have been added to the project
0 duplicate file(s) have been skipped
.EXAMPLE
PS> Get-ChildItem


    Directory: C:\Powershell\ISEPSProject


Mode                LastWriteTime         Length Name                                                                                                                                                                
----                -------------         ------ ----                                                                                                                                                                
-a----       12/28/2016   8:10 AM           2115 Add-SourceToPowershellProject.ps1                                                                                                                                   
-a----       12/27/2016   8:04 PM           1865 Clean-PowershellProject.ps1                                                                                                                                         
-a----       12/27/2016   7:46 PM           1715 Compare-PowershellProjectBackup.ps1                                                                                                                                 
-a----       12/28/2016   8:06 AM           5637 Create-PowershellProject.ps1                                                                                                                                        
-a----       12/28/2016   7:17 AM            691 Get-PowershellProject.ps1                                                                                                                                           
-a----       12/27/2016   7:45 PM            916 Get-PowershellProjectBackup.ps1                                                                                                                                     
-a----       12/28/2016   8:06 AM            718 ISEPSProject.psproj                                                                                                                                                 
-a----       12/28/2016   7:23 AM           2035 Open-PowershellProject.ps1                                                                                                                                          
-a----       12/28/2016   7:29 AM           2135 Remove-SourceFromPowershellProject.ps1                                                                                                                              



PS> Add-SourceToPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile .\Clean-PowershellProject.ps1,Compare-PowershellProjectBackup.ps1 -ProjectTab "ISE PSProj" -IncludeInBuild
2 file(s) have been added to the project
0 duplicate file(s) have been skipped
.EXAMPLE 
PS> Get-ChildItem


    Directory: C:\Powershell\ISEPSProject


Mode                LastWriteTime         Length Name                                                                                                                                                                
----                -------------         ------ ----                                                                                                                                                                
-a----       12/28/2016   8:26 AM           7895 Add-SourceToPowershellProject.ps1                                                                                                                                   
-a----       12/27/2016   8:04 PM           1865 Clean-PowershellProject.ps1                                                                                                                                         
-a----       12/27/2016   7:46 PM           1715 Compare-PowershellProjectBackup.ps1                                                                                                                                 
-a----       12/28/2016   8:06 AM           5637 Create-PowershellProject.ps1                                                                                                                                        
-a----       12/28/2016   8:29 AM            716 Get-PowershellProject.ps1                                                                                                                                           
-a----       12/27/2016   7:45 PM            916 Get-PowershellProjectBackup.ps1                                                                                                                                     
-a----       12/28/2016   8:28 AM           1482 ISEPSProject.psproj                                                                                                                                                 
-a----       12/28/2016   7:23 AM           2035 Open-PowershellProject.ps1                                                                                                                                          
-a----       12/28/2016   7:29 AM           2135 Remove-SourceFromPowershellProject.ps1                                                                                                                              



PS> Get-PowershellProject -ProjectFile .\ISEPSProject.psproj

Name                                   Value                                                                                              
----                                   -----                                                                                              
Clean-PowershellProject.ps1            @{FileName=Clean-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                
Compare-PowershellProjectBackup.ps1    @{FileName=Compare-PowershellProjectBackup.ps1; ProjectTab=ISE PSProj Backup; IncludeInBuild=False}
Add-SourceToPowershellProject.ps1      @{FileName=Add-SourceToPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}          
     

PS> Add-SourceToPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile (Get-ChildItem -Filter *.ps1).FullName -ProjectTab "ISE PSProj"
5 file(s) have been added to the project
3 duplicate file(s) have been skipped
.EXAMPLE
PS> Get-PowershellProject .\ISEPSProject.psproj

Name                                   Value                                                                                              
----                                   -----                                                                                              
Remove-SourceFromPowershellProject.ps1 @{FileName=Remove-SourceFromPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}     
Build-PowershellProject.ps1            @{FileName=Build-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                
Clean-PowershellProject.ps1            @{FileName=Clean-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                
Open-PowershellProject.ps1             @{FileName=Open-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                 
Get-PowershellProjectBackup.ps1        @{FileName=Get-PowershellProjectBackup.ps1; ProjectTab=ISE PSProj Backup; IncludeInBuild=False}    
Get-PowershellProject.ps1              @{FileName=Get-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}                  
Compare-PowershellProjectBackup.ps1    @{FileName=Compare-PowershellProjectBackup.ps1; ProjectTab=ISE PSProj; IncludeInBuild=False}
Add-SourceToPowershellProject.ps1      @{FileName=Add-SourceToPowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}          
Create-PowershellProject.ps1           @{FileName=Create-PowershellProject.ps1; ProjectTab=ISE PSProj; IncludeInBuild=True}               



PS> Add-SourceToPowershellProject -ProjectFile .\ISEPSProject.psproj -SourceFile .\Compare-PowershellProjectBackup.ps1 -ProjectTab "ISE PSProj Backup"
0 file(s) have been added to the project
0 duplicate file(s) have been skipped
1 source file(s) have had their TAB locations updated.
#>
Function Add-SourceToPowershellProject
{
    [CmdletBinding()]
    Param
    (
        <#PINC:ProjectFile#>
        ,
        <#PINC:SourceFile#>
        ,
        # Name of TAB to place the source file on when opening in ISE via the Open-PowershellProject command.
        [Parameter(Mandatory=$false,
                   Position=2)]
        [Alias('Tab','TabName')]
        [string]
        $ProjectTab = ""
        ,
        # Flag the source file for inclusion in a module build via Build-PowershellProject command.  Default can be set via Set-PowershellProjectDefaults command.
        [Parameter(Mandatory=$false,
                   Position=3)]
        [switch]
        $IncludeInBuild = (Get-PowershellProjectDefaultIncludeInBuild)
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
        } #continue processing
    }
    End
    {
        if ( $continueProcessing -eq $true ) 
        {
            $addCount = 0
            $duplicateCount = 0
            $updatedCount = 0
            $skippedCount = 0

            if ( (Get-PowershellProjectVersion -ProjectFile $ProjectFile).IsLatest -eq $false )
            {
                Update-PowershellProjectVersion -ProjectFile $ProjectFile
            }
            $projectData = Import-Clixml -Path $ProjectFile        

            foreach ( $item_SourceFile in $SourceFile )
            {                
                $okToAdd = $true
                if ( $ProjectTab -eq "" )
                {
                    $ProjectTab = Get-ISETabNameFromPath -ProjectFileItem $item_SourceFile -ProjectFile $ProjectFile
                    if ( $ProjectTab -eq "" )
                    {           
                        $okToAdd = $false      
                        Write-Warning "Unable to automatically determine -ProjectTab from directory name for $($item_SourceFile)."
                    }
                }
                #check and remove FULL path
                $projectRoot = (Get-ChildItem -Path $ProjectFile).Directory.FullName
                if ( $item_SourceFile.StartsWith($projectRoot) )
                {
                    $item_SourceFile = $item_SourceFile.SubString($projectRoot.Length+1)
                }
                #check and remove .\ notation.
                if ( $item_SourceFile.StartsWith(".\") )
                {
                    $item_SourceFile = $item_SourceFile.SubString(2)
                }        
                if ( -Not ($projectData.ContainsKey($item_Sourcefile) ) )
                {
                    if ( $okToAdd -eq $true )
                    {
                        $item = "" | Select-Object FileName,ProjectTab,IncludeInBuild
                        $item.FileName = $item_SourceFile
                        $item.ProjectTab = $ProjectTab
                        $item.IncludeInBuild = $IncludeInBuild

                        $projectData.Add($item_SourceFile, $item)
                        $addCount++
                    } else {
                        $skippedCount++
                    }
                } else {
                    if ( ($projectData.Get_Item($item_Sourcefile)).ProjectTab -eq $ProjectTab )
                    {
                        $duplicateCount++
                    } else {
                        $item = $projectData.Get_Item($item_Sourcefile)
                        $item.ProjectTab = $ProjectTab
                        $projectData.Set_Item($item_Sourcefile, $item)
                        $updatedCount++
                    }
                }
            }

            Save-PowershellProject -ProjectFile $ProjectFile -ProjectData $projectData

            Write-Output "$($addCount) file(s) have been added to the project"
            Write-Output "$($duplicateCount) duplicate file(s) have been skipped"
            Write-Output "$($updatedCount) source file(s) have had their TAB locations updated"
            Write-Output "$($skippedCount) source file(s) have been skipped"        
        } #continue processing
    }
}